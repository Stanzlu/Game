extends GutTest
## Act II, segment B5: Feuer. After Mira has gone there is one small thing left to do by the fire:
## three deeds and a silence, each its own value (Game Bible §18). The answer sets only its own
## value.<id> flag; the room shows it later in a place that is not the answer itself, and the
## silence sets nothing. The song in the house is the one melody of Act II (no fragment), the herbs
## under the beam the third fragment (a trace of the world, no child). The scene (the door, the
## stool, the evening, the beats) is tested in test_akt2_feuer_szene.

const FEUER := "res://content/dialogue/akt2/feuer.dialogue"
const HAUS := "res://content/dialogue/slice/haus.dialogue"
const BACH := "res://content/dialogue/akt2/bachlauf.dialogue"
## The four answers of the choice by the fire, each with the flag it sets ("" for the silence).
const DEEDS: Array = [
	["Spalt", "value.freedom"],
	["Hocker", "value.closeness"],
	["zusehen", "value.calm"],
	["…", ""],
]
## The lines the room answers with: the cue, the line, the flag that shows it (and the fire).
const READERS: Array = [
	["fireplace", "haus_fire_10", "value.freedom"],
	["table", "haus_table_5", "value.closeness"],
	["bucket", "haus_bucket_3", "value.calm"],
]
const OWN_LINES: PackedStringArray = [
	"haus_fire_10",
	"haus_table_5",
	"haus_bucket_3",
	"haus_herbs_1",
	"haus_herbs_2",
	"haus_herbs_3",
	"haus_herbs_4",
	"haus_herbs_5",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _values() -> PackedStringArray:
	var found: PackedStringArray = []
	for flag: String in WorldState.state.flags:
		if flag.begins_with("value."):
			found.append(flag)
	return found


## Every line of the file by its ID (answers included) and the lines the house gained, by their ID.
func _all_texts() -> PackedStringArray:
	var source := FileAccess.get_file_as_string(FEUER)
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(feu_[a-z0-9_]+)\\]").search_all(source):
		found.append(LineText.of(hit.get_string(1)))
	for id: String in OWN_LINES:
		found.append(LineText.of(id))
	return found


# --- The choice ------------------------------------------------------------------------------


func test_the_choice_has_four_answers_and_the_silence_is_the_last() -> void:
	var answers := await DialogueWalk.answers(FEUER, "fire_values")
	assert_eq(answers.size(), 4)
	for i in DEEDS.size():
		assert_true(str(DEEDS[i][0]) in answers[i], "answer %d: %s" % [i, DEEDS[i][0]])
	assert_eq(answers[3], "…")


func test_the_answers_are_the_same_whatever_has_happened() -> void:
	# no facet and no earlier value changes what can be answered: a choice nobody is held out of
	var before := await DialogueWalk.answers(FEUER, "fire_values")
	WorldState.set_facet("boundaries")
	WorldState.set_flag("value.calm")
	WorldState.set_flag("house.antreiber_refused")
	assert_eq(await DialogueWalk.answers(FEUER, "fire_values"), before)


func test_each_answer_sets_its_own_value_and_nothing_else() -> void:
	for deed: Array in DEEDS:
		WorldState.new_game()
		await DialogueWalk.play(FEUER, "fire_values", PackedStringArray([deed[0]]))
		var expected := PackedStringArray([deed[1]]) if deed[1] != "" else PackedStringArray()
		assert_eq(_values(), expected, "after: %s" % deed[0])


func test_each_answer_has_a_different_consequence_in_the_room() -> void:
	var seen_lines := {}
	for deed: Array in DEEDS:
		WorldState.new_game()
		var seen := await DialogueWalk.play(FEUER, "fire_values", PackedStringArray([deed[0]]))
		assert_true(seen.size() >= 3, "the question and what happens")
		for text: String in seen.slice(2):
			assert_false(seen_lines.has(text), "no two answers say the same: %s" % text)
			seen_lines[text] = true


func test_the_silence_says_only_that_nothing_was_done() -> void:
	var seen := await DialogueWalk.play(FEUER, "fire_values", PackedStringArray(["…"]))
	assert_eq(seen.size(), 3, "the two lines of the question and one of its own")
	assert_true(_has(seen, "feu_9"))
	assert_true(_values().is_empty())


# --- What the room says afterwards --------------------------------------------------------------


func test_every_value_shows_in_a_place_of_its_own_and_only_with_it() -> void:
	WorldState.set_fire_lit(true)
	for reader: Array in READERS:
		assert_false(
			_has(await DialogueWalk.play(HAUS, reader[0]), reader[1]), "%s before" % reader[1]
		)
		WorldState.set_flag(reader[2])
		assert_true(
			_has(await DialogueWalk.play(HAUS, reader[0]), reader[1]),
			"%s with %s" % [reader[1], reader[2]]
		)
		WorldState.new_game()
		WorldState.set_fire_lit(true)


func test_the_values_do_not_replace_each_other() -> void:
	# all three at once: every place of the house shows its own line, none takes another's
	WorldState.set_fire_lit(true)
	for reader: Array in READERS:
		WorldState.set_flag(reader[2])
	for reader: Array in READERS:
		assert_true(_has(await DialogueWalk.play(HAUS, reader[0]), reader[1]), reader[1])
	assert_eq(_values().size(), 3)


func test_the_fire_shows_the_draught_only_while_it_burns() -> void:
	# the line belongs to a burning fire; a cold hearth keeps its old text
	WorldState.set_flag("value.freedom")
	assert_false(_has(await DialogueWalk.play(HAUS, "fireplace"), "haus_fire_10"))


func test_the_choice_reads_nothing_and_holds_no_line_of_the_room() -> void:
	# the room answers somewhere else than the choice, and the choice's own cue sets and reads nothing
	var source := FileAccess.get_file_as_string(FEUER)
	assert_false(source.contains('has_flag("value.'), "the choice reads no value")
	for reader: Array in READERS:
		assert_false(source.contains(reader[1]), "%s is not in the choice's cue" % reader[1])


# --- The song and the herbs ------------------------------------------------------------------


func test_the_song_is_a_melody_and_no_fragment() -> void:
	var seen := await DialogueWalk.play(FEUER, "house_hum")
	assert_true(_has(seen, "feu_hum_1") and _has(seen, "feu_hum_2"))
	assert_true(Collection.has_melody("house_hum"))
	assert_eq(Collection.melodies(), 1)
	assert_eq(Collection.fragments(), 0, "Act II's melody has no picture of its own")


func test_the_song_has_a_sound_and_a_caption() -> void:
	var stream := SoundBank.stream("house_hum") as AudioStreamRandomizer
	assert_not_null(stream, "house_hum is in the bank")
	assert_gt(stream.streams_count, 0)
	assert_eq(AudioDirectorService.CAPTIONS["house_hum"], "CAPTION_HUM")
	assert_ne(tr("CAPTION_HUM"), "CAPTION_HUM")


func test_the_herbs_are_the_third_fragment_told_once() -> void:
	var seen := await DialogueWalk.play(HAUS, "herbs")
	for id: String in ["haus_herbs_1", "haus_herbs_2", "haus_herbs_3", "haus_herbs_4"]:
		assert_true(_has(seen, id), id)
	assert_true(Collection.has_fragment("beam_herbs"))
	assert_eq(
		await DialogueWalk.play(HAUS, "herbs"), PackedStringArray([LineText.of("haus_herbs_5")])
	)
	assert_eq(Collection.fragments(), 1)


func test_act_two_has_three_fragments_and_three_pictures() -> void:
	await DialogueWalk.play(BACH, "table")
	await DialogueWalk.play(BACH, "dry_bed")
	await DialogueWalk.play(HAUS, "herbs")
	assert_eq(Collection.fragments(), 3)
	for picture: String in ["bank_table", "dry_bed", "beam_herbs"]:
		assert_true(
			ResourceLoader.exists("res://assets/generated/fragments/fragment_%s.png" % picture),
			picture
		)


# --- What it never says ----------------------------------------------------------------------


func test_it_is_all_narration_with_no_question_or_cry() -> void:
	var resource := load(FEUER) as DialogueResource
	for title: String in resource.get_cues():
		var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, title)
		while line != null:
			assert_eq(line.character, "", "narration: %s" % line.text)
			var next_id := line.next_id
			if not line.responses.is_empty():
				next_id = line.responses[0].next_id
			line = await DialogueManager.get_next_dialogue_line(resource, next_id)
	var texts := _all_texts()
	assert_gt(texts.size(), 17, "every line and answer was read")
	for text: String in texts:
		for mark: String in ["?", "!"]:
			assert_false(text.contains(mark), "%s in: %s" % [mark, text])
		if text != "…":
			assert_false(text.contains("…"), "an ellipsis in: %s" % text)


func test_no_line_names_a_value_a_child_or_a_reason() -> void:
	# the deed is shown, never named: no value word, no judgement, no child, no cause (Brief O3/O5)
	var forbidden := [
		"Freiheit",
		"Nähe",
		"Ruhe",
		"Mut",
		"Familie",
		"Sicherheit",
		"Vertrauen",
		"wichtig",
		"richtig",
		"falsch",
		"Wert",
		"Kind",
		"Erinnerung",
		"erinner",
		"Zuhause",
		"Mutter",
		"Vater",
		"Abschied",
		"verlassen",
		"vermiss",
	]
	for text: String in _all_texts():
		for word: String in forbidden:
			assert_false(text.contains(word), "'%s' in: %s" % [word, text])


func test_nothing_here_writes_a_memory_of_mira() -> void:
	# her four remaining variants are for the evening (B6): the choice itself tells her nothing yet
	assert_false(FileAccess.get_file_as_string(FEUER).contains("add_memory"))
