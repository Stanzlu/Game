extends GutTest
## Act VI, segment R4: what the market, the hall of mirrors and the Richter say (docs/akt6/
## REGIONSBRIEFE.md, O5, O9, O12; docs/writing/STIL.md). Elysia is as it was: the same sentences in
## the same build, the one who comes back hears them. Nobody says that they repeat, nobody explains
## the mirror, and the Richter, who speaks once, is faster than she is. Nothing here sets anything.
## The scenes (the new cues on the maps, the voice over the picture) are tested in
## test_akt6_markt_szene, test_akt6_richter_szene and test_voice_line.

const MARKT := "res://content/dialogue/akt6/markt.dialogue"
const SPIEGEL := "res://content/dialogue/akt6/spiegel.dialogue"
const RICHTER := "res://content/dialogue/akt6/richter.dialogue"
const FILES: PackedStringArray = [MARKT, SPIEGEL, RICHTER]
const MARKT_CUES: PackedStringArray = [
	"festmaster_back",
	"musician_back",
	"baker_back",
	"poet_back",
	"gatekeeper_back",
	"guest_back",
	"board_back",
]
const SPIEGEL_CUES: PackedStringArray = ["keeper_back", "mirror_back"]
const RICHTER_CUES: PackedStringArray = ["voice_first", "voice_late"]
## What the text never says: what happened in the mountains, the child, the names of feelings, the
## verdicts on Elysia, any word that says that things repeat, the host and his house.
const NEVER: PackedStringArray = [
	"Kind",
	"Kreide",
	"Gebirge",
	"Maschine",
	"Mira",
	"Leere",
	"Gefühl",
	"Trost",
	"trösten",
	"Flucht",
	"Sucht",
	"Betäuber",
	"Wirt",
	"Gasthaus",
	"heilen",
	"Heilung",
	"loslassen",
	"zurück",
	"Zuhause",
	"Heimat",
	"falsch",
	"gefährlich",
	"Falle",
	"Lüge",
	"Wiederholung",
	"Schleife",
	"wie immer",
	"schon wieder",
	"endlich",
	"diesmal",
]
## What a person of the market never says: no refusal, no weather, no time, no having been away.
const NEVER_SAID_BY_ELYSIANS: PackedStringArray = [
	"Nein",
	"Wetter",
	"Regen",
	"Zeit",
	"vermisst",
	"fort",
	"zurückgekehrt",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()


func _source(path: String) -> String:
	return FileAccess.get_file_as_string(path)


func _all() -> String:
	var all := ""
	for path: String in FILES:
		all += _source(path)
	return all


## The text of every line (before its ID), comments and code left out, tags left out.
func _spoken(path: String) -> String:
	var spoken := ""
	for line: String in _source(path).split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += RegEx.create_from_string("\\[[^\\]]*\\]").sub(line.substr(0, at), "", true)
			spoken += "\n"
	return spoken


## The lines of a cue as written (answers without the dash), comments and code left out.
func _written(path: String, cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line: String in _source(path).split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges().trim_prefix("- "))
	return lines


func _cues(path: String) -> PackedStringArray:
	var names: PackedStringArray = []
	for hit: RegExMatch in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(
		_source(path)
	):
		names.append(hit.get_string(1))
	return names


func _ids(path: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:([a-z0-9_]+)\\]").search_all(
		_source(path)
	):
		found.append(hit.get_string(1))
	return found


func test_the_files_have_the_cues_in_draft_with_unique_ids_and_the_right_prefix() -> void:
	assert_eq(_cues(MARKT), MARKT_CUES, "the cues of the market, in this order")
	assert_eq(_cues(SPIEGEL), SPIEGEL_CUES)
	assert_eq(_cues(RICHTER), RICHTER_CUES)
	var prefixes := {MARKT: "mkt_", SPIEGEL: "spg_", RICHTER: "rch_"}
	var unique := {}
	for path: String in FILES:
		for id: String in _ids(path):
			assert_true(id.begins_with(prefixes[path]), "%s is in its file's prefix" % id)
			assert_false(unique.has(id), "no ID twice: %s" % id)
			unique[id] = true
		assert_eq(_source(path).count("[#draft]"), _ids(path).size(), "every line is a draft")
	assert_false(_all().contains("[#ph]"))
	# the plan is 55 lines for the segment; three cues of the first plan went into Act I's own
	assert_gte(unique.size(), 40)
	assert_lte(unique.size(), 58)


func test_nothing_in_these_files_sets_anything() -> void:
	var all := _all()
	assert_null(RegEx.create_from_string("(?m)^\\s*do\\s").search(all), "no do line at all")
	for call_name: String in [
		"set_flag", "set_facet", "add_xp", "add_gold", "add_item", "start_quest"
	]:
		assert_false(all.contains(call_name), "%s does not occur" % call_name)
	assert_null(RegEx.create_from_string("=> (?!END)").search(all), "no jumps: each cue stands")
	for path: String in FILES:
		for cue: String in _cues(path):
			var kept := JSON.stringify(WorldState.state.to_dict())
			var seen := await DialogueWalk.play(path, cue)
			assert_gte(seen.size(), 1, "%s has its lines" % cue)
			assert_eq(
				JSON.stringify(WorldState.state.to_dict()).length(),
				kept.length(),
				"%s: nothing" % cue
			)


func test_no_digit_no_verdict_no_word_for_what_repeats() -> void:
	for path: String in FILES:
		var spoken := _spoken(path)
		for digit: String in "0123456789":
			assert_false(spoken.contains(digit), "numbers are written out: " + digit)
		for word: String in NEVER:
			assert_false(spoken.contains(word), "%s never says %s" % [path.get_file(), word])
	var said := ""
	for path: String in FILES:
		said += _spoken(path)
	# the one echo of Act I's toast ("Ganz Elysia hebt seines"): the whole town raises its glass
	var named := RegEx.create_from_string("\\bElysia\\b").search_all(said)
	assert_lte(named.size(), 1, "the place is hardly named")
	assert_true(
		named.is_empty() or "\n".join(_written(MARKT, "festmaster_back")).contains("Ganz Elysia")
	)


func test_the_people_of_the_market_say_nothing_of_a_refusal_the_weather_or_having_been_away(
) -> void:
	var spoken := ""
	for line: String in _spoken(MARKT).split("\n", false):
		if not line.begins_with("Die ") and not line.begins_with("Ganz "):
			spoken += line + "\n"
	for word: String in NEVER_SAID_BY_ELYSIANS:
		assert_false(spoken.contains(word), "no %s in what the market says" % word)


func test_narration_has_no_colon_no_question_no_shout_and_the_people_keep_their_names() -> void:
	for path: String in [MARKT, SPIEGEL]:
		for line: String in _spoken(path).split("\n", false):
			var text := line.strip_edges()
			if text.begins_with("Festmeisterin:") or text.contains(": "):
				assert_true(
					RegEx.create_from_string("^[A-ZÄÖÜ][a-zäöüß]+: ").search(text) != null,
					"a speaker is a name: " + text
				)
			else:
				for mark: String in ["!", "?", "…"]:
					assert_false(text.contains(mark), "narration: no %s in %s" % [mark, text])
	var voices := FileAccess.get_file_as_string("res://content/dialogue/voices.json")
	for speaker: String in ["Festmeisterin", "Musikerin", "Bäckerin", "Dichter", "Torwächter"]:
		assert_true(voices.contains('"%s"' % speaker), "%s has a voice" % speaker)
	assert_true(voices.contains('"Hallenwächter"') and voices.contains('"Richter"'))


func test_the_old_sentences_come_back_as_sentences_and_never_as_a_whole_cue() -> void:
	assert_true(
		_written(MARKT, "festmaster_back")[1] == "Festmeisterin: " + LineText.of("mk_fest_7"),
		"the toast is the old toast"
	)
	assert_true(
		_written(MARKT, "musician_back")[0] == "Musikerin: " + LineText.of("mk_music_1"),
		"the best melody of the town, which is also the only one"
	)
	assert_eq(_written(SPIEGEL, "mirror_back")[0], LineText.of("sh_mirror_1"))
	assert_eq(_written(SPIEGEL, "mirror_back")[1], LineText.of("sh_mirror_2"))
	var all_old := {}
	for id: String in ["mk_fest_7", "mk_music_1", "sh_mirror_1", "sh_mirror_2"]:
		all_old[LineText.of(id)] = true
	for path: String in [MARKT, SPIEGEL]:
		for cue: String in _cues(path):
			var fresh := 0
			for line: String in _written(path, cue):
				var bare := line.substr(line.find(": ") + 2) if line.contains(": ") else line
				if not all_old.has(bare) and not all_old.has(line):
					fresh += 1
			assert_gte(fresh, 1, "%s says something of its own" % cue)


func test_the_poet_repeats_the_verse_word_for_word_and_does_not_notice() -> void:
	var again := await DialogueWalk.play(MARKT, "poet_back", PackedStringArray(["Noch einmal."]))
	assert_eq(again.size(), 3)
	assert_eq(again[1], again[2], "the same line, character for character")
	var thanks := await DialogueWalk.play(MARKT, "poet_back", PackedStringArray(["Danke."]))
	assert_ne(thanks[2], thanks[1], "the other answer has a line of its own")


func test_the_answers_are_two_unconditional_ones_each_with_lines_of_its_own() -> void:
	for cue: String in ["festmaster_back", "musician_back", "poet_back"]:
		var groups := await DialogueWalk.groups(MARKT, cue)
		assert_eq(groups.size(), 1, "%s has one choice" % cue)
		assert_eq(groups[0].size(), 2, "%s: two answers" % cue)
		var first := await DialogueWalk.play(MARKT, cue, PackedStringArray([groups[0][0]]))
		var second := await DialogueWalk.play(MARKT, cue, PackedStringArray([groups[0][1]]))
		assert_ne(first.slice(2), second.slice(2), "%s: each answer goes its own way" % cue)
		assert_false(_source(MARKT).contains("- …"), "no silence needed: two answers are enough")
	for cue: String in ["baker_back", "gatekeeper_back", "guest_back", "board_back"]:
		assert_eq((await DialogueWalk.groups(MARKT, cue)).size(), 0, "%s: nothing to answer" % cue)


func test_the_mirror_shows_her_and_explains_nothing() -> void:
	var lines := _written(SPIEGEL, "mirror_back")
	assert_eq(lines[2], "Dich zeigt er.", "it is the one difference to Act I's mirror")
	assert_eq(LineText.of("sh_mirror_3"), "Dich zeigt er nicht.")
	var told := "\n".join(lines)
	for word: String in ["wirklich", "schön", "hässlich", "erkennst", "du bist", "bedeutet"]:
		assert_false(told.contains(word), "the mirror does not judge or explain: " + word)
	assert_null(
		RegEx.create_from_string("\\bechte?[mnrs]?\\b").search(told), "nor says what is real"
	)
	var looked := await DialogueWalk.play(SPIEGEL, "mirror_back", PackedStringArray(["Weiter"]))
	var away := await DialogueWalk.play(SPIEGEL, "mirror_back", PackedStringArray(["Wegsehen."]))
	assert_ne(looked.slice(5), away.slice(5), "each way has lines of its own")
	assert_false(WorldState.has_facet("perception"), "and neither sets anything")


func test_the_richter_begins_a_long_sentence_and_calls_after_her_and_is_not_done() -> void:
	var lines := _written(RICHTER, "voice_first")
	assert_eq(lines.size(), 2)
	assert_true(lines[0].begins_with("Richter: Zu Protokoll: Die Angeklagte"), "his record")
	assert_gt(lines[0].length(), 140, "a list that takes its time")
	assert_true(lines[0].ends_with("–"), "and does not end")
	assert_true(lines[1].contains("noch nicht fertig"), "he calls after her")
	assert_false(lines[1].contains("–"))
	for line: String in lines:
		assert_true(line.begins_with("Richter: "), "only he speaks")
		for mark: String in ["!", "?"]:
			assert_false(line.contains(mark), "he does not shout or ask")
		for word: String in ["wertlos", "Versager", "peinlich", "schuld", "Du bist", "du bist"]:
			assert_false(line.contains(word), "no verdict on her, only trifles: " + word)


func test_the_quiet_sentence_is_about_nothing_in_particular_and_not_about_her() -> void:
	var lines := _written(RICHTER, "voice_late")
	assert_eq(lines.size(), 1, "one sentence")
	var told := lines[0]
	assert_true(told.begins_with("Richter: "))
	for word: String in ["Angeklagte", "Protokoll", "Akte", "du ", "dich", "dir ", "dein", "Du "]:
		assert_false(told.contains(word), "nothing about her, no record: " + word)
	assert_true(told.contains("vorher") and told.contains("anderer"), "he says it before others do")
	assert_false(told.contains("!") or told.contains("?") or told.contains("–"))
	for word: String in ["früher", "damals", "Kind", "Eltern", "Vater", "Mutter", "Schuld"]:
		assert_false(told.contains(word), "no cause and no culprit: " + word)
