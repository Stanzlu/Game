# gdlint: ignore=max-public-methods
extends GutTest
## StoryLint (docs/PRODUKTIONSPLAN.md, T2): each rule has a fixture that must turn red, a fixture
## that must stay green, and the real project must pass all of them.

const DIALOGUE := "res://content/dialogue/slice/fixture.dialogue"
const DOOR := "res://world/props/door.tscn"
const Fixtures := preload("res://tests/unit/content_fixtures.gd")


func _placement(
	prop: String, params: Dictionary, marker := "", cell := Vector2i(1, 1)
) -> Dictionary:
	return {"symbol": "?", "cell": cell, "prop": prop, "marker": marker, "params": params}


func _map(placements: Array[Dictionary]) -> MapData:
	var data := MapData.new()
	data.placements = placements
	return data


func _sources() -> StoryLint.Sources:
	var src := StoryLint.Sources.new()
	src.cues[DIALOGUE] = PackedStringArray(["here"])
	src.maps["res://m/haus.txt"] = _map([_placement("", {}, "spawn_door")])
	src.maps["res://m/tal.txt"] = _map([_placement(DOOR, {"target": "haus", "spawn": "door"})])
	src.scene_maps = {"haus": "res://m/haus.txt", "tal": "res://m/tal.txt"}
	return src


# --- doors ---------------------------------------------------------------------------------


func test_a_door_to_a_real_scene_and_spawn_is_fine() -> void:
	assert_eq(StoryLint.door_problems(_sources()), PackedStringArray())


func test_a_door_to_an_unknown_scene_is_found() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map([_placement(DOOR, {"target": "keller"})])
	var problems := StoryLint.door_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "'keller' is not a registered scene")


func test_a_door_to_a_missing_spawn_is_found() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map([_placement(DOOR, {"target": "haus", "spawn": "hinten"})])
	var problems := StoryLint.door_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "no marker spawn_hinten")


func test_a_spawn_in_a_scene_without_a_map_is_found() -> void:
	var src := _sources()
	src.scene_maps.erase("haus")
	assert_string_contains(StoryLint.door_problems(src)[0], "no map to hold the spawn")


func test_travel_calls_in_scripts_are_checked() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = 'func f():\n\tSceneTravel.go(self, "haus", "door", "")\n'
	assert_eq(StoryLint.door_problems(src), PackedStringArray())
	src.code["res://w/a.gd"] = 'func f():\n\tSceneTravel.go(self, "haus", "west", "")\n'
	var problems := StoryLint.door_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "res://w/a.gd:2")


func test_a_renamed_scene_still_counts_as_a_target() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map([_placement(DOOR, {"target": "daheim", "spawn": "door"})])
	SceneRegistry.aliases = {"daheim": "haus"}
	var problems := StoryLint.door_problems(src)
	SceneRegistry.aliases = {}
	assert_eq(problems, PackedStringArray())


# --- cues ----------------------------------------------------------------------------------


func test_cues_that_exist_are_fine() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map(
		[_placement("res://world/props/decor.tscn", {"cue": "here", "dialogue": DIALOGUE})]
	)
	var calls := 'func f():\n\tawait Talk.present(self, D, "here", p)\n\tawait cut.say(D, "here")\n'
	src.code["res://w/a.gd"] = 'const D := "%s"\n%s' % [DIALOGUE, calls]
	assert_eq(StoryLint.cue_problems(src), PackedStringArray())


func test_a_map_cue_that_is_missing_is_found() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map(
		[_placement("res://world/props/decor.tscn", {"cue": "gone", "dialogue": DIALOGUE})]
	)
	var problems := StoryLint.cue_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "cue 'gone' is missing")


func test_a_script_cue_that_is_missing_is_found_through_its_constant() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = (
		'const DIALOGUE := preload("%s")\nfunc f():\n\tawait cut.say(DIALOGUE.resource_path, "gone")\n'
		% DIALOGUE
	)
	var problems := StoryLint.cue_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "res://w/a.gd:3")


func test_a_cue_in_an_unknown_dialogue_is_found() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = 'func f():\n\tawait cut.say("res://nope.dialogue", "here")\n'
	assert_string_contains(
		StoryLint.cue_problems(src)[0], "dialogue res://nope.dialogue is unknown"
	)


# --- quests --------------------------------------------------------------------------------


func test_a_quest_with_a_trigger_for_every_stage_is_fine() -> void:
	var src := _sources()
	src.quests = [Fixtures.quest()]
	src.code["res://w/a.gd"] = (
		'func f():\n\tWorldState.start_quest("side_test")\n'
		+ '\tWorldState.advance_quest("side_test", "middle")\n'
		+ '\tWorldState.advance_quest("side_test", "done")\n'
		+ '\tWorldState.advance_quest("side_test", "missed")\n'
	)
	assert_eq(StoryLint.quest_problems(src), PackedStringArray())


func test_a_stage_nothing_advances_to_is_found() -> void:
	var src := _sources()
	src.quests = [Fixtures.quest()]
	src.dialogues["res://d/a.dialogue"] = (
		'do WorldState.start_quest("side_test")\n'
		+ 'do WorldState.advance_quest("side_test", "middle")'
	)
	src.maps["res://m/tal.txt"] = _map(
		[_placement("", {"actions": [{"quest": "side_test", "stage": "done"}]})]
	)
	var problems := StoryLint.quest_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "stage 'missed' has no trigger")


func test_a_quest_nothing_starts_is_found() -> void:
	var src := _sources()
	src.quests = [Fixtures.quest()]
	assert_string_contains(StoryLint.quest_problems(src)[0], "nothing starts the quest")


func test_a_map_action_can_start_and_advance_a_quest() -> void:
	var src := _sources()
	src.quests = [Fixtures.quest()]
	var stage := {"quest": "side_test", "stage": "middle", "start": true}
	var more := [{"quest": "side_test", "stage": "done"}, {"quest": "side_test", "stage": "missed"}]
	src.maps["res://m/tal.txt"] = _map(
		[_placement("", {"actions": [stage]}), _placement("", {"actions": more})]
	)
	assert_eq(StoryLint.quest_problems(src), PackedStringArray())


# --- flags ---------------------------------------------------------------------------------


func test_a_flag_that_is_set_and_read_is_fine() -> void:
	var src := _sources()
	src.dialogues["res://d/a.dialogue"] = 'do WorldState.set_flag("area.door_open")'
	src.maps["res://m/tal.txt"] = _map([_placement("", {"if": "area.door_open"})])
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())


func test_a_flag_that_is_set_and_never_read_is_found() -> void:
	var src := _sources()
	src.dialogues["res://d/a.dialogue"] = 'do WorldState.set_flag("area.lonely")'
	var problems := StoryLint.flag_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "sets flag 'area.lonely', nothing reads it")


func test_a_flag_that_is_read_and_never_set_is_found() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = 'func f():\n\treturn WorldState.has_flag("area.typo")\n'
	var problems := StoryLint.flag_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "reads flag 'area.typo', nothing sets it")


func test_a_constant_flag_is_followed_into_its_calls() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = (
		'const FLAG := "area.wood"\nfunc f():\n\tWorldState.set_flag(FLAG)\n'
		+ "func g():\n\treturn WorldState.has_flag(FLAG)\n"
	)
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())
	src.code["res://w/a.gd"] = 'const FLAG := "area.wood"\nfunc f():\n\tWorldState.set_flag(FLAG)\n'
	assert_eq(StoryLint.flag_problems(src).size(), 1)


func test_beat_flags_are_set_by_the_beat_log_and_need_no_reader() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = 'func f():\n\tBeat.mark("evening")\n'
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())
	src.code["res://w/b.gd"] = 'func g():\n\treturn Beat.reached("nowhere")\n'
	assert_string_contains(StoryLint.flag_problems(src)[0], "reads flag 'beat.nowhere'")


func test_a_flag_set_for_tests_and_named_as_such_is_allowed() -> void:
	var src := _sources()
	var flag: String = StoryLint.WRITE_ONLY_FLAGS.keys()[0]
	src.dialogues["res://d/a.dialogue"] = 'do WorldState.set_flag("%s")' % flag
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())


func test_a_map_prop_flag_guards_itself() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map([_placement("", {"flag": "area.chest_opened"})])
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())


# --- duplicates ----------------------------------------------------------------------------


func test_a_spawn_marker_twice_in_one_map_is_found() -> void:
	var src := _sources()
	src.maps["res://m/haus.txt"] = _map(
		[_placement("", {}, "spawn_door"), _placement("", {}, "spawn_door", Vector2i(5, 5))]
	)
	var problems := StoryLint.duplicate_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "marker 'spawn_door' twice")


func test_the_same_marker_in_two_maps_is_fine() -> void:
	var src := _sources()
	src.maps["res://m/tal.txt"] = _map([_placement("", {}, "spawn_door")])
	assert_eq(StoryLint.duplicate_problems(src), PackedStringArray())


func test_a_beat_marked_at_two_places_is_found() -> void:
	var src := _sources()
	src.code["res://w/a.gd"] = 'func f():\n\tBeat.mark("fire")\n'
	src.code["res://w/b.gd"] = 'func g():\n\tBeat.mark("fire")\n\tBeat.mark("other")\n'
	var problems := StoryLint.duplicate_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "beat 'fire' is also marked at")


# --- effects -------------------------------------------------------------------------------


func test_a_flash_without_the_setting_is_found() -> void:
	var src := _sources()
	src.code["res://u/bar.gd"] = "var _flash := 0.0\n"
	var problems := StoryLint.effect_problems(src)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "display.reduce_flashing")


func test_a_flash_that_reads_the_setting_is_fine() -> void:
	var src := _sources()
	var reads := 'func f():\n\treturn Settings.get_bool("display.reduce_flashing")\n'
	src.code["res://u/bar.gd"] = "var _flash := 0.0\n" + reads
	assert_eq(StoryLint.effect_problems(src), PackedStringArray())


func test_a_shake_without_the_setting_is_found() -> void:
	var src := _sources()
	src.code["res://u/cam.gd"] = "func shake(strength: float) -> void:\n\tpass\n"
	assert_string_contains(StoryLint.effect_problems(src)[0], "display.screen_shake")


func test_calls_and_local_names_are_not_effects() -> void:
	var src := _sources()
	var calls := "func f():\n\tview.shake(1.0, 0.2)\n\tvar flicker := 0.3\n\trow.flash(cell)\n"
	src.code["res://u/a.gd"] = calls
	assert_eq(StoryLint.effect_problems(src), PackedStringArray())


# --- the real project ----------------------------------------------------------------------


func test_the_real_project_passes_every_rule() -> void:
	var src := StoryLint.load_project()
	# the rules must have something to look at, or an empty scan would pass for ever
	assert_gt(src.maps.size(), 8, "maps")
	assert_gt(src.code.size(), 100, "scripts")
	assert_gt(src.dialogues.size(), 5, "dialogues")
	assert_gt(src.cues.size(), 5, "cue lists")
	assert_gt(src.scene_maps.size(), 5, "scene maps")
	assert_gt(src.quests.size(), 5, "quests")
	assert_eq(StoryLint.door_problems(src), PackedStringArray())
	assert_eq(StoryLint.cue_problems(src), PackedStringArray())
	assert_eq(StoryLint.quest_problems(src), PackedStringArray())
	assert_eq(StoryLint.flag_problems(src), PackedStringArray())
	assert_eq(StoryLint.duplicate_problems(src), PackedStringArray())
	assert_eq(StoryLint.effect_problems(src), PackedStringArray())


func test_the_real_project_has_doors_cues_and_flags_to_check() -> void:
	var doors := 0
	var src := StoryLint.load_project()
	for map_path: String in src.maps:
		for p: Dictionary in (src.maps[map_path] as MapData).placements:
			if str(p["prop"]) in StoryLint.TRAVEL_PROPS:
				doors += 1
	assert_gt(doors, 3, "the slice has doors and rifts")
