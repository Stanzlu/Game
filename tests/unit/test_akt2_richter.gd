extends GutTest
## Act II, segment B4: Richter. After the second fall into the stream a voice speaks, once: dry,
## in the tone of a file, about things (a stone, a stream, a request for quiet) and never about
## the player (Game Bible §51, brief O2). It has no answer, sets no flag and the world has the last
## word. The scene (when it speaks and when it never does) is tested in test_akt2_richter_szene.

const RICHTER := "res://content/dialogue/akt2/richter.dialogue"
const CUE := "judge"
const VOICES := "res://content/dialogue/voices.json"
const NARRATION: PackedStringArray = ["ric_1", "ric_8"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for i in range(1, 9):
		found.append("ric_%d" % i)
	return found


func _id_of(text: String) -> String:
	for id: String in _ids():
		if LineText.of(id) == text:
			return id
	return ""


func test_the_voice_says_its_eight_lines_in_order_and_ends_on_the_world() -> void:
	var seen := await DialogueWalk.play(RICHTER, CUE)
	var expected: PackedStringArray = []
	for id: String in _ids():
		expected.append(LineText.of(id))
	assert_eq(seen, expected)
	assert_true(LineText.of("ric_8") in seen and seen[seen.size() - 1] == LineText.of("ric_8"))


func test_only_the_voice_speaks_and_it_is_called_a_voice_until_act_four() -> void:
	var resource := load(RICHTER) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, CUE)
	var count := 0
	while line != null:
		var id := _id_of(line.text)
		var expected := "" if id in NARRATION else "Stimme"
		assert_eq(line.character, expected, "who says %s" % id)
		count += 1
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	assert_eq(count, 8)
	var voices: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(VOICES))
	assert_eq(voices.get("Stimme"), "neutral", "a voice with a voice kind")
	assert_false(voices.has("Richter"), "he gets his name in Act IV")


func test_it_asks_nothing_and_changes_nothing() -> void:
	WorldState.set_flag("valley.fell_in")
	WorldState.set_flag("valley.fell_twice")
	var state_before := WorldState.state.to_dict()
	var groups := await DialogueWalk.groups(RICHTER, CUE)
	assert_true(groups.is_empty(), "no choice: nothing to answer a voice with")
	await DialogueWalk.play(RICHTER, CUE)
	assert_eq(WorldState.state.to_dict(), state_before, "nothing changes: no flag, memory, item")
	# and no line of the file can: it has no code at all, only the cue and its lines
	for line in FileAccess.get_file_as_string(RICHTER).split("\n"):
		var text := line.strip_edges()
		assert_false(text.begins_with("do ") or text.begins_with("set "), "no effect: %s" % text)
		assert_false(text.contains("WorldState"), "no state: %s" % text)


func test_no_line_has_a_question_a_cry_an_ellipsis_a_digit_or_in_narration_a_colon() -> void:
	for id: String in _ids():
		var text := LineText.of(id)
		assert_ne(text, "", "%s exists" % id)
		for mark: String in ["?", "!", "…"]:
			assert_false(text.contains(mark), "%s in %s" % [mark, id])
		for digit: String in "0123456789":
			assert_false(text.contains(digit), "%s in %s" % [digit, id])
		if id in NARRATION:
			assert_false(text.contains(":"), "no colon in the narration %s" % id)


## The words of a line, lower case, with everything that is not a letter taken out.
func _words(text: String) -> PackedStringArray:
	var letters := RegEx.create_from_string("[^a-zäöüß]+")
	return letters.sub(text.to_lower(), " ", true).split(" ", false)


func test_the_voice_speaks_of_things_and_never_of_the_player() -> void:
	# §51: it shames the act of a stone, not the player; no address, no verdict, no count of falls
	var as_words := ["du", "dich", "dir", "ihr", "euch", "sie", "ihnen", "man", "wir", "uns"]
	var by_start := [
		"dein",
		"angeklagt",
		"spielerin",
		"zweit",
		"wieder",
		"wiederum",
		"erneut",
		"schon",
		"immer",
		"nie",
		"fehler",
		"peinlich",
		"versag",
		"schuld",
		"urteil",
		"straf",
		"wert",
		"gestolper",
		"gefallen",
		"person",
		"zeug",
		"beteiligte",
	]
	for id: String in _ids():
		for word in _words(LineText.of(id)):
			assert_false(word in as_words, "'%s' in %s" % [word, id])
			for stem: String in by_start:
				assert_false(word.begins_with(stem), "'%s' in %s" % [word, id])


func test_the_guard_would_catch_what_it_guards_against() -> void:
	# the word lists see inflected and punctuated forms, not only the bare stem
	var words := _words("Deine Angaben, „Du“; beim zweiten Mal wird bestraft. Wertlos! Niemals.")
	var starts := ["dein", "zweit", "wert", "nie"]
	var hits := 0
	for word in words:
		for stem: String in starts:
			if word.begins_with(stem):
				hits += 1
	assert_eq(hits, 4)
	assert_true("du" in words and "bestraft" in words)


func test_it_repeats_nothing_of_the_falls_and_borrows_nothing_from_mira_or_the_child() -> void:
	# the second fall already has its own joke (tal_fell_3/4): the voice has its own, on other things
	var forbidden := [
		"nass",
		"kalt",
		"hüfte",
		"kennt",
		"wärmer",
		"flach",
		"gerührt",
		"schaukel",
		"mira",
		"stiefel",
		"moos",
		"netz",
		"plane",
		"brücke",
		"brett",
		"feuer",
		"fisch",
		"ziege",
		"nein",
		"kind",
		"erinner",
		"zuhause",
		"heim",
		"meer",
		"elysia",
	]
	for id: String in _ids():
		var text := LineText.of(id).to_lower()
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in %s" % [word, id])


func test_it_is_short_and_the_world_has_the_last_word() -> void:
	var total := 0
	for id: String in _ids():
		var words := LineText.of(id).split(" ", false).size()
		assert_lt(words, 12, "%s is short" % id)
		total += words
	assert_lt(total, 80, "a few seconds of a voice, not a speech")
	var resource := load(RICHTER) as DialogueResource
	var last: DialogueLine = null
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, CUE)
	while line != null:
		last = line
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	assert_eq(last.character, "", "and the last line is the stream's, not the voice's")
