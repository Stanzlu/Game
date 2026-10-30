# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W2: the forest path. What stands along it is told in small finds: the
## Antreiber's six boards (the side quest "Die Wegzeichen": follow, blank, done; the last board is
## empty and holds a stub of chalk), two places to rest (the first time sets the facet care and the
## flag forest.rested, whichever place it is), the Antreiber at the empty board (absent for whoever
## left him at the fire in the house), a cone, the steps in the sunken lane (a trace of the world)
## and the way on to the south (the hut's own cues are in huette.dialogue, W3). The scene (map,
## beats, the Hang) is tested in test_akt3_waldweg_szene.

const WALD := "res://content/dialogue/akt3/waldweg.dialogue"
const QUEST := "side_forest_marks"
const STORY_FILE := "res://content/dialogue/akt3/waldweg.dialogue"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## Every ID of the file (replays and answers included) plus the journal's rows and the two
## curiosities' texts.
func _all_texts() -> PackedStringArray:
	var source := FileAccess.get_file_as_string(STORY_FILE)
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(wd_[a-z0-9_]+)\\]").search_all(source):
		found.append(LineText.of(hit.get_string(1)))
	for key: String in ["TITLE", "FOLLOW", "BLANK", "DONE"]:
		found.append(tr("QUEST_SIDE_FOREST_MARKS_" + key))
	found.append(tr("QUEST_MAIN_FOREST_WAY_WOOD"))
	for id: String in ["CURIOSITY_CONE", "CURIOSITY_CHALK_STUB"]:
		found.append(tr(id + "_NAME"))
		found.append(tr(id + "_DESC"))
	return found


# --- The boards and the quest ----------------------------------------------------------------


func test_the_first_board_starts_the_quest_and_every_board_can_be_read_again() -> void:
	for cue: String in ["mark_1", "mark_2", "mark_3", "mark_4", "mark_5"]:
		var first := await DialogueWalk.play(WALD, cue)
		assert_gte(first.size(), 2, "%s: two lines at least" % cue)
		assert_eq(
			await DialogueWalk.play(WALD, cue), first, "%s: a board says the same twice" % cue
		)
	assert_eq(WorldState.quest_stage(QUEST), "follow", "only the first board starts it")
	WorldState.new_game()
	await DialogueWalk.play(WALD, "mark_3")
	assert_eq(WorldState.quest_stage(QUEST), "", "a later board starts nothing")


func test_the_sixth_board_is_empty_and_holds_the_chalk_that_ends_the_quest() -> void:
	await DialogueWalk.play(WALD, "mark_1")
	var answers := await DialogueWalk.answers(WALD, "mark_6")
	assert_eq(answers.size(), 2, "take it or leave it")
	assert_eq(WorldState.quest_stage(QUEST), "blank", "reading the board is the second stage")
	assert_false(WorldState.has_item("curiosity_chalk_stub"))
	var left := await DialogueWalk.play(WALD, "mark_6", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "wd_m6_1") and _has(left, "wd_m6_6"))
	assert_eq(WorldState.quest_stage(QUEST), "blank", "left in its groove: the quest waits")
	assert_false(WorldState.has_item("curiosity_chalk_stub"))
	var taken := await DialogueWalk.play(WALD, "mark_6", PackedStringArray(["Einstecken"]))
	assert_true(_has(taken, "wd_m6_4"))
	assert_true(WorldState.has_item("curiosity_chalk_stub"))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_eq(await DialogueWalk.play(WALD, "mark_6"), PackedStringArray([LineText.of("wd_m6_5")]))


func test_whoever_reads_only_the_last_board_still_has_the_quest_and_the_chalk() -> void:
	await DialogueWalk.play(WALD, "mark_6", PackedStringArray(["Einstecken"]))
	assert_eq(WorldState.quest_stage(QUEST), "done", "the empty board starts it too")
	assert_true(WorldState.has_item("curiosity_chalk_stub"))


func test_the_boards_are_the_antreibers_list_and_say_nothing_about_why() -> void:
	var first := await DialogueWalk.play(WALD, "mark_1")
	assert_string_contains(first[1], "Erstens gehen")
	assert_string_contains((await DialogueWalk.play(WALD, "mark_2"))[0], "Zweitens schneller")
	var hang := await DialogueWalk.play(WALD, "mark_4")
	assert_string_contains(hang[1], "aber", "what he struck out is still there to read")
	assert_string_contains((await DialogueWalk.play(WALD, "mark_5"))[0], "Fast da")


func test_the_journal_tells_every_stage_of_the_quest_and_the_way_on() -> void:
	for key: String in ["TITLE", "FOLLOW", "BLANK", "DONE"]:
		assert_ne(tr("QUEST_SIDE_FOREST_MARKS_" + key), "QUEST_SIDE_FOREST_MARKS_" + key, key)
	assert_ne(tr("QUEST_MAIN_FOREST_WAY_WOOD"), "QUEST_MAIN_FOREST_WAY_WOOD")
	var quest := ContentDB.quest(QUEST)
	assert_eq(quest.first_stage().id, "follow")
	assert_true(quest.can_advance("follow", "blank") and quest.can_advance("blank", "done"))
	assert_true(quest.can_advance("follow", "done"), "the empty board may be the first one read")


# --- The places to rest ------------------------------------------------------------------------


func test_the_first_rest_lights_the_fire_and_sets_care_and_rested() -> void:
	var answers := await DialogueWalk.answers(WALD, "rest_1")
	assert_eq(answers.size(), 2, "make a fire or walk on")
	var seen := await DialogueWalk.play(WALD, "rest_1", PackedStringArray(["Feuer machen"]))
	for id: String in ["wd_rest1_1", "wd_rest1_4", "wd_rest1_7"]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_facet("care"))
	assert_true(WorldState.has_flag("forest.rested"))
	assert_true(WorldState.has_flag("forest.fire_1"))
	assert_false(WorldState.has_flag("forest.fire_2"), "the other ring is still cold")
	assert_eq(
		await DialogueWalk.play(WALD, "rest_1"), PackedStringArray([LineText.of("wd_embers_1")])
	)


func test_walking_on_leaves_the_ring_cold_and_sets_nothing() -> void:
	var seen := await DialogueWalk.play(WALD, "rest_1", PackedStringArray(["Weitergehen"]))
	assert_true(_has(seen, "wd_rest1_8"))
	assert_false(WorldState.has_facet("care"))
	assert_false(WorldState.has_flag("forest.rested"))
	assert_false(WorldState.has_flag("forest.fire_1"))
	var again := await DialogueWalk.play(WALD, "rest_1", PackedStringArray(["Weitergehen"]))
	assert_true(_has(again, "wd_rest1_1"), "asked again, as often as she passes")


func test_the_second_rest_is_shorter_once_she_knows_how_and_full_if_she_does_not() -> void:
	await DialogueWalk.play(WALD, "rest_1")
	var short := await DialogueWalk.play(WALD, "rest_2", PackedStringArray(["Feuer machen"]))
	assert_true(_has(short, "wd_rest2_3"), "she knows how")
	assert_false(_has(short, "wd_rest2_4"), "not told twice")
	assert_true(WorldState.has_flag("forest.fire_2"))
	WorldState.new_game()
	var full := await DialogueWalk.play(WALD, "rest_2", PackedStringArray(["Feuer machen"]))
	assert_true(_has(full, "wd_rest2_4") and _has(full, "wd_rest2_6"))
	assert_false(_has(full, "wd_rest2_3"))
	assert_true(WorldState.has_facet("care"), "the first rest, wherever it is, sets it")
	assert_true(WorldState.has_flag("forest.rested"))
	assert_false(WorldState.has_flag("forest.fire_1"), "each ring burns for itself")


func test_a_rest_is_a_choice_with_a_different_end_and_no_number() -> void:
	for cue: String in ["rest_1", "rest_2"]:
		var groups := await DialogueWalk.groups(WALD, cue)
		assert_eq(groups.size(), 1, cue)
		assert_eq(groups[0].size(), 2, "%s: a fire or the way on" % cue)
	for text: String in _all_texts():
		for word: String in ["Punkte", "Wert", "Prozent", "Level", "Fürsorge", "achtsam"]:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])


# --- The Antreiber at the empty board ----------------------------------------------------------


func test_he_has_gone_ahead_and_keeps_an_appointment_if_she_put_him_off() -> void:
	var neutral := await DialogueWalk.play(WALD, "antreiber_end", PackedStringArray(["Wie weit"]))
	assert_true(_has(neutral, "wd_antr_0b") and _has(neutral, "wd_antr_1"))
	assert_true(_has(neutral, "wd_antr_8"), "he says what he always says")
	assert_true(WorldState.has_flag("forest.antreiber_met"))
	assert_false(WorldState.has_flag("forest.antreiber_sat"))
	WorldState.new_game()
	WorldState.set_flag("house.antreiber_postponed")
	var late := await DialogueWalk.play(WALD, "antreiber_end", PackedStringArray(["…"]))
	assert_true(_has(late, "wd_antr_0a"), "morgen was a date, and it is morgen")
	assert_false(_has(late, "wd_antr_0b"))


func test_tea_is_an_answer_only_for_whoever_has_made_it() -> void:
	var without := await DialogueWalk.groups(WALD, "antreiber_end")
	assert_eq(without.size(), 1)
	assert_eq(without[0].size(), 2, "no tea without a fire")
	assert_eq(without[0][without[0].size() - 1], "…", "the silence is the last answer")
	WorldState.new_game()
	WorldState.set_facet("care")
	var with := await DialogueWalk.groups(WALD, "antreiber_end")
	assert_eq(with[0].size(), 3)
	assert_string_contains(with[0][0], "Tee")
	assert_eq(with[0][with[0].size() - 1], "…")


func test_with_tea_he_sits_and_the_map_swaps_the_standing_one_for_the_sitting_one() -> void:
	WorldState.set_facet("care")
	var seen := await DialogueWalk.play(WALD, "antreiber_end", PackedStringArray(["Tee"]))
	assert_true(_has(seen, "wd_antr_4") and _has(seen, "wd_antr_7"))
	assert_true(WorldState.has_flag("forest.antreiber_sat"))
	assert_eq(
		await DialogueWalk.play(WALD, "antreiber_end"),
		PackedStringArray([LineText.of("wd_antr_sat")])
	)


func test_the_quest_and_the_chalk_do_not_hang_on_him() -> void:
	await DialogueWalk.play(WALD, "antreiber_end", PackedStringArray(["…"]))
	assert_eq(WorldState.quest_stage(QUEST), "", "talking to him is not the quest")
	assert_false(WorldState.has_item("curiosity_chalk_stub"))
	var again := await DialogueWalk.play(WALD, "antreiber_end", PackedStringArray(["…"]))
	assert_true(_has(again, "wd_antr_again"), "the second time he is still at it")
	assert_false(_has(again, "wd_antr_1"), "the opening is told once")


# --- Things along the path -------------------------------------------------------------------


func test_the_steps_are_a_fragment_told_once_and_the_picture_is_there() -> void:
	var seen := await DialogueWalk.play(WALD, "hang_steps")
	assert_true(_has(seen, "wd_steps_1") and _has(seen, "wd_steps_3"))
	assert_true(Collection.has_fragment("hang_steps"))
	assert_eq(Collection.fragments(), 1)
	assert_true(ResourceLoader.exists("res://assets/generated/fragments/fragment_hang_steps.png"))
	assert_eq(
		await DialogueWalk.play(WALD, "hang_steps"), PackedStringArray([LineText.of("wd_steps_5")])
	)
	assert_eq(Collection.fragments(), 1, "not counted twice")


func test_the_cone_is_taken_with_the_first_answer_or_left() -> void:
	var left := await DialogueWalk.play(WALD, "cone", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "wd_cone_1") and _has(left, "wd_cone_3"))
	assert_false(WorldState.has_item("curiosity_cone"))
	assert_false(WorldState.has_flag("forest.cone_taken"))
	await DialogueWalk.play(WALD, "cone")
	assert_true(WorldState.has_item("curiosity_cone"))
	assert_true(WorldState.has_flag("forest.cone_taken"))


func test_the_two_curiosities_are_in_the_game_and_count() -> void:
	for id: String in ["curiosity_cone", "curiosity_chalk_stub"]:
		assert_true(ContentDB.has_item(id), id)
		assert_ne(tr(id.to_upper() + "_NAME"), id.to_upper() + "_NAME", id)
		assert_ne(tr(id.to_upper() + "_DESC"), id.to_upper() + "_DESC", id)
		assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % id), id)
		WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 2)


func test_the_end_of_the_way_says_what_it_shows_and_nothing_more() -> void:
	assert_eq(
		await DialogueWalk.play(WALD, "south_wait"), PackedStringArray([LineText.of("wd_south_1")])
	)


# --- What it never says ----------------------------------------------------------------------


func test_narration_has_no_colon_question_cry_or_ellipsis_and_no_digit() -> void:
	var checked := 0
	for raw in FileAccess.get_file_as_string(STORY_FILE).split("\n"):
		var line := raw.strip_edges()
		if not line.contains("[ID:") or line.begins_with("-") or line.begins_with("Antreiber:"):
			continue
		var text := line.substr(0, line.find("[ID:")).strip_edges()
		checked += 1
		for mark: String in [":", "?", "!", "…"]:
			assert_false(text.contains(mark), "%s in narration: %s" % [mark, text])
		assert_null(RegEx.create_from_string("[0-9]").search(text), "a digit in: %s" % text)
	assert_gt(checked, 40, "every line of narration was read")


func test_none_of_his_lines_has_a_cry_in_it() -> void:
	# a static scan: every line of his, whatever flags a walk would need to reach it
	var spoken := 0
	for raw in FileAccess.get_file_as_string(STORY_FILE).split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("Antreiber:"):
			spoken += 1
			assert_false(line.contains("!"), "he only cries while he drives: %s" % line)
	assert_gte(spoken, 9, "all his lines were read")


func test_the_antreiber_drives_nobody_here_and_speaks_in_lists_and_times() -> void:
	var resource := load(WALD) as DialogueResource
	var spoken := 0
	for title: String in resource.get_cues():
		var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, title)
		var guard := 0
		while line != null and guard < 40:
			guard += 1
			if line.character != "":
				spoken += 1
				assert_eq(line.character, "Antreiber")
				assert_false(
					line.text.contains("!"), "he only cries while he drives: %s" % line.text
				)
			var next_id := line.next_id
			if not line.responses.is_empty():
				next_id = line.responses[0].next_id
			line = await DialogueManager.get_next_dialogue_line(resource, next_id)
	assert_gte(spoken, 3, "his lines were read")


func test_no_trace_names_a_child_a_reason_or_a_memory() -> void:
	# Brief O5/O7: the steps are a trace of the world, the boards are his list; neither names a child,
	# a cause, a place that is home or a memory (his reason is W4's, and a thing, not a sentence)
	var forbidden := [
		"Kind",
		"Erinnerung",
		"erinner",
		"Zuhause",
		"Meer",
		"Heim",
		"verlor",
		"Mutter",
		"Vater",
		"Mama",
		"Papa",
		"Familie",
		"Abschied",
		"gestorben",
		"vermiss",
		"Angst",
		"Flut",
	]
	for text: String in _all_texts():
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
