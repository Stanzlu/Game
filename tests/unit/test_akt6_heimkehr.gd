extends GutTest
## Act VI, segment R8: what the homecoming says (docs/akt6/REGIONSBRIEFE.md, O12, O14, O15, O18).
## The house is as she left it; the host comes to visit and has nothing to offer (the same face,
## without an offer), his joke is his own hands and his evening; the drover reads the visit off
## the sheet on the wall and the afternoon with nothing in it; Elysia's song comes home as a thing
## that is heard. Nothing is set by a line, nothing is praised, nothing is said about leaving or
## staying. The scene (the knock, the walk, the song, the end of the act) is tested in
## test_akt6_heimkehr_szene.

const FILE := "res://content/dialogue/akt6/heimkehr.dialogue"
const CUES: PackedStringArray = [
	"home_in",
	"host_in",
	"antreiber_visit",
	"home_song",
	"home_close",
	"host_home",
	"plan_board_back",
]
## What the text never says: the names of things the strategy is about, any verdict on staying or
## on going, the Richter, and what happened in the mountains.
const NEVER: PackedStringArray = [
	"Kind",
	"Gefühl",
	"fühlen",
	"Betäub",
	"Flucht",
	"Sucht",
	"Trost",
	"Heilung",
	"Leere",
	"Muster",
	"Schleife",
	"falsch",
	"richtig",
	"mutig",
	"stolz",
	"endlich",
	"genug",
	"Richter",
	"Mira",
	"Gebirge",
	"Elysia",
	"Zuhause",
	"Heimat",
]
## What a host who offers says, and what a host who holds says: neither is in this file.
const OFFERS: PackedStringArray = [
	"Setz dich",
	"Setz dich doch",
	"Bleib",
	"bleib",
	"Nimm",
	"nimm",
	"Iss ",
	"Möchtest",
	"Willst du",
	"Hier, ",
	"Du musst",
	"Musst du",
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
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:(hk6_[a-z0-9_]+)\\]").search_all(
		_source()
	):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out, tags left out.
func _spoken() -> String:
	var spoken := ""
	for line: String in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += RegEx.create_from_string("\\[[^\\]]*\\]").sub(line.substr(0, at), "", true)
			spoken += "\n"
	return spoken


## The lines of a cue as written, comments and code left out.
func _written(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line: String in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges())
	return lines


## Everything the game remembers, but for the play time that runs on by itself.
func _written_down() -> String:
	var state := WorldState.state.to_dict()
	state.erase("playtime_seconds")
	return JSON.stringify(state)


func test_the_file_has_the_cues_in_draft_with_unique_ids() -> void:
	var names: PackedStringArray = []
	for hit: RegExMatch in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var unique := {}
	for id in _ids():
		assert_false(unique.has(id), "no ID twice: %s" % id)
		unique[id] = true
	assert_eq(_source().count("[#draft]"), _ids().size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"))
	assert_gte(unique.size(), 20)
	assert_lte(unique.size(), 34)


func test_nothing_is_a_digit_a_verdict_or_a_word_for_what_the_strategy_was() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word: String in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)


func test_it_is_things_and_the_voices_of_two_people_with_no_answer_and_nothing_set() -> void:
	for line: String in _source().split("\n"):
		assert_false(line.begins_with("- "), "no answer: " + line)
	for call_name: String in [
		"set_flag", "clear_flag", "add_item", "add_xp", "add_gold", "set_facet", "start_quest"
	]:
		assert_false(_source().contains(call_name), "%s does not occur" % call_name)
	for cue: String in CUES:
		for line in _written(cue):
			if line.begins_with("Gastwirt: ") or line.begins_with("Antreiber: "):
				continue
			var text := line.strip_edges()
			assert_false(text.contains(": "), "narration has no speaker: " + text)
			for mark: String in ["!", "?", "…"]:
				assert_false(text.contains(mark), "no %s in narration: %s" % [mark, text])
	var kept := _written_down()
	for cue: String in CUES:
		await DialogueWalk.play(FILE, cue)
	assert_eq(_written_down(), kept, "nothing was set, nothing given")


func test_the_host_comes_with_nothing_to_offer_and_makes_his_joke_about_his_hands() -> void:
	var host_lines := PackedStringArray()
	for cue: String in ["host_in", "host_home"]:
		for line in _written(cue):
			if line.begins_with("Gastwirt: "):
				host_lines.append(line)
	assert_lte(host_lines.size(), 6, "he says little")
	var told := "\n".join(host_lines)
	for word in OFFERS:
		assert_false(told.contains(word), "he offers nothing, asks nothing, holds nothing: " + word)
	var visit := "\n".join(await DialogueWalk.play(FILE, "host_in"))
	assert_true(visit.contains("nichts mitgebracht"), "he has brought nothing")
	assert_true(visit.contains("Hände"), "and the joke is his hands")
	assert_true(visit.contains("Löffel"), "and his evening without a spoon")
	for line in host_lines:
		assert_true(RegEx.create_from_string("^Gastwirt: [A-ZÄÖÜ]").search(line) != null)
		assert_lte(line.length(), 140, "short: " + line)


func test_the_host_never_names_the_table_the_soup_the_standing_up_or_his_strategy() -> void:
	var told := "\n".join(PackedStringArray(_written("host_in") + _written("host_home")))
	for word: String in [
		"Tisch", "Suppe", "Aufstehen", "aufgestanden", "Gasthaus", "Betäub", "Ablenkung", "Elysia"
	]:
		assert_false(told.contains(word), "no word about the inn: " + word)


func test_the_drover_says_what_the_sheet_says_with_no_question_and_no_cry() -> void:
	var lines := _written("antreiber_visit")
	var spoken := PackedStringArray()
	for line in lines:
		if line.begins_with("Antreiber: "):
			spoken.append(line)
	assert_lte(spoken.size(), 3)
	assert_gte(spoken.size(), 2)
	for line in spoken:
		for mark: String in ["!", "?", "…"]:
			assert_false(line.contains(mark), "no %s: %s" % [mark, line])
	var told := "\n".join(spoken)
	assert_true(told.contains("Unangemeldet"), "the sheet's word for a visit (Act III)")
	assert_true(told.contains("nichts eingetragen"), "the afternoon with nothing in it")
	assert_true(told.contains("zweimal nachgesehen"), "looked at twice")
	assert_true("\n".join(lines).contains("Füße"), "and his feet stay where they are")


func test_the_song_is_a_thing_that_is_heard_and_says_what_it_does_not_do() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "home_song"))
	assert_true(told.contains("Lied"))
	assert_true(told.contains("Garten"), "she knows it from the garden")
	assert_true(told.contains("dieselben"), "the same notes")
	assert_true(told.contains("langsamer"), "slower than in the garden")
	assert_true(told.contains("zögert"), "and a hand plays it")
	for word: String in ["Erinnerung", "Fragment", "Zeichen", "Lohn", "Wärme", "Trauer", "Freude"]:
		assert_false(told.contains(word), "no meaning, no reward: " + word)


func test_the_last_lines_are_true_with_and_without_the_host_and_name_only_things() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "home_close"))
	assert_true(told.contains("Tee"), "the tea of the morning, gone cold")
	assert_true(told.contains("Bach"))
	assert_false(told.contains("Wirt") or told.contains("Gastwirt"), "true without him")
	var home := "\n".join(await DialogueWalk.play(FILE, "home_in"))
	assert_false(home.contains("Wirt"), "the house as she left it")
	assert_true(home.contains("nicht hierher gehört"), "nothing in the air that is not from here")


func test_the_sheet_on_the_wall_shows_the_empty_afternoon_and_the_host_only_with_him() -> void:
	var without := "\n".join(await DialogueWalk.play(FILE, "plan_board_back"))
	assert_true(without.contains("Um fünf Uhr steht nichts"), "an hour with nothing in it")
	assert_true(without.contains("Strich"), "the stroke at the end is not wiped out")
	assert_true(without.contains("unangemeldet"), "visits are still unannounced")
	assert_false(without.contains("Gastwirt"))
	WorldState.set_flag("house.guest_host")
	var with_him := "\n".join(await DialogueWalk.play(FILE, "plan_board_back"))
	assert_true(with_him.contains("»Gastwirt«"), "his name is by the word")
	assert_true(with_him.contains("nichts mitgebracht"), "with the duration that fits him")
	assert_false(with_him.contains("unangemeldet"))
	assert_false(with_him.contains("Einsiedler"))
	# the hermit of Act III keeps his name on the sheet, with or without the host
	WorldState.clear_flag("house.guest_host")
	WorldState.set_flag("house.guest_hermit")
	var hermit := "\n".join(await DialogueWalk.play(FILE, "plan_board_back"))
	assert_true(hermit.contains("»Einsiedler«") and hermit.contains("»offen«"))
	assert_false(hermit.contains("unangemeldet"), "a name stands there now")
	WorldState.set_flag("house.guest_host")
	var both := "\n".join(await DialogueWalk.play(FILE, "plan_board_back"))
	assert_true(both.contains("»Einsiedler«") and both.contains("»Gastwirt«"), "both names")
	assert_eq(
		RegEx.create_from_string('has_flag\\("house.guest_host"\\)').search_all(_source()).size(), 1
	)
