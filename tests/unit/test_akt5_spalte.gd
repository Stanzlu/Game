extends GutTest
## Act V, segment G6: what the Grat tells (docs/akt5/REGIONSBRIEFE.md, O7, O10). The view from the
## top of the ramp, the signpost at the fork, the mouth of the cleft, the hollow at its end with
## the second flashback (the hiding), the candle stub, and the plateau's edge with the one answer
## that only the facet courage shows. Nobody speaks here: it is narration and the player's own
## answers. The flashback is four lines, no word of the child, no grown-up, no cause. The ground
## and the cells of the things are tested in test_layout_akt5.py, the scene in
## test_akt5_spalte_szene.

const FILE := "res://content/dialogue/akt5/spalte.dialogue"
const CUES: PackedStringArray = [
	"ledge_view", "fork_sign", "cleft_mouth", "hiding_place", "candle", "plateau_edge"
]
## What the text never says (the cause, the people, the lesson).
const NEVER: PackedStringArray = [
	"Kind",
	"Tür",
	"Mut",
	"mutig",
	"Angst",
	"verstecken",
	"versteckt",
	"Vertrauen",
	"Erwachsene",
	"Mutter",
	"Vater",
	"Stimme",
	"weil",
	"damals",
	"jemand",
	"Schritt",
	"Lehre",
	"gut gemacht",
	"stolz",
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
	for hit in RegEx.create_from_string("\\[ID:(spa_[a-z0-9_]+)\\]").search_all(_source()):
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


func _block(cue: String) -> String:
	var text := ""
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside:
			text += line + "\n"
	return text


func _told(cue: String, picks: PackedStringArray = []) -> String:
	return "\n".join(await DialogueWalk.play(FILE, cue, picks))


# --- The file -----------------------------------------------------------------------------------


func test_the_file_tells_the_cues_of_the_map_in_draft_with_unique_ids() -> void:
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
	# the segment plans 30 lines (plus or minus eight); the answers are on top
	assert_gte(ids.size() - answers, 22)
	assert_lte(ids.size() - answers, 38)
	assert_null(
		RegEx.create_from_string("=> (?!END)").search(_source()),
		"no jumps: nothing here calls another cue"
	)
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			continue
		assert_false(line.begins_with("Wächter"), "nobody speaks here")


func test_nothing_is_a_digit_a_colon_or_a_word_of_the_people_and_the_cause() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges().trim_prefix("- ")
		if text.contains("[if "):
			text = text.substr(0, text.find("[if "))
		assert_false(text.contains(":"), "narration has no colon: " + text)
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)


func test_the_cues_without_a_choice_set_nothing_and_say_no_more_than_they_see() -> void:
	for cue: String in ["ledge_view", "fork_sign", "cleft_mouth"]:
		var before := WorldState.state.flags.duplicate()
		var told := await _told(cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)
		assert_false(WorldState.has_facet("courage"), "%s sets no facet: the scene does" % cue)
		assert_gte(told.count("\n"), 2, "%s has its lines" % cue)


func test_the_signpost_shows_two_ways_and_judges_neither() -> void:
	var told := await _told("fork_sign")
	assert_true(told.contains("Umweg") and told.contains("Spalte"))
	assert_true(told.contains("Norden") and told.contains("Süden"))
	for word: String in ["besser", "schlechter", "Vorsicht", "gefährlich", "Warnung", "Mut"]:
		assert_false(told.contains(word), "no judgment: %s" % word)


func test_the_mouth_of_the_cleft_asks_for_nothing() -> void:
	var told := await _told("cleft_mouth")
	assert_true(told.contains("drei Schultern"))
	for word: String in ["musst", "solltest", "geh hinein", "traust", "wage", "Vorsicht", "Gefahr"]:
		assert_false(told.contains(word), "no push, no warning: %s" % word)


# --- The flashback ------------------------------------------------------------------------------


func test_the_hiding_is_four_lines_and_the_picture_comes_with_the_last() -> void:
	var seen := await DialogueWalk.play(FILE, "hiding_place")
	assert_eq(seen.size(), 4, "a standing picture of at most four lines (O7)")
	for i in range(1, 5):
		assert_true(LineText.of("spa_hiding_%d" % i) in seen, "line %d" % i)
	assert_true(WorldState.has_flag("fragment.hiding"))
	assert_eq(Collection.fragments(), 1, "the second picture of the child, and she is not in it")
	var block := _block("hiding_place")
	assert_gt(block.find('set_flag("fragment.hiding")'), block.find("[ID:spa_hiding_4]"), "last")


func test_the_hiding_names_no_one_and_no_cause_and_comes_back_as_one_line() -> void:
	var first := await _told("hiding_place")
	for word: String in ["Mädchen", "Junge", "Mann", "Frau", "Hand", "Hände", "Gesicht"]:
		assert_false(first.contains(word), "nobody is in the picture: %s" % word)
	assert_true(
		first.contains("Mulde") and first.contains("Streifen Licht") and first.contains("Decke")
	)
	assert_true(first.contains("warm"), "the one thing a body leaves")
	for word: String in ["Kies", "knirscht", "geht", "vorbei", "Schritt", "Tritt", "Atem"]:
		assert_false(first.contains(word), "no one passes outside and nothing sounds: %s" % word)
	var again := await DialogueWalk.play(FILE, "hiding_place")
	assert_eq(again.size(), 1, "a visit again is one line")
	assert_eq(again[0], LineText.of("spa_hiding_5"))
	assert_eq(Collection.fragments(), 1, "counted once")


func test_the_picture_of_the_hiding_exists_and_is_a_small_picture() -> void:
	var path := "res://assets/generated/fragments/fragment_hiding.png"
	assert_true(ResourceLoader.exists(path), path)
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	assert_not_null(image)
	assert_eq(image.get_size(), Vector2i(16, 16))


# --- The candle ---------------------------------------------------------------------------------


func test_the_candle_can_be_taken_or_left_and_both_answers_are_there() -> void:
	var answers := await DialogueWalk.answers(FILE, "candle")
	assert_eq(answers, PackedStringArray(["Einstecken.", "Liegen lassen."]))
	await _told("candle", PackedStringArray(["Liegen lassen"]))
	assert_false(WorldState.has_item("curiosity_candle_stub"))
	assert_false(WorldState.has_flag("grat.candle_taken"), "left, it is still there")
	var told := await _told("candle", PackedStringArray(["Einstecken"]))
	assert_true(WorldState.has_item("curiosity_candle_stub"))
	assert_true(WorldState.has_flag("grat.candle_taken"))
	assert_eq(Collection.curiosities(), 1, "a curiosity of the segment")
	for word in NEVER:
		assert_false(told.contains(word), "no %s" % word)


func test_the_candle_is_an_item_with_a_name_a_description_and_an_icon() -> void:
	assert_true(ContentDB.has_item("curiosity_candle_stub"))
	assert_ne(tr("CURIOSITY_CANDLE_STUB_NAME"), "CURIOSITY_CANDLE_STUB_NAME")
	assert_ne(tr("CURIOSITY_CANDLE_STUB_DESC"), "CURIOSITY_CANDLE_STUB_DESC")
	var path := "res://assets/generated/items/curiosity_candle_stub.png"
	assert_true(ResourceLoader.exists(path), path)
	for digit: String in "0123456789":
		assert_false(tr("CURIOSITY_CANDLE_STUB_DESC").contains(digit), "numbers are written out")


# --- The plateau's edge, the facet ----------------------------------------------------------


func test_the_edge_shows_two_answers_and_the_silence_and_three_with_courage() -> void:
	var plain := await DialogueWalk.answers(FILE, "plateau_edge")
	assert_eq(plain, PackedStringArray(["Umsehen.", "…"]), "nothing else without it")
	WorldState.set_facet("courage")
	var daring := await DialogueWalk.answers(FILE, "plateau_edge")
	assert_eq(daring.size(), 3)
	assert_eq(daring[0], "Umsehen.", "the unconditional answer stays first")
	assert_true("Bis an den Rand" in daring[1], "the answer of the facet shows beside it")
	assert_eq(daring[2], "…", "the silence stays the last")


func test_the_look_down_gives_no_praise_and_no_lesson_and_says_nothing_of_what_comes() -> void:
	WorldState.set_facet("courage")
	var told := await _told("plateau_edge", PackedStringArray(["Bis an den Rand"]))
	assert_true(told.contains("Anlage") and told.contains("See"))
	for word: String in ["Haus", "gelernt", "geschafft", "endlich", "Tür", "Kind", "bereit"]:
		assert_false(told.contains(word), "no %s" % word)
	var all := await _told("plateau_edge")
	for word: String in ["Nichts wächst", "bedeckt", "Rundum", "Steine"]:
		assert_false(all.contains(word), "the plateau is grass, open to the west: %s" % word)
	var plain := await _told("plateau_edge", PackedStringArray(["Umsehen"]))
	assert_false(plain.contains("Anlage"), "the other answer does not see the Anlage from the edge")
	var block := _block("plateau_edge")
	assert_true(block.contains('has_facet("courage")'), "the reader reads it as a literal")


func test_the_scene_is_the_setter_of_courage_and_the_text_never_sets_it() -> void:
	assert_false(_source().contains("set_facet"), "the text only reads")
	var scene := FileAccess.get_file_as_string("res://world/levels/akt5/grat_scene.gd")
	assert_true(scene.contains('set_facet("courage")'), "the scene sets it at the end of the cleft")
	for cue: String in ["ledge_view", "fork_sign", "cleft_mouth", "hiding_place", "candle"]:
		assert_false(_block(cue).contains("courage"), "%s does not read it" % cue)


func test_the_journal_follows_the_walk_without_a_lesson() -> void:
	var line := tr("QUEST_MAIN_MOUNTAIN_WAY_HIGH")
	assert_ne(line, "QUEST_MAIN_MOUNTAIN_WAY_HIGH")
	for word: String in ["Mut", "mutig", "loslassen", "Vertrauen", "Kind"]:
		assert_false(line.contains(word), "no %s" % word)
	for digit: String in "0123456789":
		assert_false(line.contains(digit), "numbers are written out")
