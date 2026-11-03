extends GutTest
## Act V, segment G2: the high valley (docs/akt5/REGIONSBRIEFE.md). Things to look at in a valley
## between walls: a sign, the print of a hand on a stone at the tarn (the first flashback, a picture
## of the child, four lines and nothing more), a stone that will not stay on three cairns, a crystal
## and a marmot's hoard to take or leave, the gate of the Anlage and the way up to the ridge (both
## closed). Nobody speaks. The map and the scene are tested in test_akt5_hochtal_szene.

const FILE := "res://content/dialogue/akt5/hochtal.dialogue"
const STONE_QUEST := "side_grat_stone"
const CUES: PackedStringArray = [
	"valley_sign",
	"hand_stone",
	"stone_pick",
	"cairn_1",
	"cairn_1_offer",
	"cairn_1_try",
	"cairn_2",
	"cairn_2_offer",
	"cairn_2_try",
	"cairn_3",
	"cairn_3_offer",
	"cairn_3_try",
	"quartz",
	"marmot_den",
	"plant_gate",
	"ramp_wait",
]
const STONE := "item_restless_stone"
const QUARTZ := "curiosity_quartz"
const THIMBLE := "curiosity_thimble"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(hoch_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += line.substr(0, at) + "\n"
	return spoken


## The lines of one cue as the file has them (code and answers included).
func _block(cue: String) -> String:
	var text := ""
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside:
			text += line + "\n"
	return text


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	var unique := {}
	var answers := 0
	for id in ids:
		unique[id] = true
		if RegEx.create_from_string("_r[0-9]+$").search(id) != null:
			answers += 1
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# the segment plans 30 lines (plus or minus six) and the answers on top
	assert_lte(ids.size() - answers, 36, "the lines of the segment")
	assert_gte(ids.size() - answers, 24, "and not a valley without things")


func test_nobody_speaks_and_every_line_is_told_without_a_number() -> void:
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with("-"):
			continue
		assert_false(text.contains(": "), "narration has no speaker: " + text)
	for digit: String in "0123456789":
		assert_false(_spoken().contains(digit), "no number in the text: " + digit)


func test_every_cue_that_only_looks_can_be_read_again_and_sets_nothing() -> void:
	for cue: String in ["valley_sign", "cairn_1", "cairn_2", "cairn_3", "plant_gate", "ramp_wait"]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, "%s: two lines at least" % cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)
		var asked := await DialogueWalk.answers(FILE, cue)
		assert_eq(asked.size(), 0, "%s asks nothing" % cue)


# --- The hand ---------------------------------------------------------------------------------


func test_the_hand_is_a_picture_of_four_lines_and_a_fragment_the_first_time() -> void:
	var first := await DialogueWalk.play(FILE, "hand_stone")
	assert_eq(first.size(), 4, "four lines and nothing more (O7)")
	for n in range(1, 5):
		assert_true(_has(first, "hoch_hand_%d" % n))
	assert_true(Collection.has_fragment("hand"))
	assert_eq(Collection.fragments(), 1)
	var again := await DialogueWalk.play(FILE, "hand_stone")
	assert_eq(again.size(), 1, "a short line the second time")
	assert_true(_has(again, "hoch_hand_5"))
	assert_eq(Collection.fragments(), 1, "once")


func test_the_hand_has_no_child_no_grown_up_no_cause_and_no_word_for_a_feeling() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "hand_stone"))
	for word: String in [
		"Kind",
		"Mutter",
		"Vater",
		"Eltern",
		"Mama",
		"Papa",
		"Erwachsene",
		"Hände",
		"weil",
		"damals",
		"Angst",
		"traurig",
		"Schmerz",
		"Liebe",
		"erinner",
		"!",
	]:
		assert_false(told.contains(word), "the print is a print, no %s" % word)
	assert_true(told.contains("Hand"))
	assert_true(told.contains("Wasser"), "water instead of dust")


func test_the_hand_is_a_fragment_with_a_picture_and_never_a_requirement() -> void:
	assert_true(ResourceLoader.exists("res://assets/generated/fragments/fragment_hand.png"))
	assert_eq(_block("hand_stone").count("advance_quest"), 0, "no stage hangs on it")
	assert_false(
		_source().contains("main_mountain_way"), "the valley's text never touches the walk"
	)


# --- The stone that does not stay -----------------------------------------------------------------


func test_the_stone_can_be_taken_or_left_and_either_costs_nothing() -> void:
	var answers := await DialogueWalk.answers(FILE, "stone_pick")
	assert_eq(answers.size(), 2, "take it or leave it")
	var left := await DialogueWalk.play(FILE, "stone_pick", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "hoch_stone_1") and _has(left, "hoch_stone_3"))
	assert_false(WorldState.has_item(STONE))
	assert_false(WorldState.has_flag("grat.stone_taken"))
	var taken := await DialogueWalk.play(FILE, "stone_pick", PackedStringArray(["Einstecken"]))
	assert_true(_has(taken, "hoch_stone_2"))
	assert_true(WorldState.has_item(STONE))
	assert_true(WorldState.has_flag("grat.stone_taken"))


func test_a_cairn_offers_the_stone_only_to_whoever_carries_it_and_never_one_answer() -> void:
	for n in range(1, 4):
		var cue := "cairn_%d" % n
		assert_eq((await DialogueWalk.answers(FILE, cue)).size(), 0, "%s: nothing to ask" % cue)
		WorldState.set_flag("grat.stone_taken")
		var answers := await DialogueWalk.answers(FILE, cue)
		assert_eq(answers.size(), 2, "%s: lay it on top or walk on" % cue)
		assert_true("Weitergehen" in answers[1], "the unconditional answer stays the last")
		var before := WorldState.state.flags.duplicate()
		await DialogueWalk.play(FILE, cue, PackedStringArray(["Weitergehen"]))
		assert_eq(WorldState.state.flags, before, "%s: walking on sets nothing" % cue)
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.REAL)


func test_each_try_sets_its_own_flag_before_the_first_line_and_none_sets_another() -> void:
	for n in range(1, 4):
		var cue := "cairn_%d_try" % n
		var block := _block(cue)
		var flag := 'set_flag("grat.stone_try_%d")' % n
		assert_gt(block.find(flag), -1, "%s sets its flag" % cue)
		assert_lt(block.find(flag), block.find("[ID:"), "before the first line: " + cue)
		WorldState.new_game()
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 2, "%s: told in two lines" % cue)
		for other in range(1, 4):
			assert_eq(
				WorldState.has_flag("grat.stone_try_%d" % other),
				other == n,
				"%s: only its own" % cue
			)
	assert_false(_source().contains("advance_quest"), "the scene moves the quest, not the text")


func test_the_three_tries_are_three_different_things_and_the_third_keeps_the_stone() -> void:
	var told := {}
	for n in range(1, 4):
		told[n] = "\n".join(await DialogueWalk.play(FILE, "cairn_%d_try" % n))
	assert_true(told[1].contains("rollt"), "it rolls")
	assert_true(told[2].contains("neigt") or told[2].contains("kippt"), "it tips")
	assert_true(told[3].contains("Wind"), "the wind takes it")
	assert_true(told[3].contains("Tasche"), "and in the end it is in the pocket")
	for key: int in told:
		for word: String in ["gehört", "Lektion", "lernst", "Sinn", "Zuhause", "bleibt nirgends"]:
			assert_false(told[key].contains(word), "no moral from the stone: %s" % word)


func test_the_stone_is_an_item_with_a_picture_and_a_sentence_and_its_quest_has_two_stages() -> void:
	var item := ContentDB.item(STONE)
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.ITEM, "a thing she carries, not a curiosity")
	assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % STONE))
	for key: String in ["ITEM_RESTLESS_STONE_NAME", "ITEM_RESTLESS_STONE_DESC"]:
		assert_ne(tr(key), key, key)
	var quest := ContentDB.quest(STONE_QUEST)
	assert_not_null(quest)
	assert_eq(quest.kind, QuestDef.Kind.SIDE)
	assert_eq(quest.first_stage().id, "carry")
	assert_true(quest.can_advance("carry", "done"))
	assert_true(quest.stage("done").is_final())
	for key: String in [
		"QUEST_SIDE_GRAT_STONE_TITLE", "QUEST_SIDE_GRAT_STONE_CARRY", "QUEST_SIDE_GRAT_STONE_DONE"
	]:
		assert_ne(tr(key), key, key)


# --- The crystal and the hoard -----------------------------------------------------------------


func test_the_crystal_and_the_thimble_can_be_taken_or_left_and_either_costs_nothing() -> void:
	for spec: Array in [
		["quartz", QUARTZ, "grat.quartz_taken"],
		["marmot_den", THIMBLE, "grat.thimble_taken"],
	]:
		var cue: String = spec[0]
		var answers := await DialogueWalk.answers(FILE, cue)
		assert_eq(answers.size(), 2, "%s: take it or leave it" % cue)
		await DialogueWalk.play(FILE, cue, PackedStringArray(["Liegen lassen"]))
		assert_false(WorldState.has_item(spec[1]), "%s: left" % cue)
		assert_false(WorldState.has_flag(spec[2]))
		await DialogueWalk.play(FILE, cue, PackedStringArray([answers[0].substr(0, 8)]))
		assert_true(WorldState.has_item(spec[1]), "%s: taken" % cue)
		assert_true(WorldState.has_flag(spec[2]))


func test_both_are_curiosities_for_the_shelves_with_a_picture_and_a_sentence() -> void:
	for id: String in [QUARTZ, THIMBLE]:
		var item := ContentDB.item(id)
		assert_not_null(item, id)
		assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
		assert_true(item.can_be_placed(), "it can stand on a shelf of the house")
		assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % id))
		for suffix: String in ["_NAME", "_DESC"]:
			var key := id.to_upper() + suffix
			assert_ne(tr(key), key, key)


func test_the_marmot_never_shows_itself() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "marmot_den"))
	assert_true(told.contains("kein Murmeltier"), "a trace, not a creature")
	assert_false(told.contains("pfeift"), "it does not whistle")
	assert_false(told.contains("Fell"), "and has no fur to describe")


# --- The closed places --------------------------------------------------------------------------


func test_the_gate_and_the_way_up_promise_nothing_and_the_gate_has_no_guardian_yet() -> void:
	var gate := "\n".join(await DialogueWalk.play(FILE, "plant_gate"))
	assert_true(gate.contains("tickt"), "a sound as a picture")
	for word: String in ["Wächter", "zähl", "Nummer", "Hebel", "Zahl", "System"]:
		assert_false(gate.contains(word), "the keeper comes in G3: no %s" % word)
	var ramp := "\n".join(await DialogueWalk.play(FILE, "ramp_wait"))
	for word: String in ["Spalte", "Kind", "Haus", "bald", "später"]:
		assert_false(ramp.contains(word), "nothing is promised: no %s" % word)


func test_no_line_gives_the_valley_a_moral_or_a_word_about_how_she_feels() -> void:
	for word: String in [
		"Therapie", "Heilung", "Gefühl", "fühlst", "Trauma", "Sucht", "Kontrolle", "loslassen"
	]:
		assert_false(_spoken().contains(word), "no %s in the valley" % word)
