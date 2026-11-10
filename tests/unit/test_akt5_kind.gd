extends GutTest
## Act V, segment G7: what is said when the grown-up sits down beside the child (docs/akt5/
## REGIONSBRIEFE.md, O8, O10; Bible 15; docs/writing/stimmen/kind.md). The child sits and waits
## (look), the grown-up sits down (seat), frames hang in the air (frames), the answer is given or
## not (answer), the child is gone (gone), and the stone is warm at one end (empty). The child says
## at most three words, mostly nothing, and never answers what was said; nobody is thanked, taught,
## comforted or told why. The scene itself (the frames, the pictures, the flags) is tested in
## test_akt5_kind_szene.

const FILE := "res://content/dialogue/akt5/kind.dialogue"
const CUES: PackedStringArray = [
	"child_look",
	"child_seat",
	"child_hum",
	"child_frames",
	"child_answer",
	"child_return",
	"child_gone",
	"seat_empty",
]
## What the text never says: the cause, the people, the lesson, the contents of the frames, the
## garden (G9 shows it), the house (G8 shows it).
const NEVER: PackedStringArray = [
	"Mama",
	"Papa",
	"Mutter",
	"Vater",
	"damals",
	"früher",
	"weil",
	"Angst",
	"einsam",
	"Einsamkeit",
	"verlassen",
	"wertlos",
	"heilen",
	"Trauma",
	"Vertrauen",
	"Mut",
	"loslassen",
	"Tür",
	"Beet",
	"Trieb",
	"Samen",
	"Garten",
	"Haus",
	"leer",
	"alle",
	"sechs",
	"fehlt",
	"Zahl",
	"Danke",
	"danke",
	"richtig",
	"falsch",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(kv_[a-z0-9_]+)\\]").search_all(_source()):
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


func _told(cue: String, picks: PackedStringArray = []) -> String:
	return "\n".join(await DialogueWalk.play(FILE, cue, picks))


## The words of the child, one string for each line.
func _child() -> PackedStringArray:
	var said := PackedStringArray()
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with("Kind: "):
			said.append(text.trim_prefix("Kind: "))
	return said


# --- The file -----------------------------------------------------------------------------------


func test_the_file_tells_the_cues_of_the_scene_in_draft_with_unique_ids() -> void:
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
	assert_false(_source().contains("[#ph]"))
	# the segment plans 24 lines (plus or minus eight); the three answers are on top
	assert_gte(ids.size() - answers, 16)
	assert_lte(ids.size() - answers, 32)
	assert_null(RegEx.create_from_string("=> (?!END)").search(_source()), "no jumps")
	assert_false(_source().contains("set_facet"), "the text only reads")
	assert_false(_source().contains("\ndo "), "and sets nothing: the scene does")


func test_nothing_is_a_digit_a_colon_a_shout_or_a_word_of_the_cause() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges().trim_prefix("- ")
		if text.contains("[if "):
			text = text.substr(0, text.find("[if "))
		if text.begins_with("Kind: "):
			text = text.trim_prefix("Kind: ")
		assert_false(text.contains(":"), "no colon but the speaker's: " + text)
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)


func test_the_child_says_at_most_three_words_and_never_answers_what_was_said() -> void:
	var said := _child()
	assert_gte(said.size(), 1)
	assert_lte(said.size(), 5, "mostly nothing")
	for line in said:
		assert_lte(line.split(" ", false).size(), 3, "three words at most: " + line)
		for word: String in ["Ich", "Du", "bin", "da", "bleib", "Bleib", "gut", "Gut", "bitte"]:
			assert_false(
				line.split(" ", false).has(word), "it does not echo, ask or comfort: " + line
			)


func test_the_cues_set_nothing_and_ask_for_nothing() -> void:
	for cue in CUES:
		var before := WorldState.state.flags.duplicate()
		await DialogueWalk.play(FILE, cue)
		assert_eq(WorldState.state.flags, before, "%s sets no flag" % cue)
		assert_false(WorldState.has_facet("trust"), "%s sets no facet" % cue)


# --- The parts ----------------------------------------------------------------------------------


func test_before_she_sits_there_is_only_narration_and_no_invitation() -> void:
	var seen := await DialogueWalk.play(FILE, "child_look")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 3)
	assert_false(told.contains("Kind:"), "the child says nothing")
	for word: String in ["setz", "Setz", "komm", "Komm", "musst", "solltest", "willst"]:
		assert_false(told.contains(word), "no invitation: " + word)
	assert_true(told.contains("Stein"), "the stone beside it is a thing, not a request")


func test_she_sits_and_the_child_does_not_move_away_and_then_it_hums() -> void:
	var told := await _told("child_seat")
	assert_true(told.contains("setzt dich"))
	assert_true(told.contains("rückt nicht weg"))
	var hum := await _told("child_hum")
	assert_true(
		hum.contains("summt"),
		"the line that names the hum has its own cue: the sound comes with it"
	)
	assert_true(hum.contains("Melodie"))
	for word: String in ["lächelt", "freut", "Hand", "umarm", "tröst"]:
		assert_false((told + hum).contains(word), "no gesture of comfort: " + word)


func test_the_frames_are_named_and_nothing_is_said_of_what_is_in_them() -> void:
	var seen := await DialogueWalk.play(FILE, "child_frames")
	var told := "\n".join(seen)
	assert_lte(seen.size(), 2)
	assert_true(told.contains("Rahmen"))
	for word: String in [
		"Bild", "Flur", "Hand", "Zimmer", "Verstecken", "nicht alle", "Lücke", "leer", "noch"
	]:
		assert_false(
			told.contains(word), "nothing of the contents, the gaps or the number: " + word
		)


func test_the_answer_is_the_one_that_is_always_there_the_one_of_trust_and_the_silence() -> void:
	var plain := await DialogueWalk.answers(FILE, "child_answer")
	assert_eq(plain, PackedStringArray(["Ich bin da.", "…"]), "nothing else without trust")
	WorldState.set_facet("trust")
	var trusting := await DialogueWalk.answers(FILE, "child_answer")
	assert_eq(trusting.size(), 3)
	assert_eq(trusting[0], "Ich bin da.", "the unconditional answer stays first")
	assert_eq(trusting[1], "Ich warte mit dir.", "the one that asks for nothing")
	assert_eq(trusting[2], "…", "the silence stays the last")


func test_no_way_is_wrong_each_has_its_own_line_and_none_praises_or_teaches() -> void:
	WorldState.set_facet("trust")
	var routes := {}
	for pick: String in ["Ich bin da", "Ich warte mit", "…"]:
		var seen := await DialogueWalk.play(FILE, "child_answer", PackedStringArray([pick]))
		routes[pick] = "\n".join(seen)
		assert_gte(seen.size(), 5, "the two lines before and three of its own: " + pick)
		assert_lte(seen.size(), 6)
		for word: String in [
			"gut", "schön", "richtig", "stolz", "Lob", "zeigt", "lernst", "wichtig"
		]:
			assert_false(routes[pick].contains(word), "%s: no %s" % [pick, word])
	assert_ne(routes["Ich bin da"], routes["Ich warte mit"], "not the same lines")
	assert_ne(routes["Ich bin da"], routes["…"])
	assert_ne(routes["Ich warte mit"], routes["…"])


func test_the_child_goes_without_a_goodbye_and_the_stone_is_warm_at_one_end() -> void:
	var back := await DialogueWalk.play(FILE, "child_return")
	assert_eq(back.size(), 1, "the tune takes up again: the sound comes with this line")
	assert_true(back[0].contains("Summen"))
	var seen := await DialogueWalk.play(FILE, "child_gone")
	var told := "\n".join(seen)
	assert_eq(seen.size(), 2)
	assert_true(told.contains("warm"))
	assert_true(told.contains("neben dich"), "she looks, and the place is empty")
	for word: String in [
		"Tschüss", "Abschied", "Auf Wiedersehen", "Dank", "verspro", "kommt wieder", "geht"
	]:
		assert_false(told.contains(word), "nothing is said of leaving: " + word)
	var empty := await DialogueWalk.play(FILE, "seat_empty")
	assert_eq(empty.size(), 2)
	assert_true("\n".join(empty).contains("warm"))


# --- The journal, the pictures --------------------------------------------------------------


func test_the_journal_follows_the_walk_and_names_neither_the_bed_nor_the_shoot() -> void:
	var line := tr("QUEST_MAIN_MOUNTAIN_WAY_CHILD")
	assert_ne(line, "QUEST_MAIN_MOUNTAIN_WAY_CHILD")
	for word: String in ["Beet", "Trieb", "Samen", "Mut", "Vertrauen", "Angst", "geheilt"]:
		assert_false(line.contains(word), "no %s" % word)
	for digit: String in "0123456789":
		assert_false(line.contains(digit), "numbers are written out")


func test_the_pictures_the_scene_can_show_exist_and_the_frame_is_a_prop() -> void:
	for name: String in ["hallway", "closed_door", "empty_room", "hand", "hiding"]:
		var path := "res://assets/generated/fragments/fragment_%s.png" % name
		assert_true(ResourceLoader.exists(path), path)
	for sprite: String in ["tal/gb_picture_frame", "tal/gb_sit_rock", "tal/gb_sprout"]:
		assert_true(PropCatalog.has(sprite), sprite)
	assert_true(_source().contains('has_facet("trust")'), "the reader reads it as a literal")
