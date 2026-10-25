extends GutTest
## Act II, segment B6: Abend. At Mira's fire she reads what carried across the water, not the
## values (Game Bible §18): the door that went ajar (the eye), the window that stayed lit (the eye
## over time), a knock in the house (the ear), and for the silence, and for every game without a
## value, her view of the smoke. One reading per evening, no answers, no judgement. The scene (the
## real ending with the new lines, the chapter mark) is tested in test_akt2_abend_szene.

const TAL := "res://content/dialogue/slice/tal.dialogue"
const CUE := "evening_values"
const FIRST := "tal_eve_val_1"
const LAST := "tal_eve_val_13"
## The reading of each value: the flag, its lines, the memory it leaves.
const READINGS: Array = [
	["value.freedom", ["tal_eve_val_2", "tal_eve_val_3", "tal_eve_val_4"], "saw_door_ajar"],
	[
		"value.calm",
		["tal_eve_val_5", "tal_eve_val_6", "tal_eve_val_7", "tal_eve_val_8"],
		"checked_house"
	],
	["value.closeness", ["tal_eve_val_9", "tal_eve_val_10", "tal_eve_val_11"], "heard_furniture"],
]
const SILENCE: PackedStringArray = ["tal_eve_val_12"]
const MEMORIES: PackedStringArray = ["saw_door_ajar", "checked_house", "heard_furniture"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _ids(from: int, to: int) -> PackedStringArray:
	var found: PackedStringArray = []
	for i in range(from, to + 1):
		found.append("tal_eve_val_%d" % i)
	return found


func _remembered() -> PackedStringArray:
	var found: PackedStringArray = []
	for memory: String in MEMORIES:
		if WorldState.has_memory("mira", memory):
			found.append(memory)
	return found


## Every ID of the reading, in order: the cue is the only place they live.
func _all_ids() -> PackedStringArray:
	return _ids(1, 13)


# --- The four readings -----------------------------------------------------------------------


func test_each_value_is_read_in_its_own_way_and_leaves_one_memory() -> void:
	for reading: Array in READINGS:
		WorldState.new_game()
		WorldState.set_flag(reading[0])
		var seen := await DialogueWalk.play(TAL, CUE)
		var expected: PackedStringArray = PackedStringArray([FIRST])
		expected.append_array(reading[1])
		expected.append(LAST)
		var shown: PackedStringArray = []
		for id: String in _all_ids():
			if _has(seen, id):
				shown.append(id)
		assert_eq(shown, expected, "the reading of %s" % reading[0])
		assert_eq(_remembered(), PackedStringArray([reading[2]]), "and what Mira keeps of it")


func test_the_silence_and_a_game_without_values_get_the_smoke() -> void:
	var seen := await DialogueWalk.play(TAL, CUE)
	var shown: PackedStringArray = []
	for id: String in _all_ids():
		if _has(seen, id):
			shown.append(id)
	var expected := PackedStringArray([FIRST])
	expected.append_array(SILENCE)
	expected.append(LAST)
	assert_eq(shown, expected)
	assert_true(_remembered().is_empty(), "nothing is remembered of a silence")


func test_a_saved_game_with_two_or_three_values_still_gets_one_reading() -> void:
	# the choice sets one value; a replay or a later act could set more: door, then window, then knock
	for flags: Array in [
		["value.closeness", "value.calm"],
		["value.freedom", "value.closeness"],
		["value.freedom", "value.calm", "value.closeness"]
	]:
		WorldState.new_game()
		for flag: String in flags:
			WorldState.set_flag(flag)
		var seen := await DialogueWalk.play(TAL, CUE)
		var readings := 0
		for reading: Array in READINGS:
			if _has(seen, reading[1][0]):
				readings += 1
		assert_eq(readings, 1, "one reading for %s" % str(flags))
		assert_eq(_remembered().size(), 1, "and one memory")
	WorldState.new_game()
	WorldState.set_flag("value.calm")
	WorldState.set_flag("value.closeness")
	assert_true(
		_has(await DialogueWalk.play(TAL, CUE), "tal_eve_val_5"), "the window before the knock"
	)


func test_the_reading_asks_nothing_and_offers_no_answer() -> void:
	for flags: Array in [[], ["value.freedom"], ["value.calm"], ["value.closeness"]]:
		WorldState.new_game()
		for flag: String in flags:
			WorldState.set_flag(flag)
		var groups := await DialogueWalk.groups(TAL, CUE)
		assert_true(groups.is_empty(), "no choice here for %s" % str(flags))


func test_it_comes_after_her_question_and_before_the_log_and_the_goodbye() -> void:
	var seen := await DialogueWalk.play(TAL, "ending")
	var day := seen.find(LineText.of("tal_eve_day_1"))
	var first := seen.find(LineText.of(FIRST))
	var log_breaks := seen.find(LineText.of("tal_end_11"))
	var goodbye := seen.find(LineText.of("tal_end_2"))
	assert_true(day >= 0 and first > day, "after she asked for a story")
	assert_gt(log_breaks, first, "before the log breaks in the glow")
	assert_gt(goodbye, log_breaks, "and before 'Morgen gehe ich weiter.'")
	assert_true(_has(seen, LAST), "and it ends in the net")


# --- What it never says ----------------------------------------------------------------------


func test_the_narration_is_narration_and_mira_speaks_in_her_own_lines() -> void:
	var resource := load(TAL) as DialogueResource
	var narration := PackedStringArray(["tal_eve_val_1", "tal_eve_val_5", "tal_eve_val_9", LAST])
	for flags: Array in [[], ["value.freedom"], ["value.calm"], ["value.closeness"]]:
		WorldState.new_game()
		for flag: String in flags:
			WorldState.set_flag(flag)
		var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, CUE)
		while line != null:
			var by_mira := line.character == "Mira"
			var id := _id_of(line.text)
			assert_eq(by_mira, id not in narration, "who says %s" % id)
			assert_true(line.character in ["", "Mira"], line.text)
			line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)


func _id_of(text: String) -> String:
	for id: String in _all_ids():
		if LineText.of(id) == text:
			return id
	return ""


func test_no_line_has_a_question_a_cry_an_ellipsis_a_digit_or_a_colon_in_it() -> void:
	for id: String in _all_ids():
		var text := LineText.of(id)
		assert_ne(text, "", "%s exists" % id)
		for mark: String in ["?", "!", "…", ":"]:
			assert_false(text.contains(mark), "%s in %s" % [mark, id])
		for digit: String in "0123456789":
			assert_false(text.contains(digit), "%s in %s" % [digit, id])


func test_no_line_names_a_value_judges_comforts_or_asks_for_a_reason() -> void:
	# the reading shows traces, never the value, and Mira is neither mentor nor comfort (STIL, mira.md)
	var forbidden := [
		"Freiheit",
		"Nähe",
		"Ruhe",
		"Mut",
		"Familie",
		"Sicherheit",
		"Vertrauen",
		"Wert",
		"Hocker",
		"offen",
		"frei",
		"nah",
		"ruhig",
		"still",
		"dunkel",
		"allein",
		"zusammen",
		"sicher",
		"sorg",
		"gut",
		"schön",
		"klug",
		"mutig",
		"endlich",
		"immer noch",
		"warum",
		"wieso",
		"wofür",
		"fühl",
		"brauch",
		"Kind",
		"Erinnerung",
		"Abschied",
		"verlassen",
		"vermiss",
	]
	for id: String in _all_ids():
		for word: String in forbidden:
			assert_false(LineText.of(id).contains(word), "'%s' in %s" % [word, id])


func test_mira_keeps_her_short_sentences() -> void:
	# Ø 7,2 words in her sheet, never a speech: no line of hers longer than ten words
	for id: String in _all_ids():
		var text := LineText.of(id)
		var words := text.split(" ", false).size()
		assert_lt(words, 21, "%s is short" % id)
	for id: String in ["tal_eve_val_2", "tal_eve_val_3", "tal_eve_val_4", "tal_eve_val_6"]:
		assert_lt(LineText.of(id).split(" ", false).size(), 11, id)


# --- The journal and the budget ------------------------------------------------------------------


func test_the_three_memories_have_a_sentence_in_the_journal() -> void:
	for memory: String in MEMORIES:
		var key := "MEMORY_MIRA_" + memory.to_upper()
		assert_ne(tr(key), key, "%s has a sentence" % key)
		for digit: String in "0123456789":
			assert_false(tr(key).contains(digit), "no digit in %s" % key)


func test_act_two_stays_within_its_six_new_memories_of_mira() -> void:
	# B2 used kept_origin and kept_day, B6 uses three: one of the six is left for the acts after
	var used := PackedStringArray(["kept_origin", "kept_day"])
	used.append_array(MEMORIES)
	assert_lt(used.size(), 6, "one left")
	var source := FileAccess.get_file_as_string(TAL)
	var cue_from := source.find("~ " + CUE)
	var cue_to := source.find("~ evening_elysia")
	var cue := source.substr(cue_from, cue_to - cue_from)
	assert_eq(cue.count("add_memory"), 3, "three, one for each reading")
	assert_false(cue.contains("set_flag"), "and no new flag: the values are read, never set")
