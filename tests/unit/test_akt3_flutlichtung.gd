# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W4: the clearing the water once stood on. The Antreiber's reason is shown by
## things and never said: a mark (a bleached trunk, a band of silt over her head round every beech),
## a camp (a ring full of silt, a kettle on its side, a stiff blanket with one red stroke at the
## hem) and the prints of a single runner going north. He stands at the mark and measures; his feet
## go on the spot, and stand still when he sits. Side quest B (a nest and a fork), a curiosity (the
## driftwood) and a fragment (the stepping stones, a trace of the world) hang on nobody. The scene
## (door, beats, the hero's quest) is tested in test_akt3_flutlichtung_szene, the map elsewhere.

const FLUT := "res://content/dialogue/akt3/flutlichtung.dialogue"
const QUEST := "side_forest_nest"
const MAIN_QUEST := "main_forest_way"
const CUES: Array[String] = [
	"flood_mark",
	"flood_camp",
	"flood_trail",
	"antreiber_flood",
	"antreiber_flood_ask",
	"antreiber_flood_again",
	"south_wait",
	"nest",
	"fork",
	"driftwood",
	"stones",
]
## Phrases the earlier segments have used up; a line of this file must not say them again.
const USED_UP: Array[String] = [
	"Atemzug",
	"nur kurz",
	"wohin mit",
	"Etappen",
	"dunkel wird",
	"spart Zeit",
	"Fast da",
	"holt nichts",
	"klappt",
	"pünktlich",
	"Zahlen auf",
	"Der Tee ist gut",
	"Daumen",
	"Becher",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _say(ids: Array[String]) -> String:
	var found: PackedStringArray = []
	for id: String in ids:
		found.append(LineText.of(id))
	return " ".join(found)


## A typed list of names (typed and untyped arrays do not compare equal in an assert).
func _names(names: Array) -> Array[String]:
	var found: Array[String] = []
	for name: String in names:
		found.append(name)
	return found


## Every flag that is set now, sorted.
func _flag_names() -> Array[String]:
	var found: Array[String] = []
	for flag: String in WorldState.state.flags:
		found.append(flag)
	found.sort()
	return found


## The flags that are there now and were not in `before`, sorted.
func _added(before: Dictionary) -> Array[String]:
	var added: Array[String] = []
	for flag: String in WorldState.state.flags:
		if not before.has(flag):
			added.append(flag)
	added.sort()
	return added


## The lines of one cue as written (tabs kept), without blank lines and comments.
func _cue_raw(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	var inside := false
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		if raw.begins_with("~ "):
			inside = raw.strip_edges() == "~ " + cue
			continue
		if inside and not raw.strip_edges().is_empty() and not raw.begins_with("#"):
			found.append(raw)
	return found


## The statements of a cue (stripped), the closing "=> END" left out.
func _statements(cue: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for raw in _cue_raw(cue):
		found.append(raw.strip_edges())
	if not found.is_empty() and found[found.size() - 1] == "=> END":
		found.remove_at(found.size() - 1)
	return found


## Every line of the file that carries an ID: {id, text, speaker, answer}. The text is what the
## player sees (no tags, no condition); the speaker is "" for narration.
func _story_lines() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		var line := raw.strip_edges()
		if not line.contains("[ID:"):
			continue
		var id_at := line.find("[ID:")
		var text := line.substr(0, id_at).strip_edges()
		var id := line.substr(id_at + 4, line.find("]", id_at) - id_at - 4)
		var answer := text.begins_with("- ")
		if answer:
			text = text.substr(2).strip_edges()
		if text.contains(" [if "):
			text = text.substr(0, text.find(" [if ")).strip_edges()
		var speaker := ""
		if text.begins_with("Antreiber:"):
			speaker = "Antreiber"
			text = text.substr("Antreiber:".length()).strip_edges()
		found.append({"id": id, "text": text, "speaker": speaker, "answer": answer})
	return found


## The visible text of every ID of the file (answers included) plus the journal's rows for the
## side quest and the driftwood's name and description.
func _all_texts() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(fl_[a-z0-9_]+)\\]").search_all(
		FileAccess.get_file_as_string(FLUT)
	):
		found.append(LineText.of(hit.get_string(1)))
	for key: String in ["TITLE", "FIND", "FORK", "DONE"]:
		found.append(tr("QUEST_SIDE_FOREST_NEST_" + key))
	found.append(tr("CURIOSITY_DRIFTWOOD_NAME"))
	found.append(tr("CURIOSITY_DRIFTWOOD_DESC"))
	return found


# --- The file and what it sets ---------------------------------------------------------------


func test_the_file_has_every_cue_the_map_and_the_scene_name() -> void:
	var cues := (load(FLUT) as DialogueResource).get_cues()
	for cue: String in CUES:
		assert_true(cue in cues, "cue %s" % cue)
	assert_true("fork_nest" in cues, "the fork's answers have a cue of their own")


func test_the_file_stays_inside_its_line_budget_of_the_brief() -> void:
	var narrated := 0
	for line: Dictionary in _story_lines():
		if not line["answer"]:
			narrated += 1
	assert_between(
		narrated, 30, 48, "about thirty-six lines were planned, forty-eight is the limit"
	)


func test_nothing_but_the_contract_is_set_started_advanced_or_given() -> void:
	# a static scan of every effect in the file, whatever a walk would need to reach it
	var found: Array[String] = []
	var regex := RegEx.create_from_string("^\\s*do WorldState\\.(\\w+)\\((.*)\\)\\s*$")
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		var hit := regex.search(raw)
		if hit != null:
			found.append("%s(%s)" % [hit.get_string(1), hit.get_string(2)])
	found.sort()
	var expected: Array[String] = [
		'add_item("curiosity_driftwood")',
		'advance_quest("side_forest_nest", "done")',
		'advance_quest("side_forest_nest", "fork")',
		'set_flag("forest.antreiber_met")',
		'set_flag("forest.driftwood_taken")',
		'set_flag("forest.flood_sat")',
		'set_flag("forest.flood_seen")',
		'set_flag("forest.nest_placed")',
		'set_flag("forest.nest_taken")',
		'set_flag("fragment.stepping_stones")',
		'start_quest("side_forest_nest")',
	]
	assert_eq(found, expected, "no care, no rest, no relationship, no other quest, no item")


func test_each_cue_sets_only_what_the_contract_gives_it() -> void:
	# whatever answer is taken, with the facet and the nest to hand so that every answer is there
	var table := [
		{"cue": "flood_mark", "picks": [""], "allowed": ["forest.flood_seen"]},
		{"cue": "flood_camp", "picks": [""], "allowed": []},
		{"cue": "flood_trail", "picks": [""], "allowed": []},
		{
			"cue": "antreiber_flood",
			"picks": ["Tee", "Ich bleibe hier", "…"],
			"allowed": ["forest.antreiber_met", "forest.flood_sat"],
		},
		{
			"cue": "antreiber_flood_ask",
			"picks": ["Tee", "Ich bleibe hier", "…"],
			"allowed": ["forest.flood_sat"],
		},
		{"cue": "antreiber_flood_again", "picks": ["Bleib sitzen", "…"], "allowed": []},
		{"cue": "south_wait", "picks": [""], "allowed": []},
		{
			"cue": "nest",
			"picks": ["Aufheben", "Liegen lassen", "…"],
			"allowed": ["forest.nest_taken"],
		},
		{
			"cue": "fork",
			"picks": ["Das Nest in die Gabel", "Noch nicht", "…"],
			"allowed": ["forest.nest_placed"],
		},
		{
			"cue": "driftwood",
			"picks": ["Einstecken", "Liegen lassen", "…"],
			"allowed": ["forest.driftwood_taken"],
		},
		{"cue": "stones", "picks": [""], "allowed": ["fragment.stepping_stones"]},
	]
	var walked := 0
	for entry: Dictionary in table:
		var cue: String = entry["cue"]
		for pick: String in entry["picks"]:
			WorldState.new_game()
			WorldState.set_facet("care")
			WorldState.set_flag("forest.nest_taken")
			WorldState.start_quest(QUEST)
			WorldState.advance_quest(QUEST, "fork")
			var before := WorldState.state.flags.duplicate()
			var items := WorldState.state.inventory.duplicate()
			await DialogueWalk.play(FLUT, cue, PackedStringArray([pick]))
			walked += 1
			for flag: String in _added(before):
				assert_true(flag in entry["allowed"], "%s (pick '%s') sets %s" % [cue, pick, flag])
			if cue != "driftwood":
				assert_eq(WorldState.state.inventory, items, "%s gives no item" % cue)
			assert_true(WorldState.has_facet("care"), "no cue takes the facet away")
	assert_eq(walked, 22, "every answer of every cue was walked")


# --- The things: trail, camp, mark --------------------------------------------------------------


func test_the_trail_is_one_runner_going_north_that_runs_out() -> void:
	var seen := await DialogueWalk.play(FLUT, "flood_trail")
	assert_eq(seen.size(), 4)
	for id: String in ["fl_trail_1", "fl_trail_2", "fl_trail_3", "fl_trail_4"]:
		assert_true(_has(seen, id), id)
	var text := _say(["fl_trail_1", "fl_trail_2", "fl_trail_3", "fl_trail_4"])
	for word: String in ["Läufer", "Ballen", "Ferse", "Norden", "gerannt", "links, rechts"]:
		assert_string_contains(text, word)
	assert_eq(text.count("Läufer"), 1, "one runner, said once")
	for word: String in ["zweite", "kleine", "kleiner", "Paar", "Becher", "Kind"]:
		assert_false(text.contains(word), "'%s' in the trail" % word)
	var deep := text.find("tief")
	var shallow := text.find("flacher")
	var gone := text.find("kaum noch da")
	assert_true(deep > -1 and deep < shallow and shallow < gone, "deep, then shallow, then gone")
	assert_lt(text.find("Norden"), deep, "the direction is known before the prints fade")
	assert_eq(await DialogueWalk.play(FLUT, "flood_trail"), seen, "the same twice")
	assert_eq(_flag_names(), _names([]), "a trail sets nothing")


func test_the_camp_is_one_ring_one_kettle_one_blanket_and_a_single_red_stroke() -> void:
	var seen := await DialogueWalk.play(FLUT, "flood_camp")
	assert_eq(seen.size(), 4)
	var text := _say(["fl_camp_1", "fl_camp_2", "fl_camp_3", "fl_camp_4"])
	for word: String in [
		"Feuerring",
		"Schlick",
		"gerissen",
		"Dreibein",
		"quer",
		"Haken",
		"Kessel",
		"Deckel",
		"Decke",
		"Pfahl",
		"steif",
		"Saum",
		"Kreide",
		"Lineal",
		"rot",
	]:
		assert_string_contains(text, word)
	assert_eq(text.count("Strich"), 1, "a single stroke")
	assert_eq(text.count("Dreibein"), 1, "one tripod: two legs askew, the third across")
	assert_eq(text.count("Kessel"), 1, "one kettle, on its side, and the lid beside it")
	var blankets := RegEx.create_from_string("\\bDecke\\b").search_all(text)
	assert_eq(blankets.size(), 1, "one blanket")
	for word: String in ["Becher", "Tasse", "zweite", "zweiter", "kleine", "Schuh", "Kind", "Name"]:
		assert_false(text.contains(word), "'%s' in the camp" % word)
	assert_eq(_flag_names(), _names([]), "a camp sets nothing")
	assert_eq(Collection.fragments(), 0, "the camp is not the fragment")


func test_the_mark_is_told_in_five_lines_and_sets_flood_seen_after_them() -> void:
	var seen := await DialogueWalk.play(FLUT, "flood_mark")
	assert_eq(seen.size(), 5)
	for id: String in ["fl_mark_1", "fl_mark_2", "fl_mark_3", "fl_mark_4", "fl_mark_5"]:
		assert_true(_has(seen, id), id)
	assert_true(WorldState.has_flag("forest.flood_seen"))
	assert_eq(_flag_names(), _names(["forest.flood_seen"]), "and nothing else")
	var statements := _statements("flood_mark")
	assert_eq(
		statements[statements.size() - 1],
		'do WorldState.set_flag("forest.flood_seen")',
		"the flag is the last thing the cue does, after every line"
	)
	for index in range(statements.size() - 1):
		assert_false(statements[index].contains("set_flag"), "no flag before the lines are told")
	var text := _say(["fl_mark_1", "fl_mark_2", "fl_mark_3", "fl_mark_4", "fl_mark_5"])
	for word: String in [
		"bleich", "Krone", "Zacken", "Kopf", "Buche", "Schnitt", "Span", "Kruste", "Arm"
	]:
		assert_string_contains(text, word)
	assert_eq(text.count("Schnitt"), 1, "a single cut")
	assert_null(RegEx.create_from_string("[0-9]").search(text), "no number on it")
	# everything else on the way he has lettered on a board; here there is none
	assert_string_contains(LineText.of("fl_mark_4"), "Daneben hängt kein Brett")
	assert_eq(text.count("Brett"), 1, "the absence of the board is said once")


func test_the_second_look_at_the_mark_is_one_line_without_news() -> void:
	await DialogueWalk.play(FLUT, "flood_mark")
	var again := await DialogueWalk.play(FLUT, "flood_mark")
	assert_eq(again, PackedStringArray([LineText.of("fl_mark_6")]))
	assert_lt(LineText.of("fl_mark_6").split(" ").size(), 12, "short")
	assert_eq(_flag_names(), _names(["forest.flood_seen"]), "still one flag")


func test_the_mark_is_the_cue_that_sets_the_flag_and_the_antreiber_never_names_it() -> void:
	var setters := 0
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		if raw.contains('set_flag("forest.flood_seen")'):
			setters += 1
	assert_eq(setters, 1, "one setter")
	for cue: String in ["antreiber_flood", "antreiber_flood_ask", "antreiber_flood_again"]:
		for statement in _statements(cue):
			assert_false(statement.contains("flood_seen"), "%s: %s" % [cue, statement])
		WorldState.new_game()
		WorldState.set_facet("care")
		for pick: String in ["Tee", "Ich bleibe hier", "…"]:
			await DialogueWalk.play(FLUT, cue, PackedStringArray([pick]))
			assert_false(WorldState.has_flag("forest.flood_seen"), "%s with '%s'" % [cue, pick])


func test_the_mark_leaves_the_heros_quest_to_the_scene() -> void:
	WorldState.start_quest(MAIN_QUEST)
	for stage: String in ["brook", "wood"]:
		assert_true(WorldState.advance_quest(MAIN_QUEST, stage))
	await DialogueWalk.play(FLUT, "flood_mark")
	assert_eq(WorldState.quest_stage(MAIN_QUEST), "wood", "the cue moves no quest")
	assert_false(WorldState.is_objective_done(MAIN_QUEST, "flood"), "the goal is the scene's")
	assert_false(WorldState.is_objective_done(MAIN_QUEST, "hermit"))


# --- The Antreiber at the mark -----------------------------------------------------------------


func test_he_measures_and_his_feet_go_on_the_spot_without_a_word_about_why() -> void:
	var seen := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["…"]))
	for id: String in ["fl_antr_1", "fl_antr_2", "fl_antr_3", "fl_ask_5"]:
		assert_true(_has(seen, id), id)
	assert_string_contains(LineText.of("fl_antr_1"), "Zollstock")
	assert_string_contains(LineText.of("fl_antr_2"), "messe")
	assert_string_contains(LineText.of("fl_antr_3"), "auf der Stelle")
	assert_string_contains(LineText.of("fl_ask_5"), "Füße gehen weiter")
	assert_true(WorldState.has_flag("forest.antreiber_met"))
	assert_eq(_flag_names(), _names(["forest.antreiber_met"]), "met is the only flag")
	assert_false(WorldState.has_flag("forest.flood_sat"))
	assert_false(WorldState.has_flag("forest.antreiber_sat"), "that is the board's flag")


func test_the_opening_is_said_again_until_he_sits() -> void:
	await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["Ich bleibe hier"]))
	var again := await DialogueWalk.play(
		FLUT, "antreiber_flood", PackedStringArray(["Ich bleibe hier"])
	)
	assert_true(_has(again, "fl_antr_2"), "he is still at it")
	assert_false(_has(again, "fl_again_1"), "and not yet sitting")


func test_whoever_met_him_at_the_board_meets_the_same_opening_here() -> void:
	# he went ahead; the clearing does not read where she met him before
	WorldState.set_flag("forest.antreiber_met")
	WorldState.set_flag("forest.antreiber_sat")
	var seen := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["…"]))
	assert_true(_has(seen, "fl_antr_1") and _has(seen, "fl_antr_2"))
	assert_false(WorldState.has_flag("forest.flood_sat"), "the board's tea is not this tea")


func test_tea_is_an_answer_only_for_whoever_has_made_it() -> void:
	var without := await DialogueWalk.groups(FLUT, "antreiber_flood_ask")
	assert_eq(without.size(), 1)
	assert_eq(without[0].size(), 2, "no tea without a fire: staying and the silence")
	assert_string_contains(without[0][0], "Ich bleibe hier")
	assert_eq(without[0][1], "…", "the silence is the last answer")
	for answer: String in without[0]:
		assert_false(answer.contains("Tee"), "no tea in: %s" % answer)
	WorldState.new_game()
	WorldState.set_facet("care")
	var with := await DialogueWalk.groups(FLUT, "antreiber_flood_ask")
	assert_eq(with[0].size(), 3)
	assert_string_contains(with[0][0], "Tee")
	assert_string_contains(with[0][1], "Ich bleibe hier")
	assert_eq(with[0][2], "…", "the silence stays the last answer")
	WorldState.set_flag("forest.flood_sat")
	var sat := await DialogueWalk.groups(FLUT, "antreiber_flood_ask")
	assert_eq(sat[0].size(), 2, "a man who sits is not offered a seat again")


func test_with_tea_he_tests_the_ground_sits_and_his_feet_stand_still() -> void:
	WorldState.set_facet("care")
	var seen := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["Tee"]))
	for id: String in ["fl_antr_1", "fl_antr_3", "fl_ask_1", "fl_ask_2", "fl_ask_3"]:
		assert_true(_has(seen, id), id)
	assert_string_contains(LineText.of("fl_ask_1"), "Schuhspitze")
	assert_string_contains(LineText.of("fl_ask_2"), "Trocken")
	assert_string_contains(LineText.of("fl_ask_3"), "auf den Boden")
	assert_string_contains(LineText.of("fl_ask_3"), "Füße stehen still")
	assert_true(WorldState.has_flag("forest.flood_sat"))
	assert_true(WorldState.has_flag("forest.antreiber_met"))
	assert_eq(
		_flag_names(),
		_names(["forest.antreiber_met", "forest.flood_sat"]),
		"the two flags, no more"
	)
	assert_eq(WorldState.state.inventory.size(), 0, "tea costs nothing")
	assert_true(WorldState.has_facet("care"), "and takes nothing")


func test_staying_and_the_silence_answer_differently_and_set_nothing() -> void:
	var stay := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["Ich bleibe"]))
	assert_true(_has(stay, "fl_ask_4"))
	assert_false(_has(stay, "fl_ask_5"))
	assert_string_contains(LineText.of("fl_ask_4"), "Zollstock")
	WorldState.new_game()
	var silent := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["…"]))
	assert_true(_has(silent, "fl_ask_5"))
	assert_false(_has(silent, "fl_ask_4"))
	for taken: PackedStringArray in [stay, silent]:
		assert_false(_has(taken, "fl_ask_3"), "nobody sat down")
	assert_false(WorldState.has_flag("forest.flood_sat"))
	assert_false(WorldState.has_facet("care"), "talking to him gives no facet")


func test_once_he_sits_the_cue_gives_a_short_line_without_news() -> void:
	WorldState.set_flag("forest.flood_sat")
	var seen := await DialogueWalk.play(
		FLUT, "antreiber_flood", PackedStringArray(["Bleib sitzen"])
	)
	assert_true(_has(seen, "fl_again_1") and _has(seen, "fl_again_2") and _has(seen, "fl_again_3"))
	for id: String in ["fl_antr_1", "fl_antr_2", "fl_antr_3"]:
		assert_false(_has(seen, id), "the opening is not said again: %s" % id)
	assert_string_contains(LineText.of("fl_again_1"), "Füße stehen still")
	var groups := await DialogueWalk.groups(FLUT, "antreiber_flood")
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 2, "one answer and the silence")
	assert_string_contains(groups[0][0], "Bleib sitzen")
	assert_eq(groups[0][1], "…", "the silence is last")
	var silent := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["…"]))
	assert_true(_has(silent, "fl_again_4"))


func test_the_again_cue_is_reached_only_through_the_flag() -> void:
	var statements := _statements("antreiber_flood")
	assert_eq(statements[0], 'if WorldState.has_flag("forest.flood_sat")', "first thing he asks")
	assert_eq(statements[1], "=> antreiber_flood_again")
	var jumps := 0
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		if raw.contains("=> antreiber_flood_again"):
			jumps += 1
	assert_eq(jumps, 1, "no other way in")
	var seen := await DialogueWalk.play(FLUT, "antreiber_flood", PackedStringArray(["…"]))
	assert_false(_has(seen, "fl_again_1"), "not sitting: no sitting lines")


# --- The side quest, the curiosity, the fragment -----------------------------------------------


func test_the_nest_starts_the_quest_when_it_is_seen_and_taking_it_moves_it_on() -> void:
	assert_eq(_statements("nest")[0], 'do WorldState.start_quest("side_forest_nest")')
	var left := await DialogueWalk.play(FLUT, "nest", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "fl_nest_1") and _has(left, "fl_nest_3"))
	assert_eq(WorldState.quest_stage(QUEST), "find", "seen, not taken: the first stage")
	assert_false(WorldState.has_flag("forest.nest_taken"))
	var silent := await DialogueWalk.play(FLUT, "nest", PackedStringArray(["…"]))
	assert_true(_has(silent, "fl_nest_4"))
	assert_eq(WorldState.quest_stage(QUEST), "find")
	assert_eq(_flag_names(), _names([]), "leaving it sets nothing")
	var taken := await DialogueWalk.play(FLUT, "nest", PackedStringArray(["Aufheben"]))
	assert_true(_has(taken, "fl_nest_2"))
	assert_eq(WorldState.quest_stage(QUEST), "fork")
	assert_true(WorldState.has_flag("forest.nest_taken"))
	assert_eq(_flag_names(), _names(["forest.nest_taken"]), "and no other flag")
	assert_eq(WorldState.state.inventory.size(), 0, "the nest is a flag, no item")
	assert_eq(Collection.curiosities(), 0, "and no curiosity")


func test_the_nest_has_three_answers_and_the_first_one_takes_it() -> void:
	var groups := await DialogueWalk.groups(FLUT, "nest", PackedStringArray(["Liegen lassen"]))
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 3, "take it, leave it, silence")
	assert_string_contains(groups[0][0], "Aufheben")
	assert_eq(groups[0][2], "…", "the silence is last")
	await DialogueWalk.play(FLUT, "nest")
	assert_true(WorldState.has_flag("forest.nest_taken"), "the first answer takes it")


func test_the_fork_without_the_nest_is_an_observation_and_asks_nothing() -> void:
	var seen := await DialogueWalk.play(FLUT, "fork")
	assert_eq(seen, PackedStringArray([LineText.of("fl_fork_1")]))
	assert_string_contains(seen[0], "Ast")
	assert_string_contains(seen[0], "Gabel")
	var groups := await DialogueWalk.groups(FLUT, "fork")
	assert_eq(groups.size(), 0, "no answer without the nest")
	assert_eq(_flag_names(), _names([]))
	assert_false(WorldState.is_quest_started(QUEST), "the fork starts nothing")


func test_the_nest_goes_into_the_fork_and_ends_the_quest() -> void:
	await DialogueWalk.play(FLUT, "nest")
	var groups := await DialogueWalk.groups(FLUT, "fork", PackedStringArray(["Noch nicht"]))
	assert_eq(groups.size(), 1)
	assert_eq(groups[0].size(), 3, "lay it in, not yet, silence")
	assert_string_contains(groups[0][0], "Das Nest in die Gabel legen")
	assert_string_contains(groups[0][1], "Noch nicht")
	assert_eq(groups[0][2], "…", "the silence is last")
	assert_false(WorldState.has_flag("forest.nest_placed"), "not yet is not yet")
	assert_eq(WorldState.quest_stage(QUEST), "fork")
	var silent := await DialogueWalk.play(FLUT, "fork", PackedStringArray(["…"]))
	assert_true(_has(silent, "fl_fork_4"))
	assert_false(WorldState.has_flag("forest.nest_placed"))
	var before := WorldState.state.flags.duplicate()
	var placed := await DialogueWalk.play(
		FLUT, "fork", PackedStringArray(["Das Nest in die Gabel"])
	)
	assert_true(_has(placed, "fl_fork_2"))
	assert_true(WorldState.has_flag("forest.nest_placed"))
	assert_eq(_added(before), _names(["forest.nest_placed"]))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(WorldState.is_quest_done(QUEST))
	assert_eq(
		WorldState.quest_history(QUEST), PackedStringArray(["find", "fork", "done"]), "all three"
	)
	assert_eq(
		await DialogueWalk.play(FLUT, "fork"),
		PackedStringArray([LineText.of("fl_fork_5")]),
		"afterwards one line: it lies as if it had always been there"
	)
	assert_string_contains(LineText.of("fl_fork_5"), "als wäre es immer dort gewesen")


func test_the_nest_can_be_carried_for_as_long_as_she_likes() -> void:
	# no clock and no hurry: "not yet" is an answer as often as she gives it
	await DialogueWalk.play(FLUT, "nest")
	for _round in 3:
		var seen := await DialogueWalk.play(FLUT, "fork", PackedStringArray(["Noch nicht"]))
		assert_true(_has(seen, "fl_fork_3"))
	assert_eq(WorldState.quest_stage(QUEST), "fork")
	assert_false(WorldState.has_flag("forest.nest_placed"))


func test_the_quest_is_three_stages_with_a_journal_and_no_goal_of_the_hero() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_not_null(quest)
	assert_eq(quest.kind, QuestDef.Kind.SIDE)
	assert_eq(quest.first_stage().id, "find")
	assert_true(quest.can_advance("find", "fork") and quest.can_advance("fork", "done"))
	assert_false(quest.can_advance("find", "done"), "the fork is not to be skipped")
	assert_eq(quest.stage("done").outcome, "done")
	assert_eq(quest.stages.size(), 3)
	for key: String in ["TITLE", "FIND", "FORK", "DONE"]:
		assert_ne(tr("QUEST_SIDE_FOREST_NEST_" + key), "QUEST_SIDE_FOREST_NEST_" + key, key)
	assert_eq(tr("QUEST_SIDE_FOREST_NEST_TITLE"), "Das Nest")
	for key: String in ["FIND", "FORK", "DONE"]:
		var row := tr("QUEST_SIDE_FOREST_NEST_" + key)
		assert_null(RegEx.create_from_string("[0-9]").search(row), "no digit in %s" % key)
		assert_false(row.contains("kümmer"), "no looking-after in %s" % key)
	assert_string_contains(tr("QUEST_SIDE_FOREST_NEST_FORK"), "Gabel", "the journal gives the hint")
	assert_false(
		tr("QUEST_MAIN_FOREST_WAY_WOOD").contains("Flut"), "the hero's journal keeps its secret"
	)


func test_the_driftwood_is_taken_with_the_first_answer_or_left() -> void:
	var groups := await DialogueWalk.groups(FLUT, "driftwood", PackedStringArray(["Liegen lassen"]))
	assert_eq(groups[0].size(), 3)
	assert_string_contains(groups[0][0], "Einstecken")
	assert_eq(groups[0][2], "…", "the silence is last")
	var left := await DialogueWalk.play(FLUT, "driftwood", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "fl_drift_1") and _has(left, "fl_drift_4"))
	assert_false(WorldState.has_item("curiosity_driftwood"))
	assert_false(WorldState.has_flag("forest.driftwood_taken"))
	var silent := await DialogueWalk.play(FLUT, "driftwood", PackedStringArray(["…"]))
	assert_true(_has(silent, "fl_drift_5"))
	assert_eq(_flag_names(), _names([]))
	await DialogueWalk.play(FLUT, "driftwood")
	assert_true(WorldState.has_item("curiosity_driftwood"))
	assert_true(WorldState.has_flag("forest.driftwood_taken"))
	assert_eq(Collection.curiosities(), 1)
	assert_eq(_flag_names(), _names(["forest.driftwood_taken"]))


func test_the_driftwood_is_in_the_game_and_counts() -> void:
	var id := "curiosity_driftwood"
	assert_true(ContentDB.has_item(id))
	assert_eq(tr("CURIOSITY_DRIFTWOOD_NAME"), "Ein Stück Treibholz", "named like the others")
	assert_ne(tr("CURIOSITY_DRIFTWOOD_DESC"), "CURIOSITY_DRIFTWOOD_DESC")
	assert_string_contains(tr("CURIOSITY_DRIFTWOOD_DESC"), "Seitenast")
	assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % id), "the picture")
	var text := _say(["fl_drift_1", "fl_drift_2"])
	for word: String in ["Treibholz", "silbergrau", "Seitenast", "Knoten", "gebrochen"]:
		assert_string_contains(text, word)
	WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 1)


func test_the_stones_are_a_fragment_told_once_and_the_picture_is_there() -> void:
	var seen := await DialogueWalk.play(FLUT, "stones")
	assert_eq(seen.size(), 3)
	for id: String in ["fl_stones_1", "fl_stones_2", "fl_stones_3"]:
		assert_true(_has(seen, id), id)
	assert_true(Collection.has_fragment("stepping_stones"))
	assert_eq(Collection.fragments(), 1)
	assert_eq(_flag_names(), _names(["fragment.stepping_stones"]), "and no other flag")
	assert_true(
		ResourceLoader.exists("res://assets/generated/fragments/fragment_stepping_stones.png"),
		"the picture of the fragment"
	)
	var statements := _statements("stones")
	assert_eq(
		statements[statements.size() - 1], 'do WorldState.set_flag("fragment.stepping_stones")'
	)
	assert_eq(
		await DialogueWalk.play(FLUT, "stones"), PackedStringArray([LineText.of("fl_stones_5")])
	)
	assert_eq(Collection.fragments(), 1, "not counted twice")


func test_the_stones_are_a_trace_of_the_world_and_neither_the_mark_nor_a_person() -> void:
	var text := _say(["fl_stones_1", "fl_stones_2", "fl_stones_3", "fl_stones_5"])
	for word: String in [
		"Steine", "Bach", "Schrittlänge", "hergetragen", "gelegt", "Moos", "tragen noch"
	]:
		assert_string_contains(text, word)
	assert_eq(text.count("Jemand"), 1, "somebody, said once, and nobody else")
	assert_lt(LineText.of("fl_stones_5").split(" ").size(), 12, "the second time one short line")
	for word: String in ["Streifen", "Schnitt", "Schlick", "Marke", "Krone", "Läufer", "Lager"]:
		assert_false(text.contains(word), "'%s' is the mark's, not the stones'" % word)
	for word: String in ["Kind", "Hand", "Name", "Namen", "Stimme"]:
		assert_false(text.contains(word), "'%s' would make it a person" % word)
	assert_eq(WorldState.quest_stage(QUEST), "", "the stones are no quest")
	assert_false(WorldState.has_flag("forest.flood_seen"), "and no step toward the hero's goal")


func test_the_nest_the_fork_and_the_driftwood_say_what_the_pictures_show() -> void:
	var nest := _say(["fl_nest_1"])
	for word: String in ["Nest", "Halmen", "Moos", "grün", "Mulde", "nichts"]:
		assert_string_contains(nest, word)
	var fork := _say(["fl_fork_1"])
	for word: String in ["Ast", "aufrecht", "bemoost", "Gabel", "gespalten"]:
		assert_string_contains(fork, word)
	for word: String in ["Vogel", "Küken", "Feder", "Mutter"]:
		assert_false((nest + fork).contains(word), "'%s': the nest is empty and stays so" % word)


# --- The way on to the south ------------------------------------------------------------------


func test_the_end_of_the_path_says_what_it_shows_and_nothing_more() -> void:
	var seen := await DialogueWalk.play(FLUT, "south_wait")
	assert_eq(seen.size(), 2, "two lines")
	assert_string_contains(seen[0], "Pfad")
	assert_string_contains(seen[0] + seen[1], "Kronen")
	assert_eq(
		(await DialogueWalk.groups(FLUT, "south_wait")).size(), 0, "no answer at a closed way"
	)
	assert_eq(_flag_names(), _names([]))


# --- What it never says ------------------------------------------------------------------------


func test_narration_has_no_colon_question_cry_or_ellipsis_and_no_digit() -> void:
	var checked := 0
	for line: Dictionary in _story_lines():
		if line["answer"] or line["speaker"] != "":
			continue
		var text: String = line["text"]
		checked += 1
		for mark: String in [":", "?", "!", "…"]:
			assert_false(text.contains(mark), "%s in narration: %s" % [mark, text])
		assert_null(RegEx.create_from_string("[0-9]").search(text), "a digit in: %s" % text)
	assert_gt(checked, 40, "every line of narration was read, 43 at the time of writing")


func test_the_only_speaker_is_the_antreiber_and_he_never_cries_or_asks() -> void:
	var spoken := 0
	var speakers := {}
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		var line := raw.strip_edges()
		var hit := RegEx.create_from_string("^([A-ZÄÖÜ][a-zäöüß]{1,20}):\\s").search(line)
		if hit != null:
			speakers[hit.get_string(1)] = true
		if line.begins_with("Antreiber:"):
			spoken += 1
			assert_false(line.contains("!"), "he only cries while he drives: %s" % line)
			assert_false(line.contains("?"), "he asks nothing here: %s" % line)
	assert_eq(speakers.keys(), ["Antreiber"], "no other voice in the clearing")
	assert_gte(spoken, 3, "all his lines were read")


func test_none_of_his_lines_comes_out_of_the_dialogue_with_another_voice_or_a_cry() -> void:
	# the same through the dialogue manager: every cue, every answer
	var resource := load(FLUT) as DialogueResource
	var spoken := 0
	for title: String in resource.get_cues():
		WorldState.new_game()
		WorldState.set_facet("care")
		var open: Array[String] = [title]
		var visited := {}
		var guard := 0
		while not open.is_empty() and guard < 60:
			guard += 1
			var next_id: String = open.pop_back()
			if visited.has(next_id):
				continue
			visited[next_id] = true
			var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, next_id)
			if line == null:
				continue
			if line.character != "":
				spoken += 1
				assert_eq(line.character, "Antreiber")
				assert_false(line.text.contains("!"), "a cry: %s" % line.text)
			if line.responses.is_empty():
				open.append(line.next_id)
			for response: DialogueResponse in line.responses:
				if response.is_allowed:
					open.append(response.next_id)
	assert_gte(spoken, 3, "his lines were reached")


func test_his_lines_are_short_and_name_neither_water_nor_people_nor_her() -> void:
	var lines := 0
	var words := 0
	var forbidden := [
		"Wasser",
		"Flut",
		"Bach",
		"Fluss",
		"Mensch",
		"Leute",
		"jemand",
		"niemand",
		"Grund",
		"Gründe",
	]
	for line: Dictionary in _story_lines():
		if line["speaker"] != "Antreiber":
			continue
		var text: String = line["text"]
		lines += 1
		words += text.split(" ", false).size()
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in his line: %s" % [word, text])
		var about_her := RegEx.create_from_string("(?i)\\b(du|dich|dir|dein\\w*|ihr|euch)\\b")
		assert_null(about_her.search(text), "he says nothing about her: %s" % text)
		assert_lte(text.split(" ", false).size(), 8, "short: %s" % text)
	assert_gte(lines, 3, "his lines were read")
	assert_lt(float(words) / lines, 7.0, "fewer than seven words a line on average")


func test_every_group_has_an_unconditional_answer_and_the_silence_last() -> void:
	# a static scan: every group of the file (ContentValidator checks that no choice is a fake one)
	var groups := 0
	for cue: String in (load(FLUT) as DialogueResource).get_cues():
		var answers: Array[String] = []
		for raw in _cue_raw(cue):
			if raw.begins_with("- "):
				answers.append(raw)
		if answers.is_empty():
			continue
		groups += 1
		assert_true(answers[answers.size() - 1].begins_with("- … [ID:"), "%s: silence last" % cue)
		var plain := 0
		for answer in answers:
			if not answer.contains("[if ") and not answer.begins_with("- … [ID:"):
				plain += 1
		assert_gte(plain, 1, "%s: an answer that is always there besides the silence" % cue)
	assert_gte(groups, 5, "all five groups were read")
	# and as the player meets them
	for cue: String in ["antreiber_flood_again", "fork_nest", "driftwood", "nest"]:
		var found := await DialogueWalk.groups(FLUT, cue)
		assert_gte(found.size(), 1, cue)
		assert_gte(found[0].size(), 2, cue)
		assert_eq(found[0][found[0].size() - 1], "…", "%s: the silence is last" % cue)


func test_the_care_answer_is_the_only_conditional_one_and_has_a_facet_to_name() -> void:
	var conditional: Array[String] = []
	for raw in FileAccess.get_file_as_string(FLUT).split("\n"):
		if raw.begins_with("- ") and raw.contains("[if "):
			conditional.append(raw)
	assert_eq(conditional.size(), 1, "tea is the only answer that can be missing")
	assert_true(conditional[0].contains('has_facet("care")'))
	assert_true(conditional[0].contains('not WorldState.has_flag("forest.flood_sat")'))


func test_every_effect_stands_after_the_lines_of_its_branch() -> void:
	# what is set stands at the end of the lines; the quest of `nest` is started before its lines on
	# purpose (the first look is what starts it) and is checked on its own
	var effects := 0
	var raws := FileAccess.get_file_as_string(FLUT).split("\n")
	for index in raws.size():
		var raw := raws[index]
		var statement := raw.strip_edges()
		if not statement.begins_with("do WorldState.") or statement.contains("start_quest"):
			continue
		effects += 1
		var depth := raw.length() - raw.lstrip("\t").length()
		var at := index + 1
		while at < raws.size() and (raws[at].strip_edges().is_empty() or raws[at].begins_with("#")):
			at += 1
		assert_lt(at, raws.size(), "an effect is never the last line of the file")
		var next := raws[at]
		var next_depth := next.length() - next.lstrip("\t").length()
		var is_story := next.contains("[ID:") and not next.strip_edges().begins_with("- ")
		assert_false(is_story and next_depth >= depth, "a line follows the effect: %s" % statement)
	assert_eq(effects, 10, "all ten effects were checked")


func test_the_second_telling_of_a_thing_is_one_short_line() -> void:
	for id: String in ["fl_mark_6", "fl_stones_5", "fl_fork_5"]:
		assert_lte(LineText.of(id).split(" ", false).size(), 12, id)


func test_nothing_says_why_and_nothing_names_a_child_a_cause_or_a_memory() -> void:
	var forbidden := [
		"Kind",
		"Mutter",
		"Vater",
		"Familie",
		"Mama",
		"Papa",
		"Zuhause",
		"Heim",
		"ertrunken",
		"gestorben",
		"verlor",
		"gerettet",
		"Schuld",
		"schuld",
		"Angst",
		"Unfall",
		"Regen",
		"Sturm",
		"Gewitter",
		"Summen",
		"Lied",
		"Meer",
		"Muschel",
		"Erinnerung",
		"erinner",
		"Abschied",
		"vermiss",
		"Gefahr",
		"sicher",
		"Schutz",
		"gesund",
		"einsam",
		"verletz",
		"Fürsorge",
		"achtsam",
		"Punkte",
		"Prozent",
		"Level",
		"Therap",
		"Diagnos",
		"Trauma",
	]
	var words := RegEx.create_from_string(
		"(?i)\\b(weil|deshalb|seitdem|damals|darum|deswegen|daher|denn|tot|tote|totes|tod)\\b"
	)
	var texts := _all_texts()
	assert_gt(texts.size(), 64, "every line, answer, journal row and item text was collected")
	for text: String in texts:
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])
		assert_null(words.search(text), "a reason is given in: %s" % text)


func test_no_line_says_a_phrase_the_earlier_segments_have_used_up() -> void:
	var texts := _all_texts()
	assert_gt(texts.size(), 64)
	for text: String in texts:
		for phrase: String in USED_UP:
			assert_false(text.contains(phrase), "'%s' is used up, in: %s" % [phrase, text])


func test_he_is_shown_by_his_feet_and_the_feet_are_the_new_gesture() -> void:
	var feet := 0
	for line: Dictionary in _story_lines():
		if line["text"].contains("Füße"):
			feet += 1
	assert_eq(feet, 4, "on the spot, still, going on, still again: four lines and no more")
	assert_string_contains(LineText.of("fl_antr_3"), "auf den Ballen")
	assert_string_contains(LineText.of("fl_trail_1"), "Ballen", "the prints are on the balls too")
	for id: String in ["fl_antr_3", "fl_ask_3", "fl_ask_5", "fl_again_1"]:
		assert_string_contains(LineText.of(id), "Füße")
	assert_false(
		_say(["fl_antr_3", "fl_ask_3", "fl_ask_5", "fl_again_1"]).contains("merkt"),
		"it is seen and never said what he notices"
	)


func test_the_things_say_nothing_about_him_and_nothing_follows_the_heavy_one_as_a_joke() -> void:
	# the trail, the camp and the mark are told without the Antreiber; the camp's stroke is his
	# hand and the narrator never says so
	var things := _say(
		[
			"fl_trail_1",
			"fl_trail_2",
			"fl_trail_3",
			"fl_trail_4",
			"fl_camp_1",
			"fl_camp_2",
			"fl_camp_3",
			"fl_camp_4",
			"fl_mark_1",
			"fl_mark_2",
			"fl_mark_3",
			"fl_mark_4",
			"fl_mark_5",
			"fl_mark_6",
		]
	)
	for word: String in ["Antreiber", "sein", "seine", "Bretter", "Weg zum"]:
		assert_false(things.contains(word), "'%s' would explain whose it is" % word)
	assert_eq(things.count("Brett"), 1, "only the missing board of the mark, said by its absence")
	var seen := await DialogueWalk.play(FLUT, "flood_mark")
	assert_eq(seen[seen.size() - 1], LineText.of("fl_mark_5"), "the heavy line is the last one")
