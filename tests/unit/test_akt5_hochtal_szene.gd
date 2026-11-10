extends GutTest
## Act V, segment G2: the high valley (docs/akt5/REGIONSBRIEFE.md). The second map of class M
## (96 x 56 cells): a valley between walls with a tarn, meadows, scree, a marmot's slope, three
## cairns and, in the east, the Anlage behind a fence. The scene starts nothing but the next step of
## the hero's walk and the stone's quest and marks two beats. What the cues say is tested in
## test_akt5_hochtal; the ground and the reach of every thing in test_layout_akt5.py.

const GRAT := preload("res://world/levels/akt5/grat.tscn")
const PASS := preload("res://world/levels/akt5/pass.tscn")
const QUEST := "main_mountain_way"
const STONE_QUEST := "side_grat_stone"
const DIALOGUE := "res://content/dialogue/akt5/hochtal.dialogue"
const SIZE := Vector2i(96, 56)
const START := Vector2i(50, 46)
const FROM_PASS := Vector2i(22, 48)
const DOOR_CELL := Vector2i(22, 54)
const PASS_DOOR_CELL := Vector2i(66, 3)
const FROM_VALLEY := Vector2i(66, 4)
const GATE_FRONT := Vector2i(76, 41)
const RAMP_FOOT := Vector2i(16, 21)
const CUES: PackedStringArray = [
	"valley_sign",
	"hand_stone",
	"stone_pick",
	"cairn_1",
	"cairn_2",
	"cairn_3",
	"quartz",
	"marmot_den",
	"plant_gate",
	"ramp_wait",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _valley() -> GratScene:
	var scene: GratScene = GRAT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _up() -> PassScene:
	var scene: PassScene = PASS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


func _doors_to(scene: GameScene, target: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == target and not node.is_queued_for_deletion()
	)


func _blockers(scene: GameScene) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			var script: Script = node.get_script()
			return (
				script != null
				and script.resource_path.ends_with("blocker.gd")
				and not node.is_queued_for_deletion()
			)
	)


# --- The map ------------------------------------------------------------------------------------


func test_the_valley_is_a_map_of_class_m_with_its_markers() -> void:
	var scene := await _valley()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_lte(data.width * data.height, 120 * 70, "class M (ADR-068)")
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_pass")[0]["cell"], FROM_PASS)
	assert_eq(_cell(scene), START, "a game begun here stands on the meadow south of the tarn")
	assert_gt(DOOR_CELL.y - START.y, 5, "the benchmark's second leg does not reach the door")
	assert_gt(DOOR_CELL.distance_to(Vector2(START)), 20.0, "far from the door")


func test_every_thing_of_the_valley_is_there_with_its_cue_and_the_cue_is_in_the_text() -> void:
	var scene := await _valley()
	var text := FileAccess.get_file_as_string(DIALOGUE)
	for cue: String in CUES:
		# the two blockers keep no meta for their cue: they are counted with the doors
		if cue not in ["plant_gate", "ramp_wait"]:
			assert_not_null(_first(scene, cue), cue)
		assert_true(text.contains("~ " + cue + "\n"), "%s is told in the file" % cue)
	assert_eq(_decor_with(scene, "tal/gb_hand_stone").size(), 1, "one stone with a print")
	assert_eq(_decor_with(scene, "tal/gb_plant_hall").size(), 1, "one Anlage")
	assert_eq(_decor_with(scene, "tal/gb_smoke_plant").size(), 1, "and its smoke")
	# nobody walks here: the one who sits at the edge of the plateau (G7) is a child
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 1, "one child, sitting")


func test_it_is_a_morning_without_lights_and_without_a_cutscene() -> void:
	var scene := await _valley()
	assert_eq(scene.day_light.preset, "morgen")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-073 O3")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked(), "nothing holds her in the valley")


func test_the_three_cairns_stand_each_in_sight_of_the_one_before() -> void:
	var scene := await _valley()
	var cells: Array[Vector2i] = [FROM_PASS]
	for cue: String in ["cairn_1", "cairn_2", "cairn_3"]:
		cells.append(scene.map.world_to_cell((_first(scene, cue) as Node2D).global_position))
	for i in range(1, cells.size()):
		var gap := Vector2(cells[i]).distance_to(Vector2(cells[i - 1]))
		assert_gte(gap, 6.0, "cairn %d is not on top of the one before" % i)
		assert_lte(gap, 18.0, "cairn %d is in sight of the one before" % i)


# --- The walk and the beats ----------------------------------------------------------------------


func test_entering_the_valley_takes_the_walk_one_step_on_and_marks_the_beat() -> void:
	WorldState.start_quest(QUEST)
	assert_eq(WorldState.quest_stage(QUEST), "climb")
	var scene := await _valley()
	assert_eq(WorldState.quest_stage(QUEST), "valley")
	assert_true(Beat.reached("grat_enter"))
	assert_false(Beat.reached("grat_hand"), "the print is not seen yet")
	assert_not_null(scene)
	var again := await _valley()
	assert_eq(WorldState.quest_stage(QUEST), "valley", "a second time changes nothing")
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(["climb", "valley"]), "once")
	assert_not_null(again)


func test_a_game_begun_in_the_valley_has_the_walk_too() -> void:
	assert_eq(WorldState.quest_stage(QUEST), "", "not before")
	var scene := await _valley()
	assert_eq(WorldState.quest_stage(QUEST), "valley")
	assert_not_null(scene)


func test_the_print_of_the_hand_marks_its_beat_when_it_is_seen() -> void:
	var scene := await _valley()
	WorldState.set_flag("fragment.hand")
	await wait_physics_frames(2)
	assert_true(Beat.reached("grat_hand"))
	assert_not_null(scene)


# --- The stone ---------------------------------------------------------------------------------


func test_the_stones_quest_begins_with_the_stone_and_ends_with_the_third_try() -> void:
	var scene := await _valley()
	assert_false(WorldState.is_quest_started(STONE_QUEST), "not before")
	WorldState.set_flag("grat.stone_taken")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(STONE_QUEST), "carry")
	for flag: String in ["grat.stone_try_1", "grat.stone_try_2"]:
		WorldState.set_flag(flag)
		await wait_physics_frames(2)
		assert_eq(WorldState.quest_stage(STONE_QUEST), "carry", "not yet: " + flag)
	WorldState.set_flag("grat.stone_try_3")
	await wait_physics_frames(2)
	assert_true(WorldState.is_quest_done(STONE_QUEST), "the third cairn ends it")
	assert_not_null(scene)


func test_a_loaded_game_catches_the_stones_quest_up() -> void:
	for flag: String in [
		"grat.stone_taken", "grat.stone_try_1", "grat.stone_try_2", "grat.stone_try_3"
	]:
		WorldState.set_flag(flag)
	var scene := await _valley()
	assert_true(WorldState.is_quest_done(STONE_QUEST), "flags from before the quest was there")
	assert_not_null(scene)


func test_the_things_to_take_lie_until_they_are_taken_and_a_loaded_game_has_none() -> void:
	var scene := await _valley()
	assert_not_null(_first(scene, "stone_pick"))
	assert_not_null(_first(scene, "quartz"))
	assert_eq(_decor_with(scene, "tal/gb_thimble").size(), 1, "the thimble lies on top")
	for flag: String in ["grat.stone_taken", "grat.quartz_taken", "grat.thimble_taken"]:
		WorldState.set_flag(flag)
	await wait_physics_frames(3)
	assert_null(_first(scene, "stone_pick"), "the stone is gone from the foot of the cairn")
	assert_null(_first(scene, "quartz"), "the crystal too")
	assert_eq(_decor_with(scene, "tal/gb_thimble").size(), 0, "the hoard has no thimble on top")
	assert_not_null(_first(scene, "marmot_den"), "but the hoard stays")
	var again := await _valley()
	assert_null(_first(again, "stone_pick"))
	assert_eq(_decor_with(again, "tal/gb_thimble").size(), 0)


# --- The doors and the closed places ------------------------------------------------------------


func test_the_valley_has_one_door_back_to_the_pass_and_two_closed_places() -> void:
	var scene := await _valley()
	var back := _doors_to(scene, "pass")
	assert_eq(back.size(), 1)
	assert_eq(back[0].get(&"spawn"), "grat")
	assert_true(back[0].get(&"auto"))
	assert_eq(scene.map.world_to_cell((back[0] as Node2D).global_position), DOOR_CELL)
	assert_eq(
		_doors_to(scene, "maschine").size(),
		0,
		"the Anlage has its own scene (G3): no door here without the open gate"
	)
	assert_eq(_blockers(scene).size(), 2, "the gate of the Anlage and the foot of the way up")


func test_the_gate_of_the_anlage_holds() -> void:
	var scene := await _valley()
	await _put(scene, GATE_FRONT)
	var through := func() -> bool: return _cell(scene).y < 38
	assert_false(await _hold(&"move_up", through, 200), "the gate is shut (G3 opens it)")
	assert_gt(_cell(scene).y, 37)
	assert_eq(SceneTravel.last_target, "", "and nothing travels")


func test_the_way_up_to_the_ridge_holds() -> void:
	var scene := await _valley()
	await _put(scene, RAMP_FOOT)
	var through := func() -> bool: return _cell(scene).y < 19
	assert_false(await _hold(&"move_up", through, 200), "the scree gives way under her (G6)")
	assert_gt(_cell(scene).y, 18)


func test_from_the_pass_she_arrives_before_the_door_and_south_returns_to_it() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "pass"
	var scene := await _valley()
	assert_eq(_cell(scene), FROM_PASS)
	assert_gte(DOOR_CELL.y - FROM_PASS.y, 5, "an arrival outside the door's zone")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	# the cliff reaches one cell into the row below the arrival: the way south bends one cell east
	await _put(scene, FROM_PASS + Vector2i(1, 0))
	var gone := func() -> bool: return SceneTravel.last_target == "pass"
	assert_true(await _hold(&"move_down", gone, 400), "south of the arrival reaches the door")


func test_the_pass_ends_in_a_door_to_the_valley_and_she_arrives_south_of_it() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "grat"
	var scene := await _up()
	assert_eq(_cell(scene), FROM_VALLEY)
	assert_eq(SceneTravel.last_target, "")
	var gone := func() -> bool: return SceneTravel.last_target == "grat"
	assert_true(await _hold(&"move_up", gone, 300), "north reaches the door at the end")
	assert_eq(PASS_DOOR_CELL.x, FROM_VALLEY.x, "the door lies right above the arrival")


func test_the_benchmark_walk_from_the_start_does_not_reach_the_door() -> void:
	SceneTravel.stay = true
	var scene := await _valley()
	for leg: Array in [[&"move_right", 96], [&"move_down", 60]]:
		Input.action_press(leg[0])
		await wait_physics_frames(leg[1])
		Input.action_release(leg[0])
	assert_eq(SceneTravel.last_target, "", "no door within reach of the first run")
	assert_not_null(scene)
