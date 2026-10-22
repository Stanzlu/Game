extends GutTest
## Things the player feels in the world: stepping stones tip the same from every side,
## barriers show their prompt at the way, the prompt sits in the UI layer on the pixel
## grid, wet prints on mud in the rain.

const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const STONE_SCENE := preload("res://world/props/stepping_stone.tscn")
const BLOCKER_SCENE := preload("res://world/props/blocker.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const TAL := preload("res://world/levels/slice/tal.tscn")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## Walks the player at a round stone from `from` (offset to the stone) along `action` and
## returns the feet offset to the stone's origin at the moment its zone is entered.
func _entry_offset(from: Vector2, action: StringName) -> Vector2:
	var world := Node2D.new()
	add_child_autofree(world)
	var stone: Node2D = STONE_SCENE.instantiate()
	world.add_child(stone)
	stone.call(&"apply_params", {"wobbly": true})
	var zone: Area2D = stone.get("_zone")
	# only measure: the stone's own handler would start the fall
	zone.body_entered.disconnect(Callable(stone, &"_on_body_entered"))
	var player: Player = PLAYER_SCENE.instantiate()
	player.position = from  # before it enters the tree: it must not start inside the zone
	world.add_child(player)
	var entered: Array[Vector2] = []
	zone.body_entered.connect(
		func(body: Node2D) -> void:
			if body == player:
				entered.append(body.global_position)
	)
	await wait_physics_frames(3)
	Input.action_press(action)
	var ticks := 0
	while entered.is_empty() and ticks < 120:
		await wait_physics_frames(1)
		ticks += 1
	Input.action_release(action)
	# one world at a time: the next player must not meet this one
	world.queue_free()
	await wait_physics_frames(2)
	assert_false(entered.is_empty(), "the stone tipped from %s" % action)
	return entered[0] if not entered.is_empty() else Vector2(INF, INF)


func test_round_stones_tip_the_same_from_every_side() -> void:
	var from_above := await _entry_offset(Vector2(0, -40), &"move_down")
	var from_below := await _entry_offset(Vector2(0, 40), &"move_up")
	var from_west := await _entry_offset(Vector2(-40, 0), &"move_right")
	var from_east := await _entry_offset(Vector2(40, 0), &"move_left")
	# the painted stone spans -7..+6 below its origin: its middle is half a pixel above it
	# measured when the zone's signal arrives, about two ticks (3 px) after the overlap began:
	# the soles stand 2.5 px above / below the stone's middle, inside its picture (-7..+6)
	assert_almost_eq(from_above.y, -from_below.y, 1.5, "above and below are the same")
	assert_between(from_above.y, -5.0, -1.5, "from above the soles are on the stone")
	assert_between(from_below.y, 1.5, 5.0, "from below the soles are on the stone")
	assert_almost_eq(from_west.x, -from_east.x, 1.5, "left and right are the same")
	assert_between(absf(from_west.x), 7.0, 11.0, "the sides reach the zone's 6 px plus the foot")


func test_a_barrier_shows_its_prompt_at_the_way() -> void:
	var tall: StaticBody2D = BLOCKER_SCENE.instantiate()
	add_child_autofree(tall)
	tall.call(&"apply_params", {"size": [1, 5], "cue": "west_path"})
	var area: Interactable = tall.get_node("Interactable")
	var zone := area.get_child(0) as CollisionShape2D
	var rect := zone.shape as RectangleShape2D
	assert_not_null(rect, "a rectangle that follows the barrier, not a circle")
	assert_eq(rect.size, Vector2(16, 80) + BLOCKER_SCRIPT.ZONE_MARGIN)
	assert_eq(area.prompt_offset, Vector2(0, -26), "one figure height above the middle of the way")
	var stream: StaticBody2D = BLOCKER_SCENE.instantiate()
	add_child_autofree(stream)
	stream.call(&"apply_params", {"size": [5, 3], "offset": [-3, 0], "cue": "stream_wait"})
	var bank: Interactable = stream.get_node("Interactable")
	assert_eq(bank.prompt_offset, Vector2(0, -26), "at the bank, beside the figure")
	assert_eq((bank.get_child(0) as CollisionShape2D).position, Vector2(-48, 0))


func _tal() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_the_prompt_lies_in_the_ui_on_the_pixel_grid() -> void:
	var scene := await _tal()
	assert_null(scene.player.get_node_or_null("Prompt"), "no longer a child of the player")
	var layer := scene.prompt.get_parent() as CanvasLayer
	assert_not_null(layer, "in a canvas layer of the scene")
	assert_eq(layer.layer, GameScene.PROMPT_LAYER)
	assert_lt(layer.layer, scene.hud.layer, "under the HUD")
	assert_eq(scene.prompt.get_viewport(), scene.get_viewport(), "outside the world viewport")
	var target := Interactable.new()
	target.prompt_key = "INTERACT_EXAMINE"
	scene.player.add_child(target)
	target.global_position = scene.player.global_position + Vector2(13, -3)
	scene.player.sensor.target_changed.emit(target)
	await wait_seconds(0.3)
	assert_true(scene.prompt.visible)
	var want := scene.view.world_to_ui(target.global_position + target.prompt_offset)
	assert_eq(scene.prompt.position, want.round(), "world position converted and rounded")
	assert_eq(scene.prompt.position, scene.prompt.position.round())


func _mud_cell(scene: GameScene) -> Vector2i:
	for y in scene.map.data.height:
		for x in scene.map.data.width:
			if scene.map.data.tile_symbol_at(Vector2i(x, y)) == "m":
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func test_wet_prints_appear_on_mud_in_the_rain_only() -> void:
	WorldState.set_day_preset("regentag")
	var scene := await _tal()
	var mud := _mud_cell(scene)
	assert_ne(mud, Vector2i(-1, -1), "the valley has mud")
	var fx := scene.fx
	var before := fx.get_child_count()
	fx._on_footstep(&"dirt", scene.map.cell_to_world(mud), false)
	assert_eq(fx.get_child_count(), before + 1, "a print on mud")
	var path_cell := Vector2i(-1, -1)
	for y in scene.map.data.height:
		for x in scene.map.data.width:
			if scene.map.data.tile_symbol_at(Vector2i(x, y)) == ",":
				path_cell = Vector2i(x, y)
	fx._on_footstep(&"dirt", scene.map.cell_to_world(path_cell), false)
	assert_eq(fx.get_child_count(), before + 1, "none on the path")
	fx._on_footstep(&"grass", scene.map.cell_to_world(mud), false)
	assert_eq(fx.get_child_count(), before + 1, "none on grass")
	WorldState.set_day_preset("abend")
	fx._on_footstep(&"dirt", scene.map.cell_to_world(mud), false)
	assert_eq(fx.get_child_count(), before + 1, "none outside the rain")
	WorldState.set_day_preset("regentag")
	for i in 60:
		fx._on_footstep(&"dirt", scene.map.cell_to_world(mud), false)
	await wait_process_frames(2)
	assert_lte(fx.get_child_count(), before + FootstepFx.MAX_PRINTS, "at most 40 at a time")


func test_the_sound_follows_the_picture_pace_after_a_door() -> void:
	assert_almost_eq(GameScene.sound_fade_for(0.4), 0.8, 0.001, "after a door")
	assert_almost_eq(GameScene.sound_fade_for(2.0), 2.0, 0.001, "a fresh start")
	assert_almost_eq(GameScene.sound_fade_for(3.5), 3.5, 0.001, "after the rift")


func test_falling_into_the_stream_shakes_the_view() -> void:
	WorldState.set_flag("valley.mira_met")
	var scene := await _tal()
	scene.player.teleport(scene.map.cell_to_world(Vector2i(41, 19)))
	scene.player.velocity = Vector2(-80, 0)
	await wait_physics_frames(2)
	scene.player.teleport(scene.map.cell_to_world(Vector2i(40, 19)))
	scene.player.velocity = Vector2(-80, 0)
	var shook := false
	for i in 90:
		await wait_physics_frames(1)
		if scene.view._shake_time > 0.0:
			shook = true
			break
	assert_true(shook, "the plunge shook the view")
