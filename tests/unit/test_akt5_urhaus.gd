extends GutTest
## Act V, segment G8: what the first house tells (docs/akt5/REGIONSBRIEFE.md, O2, O7, O10; Bible
## 15, 37, 38). The small house on the plateau after the child is gone (plateau_after, house_front),
## the first look inside (house_look), the six rings of chalk from the bed outwards (ring_*), the
## chalked-over window with the answer that only the facet courage shows (window, window_wipe), the
## third flashback at the bed (first_house), the stick of chalk (blue_chalk) and the book on its
## post (summit_*). Nothing is explained: no cause, no maker, no feeling, no lesson. The scene (the
## places, the flags, the quest) is tested in test_akt5_urhaus_szene.

const FILE := "res://content/dialogue/akt5/urhaus.dialogue"
const CUES: PackedStringArray = [
	"plateau_after",
	"house_look",
	"house_front",
	"ring_room",
	"ring_wall",
	"ring_garden",
	"ring_street",
	"ring_town",
	"ring_world",
	"window",
	"window_wipe",
	"first_house",
	"blue_chalk",
	"summit_book",
	"summit_leaf",
	"summit_sign",
]
## The cues that set nothing at all (the others set the flags named in test_the_flags_...).
const SILENT: PackedStringArray = [
	"plateau_after",
	"house_look",
	"house_front",
	"ring_room",
	"ring_wall",
	"ring_garden",
	"ring_street",
	"ring_town",
	"ring_world",
]
## What the text never says: the cause, the maker, the feeling, the lesson, the words of the brief
## (the rings are drawings, not explanations).
const NEVER: PackedStringArray = [
	"Kind",
	"Mama",
	"Papa",
	"Mutter",
	"Vater",
	"Eltern",
	"damals",
	"früher",
	"weil",
	"Angst",
	"einsam",
	"Einsamkeit",
	"verlassen",
	"wertlos",
	"sicher",
	"Schutz",
	"geschützt",
	"loslassen",
	"Vertrauen",
	"Mut",
	"heilen",
	"Trauma",
	"Außen",
	"übrig",
	"endlich",
	"geschafft",
	"gut gemacht",
	"stolz",
	"eingesperrt",
	"ausgebaut",
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
	for hit in RegEx.create_from_string("\\[ID:(uh_[a-z0-9_]+)\\]").search_all(_source()):
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


func test_the_file_tells_the_cues_in_draft_with_unique_ids() -> void:
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
	# the segment plans 50 lines (plus or minus ten); the answers are on top
	assert_gte(ids.size() - answers, 40)
	assert_lte(ids.size() - answers, 60)
	var allowed := ["END", "window_wipe", "summit_leaf", "summit_sign"]
	for hit in RegEx.create_from_string("=> (\\w+)").search_all(_source()):
		assert_true(allowed.has(hit.get_string(1)), "a jump inside the file: " + hit.get_string(1))
	assert_false(_source().contains("set_facet"), "the text only reads")


func test_nothing_is_a_digit_a_colon_a_shout_or_a_word_of_the_cause() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for line in spoken.split("\n", false):
		var text := line.strip_edges().trim_prefix("- ")
		if text.contains("[if "):
			text = text.substr(0, text.find("[if "))
		assert_false(text.contains(":"), "no colon: " + text)
		assert_false(text.contains("!"), "no shout: " + text)
		assert_false(text.contains("?"), "no question: " + text)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)


func test_the_cues_that_only_look_set_nothing_and_ask_for_nothing() -> void:
	for cue in SILENT:
		var before := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(FILE, cue)
		assert_gte(seen.size(), 2, "%s has its lines" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets no flag" % cue)
		assert_false(WorldState.has_facet("courage"), "%s sets no facet" % cue)
		assert_eq((await DialogueWalk.answers(FILE, cue)).size(), 0, "%s asks for nothing" % cue)


# --- The outside, the first look --------------------------------------------------------------


func test_the_house_is_there_and_nobody_says_where_it_came_from() -> void:
	var after := await _told("plateau_after")
	assert_true(after.contains("Haus"))
	assert_eq(after.count("\n"), 2, "three lines")
	var front := await _told("house_front")
	assert_true(front.contains("Schindeln") and front.contains("Tür"))
	assert_true(front.contains("niedergetreten"), "no path leads there and none away")
	var look := await DialogueWalk.play(FILE, "house_look")
	assert_eq(look.size(), 4)
	assert_true("\n".join(look).contains("Bett"))
	assert_true("\n".join(look).contains("Kreide"))
	for word: String in ["Mauer", "Garten", "Straße", "Stadt", "Welt"]:
		assert_false("\n".join(look).contains(word), "the first look names no ring: " + word)


# --- The six rings ------------------------------------------------------------------------------


func test_the_rings_are_told_from_the_bed_outwards_and_only_as_drawings() -> void:
	var expected := {
		"ring_room": ["Viereck", "Bett", "Wulst"],
		"ring_wall": ["Strichen", "versetzt", "Steine"],
		"ring_garden": ["Stängel", "Blättern", "Blüte"],
		"ring_street": ["Weges", "Fußspuren", "doppelt"],
		"ring_town": ["Häuser", "Dach", "Wand an Wand"],
		"ring_world": ["Wänden", "Schwelle", "reißt nirgends ab"],
	}
	for cue: String in expected:
		var told := await _told(cue)
		for part: String in expected[cue]:
			assert_true(told.contains(part), "%s: %s" % [cue, part])
		var lines := told.split("\n", false).size()
		assert_gte(lines, 2, cue)
		assert_lte(lines, 3, cue)
		for word: String in ["Kreide", "gezeichnet", "gezogen"]:
			if told.contains(word):
				assert_false(told.contains("hat " + word), "nobody drew them: " + cue)


func test_the_outermost_ring_ends_with_no_room_for_another_one() -> void:
	var seen := await DialogueWalk.play(FILE, "ring_world")
	assert_eq(seen.size(), 3)
	assert_true(
		seen[2].contains("kein Platz"), "the last line: nothing more is drawn, and no room for it"
	)
	assert_true(seen[1].contains("Schwelle"), "it runs over the threshold without a gap")
	for line in seen:
		for word: String in ["Außen", "außen", "übrig", "draußen", "eingesperrt", "Gefängnis"]:
			assert_false(line.contains(word), "not the brief's words: " + word)


# --- The window and the facet courage -----------------------------------------------------------


func test_the_window_answers_are_the_open_one_the_one_of_courage_and_the_silence() -> void:
	var plain := await DialogueWalk.answers(FILE, "window")
	assert_eq(plain, PackedStringArray(["Ansehen.", "…"]), "nothing else without it")
	WorldState.set_facet("courage")
	var daring := await DialogueWalk.answers(FILE, "window")
	assert_eq(daring.size(), 3)
	assert_eq(daring[0], "Ansehen.", "the unconditional answer stays first")
	assert_eq(daring[1], "Die Kreide wegwischen.", "the answer of the facet shows beside it")
	assert_eq(daring[2], "…", "the silence stays the last")
	assert_true(
		_block("window").contains('has_facet("courage")'), "the reader reads it as a literal"
	)


func test_wiping_the_chalk_clears_the_window_without_praise() -> void:
	WorldState.set_facet("courage")
	var before := WorldState.state.flags.duplicate()
	for pick: String in ["Ansehen", "…"]:
		var told := await _told("window", PackedStringArray([pick]))
		assert_eq(WorldState.state.flags, before, "%s changes nothing" % pick)
		assert_false(told.contains("Mut"))
	assert_false(WorldState.has_flag("urhaus.window_clear"))
	var wiped := await _told("window", PackedStringArray(["Die Kreide wegwischen"]))
	assert_true(WorldState.has_flag("urhaus.window_clear"))
	assert_true(wiped.contains("blau"), "the fingers turn blue")
	assert_true(wiped.contains("Licht"))
	for word: String in ["gut", "stolz", "endlich", "geschafft", "gelernt", "richtig"]:
		assert_false(wiped.contains(word), "no praise, no lesson: " + word)
	var block := _block("window_wipe")
	assert_gt(block.find('set_flag("urhaus.window_clear")'), block.find("[ID:uh_wipe_3]"), "last")
	assert_false(_block("window").contains("set_flag"), "the reader of the flag never sets it")
	# once it is clear the window is two lines and asks for nothing
	var seen := await DialogueWalk.play(FILE, "window")
	assert_eq(seen.size(), 2)
	assert_eq((await DialogueWalk.answers(FILE, "window")).size(), 0)
	assert_true("\n".join(seen).contains("klar"))


# --- The third flashback ------------------------------------------------------------------------


func test_the_picture_at_the_bed_is_four_lines_and_comes_with_the_last() -> void:
	var seen := await DialogueWalk.play(FILE, "first_house")
	assert_eq(seen.size(), 4, "a standing picture of at most four lines (O7)")
	for i in range(1, 5):
		assert_true(LineText.of("uh_first_%d" % i) in seen, "line %d" % i)
	assert_true(WorldState.has_flag("fragment.first_house"))
	assert_eq(Collection.fragments(), 1, "the third picture of the child, and no child is in it")
	var block := _block("first_house")
	assert_gt(block.find('set_flag("fragment.first_house")'), block.find("[ID:uh_first_4]"), "last")
	var again := await DialogueWalk.play(FILE, "first_house")
	assert_eq(again.size(), 1, "a visit again is one line")
	assert_eq(again[0], LineText.of("uh_first_5"))
	assert_eq(Collection.fragments(), 1, "counted once")


func test_the_picture_at_the_bed_names_no_one_and_no_cause() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "first_house"))
	for word: String in ["Mädchen", "Junge", "Mann", "Frau", "Gesicht", "Stimme", "Hände"]:
		assert_false(told.contains(word), "nobody is in the picture: " + word)
	assert_true(told.contains("dieses eine Zimmer"))
	assert_true(told.contains("Fenster") and told.contains("offen"))
	assert_true(told.contains("Linien"), "the lines come back at the end")


# --- The chalk, the book ------------------------------------------------------------------------


func test_the_chalk_can_be_taken_or_left_and_both_answers_are_there() -> void:
	var answers := await DialogueWalk.answers(FILE, "blue_chalk")
	assert_eq(answers, PackedStringArray(["Einstecken.", "Liegen lassen."]))
	await _told("blue_chalk", PackedStringArray(["Liegen lassen"]))
	assert_false(WorldState.has_item("curiosity_blue_chalk"))
	assert_false(WorldState.has_flag("urhaus.chalk_taken"), "left, it is still there")
	var told := await _told("blue_chalk", PackedStringArray(["Einstecken"]))
	assert_true(WorldState.has_item("curiosity_blue_chalk"))
	assert_true(WorldState.has_flag("urhaus.chalk_taken"))
	assert_eq(Collection.curiosities(), 1, "a curiosity of the segment")
	assert_true(told.contains("blau"))
	assert_true(ContentDB.has_item("curiosity_blue_chalk"))
	assert_ne(tr("CURIOSITY_BLUE_CHALK_NAME"), "CURIOSITY_BLUE_CHALK_NAME")
	assert_ne(tr("CURIOSITY_BLUE_CHALK_DESC"), "CURIOSITY_BLUE_CHALK_DESC")
	for digit: String in "0123456789":
		assert_false(tr("CURIOSITY_BLUE_CHALK_DESC").contains(digit), "numbers are written out")


func test_the_book_is_read_first_and_the_last_page_is_empty() -> void:
	var plain := await DialogueWalk.answers(FILE, "summit_book")
	assert_eq(plain, PackedStringArray(["Blättern.", "…"]), "no entry before the reading")
	var leaf := await DialogueWalk.play(FILE, "summit_book", PackedStringArray(["Blättern"]))
	assert_eq(leaf.size(), 8, "the book and the pencil, then six hands")
	assert_true("\n".join(leaf).contains("Seite danach ist leer"), "the last page is empty")
	assert_true(WorldState.has_flag("fragment.summit_book"), "a trace of the world")
	assert_true(WorldState.has_flag("grat.summit_read"))
	assert_eq(Collection.fragments(), 1)
	var reading := await DialogueWalk.answers(FILE, "summit_book")
	assert_eq(reading.size(), 3)
	assert_eq(reading[0], "Blättern.")
	assert_eq(reading[1], "Etwas eintragen.", "the entry shows after the reading")
	assert_eq(reading[2], "…", "the silence stays the last")
	assert_false(
		_block("summit_book").contains("set_flag"), "the reader of the flags never sets them"
	)
	var block := _block("summit_leaf")
	assert_gt(
		block.find('set_flag("grat.summit_read")'), block.find('set_flag("fragment.summit_book")')
	)


func test_the_entry_is_hers_and_the_book_has_one_line_afterwards() -> void:
	WorldState.set_flag("grat.summit_read")
	var signed := await DialogueWalk.play(
		FILE, "summit_book", PackedStringArray(["Etwas eintragen"])
	)
	assert_eq(signed.size(), 5, "the book, the pencil, and her three lines")
	assert_true(WorldState.has_flag("grat.summit_signed"))
	var told := "\n".join(signed)
	assert_true(told.contains("deiner eigenen Schrift"), "what she writes is not told")
	var again := await DialogueWalk.play(FILE, "summit_book")
	assert_eq(again.size(), 1, "one line once she has signed")
	assert_eq(again[0], LineText.of("uh_book_3"))
	assert_eq((await DialogueWalk.answers(FILE, "summit_book")).size(), 0)
	var silent := await DialogueWalk.play(FILE, "summit_book", PackedStringArray(["…"]))
	assert_eq(silent.size(), 1)


# --- The journal, the pictures --------------------------------------------------------------


func test_the_journal_follows_the_walk_and_the_book_without_a_lesson() -> void:
	for key: String in [
		"QUEST_MAIN_MOUNTAIN_WAY_HOUSE",
		"QUEST_SIDE_GRAT_SUMMIT_TITLE",
		"QUEST_SIDE_GRAT_SUMMIT_READ",
		"QUEST_SIDE_GRAT_SUMMIT_DONE",
	]:
		var line := tr(key)
		assert_ne(line, key, key)
		for word: String in ["Mut", "Angst", "Schutz", "Vertrauen", "loslassen", "Ring"]:
			assert_false(line.contains(word), "%s: no %s" % [key, word])
		for digit: String in "0123456789":
			assert_false(line.contains(digit), "%s: numbers are written out" % key)


func test_the_pictures_and_things_of_the_house_exist() -> void:
	for name: String in ["first_house", "summit_book"]:
		var path := "res://assets/generated/fragments/fragment_%s.png" % name
		assert_true(ResourceLoader.exists(path), path)
	assert_true(ResourceLoader.exists("res://assets/generated/items/curiosity_blue_chalk.png"))
	var sprites := [
		"tal/gb_first_house",
		"tal/gb_summit_book",
		"tal/uh_shell",
		"tal/uh_bed",
		"tal/uh_window",
		"tal/uh_window_clear",
		"tal/uh_chalk_rings",
		"tal/uh_chalk",
	]
	for sprite: String in sprites:
		assert_true(PropCatalog.has(sprite), sprite)
