extends GutTest
## Autopilot v2 (docs/PRODUKTIONSPLAN.md T8): the macros unroll into plain events in a fixed
## order, and the waits know when their condition holds. The scripts are played by tools/check.sh.

const AUTOPILOT := preload("res://tools/autopilot/autopilot.gd")


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	WorldState.new_game()


func _keys(events: Array) -> Array:
	var keys: Array = []
	for event: Dictionary in events:
		var names := event.keys()
		names.erase("t")
		keys.append(names)
	return keys


func test_talk_unrolls_into_meeting_facing_talking_and_waiting_for_the_end() -> void:
	var events: Array = AUTOPILOT.expand([{"t": 5.0, "talk": "baker", "log": "the baker"}])
	assert_eq(events.size(), 5)
	assert_eq(events[0].get("meet"), "baker")
	assert_eq(events[0].get("log"), "the baker", "the log stays on the first event")
	assert_false(events[0].has("talk"))
	assert_eq(events[1].get("press"), ["move_up"])
	assert_eq(events[2].get("release"), ["move_up"])
	assert_eq(events[3].get("tap"), ["interact"])
	assert_eq(events[4].get("wait_for"), {"dialogue_closed": true})
	for index in range(1, events.size()):
		assert_gt(float(events[index]["t"]), float(events[index - 1]["t"]) - 0.0001)


func test_use_goes_to_a_cell_and_faces_where_asked() -> void:
	var events: Array = AUTOPILOT.expand([{"t": 1.0, "use": [8, 13], "face": "left"}])
	assert_eq(events[0].get("teleport"), [8, 13])
	assert_eq(events[1].get("press"), ["move_left"])
	assert_true(events[4].has("wait_for"))


func test_enter_takes_the_door_and_waits_for_the_scene() -> void:
	var events: Array = AUTOPILOT.expand([{"t": 2.0, "enter": "gasthaus"}])
	assert_eq(events.size(), 2)
	assert_eq(events[0].get("door"), "gasthaus")
	assert_eq(events[1].get("wait_for"), {"scene": "gasthaus"})


func test_events_at_the_same_time_keep_the_order_of_the_script() -> void:
	var events: Array = AUTOPILOT.expand(
		[
			{"t": 1.0, "log": "a"},
			{"t": 1.0, "log": "b"},
			{"t": 1.0, "log": "c"},
			{"t": 0.5, "log": "z"}
		]
	)
	var logs: Array = events.map(func(e: Dictionary) -> String: return e["log"])
	assert_eq(logs, ["z", "a", "b", "c"])


func test_repeat_still_unrolls() -> void:
	var events: Array = AUTOPILOT.expand(
		[{"t": 1.0, "repeat": 3, "every": 2.0, "tap": ["interact"]}]
	)
	assert_eq(events.size(), 3)
	assert_eq(events[2]["t"], 5.0)


func test_a_flag_and_a_quest_stage_are_conditions() -> void:
	var pilot: Node = AUTOPILOT.new()
	add_child_autofree(pilot)
	assert_false(pilot.call(&"_condition_met", {"flag": "elysia.woke"}))
	WorldState.set_flag("elysia.woke")
	assert_true(pilot.call(&"_condition_met", {"flag": "elysia.woke"}))
	assert_false(pilot.call(&"_condition_met", {"quest": "main_elysia_hero", "stage": "greet"}))
	WorldState.start_quest("main_elysia_hero")
	assert_true(pilot.call(&"_condition_met", {"quest": "main_elysia_hero", "stage": "greet"}))
	assert_false(pilot.call(&"_condition_met", {"beat": "no_such_beat"}))


func test_a_relative_script_puts_each_step_after_the_one_before() -> void:
	var events: Array = AUTOPILOT.expand(
		[{"relative": true}, {"t": 1.0, "talk": "baker"}, {"t": 0.5, "log": "after the talk"}]
	)
	var talk_end: float = events[events.size() - 2]["t"]
	var last: Dictionary = events[events.size() - 1]
	assert_eq(last.get("log"), "after the talk")
	assert_almost_eq(float(last["t"]), talk_end + 0.5, 0.0001, "half a second after the whole talk")
	assert_eq(events[0]["t"], 1.0, "the first step starts after its own pause")


# --- The command "quest" (W6): a segment that starts in the middle of an act ---------------------


## Plays `events` on a fresh autopilot (their times are 0, so the first physics step does them all).
func _play(events: Array) -> void:
	var pilot: Node = AUTOPILOT.new()
	pilot.set(&"_events", AUTOPILOT.expand(events))
	add_child_autofree(pilot)
	await wait_physics_frames(3)


func test_the_quest_command_is_no_macro_and_keeps_its_stage() -> void:
	var events: Array = AUTOPILOT.expand(
		[{"t": 1.0, "quest": "main_forest_way", "stage": "home", "log": "at home"}]
	)
	assert_eq(events.size(), 1)
	assert_eq(events[0].get("quest"), "main_forest_way")
	assert_eq(events[0].get("stage"), "home")
	assert_eq(events[0].get("log"), "at home")


func test_the_way_between_two_stages_is_the_shortest_along_next() -> void:
	var def := ContentDB.quest("main_forest_way")
	assert_eq(
		AUTOPILOT.quest_way(def, "leave", "home"),
		PackedStringArray(["brook", "wood", "night", "home"])
	)
	assert_eq(AUTOPILOT.quest_way(def, "night", "done"), PackedStringArray(["home", "done"]))
	assert_eq(AUTOPILOT.quest_way(def, "wood", "wood"), PackedStringArray(), "already there")
	assert_eq(AUTOPILOT.quest_way(def, "home", "leave"), PackedStringArray(), "never back")
	assert_eq(AUTOPILOT.quest_way(def, "leave", "nowhere"), PackedStringArray(), "no such stage")


func test_the_command_starts_the_quest_and_goes_the_real_way_to_the_stage() -> void:
	assert_false(WorldState.is_quest_started("main_forest_way"))
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "home"}])
	assert_eq(WorldState.quest_stage("main_forest_way"), "home")
	assert_eq(
		WorldState.quest_history("main_forest_way"),
		PackedStringArray(["leave", "brook", "wood", "night", "home"]),
		"every stage on the way was entered by the game's own call"
	)
	assert_true(WorldState.is_quest_active("main_forest_way"), "home is not the end")
	assert_push_error_count(0)


func test_the_command_goes_on_from_where_the_quest_stands() -> void:
	WorldState.start_quest("main_forest_way")
	WorldState.advance_quest("main_forest_way", "brook")
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "night"}])
	assert_eq(
		WorldState.quest_history("main_forest_way"),
		PackedStringArray(["leave", "brook", "wood", "night"])
	)
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "night"}])
	assert_eq(WorldState.quest_history("main_forest_way").size(), 4, "the same stage: nothing")
	assert_push_error_count(0)


func test_the_command_reaches_the_end_of_a_quest_and_finishes_it() -> void:
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "done"}])
	assert_true(WorldState.is_quest_done("main_forest_way"))
	assert_eq(WorldState.quest_outcome("main_forest_way"), "done")


func test_a_stage_behind_the_quest_is_an_error_and_changes_nothing() -> void:
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "home"}])
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "wood"}])
	assert_push_error("autopilot quest unreachable")
	assert_eq(WorldState.quest_stage("main_forest_way"), "home")
	assert_eq(WorldState.quest_history("main_forest_way").size(), 5)


func test_an_unknown_quest_or_stage_is_an_error_and_starts_nothing() -> void:
	await _play([{"t": 0.0, "quest": "main_forest_way", "stage": "nowhere"}])
	assert_push_error("autopilot quest unknown")
	assert_false(WorldState.is_quest_started("main_forest_way"), "not even started")
	await _play([{"t": 0.0, "quest": "no_such_quest", "stage": "x"}])
	assert_push_error("autopilot quest unknown")
	assert_false(WorldState.is_quest_started("no_such_quest"))


func test_a_wait_for_a_quest_stage_is_not_taken_for_the_command() -> void:
	WorldState.start_quest("main_forest_way")
	var events: Array = AUTOPILOT.expand(
		[{"t": 0.0, "wait_for": {"quest": "main_forest_way", "stage": "home"}, "timeout": 5.0}]
	)
	assert_false((events[0] as Dictionary).has("quest"), "the quest is inside the wait")
	await _play(events)
	assert_eq(WorldState.quest_stage("main_forest_way"), "leave", "waiting moves no quest")
	assert_push_error_count(0)
