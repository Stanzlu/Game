extends GutTest
## Act V, segment G1 in its scenes: the pass (class M, 96 x 58 cells, a morning without lights) and
## the road that opens a door to it from the end of Act IV on. The scene only starts the hero's
## walk and marks two beats; what the cues say is tested in test_akt5_aufstieg.

const PASS := preload("res://world/levels/akt5/pass.tscn")
const STRASSE := preload("res://world/levels/akt4/strasse.tscn")
const QUEST := "main_mountain_way"
const SIZE := Vector2i(96, 58)
const START := Vector2i(47, 50)
const FROM_ROAD := Vector2i(56, 55)
const DOOR_CELL := Vector2i(56, 56)
const END_CELL := Vector2i(66, 3)
const ROAD_DOOR_CELL := Vector2i(56, 3)
const ROAD_ARRIVAL := Vector2i(56, 4)
const PARTED: PackedStringArray = [
	"city.mira_parted_boundary", "city.mira_parted_joined", "city.mira_parted_silent"
]
const CUES: PackedStringArray = [
	"cairn_first",
	"view_smoke",
	"plank_bridge",
	"trail_sign",
	"slate_chip",
	"iron_ring",
]
const TRACES: Dictionary = {
	"city.mira_parted_boundary": "mira_trace_boundary",
	"city.mira_parted_joined": "mira_trace_joined",
	"city.mira_parted_silent": "mira_trace_silent",
}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _up() -> PassScene:
	var scene: PassScene = PASS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _road() -> StrasseScene:
	var scene: StrasseScene = STRASSE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _decor_like(scene: GameScene, prefix: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id.begins_with(prefix)
	)


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


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


func _doors_to(scene: GameScene, target: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == target and not node.is_queued_for_deletion()
	)


# --- The pass --------------------------------------------------------------------------------


func test_the_pass_is_a_map_of_class_m_with_its_markers() -> void:
	var scene := await _up()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_lte(data.width * data.height, 120 * 70, "class M (ADR-068)")
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_strasse")[0]["cell"], FROM_ROAD)
	assert_eq(_cell(scene), START, "a game begun here stands on the meadow at the foot")


## The benchmark walks right for 1.6 s and then down for 1.0 s (BenchmarkRunner.PATTERN): the first
## cairn stops the first leg, so the second never carries her through the door at the foot.
func test_the_benchmark_walk_from_the_start_does_not_reach_the_door_at_the_foot() -> void:
	SceneTravel.stay = true
	var scene := await _up()
	for leg: Array in [[&"move_right", 96], [&"move_down", 60]]:
		Input.action_press(leg[0])
		await wait_physics_frames(leg[1])
		Input.action_release(leg[0])
	assert_eq(SceneTravel.last_target, "", "the door at the foot stays shut to the benchmark")
	assert_lt(_cell(scene).x, 52, "west of the first cairn, which stands in the row")
	assert_gte(DOOR_CELL.y - START.y, 5, "and the door is still some cells off")


func test_every_thing_of_the_path_is_there_with_its_cue() -> void:
	var scene := await _up()
	for cue: String in CUES:
		assert_not_null(_first(scene, cue), cue)
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 0, "nobody is here")
	assert_gte(_decor_like(scene, "tal/gb_cairn").size(), 15, "cairns lead the way, no markers")
	assert_gte(_decor_like(scene, "tal/gb_smoke").size(), 1, "and the smoke of the Anlage")


func test_it_is_a_morning_without_lights_and_without_a_cutscene() -> void:
	var scene := await _up()
	assert_eq(scene.day_light.preset, "morgen")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-073 O3")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked(), "nothing holds her on the path")


# --- The walk and the beats ------------------------------------------------------------------


func test_entering_the_pass_starts_the_walk_and_marks_the_beat() -> void:
	assert_eq(WorldState.quest_stage(QUEST), "", "not before")
	await _up()
	assert_eq(WorldState.quest_stage(QUEST), "climb")
	assert_true(Beat.reached("pass_enter"))
	var again := await _up()
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(["climb"]), "once")
	assert_not_null(again)


func test_the_view_marks_the_beat_when_it_is_seen() -> void:
	var scene := await _up()
	assert_false(Beat.reached("pass_view"))
	WorldState.set_flag("mountain.view_seen")
	await wait_physics_frames(2)
	assert_true(Beat.reached("pass_view"))
	assert_not_null(scene)


# --- Mira's trace ----------------------------------------------------------------------------


func test_there_is_one_trace_of_mira_for_the_way_the_quarrel_ended() -> void:
	for flag: String in PARTED:
		WorldState.new_game()
		WorldState.set_flag(flag)
		var scene := await _up()
		for other: String in PARTED:
			var cue: String = TRACES[other]
			if other == flag:
				assert_not_null(_first(scene, cue), "%s: its trace lies on the path" % flag)
			else:
				assert_null(_first(scene, cue), "%s: not the trace of %s" % [flag, other])
		scene.free()
	WorldState.new_game()
	var bare := await _up()
	for cue: String in TRACES.values():
		assert_null(_first(bare, cue), "no quarrel, no trace: " + cue)


# --- The slate -------------------------------------------------------------------------------


func test_the_slate_lies_until_it_is_taken_and_a_loaded_game_has_none() -> void:
	var scene := await _up()
	assert_not_null(_first(scene, "slate_chip"))
	WorldState.set_flag("mountain.slate_taken")
	await wait_physics_frames(3)
	assert_null(_first(scene, "slate_chip"), "the stone is bare")
	var again := await _up()
	assert_null(_first(again, "slate_chip"))


# --- The doors -------------------------------------------------------------------------------


func test_the_pass_has_a_door_back_to_the_road_and_its_end_is_a_door_to_the_high_valley() -> void:
	var scene := await _up()
	var doors := _doors_to(scene, "strasse")
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "pass")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)
	assert_true(doors[0].get(&"auto"))
	var valley := _doors_to(scene, "grat")
	assert_eq(valley.size(), 1, "the scree no longer lies across the end of the path (G2)")
	assert_eq(valley[0].get(&"spawn"), "pass")
	assert_true(valley[0].get(&"auto"))
	assert_eq(scene.map.world_to_cell((valley[0] as Node2D).global_position), END_CELL)
	assert_eq(_blockers(scene).size(), 0, "and nothing holds her")


func test_from_the_road_she_arrives_before_the_door_and_south_returns_to_it() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "strasse"
	var scene := await _up()
	assert_eq(_cell(scene), FROM_ROAD)
	Input.action_press(&"move_down")
	var left := 300
	while left > 0 and SceneTravel.last_target != "strasse":
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_down")
	assert_eq(SceneTravel.last_target, "strasse", "south from the arrival reaches the door")


# --- The road --------------------------------------------------------------------------------


func test_before_the_end_of_act_four_the_road_has_no_door_to_the_mountains_and_no_third_arrow(
) -> void:
	var scene := await _road()
	assert_eq(_doors_to(scene, "pass").size(), 0)
	assert_null(_first(scene, "signpost_third"))
	assert_eq(_decor_like(scene, "tal/gb_cairn_road").size(), 0, "no cairns on the bank")


func test_from_the_end_of_act_four_a_door_leads_north_into_the_mountains() -> void:
	Chapter.mark("act4")
	var scene := await _road()
	var doors := _doors_to(scene, "pass")
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "strasse")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), ROAD_DOOR_CELL)
	assert_true(doors[0].get(&"auto"))
	assert_eq(scene.map.data.find_marker("spawn_pass")[0]["cell"], ROAD_ARRIVAL)
	assert_not_null(_first(scene, "signpost_third"), "a third arrow, in chalk, pointing up")
	assert_gte(_decor_like(scene, "tal/gb_cairn_road").size(), 3, "cairns lead along the brook")
	assert_eq(_doors_to(scene, "tal").size(), 1, "the other doors stand as before")
	assert_eq(_doors_to(scene, "stadt").size(), 1)


func test_the_arrival_from_the_pass_is_a_step_outside_the_door_zone() -> void:
	Chapter.mark("act4")
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "pass"
	var scene := await _road()
	assert_eq(_cell(scene), ROAD_ARRIVAL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	Input.action_press(&"move_up")
	var left := 300
	while left > 0 and SceneTravel.last_target != "pass":
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_up")
	assert_eq(SceneTravel.last_target, "pass", "north from the arrival reaches the door")
