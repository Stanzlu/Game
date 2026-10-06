extends GutTest
## Phase 4 building blocks and Elysia's beats: story-conditional props, doors and spawn
## markers, beat timestamps, the hero's name, the butterfly miniquest and the child.

const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const AUTOPILOT := preload("res://tools/autopilot/autopilot.gd")
const MAP := """[meta]
[legend]
. = {"atlas": [0, 0], "surface": "grass"}
@ = {"ground": ".", "marker": "player_spawn"}
d = {"ground": ".", "marker": "spawn_door"}
r = {"ground": ".", "prop": "res://world/props/decor.tscn", "params": %s}
[map]
.....
.@.d.
..r..
"""
const PARAMS := (
	'{"cue": "basin", "dialogue": "res://content/dialogue/slice/elysia.dialogue",'
	+ ' "if": "test.shown", "unless": "test.hidden"}'
)


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()
	SceneTravel.pending_spawn = ""
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _map() -> MapView:
	var map := MapView.new()
	add_child_autofree(map)
	assert_true(map.build_from_text(MAP % PARAMS, "test"))
	return map


func _conditional_props(map: MapView) -> Array[Node]:
	return map.entities.get_children().filter(
		func(node: Node) -> bool: return str(node.name).begins_with("Decor")
	)


func test_conditions_combine_if_and_unless() -> void:
	assert_true(MapView.conditions_met({}))
	assert_false(MapView.conditions_met({"if": "test.a"}))
	WorldState.set_flag("test.a")
	assert_true(MapView.conditions_met({"if": "test.a"}))
	assert_true(MapView.conditions_met({"if": ["test.a"], "unless": ["test.b"]}))
	WorldState.set_flag("test.b")
	assert_false(MapView.conditions_met({"if": "test.a", "unless": "test.b"}))


func test_conditional_props_follow_flags() -> void:
	var map := _map()
	assert_eq(_conditional_props(map).size(), 0, "hidden until its flag is set")
	WorldState.set_flag("test.shown")
	await wait_physics_frames(1)
	assert_eq(_conditional_props(map).size(), 1, "appears when the flag is set")
	WorldState.set_flag("test.hidden")
	await wait_physics_frames(1)
	var alive := _conditional_props(map).filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)
	assert_eq(alive.size(), 0, "removed by unless")


func test_spawn_marker_is_taken_once() -> void:
	var map := _map()
	SceneTravel.pending_spawn = "door"
	assert_eq(SceneTravel.take_spawn(map), map.cell_to_world(Vector2i(3, 1)))
	assert_eq(SceneTravel.pending_spawn, "", "cleared after use")
	assert_null(SceneTravel.take_spawn(map), "no pending spawn: map spawn")


func test_beats_are_marked_once_with_their_minute() -> void:
	WorldState.state.playtime_seconds = 125.0
	Beat.mark("test_beat")
	assert_true(Beat.reached("test_beat"))
	WorldState.state.playtime_seconds = 300.0
	Beat.mark("test_beat")
	assert_true(WorldState.has_flag("beat.test_beat"))
	assert_false(Beat.reached("other_beat"))


func test_hero_name_is_cleaned_and_has_a_default() -> void:
	assert_eq(WorldState.player_name(), tr("PLAYER_DEFAULT_NAME"))
	assert_eq(NameEntry.clean("  Mika!  "), "Mika")
	assert_eq(NameEntry.clean("Jörg-Ünal"), "Jörg-Ünal")
	assert_eq(NameEntry.clean("<b>[x]</b>"), "bxb")
	assert_eq(NameEntry.clean("A".repeat(40)).length(), GameState.MAX_NAME_LENGTH)
	WorldState.set_player_name("Noel")
	assert_eq(WorldState.player_name(), "Noel")


func test_autopilot_unrolls_repeated_events() -> void:
	var events: Array = AUTOPILOT.expand(
		[{"t": 2.0, "tap": ["interact"], "repeat": 3, "every": 0.5, "log": "x"}, {"t": 1.0}]
	)
	assert_eq(events.size(), 4)
	assert_eq(events[0]["t"], 1.0, "sorted by time")
	assert_eq(events[3]["t"], 3.0)
	assert_true(events[1].has("log"), "first repetition keeps the note")
	assert_false(events[2].has("log"))


func test_elysia_quest_can_be_celebrated_early() -> void:
	WorldState.start_quest("main_elysia_hero")
	assert_true(WorldState.advance_quest("main_elysia_hero", "celebrated"), "chest before quest")
	assert_true(WorldState.is_quest_done("main_elysia_hero"))


func test_elysia_wakes_and_butterflies_escalate() -> void:
	var scene: GameScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_true(WorldState.has_item("item_seed"), "the seed was always there")
	assert_true(Beat.reached("elysia_start"))
	var cut := get_tree().get_first_node_in_group(&"cutscene")
	assert_not_null(cut, "waking is a cutscene")
	WorldState.start_quest("side_elysia_butterflies")
	var xp := WorldState.state.elysia.xp
	WorldState.complete_objective("side_elysia_butterflies", "first")
	assert_eq(WorldState.state.elysia.xp - xp, ElysiaScene.BUTTERFLY_XP[0])
	WorldState.complete_objective("side_elysia_butterflies", "second")
	WorldState.complete_objective("side_elysia_butterflies", "third")
	assert_eq(
		WorldState.state.elysia.xp - xp,
		ElysiaScene.BUTTERFLY_XP[0] + ElysiaScene.BUTTERFLY_XP[1] + ElysiaScene.BUTTERFLY_XP[2]
	)
	assert_eq(WorldState.quest_stage("side_elysia_butterflies"), "return")


func test_chest_starts_the_loops_and_the_child_opens_the_rift() -> void:
	var scene: GameScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(get_tree().get_nodes_in_group(&"child_guide").size(), 0, "child comes later")
	WorldState.set_flag("elysia.chest_tree_opened")
	await wait_physics_frames(2)
	assert_true(WorldState.has_flag("elysia.loops"), "Elysia starts repeating")
	var children := get_tree().get_nodes_in_group(&"child_guide")
	assert_eq(children.size(), 1, "the child has no twin")
	var child: ChildGuide = children[0]
	assert_not_null(child.get_node_or_null("Reflection"), "the child has a reflection")
	WorldState.set_flag("elysia.child_met")
	assert_eq(child.step, ChildGuide.Step.LEAD)
	WorldState.set_flag("elysia.child_vanished")
	await wait_seconds(1.4)
	assert_true(WorldState.has_flag("elysia.rift_open"))
	assert_true(Beat.reached("rift_found"))
