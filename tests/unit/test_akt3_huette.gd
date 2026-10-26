# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W3: the hermit's hut. He puts things down and lets them stand: a cup of tea
## before the door, a stool at the table, staying (three steps, each an answer, never a time). Every
## offer can be declined and nothing is missing then. His reason is shown by things (tea outside,
## branches on the path, an open bolt, a second cup that was never used) and never said. The flute
## is the act's melody, the clothesline a trace of the world, the pipe and the pebble curiosities.
## The scene (zoom, door, beats) is tested in test_akt3_huette_szene, the map in
## test_akt3_huette_karte.

const HUT := "res://content/dialogue/akt3/huette.dialogue"
const QUEST := "main_forest_way"
const STORY_FILE := "res://content/dialogue/akt3/huette.dialogue"
const STAY_FLAGS: Array[String] = ["forest.hut_stay_1", "forest.hut_stay_2", "forest.hut_stay_3"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _stays() -> int:
	var count := 0
	for flag: String in STAY_FLAGS:
		if WorldState.has_flag(flag):
			count += 1
	return count


## Every ID of the file (replays and answers included) plus the journal's rows and the texts of
## the two curiosities.
func _all_texts() -> PackedStringArray:
	var source := FileAccess.get_file_as_string(STORY_FILE)
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(hu_[a-z0-9_]+)\\]").search_all(source):
		found.append(LineText.of(hit.get_string(1)))
	for key: String in ["NIGHT", "OBJ_HERMIT", "OBJ_FLOOD"]:
		found.append(tr("QUEST_MAIN_FOREST_WAY_" + key))
	for id: String in ["CURIOSITY_ELDER_PIPE", "CURIOSITY_HOLED_STONE"]:
		found.append(tr(id + "_NAME"))
		found.append(tr(id + "_DESC"))
	return found


# --- Offer one: the cup before the door ----------------------------------------------------


func test_the_cup_before_the_door_is_offered_with_three_answers_and_can_be_left() -> void:
	var left := await DialogueWalk.play(HUT, "door_tea", PackedStringArray(["Stehen lassen"]))
	assert_true(_has(left, "hu_door_1") and _has(left, "hu_door_6"))
	assert_false(WorldState.has_flag("forest.hut_tea"), "left standing: nothing happened")
	var silent := await DialogueWalk.play(HUT, "door_tea", PackedStringArray(["…"]))
	assert_true(_has(silent, "hu_door_7"))
	assert_false(WorldState.has_flag("forest.hut_tea"))
	var groups := await DialogueWalk.groups(HUT, "door_tea", PackedStringArray(["Stehen lassen"]))
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 3, "drink, leave it, silence")
	assert_eq(groups[0][2], "…", "the silence is last")


func test_drinking_sets_the_flag_and_the_cup_is_told_once() -> void:
	var drunk := await DialogueWalk.play(HUT, "door_tea")
	assert_true(_has(drunk, "hu_door_4"))
	assert_true(WorldState.has_flag("forest.hut_tea"))
	assert_false(WorldState.has_facet("care"), "tea that was given is not tea that was made")
	assert_false(WorldState.has_flag("forest.rested"), "and no fire was lit")
	assert_eq(
		await DialogueWalk.play(HUT, "door_tea"), PackedStringArray([LineText.of("hu_door_5")])
	)


func test_branches_are_seen_and_say_nothing_of_why() -> void:
	var seen := await DialogueWalk.play(HUT, "branches")
	assert_eq(seen.size(), 2)
	assert_string_contains(seen[1], "Gebunden sind sie nicht")


# --- Offer two: a stool, and what he says --------------------------------------------------


func test_he_offers_the_stool_and_says_what_the_tea_outside_was() -> void:
	var cold := await DialogueWalk.play(HUT, "hermit", PackedStringArray(["…"]))
	assert_true(_has(cold, "hu_h_1") and _has(cold, "hu_h_3") and _has(cold, "hu_h_4"))
	assert_true(WorldState.has_flag("forest.hut_met"))
	WorldState.new_game()
	WorldState.set_flag("forest.hut_tea")
	var drunk := await DialogueWalk.play(HUT, "hermit", PackedStringArray(["…"]))
	assert_true(_has(drunk, "hu_h_2"), "he says who the tea was for")
	assert_false(_has(drunk, "hu_h_3"))
	var again := await DialogueWalk.play(HUT, "hermit", PackedStringArray(["…"]))
	assert_true(_has(again, "hu_h_5"), "the second time only the stool")
	assert_false(_has(again, "hu_h_1"), "the greeting is said once")


func test_the_invitation_to_the_valley_needs_the_tea_she_can_make() -> void:
	var without := await DialogueWalk.groups(HUT, "hermit", PackedStringArray(["…"]))
	assert_eq(without[0].size(), 2, "no tea to offer: the way on and the silence")
	assert_eq(without[0][1], "…")
	WorldState.new_game()
	WorldState.set_facet("care")
	var with := await DialogueWalk.groups(HUT, "hermit", PackedStringArray(["Komm doch"]))
	assert_eq(with[0].size(), 3)
	assert_string_contains(with[0][0], "Tee")
	assert_eq(with[0][2], "…", "the silence stays the last answer")
	assert_true(WorldState.has_flag("forest.hermit_invited"))
	var next := await DialogueWalk.groups(HUT, "hermit")
	assert_eq(next[0].size(), 2, "he is asked once")
	var seen := await DialogueWalk.play(HUT, "hermit", PackedStringArray(["…"]))
	assert_true(_has(seen, "hu_h_6"), "his cup is packed")


func test_going_on_costs_nothing_and_is_answered_dryly() -> void:
	var seen := await DialogueWalk.play(HUT, "hermit", PackedStringArray(["Ich gehe weiter"]))
	assert_true(_has(seen, "hu_h_8"))
	assert_false(WorldState.has_flag("forest.hermit_invited"))
	assert_eq(_stays(), 0)
	assert_false(WorldState.has_facet("care"))


# --- Offer three: staying ------------------------------------------------------------------


func test_the_first_sitting_brings_the_flute_and_asks_nothing_he_would_hold() -> void:
	var seen := await DialogueWalk.play(HUT, "stay", PackedStringArray(["Nur sitzen"]))
	for id: String in ["hu_flute_1", "hu_flute_2", "hu_flute_3", "hu_ask_1", "hu_ask_2"]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_flag("melody.hermit_flute"))
	assert_eq(Collection.melodies(), 1)
	assert_eq(Collection.fragments(), 0, "the flute is a melody and no fragment")
	assert_eq(_stays(), 0, "sitting is not staying")
	var second := await DialogueWalk.play(HUT, "stay", PackedStringArray(["Nur sitzen"]))
	assert_false(_has(second, "hu_flute_1"), "he plays once")
	assert_true(_has(second, "hu_ask_1"))


func test_staying_has_three_steps_each_one_answer() -> void:
	var picks := PackedStringArray(["Bleiben", "Noch bleiben", "Noch bleiben"])
	var groups := await DialogueWalk.groups(HUT, "stay", picks)
	assert_eq(groups.size(), 3, "three answers to stay; the third ends it")
	for group: PackedStringArray in groups:
		assert_eq(group.size(), 3, "stay, sit only, silence")
		assert_eq(group[2], "…", "the silence is last")
	assert_eq(_stays(), 3)
	for flag: String in STAY_FLAGS:
		assert_true(WorldState.has_flag(flag), flag)


func test_each_step_sets_its_own_flag_first_and_declining_stops_there() -> void:
	WorldState.set_flag("melody.hermit_flute")
	var one := await DialogueWalk.play(HUT, "stay", PackedStringArray(["Bleiben", "Nur sitzen"]))
	assert_true(_has(one, "hu_s1_1") and _has(one, "hu_s1_3"))
	assert_eq(_stays(), 1)
	assert_true(WorldState.has_flag("forest.hut_stay_1"))
	var two := await DialogueWalk.play(HUT, "stay", PackedStringArray(["Bleiben", "…"]))
	assert_true(_has(two, "hu_s2_1"), "the next sitting goes on where she stopped")
	assert_false(_has(two, "hu_s1_1"), "the first step is not told twice")
	assert_eq(_stays(), 2)
	assert_false(WorldState.has_flag("forest.hut_stay_3"))


func test_nothing_new_happens_while_she_stays() -> void:
	WorldState.set_flag("melody.hermit_flute")
	var items := WorldState.state.inventory.duplicate()
	await DialogueWalk.play(
		HUT, "stay", PackedStringArray(["Bleiben", "Noch bleiben", "Noch bleiben"])
	)
	assert_eq(WorldState.state.inventory, items, "no item")
	assert_eq(Collection.fragments(), 0)
	assert_eq(Collection.curiosities(), 0)
	assert_eq(Collection.melodies(), 1, "the flute was there before")
	assert_eq(WorldState.quest_stage(QUEST), "", "no stage, no objective")


func test_after_the_third_step_there_are_only_calm_lines_and_no_end() -> void:
	for flag: String in STAY_FLAGS:
		WorldState.set_flag(flag)
	WorldState.set_flag("melody.hermit_flute")
	var before := _stays()
	var seen := await DialogueWalk.play(
		HUT, "stay", PackedStringArray(["Bleiben", "Bleiben", "Bleiben", "Nur sitzen"])
	)
	assert_true(_has(seen, "hu_done_1"), "the door stands open")
	var calm := 0
	for id: String in ["hu_calm_1", "hu_calm_2", "hu_calm_3"]:
		if _has(seen, id):
			calm += 1
	assert_gte(calm, 1, "a calm line for each stay")
	assert_true(_has(seen, "hu_done_2"), "sitting only ends the cue")
	assert_eq(_stays(), before, "no step beyond the third")
	var groups := await DialogueWalk.groups(HUT, "stay_more", PackedStringArray(["Bleiben", "…"]))
	assert_eq(groups.size(), 2, "the answers come back after a calm line")
	assert_eq(groups[0], groups[1], "the same three answers")


func test_every_group_has_a_way_to_decline_and_the_silence_last() -> void:
	# the groups of the hut (ContentValidator checks that no choice is a fake one); stay_more loops, so
	# it is left with "Nur sitzen"
	for cue: String in ["stay_ask", "stay_1", "stay_2", "stay_more", "hermit_end", "door_tea"]:
		var picks := (
			PackedStringArray(["Nur sitzen"]) if cue == "stay_more" else PackedStringArray()
		)
		var groups := await DialogueWalk.groups(HUT, cue, picks)
		assert_gte(groups.size(), 1, cue)
		assert_gte(groups[0].size(), 2, cue)
		assert_eq(groups[0][groups[0].size() - 1], "…", "%s: the silence is last" % cue)
		WorldState.new_game()


# --- Things to find ------------------------------------------------------------------------


func test_the_pipe_on_the_sill_is_taken_with_the_first_answer_or_left() -> void:
	var left := await DialogueWalk.play(HUT, "window", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "hu_win_1") and _has(left, "hu_win_4"))
	assert_false(WorldState.has_item("curiosity_elder_pipe"))
	await DialogueWalk.play(HUT, "window")
	assert_true(WorldState.has_item("curiosity_elder_pipe"))
	assert_true(WorldState.has_flag("forest.pipe_taken"))
	assert_eq(await DialogueWalk.play(HUT, "window"), PackedStringArray([LineText.of("hu_win_5")]))


func test_the_pebble_is_taken_with_the_first_answer_or_left() -> void:
	var left := await DialogueWalk.play(HUT, "pebble", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "hu_pebble_1") and _has(left, "hu_pebble_3"))
	assert_false(WorldState.has_item("curiosity_holed_stone"))
	await DialogueWalk.play(HUT, "pebble")
	assert_true(WorldState.has_item("curiosity_holed_stone"))
	assert_true(WorldState.has_flag("forest.pebble_taken"))


func test_the_clothesline_is_a_fragment_told_once_and_the_picture_is_there() -> void:
	var seen := await DialogueWalk.play(HUT, "clothesline")
	assert_true(_has(seen, "hu_line_1") and _has(seen, "hu_line_3"))
	assert_true(Collection.has_fragment("clothesline"))
	assert_eq(Collection.fragments(), 1)
	assert_true(ResourceLoader.exists("res://assets/generated/fragments/fragment_clothesline.png"))
	assert_eq(
		await DialogueWalk.play(HUT, "clothesline"), PackedStringArray([LineText.of("hu_line_5")])
	)
	assert_eq(Collection.fragments(), 1, "not counted twice")


func test_the_two_curiosities_are_in_the_game_and_count() -> void:
	for id: String in ["curiosity_elder_pipe", "curiosity_holed_stone"]:
		assert_true(ContentDB.has_item(id), id)
		assert_ne(tr(id.to_upper() + "_NAME"), id.to_upper() + "_NAME", id)
		assert_ne(tr(id.to_upper() + "_DESC"), id.to_upper() + "_DESC", id)
		assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % id), id)
		WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 2)


func test_the_things_that_show_why_say_what_they_are_and_nothing_more() -> void:
	var bolt := await DialogueWalk.play(HUT, "bolt")
	assert_eq(bolt.size(), 2)
	assert_string_contains(bolt[1], "offen")
	var cup := await DialogueWalk.play(HUT, "cup_nail")
	assert_string_contains(cup[0], "zweiter Becher")
	assert_string_contains(cup[1], "Benutzt sieht er nicht aus")
	var shelf := await DialogueWalk.play(HUT, "flute_shelf")
	assert_eq(shelf.size(), 2)
	WorldState.set_flag("melody.hermit_flute")
	assert_eq(
		await DialogueWalk.play(HUT, "flute_shelf"), PackedStringArray([LineText.of("hu_shelf_3")])
	)


# --- The way through the wood --------------------------------------------------------------


func test_the_quest_has_two_goals_in_the_wood_and_the_night_after_them() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_true(quest.can_advance("wood", "night"))
	assert_eq(quest.stage("wood").outcome, "", "the wood no longer ends the quest")
	assert_eq(quest.stage("night").outcome, "done")
	assert_true(quest.stage("wood").objectives.has("hermit"))
	assert_true(quest.stage("wood").objectives.has("flood"))
	for key: String in ["NIGHT", "OBJ_HERMIT", "OBJ_FLOOD"]:
		assert_ne(tr("QUEST_MAIN_FOREST_WAY_" + key), "QUEST_MAIN_FOREST_WAY_" + key, key)


# --- What it never says --------------------------------------------------------------------


func test_narration_has_no_colon_question_cry_or_ellipsis_and_no_digit() -> void:
	var checked := 0
	for raw in FileAccess.get_file_as_string(STORY_FILE).split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("%"):
			line = line.substr(1).strip_edges()
		if not line.contains("[ID:") or line.begins_with("-") or line.begins_with("Einsiedler:"):
			continue
		var text := line.substr(0, line.find("[ID:")).strip_edges()
		checked += 1
		for mark: String in [":", "?", "!", "…"]:
			assert_false(text.contains(mark), "%s in narration: %s" % [mark, text])
		assert_null(RegEx.create_from_string("[0-9]").search(text), "a digit in: %s" % text)
	assert_gt(checked, 45, "every line of narration was read")


func test_his_lines_are_short_offers_with_no_question_and_no_cry() -> void:
	var lines := 0
	var words := 0
	for raw in FileAccess.get_file_as_string(STORY_FILE).split("\n"):
		var line := raw.strip_edges()
		if not line.begins_with("Einsiedler:"):
			continue
		var text := line.substr("Einsiedler:".length(), line.find("[ID:") - "Einsiedler:".length())
		text = text.strip_edges()
		lines += 1
		words += text.split(" ", false).size()
		for mark: String in ["?", "!"]:
			assert_false(text.contains(mark), "he does not ask or cry: %s" % text)
		for word: String in ["Woher", "Wohin", "Warum", "musst", "solltest", "gefährlich"]:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
	assert_gte(lines, 8, "his lines were read")
	assert_lt(float(words) / lines, 7.0, "fewer than seven words a line on average")


func test_nothing_explains_why_he_lives_alone_and_nothing_judges_it() -> void:
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
		"Gefahr",
		"sicher",
		"Schutz",
		"gesund",
		"einsam",
		"verletz",
		"Fürsorge",
		"achtsam",
	]
	for text: String in _all_texts():
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
