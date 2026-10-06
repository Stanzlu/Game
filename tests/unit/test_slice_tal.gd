extends GutTest
## Phase 4, the valley: Mira's first no starts the shelter quest, the way across the stream
## (round stones tip, the player climbs out on the bank they came from), crossing advances
## the quest, the house looks empty until the fire burns, the goat trade.

const TAL := preload("res://world/levels/slice/tal.tscn")
const DIALOGUE := preload("res://content/dialogue/slice/tal.dialogue")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _cell(scene: GameScene, marker: String) -> Vector2:
	return scene.map.cell_to_world(scene.map.data.find_marker(marker)[0]["cell"])


func test_arrival_marks_the_beat() -> void:
	await _scene()
	assert_true(Beat.reached("valley_arrival"))


func _walk_west_from(scene: GameScene, cell: Vector2i) -> float:
	scene.player.teleport(scene.map.cell_to_world(cell))
	Input.action_press(&"move_left")
	await wait_seconds(0.5)
	Input.action_release(&"move_left")
	return scene.player.global_position.x


func test_the_stream_waits_until_mira_was_asked() -> void:
	var scene := await _scene()
	# the first stone of the field and the trunk, walking west from the east bank
	for cell: Vector2i in [Vector2i(44, 18), Vector2i(44, 7)]:
		var x: float = await _walk_west_from(scene, cell)
		assert_gt(x, scene.map.cell_to_world(cell).x - 12.0, "held back at %s" % cell)
	WorldState.set_flag("valley.mira_met")
	await wait_physics_frames(2)
	var x: float = await _walk_west_from(scene, Vector2i(44, 7))
	assert_lt(x, scene.map.cell_to_world(Vector2i(43, 7)).x, "on the trunk once she was asked")


func test_round_stone_tips_and_the_player_climbs_out_where_he_came_from() -> void:
	WorldState.set_flag("valley.mira_met")
	var scene := await _scene()
	var east := _cell(scene, "spawn_stones_e")
	# walking west from the east bank onto the round stone at (40, 19)
	scene.player.teleport(scene.map.cell_to_world(Vector2i(41, 19)))
	scene.player.velocity = Vector2(-80, 0)
	await wait_physics_frames(2)
	scene.player.teleport(scene.map.cell_to_world(Vector2i(40, 19)))
	scene.player.velocity = Vector2(-80, 0)
	await wait_seconds(1.6)
	assert_true(WorldState.has_flag("valley.fell_in"))
	assert_almost_eq(scene.player.global_position.x, east.x, 1.0, "back on the east bank")
	assert_almost_eq(scene.player.global_position.y, east.y, 1.0)


func test_flat_stones_hold() -> void:
	WorldState.set_flag("valley.mira_met")
	var scene := await _scene()
	for cell: Vector2i in [Vector2i(43, 19), Vector2i(42, 18), Vector2i(41, 17), Vector2i(39, 18)]:
		scene.player.teleport(scene.map.cell_to_world(cell))
		await wait_physics_frames(4)
	assert_false(WorldState.has_flag("valley.fell_in"), "flat stones never tip")


func test_crossing_the_stream_moves_the_quest_on() -> void:
	WorldState.set_flag("valley.mira_met")
	var scene := await _scene()
	WorldState.start_quest("main_valley_shelter")
	scene.player.teleport(_cell(scene, "spawn_stones_w") + Vector2(-24, 0))
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_valley_shelter"), "house")
	assert_true(Beat.reached("crossed"))


func test_the_house_is_dark_until_the_fire_burns() -> void:
	var scene := await _scene()
	var house := _house(scene)
	assert_eq(house.sprite_id, "tal/house_dark")
	WorldState.set_flag("house.fire_lit")
	var lit := await _scene()
	assert_eq(_house(lit).sprite_id, "tal/house")


func test_after_miras_visit_it_is_evening() -> void:
	WorldState.set_day_preset("regentag")  # stored on the first visit
	WorldState.set_flag("house.mira_visited")
	var scene := await _scene()
	assert_eq(WorldState.day_preset(), "abend")
	assert_eq(scene.day_light.preset, "abend")


func _house(scene: GameScene) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and (node as Decor).sprite_id.begins_with("tal/house"):
			return node
	return null


func test_west_path_waits_until_wood_is_needed() -> void:
	var scene := await _scene()
	var names := scene.map.entities.get_children().map(func(n: Node) -> String: return str(n.name))
	assert_true(names.any(func(n: String) -> bool: return n.begins_with("Blocker")))
	assert_false(names.any(func(n: String) -> bool: return n.begins_with("Door_0_")))
	WorldState.set_flag("valley.wood_needed")
	await wait_physics_frames(2)
	names = scene.map.entities.get_children().map(func(n: Node) -> String: return str(n.name))
	assert_true(names.any(func(n: String) -> bool: return n.begins_with("Door_0_")))


func test_west_path_closes_again_once_the_wood_is_taken() -> void:
	WorldState.set_flag("valley.wood_needed")
	WorldState.set_flag("valley.wood_taken")
	var scene := await _scene()
	var names := scene.map.entities.get_children().map(func(n: Node) -> String: return str(n.name))
	assert_false(names.any(func(n: String) -> bool: return n.begins_with("Door_0_")), "no exit")
	assert_true(names.any(func(n: String) -> bool: return n.begins_with("Blocker_2_")), "explained")


func test_goat_wants_the_potato() -> void:
	await _scene()
	WorldState.start_quest("side_valley_goat")
	WorldState.set_flag("valley.goat_met")
	assert_true(WorldState.is_objective_done("side_valley_goat", "goat"))
	WorldState.set_flag("valley.potato_taken")
	assert_eq(WorldState.quest_stage("side_valley_goat"), "trade")
	assert_true(DIALOGUE.cues.has("goat"))
	assert_true(DIALOGUE.cues.has("ending"))
