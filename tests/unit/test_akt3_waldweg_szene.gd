# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W2, the scene of the forest path: a big map (class M) with a fog, a track along
## the west bank of a brook, the six boards, two rings that are cold until someone rests at them,
## the Hang that is slow until she has rested once, the Antreiber at the empty board (not there
## for whoever left him at the fire in the house, sitting once he has had tea), the cone that leaves
## the map when taken, the hut whose door W3 wires, a way on to the south that stays shut until W4,
## the door back to the Bachlauf and the beats of the walk. What is said is tested in
## test_akt3_waldweg.

const WALDWEG := preload("res://world/levels/akt3/waldweg.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const BLOCKER_CELL := Vector2i(50, 57)
const DOOR_CELL := Vector2i(45, 1)
const ARRIVAL_CELL := Vector2i(45, 6)
const SPOTS: Array[String] = [
	"mark_1",
	"mark_2",
	"mark_3",
	"mark_4",
	"mark_5",
	"mark_6",
	"rest_1",
	"rest_2",
	"hang_steps",
	"door_tea",
	"cone",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")


func after_each() -> void:
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> WaldwegScene:
	var scene: WaldwegScene = WALDWEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


## A prop with this cue (a Decor or a walker keeps it as meta or property), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if node is NpcWalker and (node as NpcWalker).cue == cue:
			return node
	return null


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


func _walkers(scene: GameScene, cue: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is NpcWalker
				and not node.is_queued_for_deletion()
				and (node as NpcWalker).cue == cue
			)
	)


func _antreiber(scene: GameScene) -> Array[Node]:
	return _walkers(scene, "antreiber_end")


func _at(scene: GameScene, cell: Vector2i, script: Script) -> Node:
	var spot := scene.map.cell_to_world(cell)
	for node in scene.map.entities.get_children():
		if (
			not node.is_queued_for_deletion()
			and node.get_script() == script
			and node.global_position.distance_to(spot) < 2.0
		):
			return node
	return null


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _go_to(scene: WaldwegScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	scene.player.velocity = Vector2.ZERO
	await wait_physics_frames(2)


func test_it_is_a_big_map_with_a_fog_a_brook_to_hear_and_the_morning_light() -> void:
	var scene := await _scene()
	assert_true(SceneRegistry.has("waldweg"))
	assert_lte(scene.map.data.width, 120, "class M, ADR-068")
	assert_lte(scene.map.data.height, 70)
	assert_gt(scene.map.data.width * scene.map.data.height, 4000, "bigger than the valley")
	assert_true(Beat.reached("waldweg_enter"))
	assert_eq(scene.day_preset, "morgen", "the morning goes on in the forest")
	assert_gte(scene.fog_banks, 20)
	assert_gte(scene.fog_color.a, 0.15, "dense enough to be seen")
	assert_lte(scene.fog_color.a, 0.25, "thin enough to read the track and the boards")
	assert_not_null(scene.view.world_root.get_node_or_null("Fog"))
	assert_gte(
		scene.find_children("Stream*", "AudioStreamPlayer2D", true, false).size(),
		8,
		"the brook is heard"
	)


func test_the_brook_of_the_bachlauf_leads_into_the_wood_and_the_quest_follows() -> void:
	WorldState.start_quest("main_forest_way")
	WorldState.advance_quest("main_forest_way", "brook")
	await _scene()
	assert_eq(WorldState.quest_stage("main_forest_way"), "wood")
	assert_true(WorldState.is_quest_active("main_forest_way"), "the wood is not the end of the way")


func test_a_game_without_the_heros_walk_gets_no_quest_from_the_wood() -> void:
	await _scene()
	assert_eq(
		WorldState.quest_stage("main_forest_way"), "", "the quest only moves, never starts here"
	)


func test_every_spot_of_the_walk_is_there_and_the_wood_has_no_numbers() -> void:
	var scene := await _scene()
	for cue: String in SPOTS:
		assert_not_null(_first(scene, cue), "spot '%s'" % cue)
	assert_gte(_decor_with(scene, "tal/wd_marker_arrow").size(), 2, "boards one and two")
	assert_gte(_decor_with(scene, "tal/wd_marker_tally").size(), 2, "boards three and four")
	assert_eq(_decor_with(scene, "tal/wd_marker_plain").size(), 1)
	assert_eq(_decor_with(scene, "tal/wd_marker_blank").size(), 1, "the sixth stays empty")
	var trees := _alive(scene, "Decor").filter(
		func(node: Node) -> bool:
			var id := (node as Decor).sprite_id
			return id.begins_with("tal/wd_spruce") or id.begins_with("tal/wd_beech")
	)
	assert_gt(trees.size(), 60, "a tall forest around the path")


func test_a_ring_is_cold_until_someone_has_rested_there_and_each_has_its_own_fire() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "tal/wd_rest_cold").size(), 2)
	assert_eq(_decor_with(scene, "tal/wd_rest_lit").size(), 0)
	WorldState.set_flag("forest.fire_1")
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/wd_rest_lit").size(), 1, "one ring burns")
	assert_eq(_decor_with(scene, "tal/wd_rest_cold").size(), 1, "the other is cold")
	assert_eq((_first(scene, "rest_2") as Decor).sprite_id, "tal/wd_rest_cold")
	WorldState.set_flag("forest.fire_2")
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/wd_rest_lit").size(), 2)


func test_a_lit_ring_has_a_glow_and_no_light_node() -> void:
	WorldState.set_flag("forest.fire_1")
	var scene := await _scene()
	var lit := _decor_with(scene, "tal/wd_rest_lit")
	assert_eq(lit.size(), 1)
	assert_not_null(lit[0].get_node_or_null("Emissive"), "baked glow, as the mushrooms")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-070 O3")


func test_the_log_beside_a_ring_can_be_sat_on() -> void:
	var scene := await _scene()
	var logs := _decor_with(scene, "tal/wd_rest_log")
	assert_eq(logs.size(), 2, "one log at each ring")
	for node: Node in logs:
		var seat: Interactable = null
		for child in node.get_children():
			if child is Interactable:
				seat = child
		assert_not_null(seat, "a seat on the log")
		assert_eq(seat.prompt_key, "INTERACT_SIT")


# --- The Hang ------------------------------------------------------------------------------


func _hang_cells(scene: WaldwegScene) -> Array[Vector2i]:
	var top: Vector2i = scene.map.data.find_marker("hang_top")[0]["cell"]
	var foot: Vector2i = scene.map.data.find_marker("hang_foot")[0]["cell"]
	return [top, foot]


func test_the_hang_is_slow_until_she_has_rested_and_is_nothing_outside() -> void:
	var scene := await _scene()
	assert_eq(scene.player.speed_scale, 1.0, "the arrival is outside")
	var cells := _hang_cells(scene)
	var inside := Vector2i(cells[0].x, (cells[0].y + cells[1].y) / 2)
	await _go_to(scene, inside)
	assert_eq(scene.player.speed_scale, WaldwegScene.HANG_PACE, "slow in the sunken lane")
	assert_lt(WaldwegScene.HANG_PACE, 1.0)
	assert_gt(WaldwegScene.HANG_PACE, 0.5, "slow, never stopped")
	await _go_to(scene, Vector2i(cells[0].x, cells[0].y - 6))
	assert_eq(scene.player.speed_scale, 1.0, "above it")
	await _go_to(scene, Vector2i(cells[1].x, cells[1].y + 6))
	assert_eq(scene.player.speed_scale, 1.0, "below it")


func test_rest_makes_the_hang_easy_and_marks_the_beat_once() -> void:
	var scene := await _scene()
	var cells := _hang_cells(scene)
	await _go_to(scene, Vector2i(cells[0].x, (cells[0].y + cells[1].y) / 2))
	assert_eq(scene.player.speed_scale, WaldwegScene.HANG_PACE)
	assert_false(Beat.reached("forest_rest"))
	WorldState.set_facet("care")
	WorldState.set_flag("forest.rested")
	await wait_physics_frames(2)
	assert_eq(scene.player.speed_scale, 1.0, "after a rest the lane is walked at full pace")
	assert_true(Beat.reached("forest_rest"))


func test_leaving_the_scene_gives_the_pace_back() -> void:
	var scene := await _scene()
	var cells := _hang_cells(scene)
	await _go_to(scene, Vector2i(cells[0].x, (cells[0].y + cells[1].y) / 2))
	var player := scene.player
	assert_eq(player.speed_scale, WaldwegScene.HANG_PACE)
	remove_child(scene)
	assert_eq(player.speed_scale, 1.0, "a pace never outlives the lane")


func test_the_pace_in_the_hang_is_what_the_player_covers() -> void:
	var scene := await _scene()
	var cells := _hang_cells(scene)
	var top := Vector2i(cells[0].x, cells[0].y)
	await _go_to(scene, top)
	var slow_from := scene.player.global_position
	Input.action_press(&"move_down")
	await wait_physics_frames(20)
	Input.action_release(&"move_down")
	var slow := scene.player.global_position.distance_to(slow_from)
	WorldState.set_flag("forest.rested")
	await _go_to(scene, top)
	var fast_from := scene.player.global_position
	Input.action_press(&"move_down")
	await wait_physics_frames(20)
	Input.action_release(&"move_down")
	var fast := scene.player.global_position.distance_to(fast_from)
	assert_gt(slow, 0.0, "she moves")
	assert_lt(slow, fast, "slower before the rest")
	assert_almost_eq(slow / fast, WaldwegScene.HANG_PACE, 0.12)


# --- The Antreiber ------------------------------------------------------------------------


func test_he_stands_at_the_empty_board_for_whoever_did_not_leave_him_at_the_fire() -> void:
	var scene := await _scene()
	assert_eq(_antreiber(scene).size(), 1, "one Antreiber")
	assert_false((_antreiber(scene)[0] as NpcWalker).seated, "standing")


func test_he_is_not_here_for_whoever_left_him_by_the_fire_in_the_house() -> void:
	WorldState.set_flag("house.antreiber_by_fire")
	var scene := await _scene()
	assert_eq(_antreiber(scene).size(), 0, "the cat lies on him")
	assert_not_null(_first(scene, "mark_6"), "the board is still there, empty")


func test_after_tea_he_sits_instead_of_standing() -> void:
	var scene := await _scene()
	WorldState.set_flag("forest.antreiber_sat")
	await wait_physics_frames(3)
	var now := _antreiber(scene)
	assert_eq(now.size(), 1, "never two of him")
	assert_true((now[0] as NpcWalker).seated)
	assert_true(Beat.reached("waldweg_tea"))


func test_the_valley_does_not_keep_a_second_one_once_he_has_been_met_here() -> void:
	var tal: TalScene = load("res://world/levels/slice/tal.tscn").instantiate()
	WorldState.set_flag("house.antreiber_left")
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_eq(_walkers(tal, "antreiber_busy").size(), 1, "busy at the woodpile until he is met")
	WorldState.set_flag("forest.antreiber_met")
	await wait_physics_frames(3)
	assert_eq(_walkers(tal, "antreiber_busy").size(), 0, "he went ahead")


# --- Finds, beats, the ends of the way -----------------------------------------------------


func test_a_taken_cone_is_gone_from_the_map_and_a_left_one_stays() -> void:
	var scene := await _scene()
	assert_not_null(_first(scene, "cone"))
	WorldState.set_flag("forest.cone_taken")
	await wait_physics_frames(3)
	assert_null(_first(scene, "cone"), "taken")
	assert_not_null(_first(scene, "hang_steps"), "the steps stay")


func test_the_quest_marks_its_end_with_a_beat() -> void:
	var scene := await _scene()
	WorldState.start_quest("side_forest_marks")
	WorldState.advance_quest("side_forest_marks", "blank")
	await wait_physics_frames(2)
	assert_false(Beat.reached("waldweg_marks"))
	WorldState.advance_quest("side_forest_marks", "done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("waldweg_marks"))
	assert_not_null(scene)


func test_the_hut_has_a_door_that_is_never_in_the_way_and_the_cup_stands_beside_it() -> void:
	var scene := await _scene()
	assert_not_null(_first(scene, "door_tea"), "the cup of tea on its stone beside the door")
	assert_false(
		scene.map.data.find_marker("spawn_huette").is_empty(), "the place made for the way back"
	)
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") == "huette"
	)
	assert_eq(doors.size(), 1, "one door into the hut")
	assert_eq(doors[0].get(&"spawn"), "door", "to the place the hut made for it")
	assert_false(doors[0].get(&"auto"), "a door that is walked up to, not run into")


func test_the_way_on_to_the_south_is_shut_and_holds_you_back() -> void:
	WorldState.set_flag("house.antreiber_by_fire")  # no one stands in the path
	var scene := await _scene()
	var blocker := _at(scene, BLOCKER_CELL, BLOCKER_SCRIPT)
	assert_not_null(blocker, "a blocker across the path")
	await _go_to(scene, Vector2i(BLOCKER_CELL.x, BLOCKER_CELL.y - 4))
	var stopped := func() -> bool: return false
	await _hold(&"move_down", stopped, 240)
	assert_lt(scene.map.world_to_cell(scene.player.global_position).y, BLOCKER_CELL.y)
	assert_eq(SceneTravel.last_target, "", "no door to the south yet")


func test_the_door_leads_back_to_the_bachlauf_and_the_way_to_it_is_free() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "bachlauf"
	var scene := await _scene()
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") == "bachlauf"
	)
	assert_eq(doors.size(), 1, "one door, and it goes back to the stream")
	assert_eq(doors[0].get(&"spawn"), "waldweg", "to the place the Bachlauf made for it")
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	assert_gte(ARRIVAL_CELL.y - DOOR_CELL.y, 4, "an arrival outside the door's zone")
	var gone := func() -> bool: return SceneTravel.last_target == "bachlauf"
	assert_true(await _hold(&"move_up", gone, 240), "north from the arrival reaches the door")
