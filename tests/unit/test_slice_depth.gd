extends GutTest
## The slice deepened along the Game Bible: real people linger and keep busy (Elysians never
## do), the child hums the later main motif, Mira sits across her fire in the evening, the
## quiet moment by the fire comes before Mira knocks, and the goat turns up somewhere absurd.

const WALKER := preload("res://entities/npc/npc_walker.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const HAUS := preload("res://world/levels/slice/haus.tscn")


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _mira(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if node is NpcWalker and (node as NpcWalker).cue == "mira":
			if not node.is_queued_for_deletion():
				return node
	return null


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func test_a_walker_with_pause_lingers_at_its_waypoints() -> void:
	var walker: NpcWalker = WALKER.instantiate()
	add_child_autofree(walker)
	walker.apply_params({"route": [[0, 0], [3, 0]], "pause": [0.6, 0.6], "speed": 80})
	await wait_physics_frames(2)
	var start := walker.position
	await wait_seconds(0.3)
	assert_eq(walker.position, start, "still lingering at the first waypoint")
	await wait_seconds(0.8)
	assert_gt(walker.position.x, start.x + 8.0, "then on its way")


func test_mira_keeps_busy_by_day() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var day: GameScene = TAL.instantiate()
	add_child_autofree(day)
	await wait_physics_frames(3)
	assert_false(_mira(day).route.is_empty(), "net, fire, the rod at the stream")


func test_mira_sits_across_her_fire_at_night() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("house.mira_visited")
	var evening: GameScene = TAL.instantiate()
	add_child_autofree(evening)
	await wait_physics_frames(3)
	var mira := _mira(evening)
	assert_true(mira.route.is_empty(), "in the evening she stays by the fire")
	assert_eq(mira.facing, Facing.Dir.W, "looking across the fire")


func test_the_child_hums() -> void:
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.loops")
	var scene: GameScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var child := get_tree().get_first_node_in_group(&"child_guide") as ChildGuide
	var hum := child.get_node_or_null("Hum") as AudioStreamPlayer2D
	assert_not_null(hum, "the child has a voice")
	assert_not_null(hum.stream, "and a tune")
	assert_lt(hum.max_distance, 1000.0, "heard only nearby, so one can follow it")


func test_sitting_by_the_fire_comes_before_miras_knock() -> void:
	Settings.set_value("text.auto_advance", true, false)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	var rug := scene.map.cell_to_world(Vector2i(17, 11))
	scene.player.sit_on(rug, Facing.Dir.N)
	await wait_seconds(HausScene.REST_BEFORE_KNOCK + 0.5)
	assert_true(scene.dialogue_box.visible, "a moment by the fire")
	assert_false(WorldState.has_flag("house.mira_knocked"), "nobody knocks yet")
	# with auto advance the two quiet lines take their time; Mira still comes long before 60 s
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_knocked"), 35.0)
	assert_true(WorldState.has_flag("house.mira_knocked"), "then Mira comes")


func test_after_the_trade_the_goat_trots_off_and_turns_up_on_the_woodpile() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.goat_loose")
	var scene: GameScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var goat: Node2D = _alive(scene, "Goat")[0]
	WorldState.set_flag("valley.goat_traded")
	await wait_physics_frames(2)
	assert_true(is_instance_valid(goat), "it trots off instead of vanishing")
	var perched: Node2D = _alive(scene, "Goat_30_14")[0]
	assert_false(perched.visible, "and shows up a little later")
	await wait_seconds(3.6)
	assert_false(is_instance_valid(goat), "gone")
	assert_true(perched.visible, "on the woodpile")
	assert_lt((perched.get_node("Sprite") as Node2D).position.y, -10.0, "standing on top")
