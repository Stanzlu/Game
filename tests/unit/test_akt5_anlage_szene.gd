extends GutTest
## Act V, segment G3: the keeper's hall (docs/akt5/REGIONSBRIEFE.md, O4, O5, O6, O19, O20). A room
## of class S (33 x 22 cells, zoom 1.5, by hand) full of pipes, dials and steam; in the middle the
## console with twelve levers, three in use and nine under cloths, behind it the small closed door,
## the keeper at the console. The scene plays the trial of the three levers and nothing else.
## What the cues say is tested in test_akt5_anlage, the map's ground and reach in
## tools/art/test_maschine_map.py.

const MASCHINE := preload("res://world/levels/akt5/maschine.tscn")
const GRAT := preload("res://world/levels/akt5/grat.tscn")
const QUEST := "main_mountain_way"
const DIALOGUE := "res://content/dialogue/akt5/anlage.dialogue"
const SIZE := Vector2i(33, 22)
const START := Vector2i(26, 8)
const FROM_VALLEY := Vector2i(7, 15)
const DOOR_CELL := Vector2i(7, 17)
const FRONT_OF_THREE := Vector2i(12, 9)
const LIVE: Array[int] = [1, 2, 3]
const CUES: PackedStringArray = [
	"waechter",
	"lever_idle",
	"small_door",
	"worn_dial",
	"gauges",
	"steam_pipe",
]
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	Settings.set_value("display.screen_shake", true, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	Settings.set_value("display.screen_shake", true, false)
	Input.action_release(&"move_down")
	Input.action_release(&"move_up")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _hall() -> MaschineScene:
	var scene: MaschineScene = MASCHINE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


func _levers(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(func(node: Node) -> bool: return node is ConsoleLever)


func _gauges(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(func(node: Node) -> bool: return node is Gauge)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and (node as Decor).sprite_id == sprite
	)


func _first(scene: GameScene, cue: String) -> Node:
	for node in _alive(scene):
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Moves the text on as a player does, every few ticks. True once nothing is open and nothing is
## running any more.
func _told(scene: GameScene, until: Callable, seconds := 40.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				_confirm()
			return until.call(),
		seconds
	)


func _pull(scene: MaschineScene, numbers: Array) -> void:
	for number: int in numbers:
		scene.lever(number).pulled.emit(number)
		await wait_physics_frames(2)


func _downs(scene: MaschineScene) -> Array:
	var down := []
	for number: int in [1, 2, 3]:
		if scene.lever(number).down:
			down.append(number)
	return down


# --- The map ------------------------------------------------------------------------------------


func test_the_hall_is_a_room_of_class_s_at_the_zoom_of_an_interior() -> void:
	var scene := await _hall()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_eq(scene.view_zoom, 1.5)
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_grat")[0]["cell"], FROM_VALLEY)
	assert_eq(_cell(scene), START, "a game begun here stands at the east end of the console")
	assert_gt(Vector2(DOOR_CELL).distance_to(Vector2(START)), 20.0, "far from the door")
	assert_eq(
		scene.view.bounds.size,
		Vector2(MaschineScene.ROOM.size * data.tile_size),
		"the camera keeps the room whole"
	)


func test_the_hall_has_one_door_back_to_the_valley() -> void:
	var scene := await _hall()
	var doors := _alive(scene).filter(
		func(node: Node) -> bool: return node.get(&"target") == "grat"
	)
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "maschine")
	assert_true(doors[0].get(&"auto"))
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)


func test_from_the_valley_she_arrives_before_the_door_and_south_returns_to_it() -> void:
	SceneTravel.pending_spawn = "grat"
	var scene := await _hall()
	assert_eq(_cell(scene), FROM_VALLEY)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	Input.action_press(&"move_down")
	var gone := func() -> bool: return SceneTravel.last_target == "grat"
	await wait_until(gone, 6.0)
	Input.action_release(&"move_down")
	assert_eq(SceneTravel.last_target, "grat", "south from the arrival reaches the door")


func test_the_valleys_gate_leads_into_the_hall_once_it_is_open() -> void:
	var scene: GratScene = GRAT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var doors := _alive(scene).filter(
		func(node: Node) -> bool: return node.get(&"target") == "maschine"
	)
	assert_eq(doors.size(), 0, "the gate is shut: no door")
	WorldState.set_flag("grat.gate_open")
	await wait_physics_frames(3)
	doors = _alive(scene).filter(func(node: Node) -> bool: return node.get(&"target") == "maschine")
	assert_eq(doors.size(), 1, "the gate opened: a door in the yard")
	assert_eq(doors[0].get(&"spawn"), "grat")
	var blockers := _alive(scene).filter(
		func(node: Node) -> bool:
			var script: Script = node.get_script()
			return script != null and script.resource_path.ends_with("blocker.gd")
	)
	assert_eq(blockers.size(), 1, "and the blocker at the gate is gone, the way up stays shut")
	assert_eq(_decor_with(scene, "tal/gb_plant_gate_open").size(), 1, "the gate stands open")
	assert_eq(_decor_with(scene, "tal/gb_plant_gate").size(), 0, "the sprite swaps, no twin")


# --- The things -----------------------------------------------------------------------------------


func test_twelve_levers_with_their_numbers_three_in_use_and_nine_under_a_cloth() -> void:
	var scene := await _hall()
	var levers := _levers(scene)
	assert_eq(levers.size(), 12)
	var live := []
	var numbers := {}
	for node in levers:
		var lever := node as ConsoleLever
		numbers[lever.number] = true
		if lever.live:
			live.append(lever.number)
		else:
			assert_true(lever.has_meta(&"cue") and lever.get_meta(&"cue") == "lever_idle")
	assert_eq(numbers.size(), 12, "each number once")
	live.sort()
	assert_eq(live, [1, 2, 3], "the three in use")
	assert_eq(_decor_with(scene, "tal/ma_lever_cover").size(), 9, "a cloth on each of the others")
	for number: int in LIVE:
		assert_false(scene.lever(number).down, "all stand up at first")


func test_the_keeper_stands_at_the_console_and_does_not_walk() -> void:
	var scene := await _hall()
	var keeper: Node = null
	for node in _alive(scene):
		if node is NpcWalker and (node as NpcWalker).cue == "waechter":
			keeper = node
	assert_not_null(keeper, "the keeper")
	var at := (keeper as Node2D).global_position
	await wait_physics_frames(90)
	assert_eq((keeper as Node2D).global_position, at, "he stays where he is")
	for cue: String in CUES:
		if cue != "waechter":
			assert_not_null(_first(scene, cue), cue)
	var text := FileAccess.get_file_as_string(DIALOGUE)
	for cue: String in CUES:
		assert_true(text.contains("~ " + cue + "\n"), "%s is told in the file" % cue)


func test_the_hall_has_at_most_six_lamps_and_four_dials_of_which_one_trembles() -> void:
	var scene := await _hall()
	var lights := scene.find_children("*", "PointLight2D", true, false)
	assert_lte(lights.size(), 6, "ADR-073 O3: the steam lamps")
	assert_gte(lights.size(), 4, "the hall is lit by them")
	var gauges := _gauges(scene)
	assert_eq(gauges.size(), 4)
	var trembling := gauges.filter(func(node: Node) -> bool: return node._amplitude > 0.0)
	assert_eq(trembling.size(), 1, "one dial trembles a little")
	assert_not_null(_first(scene, "gauges"))


func test_the_trembling_needle_moves_only_while_picture_shaking_is_allowed() -> void:
	var scene := await _hall()
	var dial: Gauge = _gauges(scene).filter(func(n: Node) -> bool: return n._amplitude > 0.0)[0]
	var seen := {}
	for i in 30:
		await wait_process_frames(2)
		seen[snappedf(dial.needle.rotation_degrees, 0.01)] = true
	assert_gt(seen.size(), 3, "it trembles")
	Settings.set_value("display.screen_shake", false, false)
	await wait_process_frames(3)
	var still := dial.needle.rotation_degrees
	await wait_process_frames(10)
	assert_eq(dial.needle.rotation_degrees, still, "with the setting off it rests")
	assert_almost_eq(still, dial._rest, 0.001, "at its resting angle")


func test_steam_and_lamps_are_pictures_of_their_own_that_the_scene_could_drop() -> void:
	var scene := await _hall()
	assert_gte(_decor_with(scene, "tal/ma_steam").size(), 2, "steam stands in the room")


# --- The walk and the trial ---------------------------------------------------------------------


func test_entering_the_hall_takes_the_walk_one_step_on_and_marks_the_beat() -> void:
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "valley")
	var scene := await _hall()
	assert_eq(WorldState.quest_stage(QUEST), "plant")
	assert_true(Beat.reached("maschine_enter"))
	assert_false(Beat.reached("maschine_probe"), "the trial is not done yet")
	assert_not_null(scene)


func test_before_the_trial_is_called_a_lever_is_only_a_lever() -> void:
	var scene := await _hall()
	await _pull(scene, [2])
	assert_eq(_downs(scene), [2], "it goes down")
	await _pull(scene, [2])
	assert_eq(_downs(scene), [], "and up again")
	await _pull(scene, [3, 1, 2])
	assert_false(WorldState.has_flag("plant.probe_done"), "nothing is entered")
	assert_false(Beat.reached("maschine_probe"))


func test_the_right_order_is_entered_and_the_three_stay_down() -> void:
	WorldState.set_flag("plant.probe")
	var scene := await _hall()
	await _pull(scene, [3, 1])
	assert_eq(_downs(scene), [1, 3], "so far so right")
	assert_false(WorldState.has_flag("plant.probe_done"))
	await _pull(scene, [2])
	var done := func() -> bool: return WorldState.has_flag("plant.probe_done")
	assert_true(await _told(scene, done), "he enters it")
	assert_true(await _told(scene, func() -> bool: return not scene.player.is_locked()))
	assert_true(Beat.reached("maschine_probe"))
	assert_eq(_downs(scene), [1, 2, 3], "the three stay down")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)


func test_a_wrong_order_costs_one_line_and_the_three_go_back_and_she_can_try_again() -> void:
	WorldState.set_flag("plant.probe")
	var scene := await _hall()
	await _pull(scene, [1])
	var back := func() -> bool: return _downs(scene).is_empty() and not scene.player.is_locked()
	assert_true(await _told(scene, back), "one line, and all three go back")
	assert_false(WorldState.has_flag("plant.probe_done"), "nothing was lost, nothing is locked")
	assert_false(Beat.reached("maschine_probe"))
	await _pull(scene, [3, 1, 2])
	var done := func() -> bool: return WorldState.has_flag("plant.probe_done")
	assert_true(await _told(scene, done), "the second try is as good as the first")


func test_a_lever_that_is_down_is_not_pulled_again_during_the_trial() -> void:
	WorldState.set_flag("plant.probe")
	var scene := await _hall()
	await _pull(scene, [3])
	await _pull(scene, [3])
	assert_eq(_downs(scene), [3], "still the first lever of the order, not a wrong one")
	await _pull(scene, [1, 2])
	assert_true(await _told(scene, func() -> bool: return WorldState.has_flag("plant.probe_done")))


func test_a_loaded_game_after_the_trial_finds_the_three_down() -> void:
	WorldState.set_flag("plant.probe")
	WorldState.set_flag("plant.probe_done")
	var scene := await _hall()
	assert_eq(_downs(scene), [1, 2, 3])
	await _pull(scene, [1])
	assert_eq(_downs(scene), [2, 3], "after the trial a lever is a lever again")


func test_a_live_lever_answers_her_use_at_the_console() -> void:
	var scene := await _hall()
	var pulled := []
	scene.lever(3).pulled.connect(func(number: int) -> void: pulled.append(number))
	# she walks up to the console and stops at its edge: the lever's zone and her sensor meet there
	await _put(scene, FRONT_OF_THREE + Vector2i(0, 2))
	Input.action_press(&"move_up")
	await wait_physics_frames(40)
	Input.action_release(&"move_up")
	await wait_physics_frames(6)
	_confirm()
	await wait_physics_frames(4)
	assert_eq(pulled, [3], "the lever in front of her")
	assert_not_null(scene.lever(3).get_node_or_null("Interactable"))
