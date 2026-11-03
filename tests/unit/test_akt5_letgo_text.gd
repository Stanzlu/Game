extends GutTest
## Act V, segment G5: what the keeper says when the levers fall by themselves
## (docs/akt5/REGIONSBRIEFE.md, O4, O10, O13). The empty console, the first lever, the burst of
## steam, the lamp that goes out and is not mended, the end in which he enters it all and doubts
## it, the potato; and in anlage.dialogue the help "Und jetzt?", his rest after the letting go (with
## the answer that only the facet trust shows) and the potato's entry. He is never cured, never
## grateful, never taught; the hall stands anyway, and he says it is one case. The hall itself is
## tested in test_akt5_letgo_szene, the model in test_akt5_letgo.

const ANLAGE := "res://content/dialogue/akt5/anlage.dialogue"
const FILE := "res://content/dialogue/akt5/loslassen.dialogue"
const CUES: PackedStringArray = [
	"letgo_away", "letgo_first", "letgo_mid", "letgo_defect", "letgo_end", "letgo_potato"
]
const SPEAKER := "Wächter: "
## What he never says (the lesson, the thanks, the cure, the reason behind him).
const NEVER: PackedStringArray = [
	"Kind",
	"Tür",
	"Riegel",
	"Angst",
	"Gefahr",
	"loslassen",
	"Loslassen",
	"vertrau",
	"Vertrauen",
	"Kontrolle",
	"Danke",
	"danke",
	"geheilt",
	"gut gemacht",
	"toll",
	"Lehre",
	"verstanden",
	"Einsicht",
	"Symbol",
	"bedeutet",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _source(path := FILE) -> String:
	return FileAccess.get_file_as_string(path)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(los_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out.
func _spoken(path := FILE) -> String:
	var spoken := ""
	for line in _source(path).split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += line.substr(0, at) + "\n"
	return spoken


func _block(cue: String, path := FILE) -> String:
	var text := ""
	var inside := false
	for line in _source(path).split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside:
			text += line + "\n"
	return text


func _told(cue: String, picks: PackedStringArray = [], path := FILE) -> String:
	return "\n".join(await DialogueWalk.play(path, cue, picks))


## What the keeper says in the G5 cues of both files.
func _said() -> PackedStringArray:
	var said := PackedStringArray()
	var blocks: Array[String] = []
	for cue in CUES:
		blocks.append(_block(cue))
	for cue: String in ["waechter_done", "potato_entry"]:
		blocks.append(_block(cue, ANLAGE))
	for block in blocks:
		for line in block.split("\n", false):
			var at := line.find("[ID:")
			var text := line.substr(0, at).strip_edges() if at > -1 else ""
			if text.begins_with(SPEAKER):
				said.append(text.trim_prefix(SPEAKER))
	return said


# --- The file -----------------------------------------------------------------------------------


func test_the_file_tells_the_cues_the_scene_plays_in_draft_with_unique_ids() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"))
	# the segment plans 45 lines (plus or minus eight) in all; the scene plays these
	assert_gte(ids.size(), 18)
	assert_lte(ids.size(), 30)
	assert_false(_source().contains("[if "), "no cue of the letting go reads a flag")
	assert_false(_source().contains("\ndo "), "and none sets one: the scene does")


func test_the_cues_set_nothing_the_scene_does() -> void:
	for cue in CUES:
		var before := WorldState.state.flags.duplicate()
		await DialogueWalk.play(FILE, cue)
		assert_eq(WorldState.state.flags, before, "%s sets no flag" % cue)
		assert_false(WorldState.has_facet("trust"), "%s sets no facet" % cue)


func test_nothing_he_says_is_a_digit_and_narration_has_no_speaker() -> void:
	for path: String in [FILE, ANLAGE]:
		for digit: String in "0123456789":
			assert_false(_spoken(path).contains(digit), "numbers are written out: " + digit)
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with(SPEAKER):
			continue
		assert_false(text.contains(": "), "narration has no speaker: " + text)
		assert_false(text.contains("…"), "narration has no ellipsis: " + text)


func test_the_keeper_stays_dry_short_and_never_thanks_teaches_or_is_cured() -> void:
	var said := _said()
	assert_gte(said.size(), 20)
	var all := "\n".join(said)
	for line in said:
		assert_lte(line.split(" ", false).size(), 16, "short: " + line)
		assert_false(line.contains("!"), "no shout: " + line)
		assert_false(line.contains("?"), "he asks nothing: " + line)
	for word: String in NEVER:
		assert_false(all.contains(word), "the keeper never says %s" % word)
	var narration := _spoken()
	for word: String in ["Kind", "Tür", "Angst", "loslassen", "Vertrauen"]:
		assert_false(narration.contains(word), "nor does the text: %s" % word)


# --- The course -------------------------------------------------------------------------------


func test_the_empty_console_is_entered_and_the_pause_is_without_an_end() -> void:
	var told := await _told("letgo_away")
	assert_true(told.contains("Pult unbesetzt"))
	assert_true(told.contains("zwölf Hebel"), "all twelve stand up")
	assert_true(told.contains("keiner wird bedient"))
	assert_true(told.contains("laufend"), "and the pause has no end in the column")


func test_the_first_lever_falls_unpulled_and_the_column_says_nobody() -> void:
	var told := await _told("letgo_first")
	assert_true(told.contains("Hebel Drei"), "the one the trial called first")
	assert_true(told.contains("Das war nicht eingeplant. Ich trage es ein."), "O13")
	assert_true(told.contains("niemand"), "the joke is the column")
	assert_false(told.contains("Hebel Eins"), "the cue names no other lever")


func test_half_way_something_goes_wrong_and_his_hand_does_not_pull() -> void:
	var told := await _told("letgo_mid")
	assert_true(told.contains("Dampf"))
	assert_true(told.contains("zieht nicht"), "the hand over the lever stays")
	assert_true(told.contains("Ich ziehe nicht. Ich trage ein, dass ich nicht ziehe."))
	for word: String in ["Gefahr", "gefährlich", "Vorsicht", "Hilfe", "Alarm", "Notfall"]:
		assert_false(told.contains(word), "no %s: the hall does not end" % word)


func test_a_lamp_goes_out_he_enters_it_open_and_nobody_mends_it() -> void:
	var seen := await DialogueWalk.play(FILE, "letgo_defect")
	var told := "\n".join(seen)
	assert_true(told.contains("Defekt. Offen."))
	assert_true(told.contains("Lampe Eins"), "the left one at the girder")
	assert_true(told.contains("Niemand geht zur Lampe"), "nobody mends it")
	for word: String in ["repariere", "behebe", "ersetze", "Ersatz", "Werkzeug", "Leiter"]:
		assert_false(told.contains(word), "no %s: the defect stays" % word)


func test_the_end_enters_it_all_and_doubts_it_and_ends_on_a_reservation() -> void:
	var seen := await DialogueWalk.play(FILE, "letgo_end")
	var told := "\n".join(seen)
	assert_true(told.contains("Alle Hebel unten"))
	assert_true(told.contains("kein zulässiger Zustand"), "he does not accept it")
	assert_true(told.contains("trotzdem ein"), "and enters it anyway")
	assert_true(told.contains("Einzelfall"), "one case")
	assert_true(told.contains("Das Verfahren ist richtig"), "and keeps the procedure")
	assert_true(told.contains("Ohne Eintrag"), "the field he leaves out, as every time")
	assert_true(seen[seen.size() - 1].contains("Bis dahin gilt das Verfahren"), "the last word")
	assert_false(told.contains("vorbehaltlich"), "that one is used already (anl_over_3)")
	assert_lte(seen.size(), 10)
	assert_gte(seen.size(), 8)
	for word: String in ["weniger", "lassen", "warten", "Wegtreten", "Pult verlassen", "Hilfe"]:
		assert_false(told.contains(word), "no word for what the wait was: %s" % word)


func test_a_potato_rolls_out_and_the_text_says_no_more() -> void:
	var seen := await DialogueWalk.play(FILE, "letgo_potato")
	assert_eq(seen.size(), 2)
	assert_true(seen[0].contains("Rohr links"))
	assert_eq(seen[1], "Eine Kartoffel.")


# --- The help, his rest, the potato -----------------------------------------------------------


func test_the_help_after_the_load_is_one_answer_away_and_says_only_what_is_allowed() -> void:
	for flag: String in ["plant.probe_done", "plant.load", "plant.overload"]:
		WorldState.set_flag(flag)
	var answers := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_eq(answers.size(), 3)
	assert_true("Und jetzt" in answers[0], "the help comes first")
	assert_eq(answers[1], "Gut.", "an answer that costs nothing")
	assert_eq(answers[2], "…", "the silence stays the last")
	var help := await _told("waechter", PackedStringArray(["Und jetzt"]), ANLAGE)
	assert_true(help.contains("keinen Schritt"), "the procedure has none for this")
	assert_true(help.contains("das Pult nicht zu bedienen und abzuwarten"), "what is allowed")
	assert_true(help.contains("Ich rate nicht dazu"), "he does not advise it")
	for word: String in ["loslassen", "vertrau", "Kontrolle", "musst", "solltest", "bringt"]:
		assert_false(help.contains(word), "no lesson: %s" % word)
	var thanks := await _told("waechter", PackedStringArray(["Gut"]), ANLAGE)
	assert_true(thanks.contains("zur Kenntnis genommen"), "he cannot enter thanks")


func test_after_the_letting_go_the_latest_state_wins() -> void:
	for flag: String in ["plant.probe_done", "plant.load", "plant.overload", "plant.letgo"]:
		WorldState.set_flag(flag)
	var seen := await DialogueWalk.play(ANLAGE, "waechter")
	assert_true(LineText.of("anl_done_1") in seen, "his rest beats the reckoning")
	assert_false(LineText.of("anl_over_3") in seen)


func test_his_rest_checks_it_all_names_the_lamp_and_keeps_the_page_of_single_cases() -> void:
	WorldState.set_flag("plant.letgo")
	var seen := await DialogueWalk.play(ANLAGE, "waechter")
	var told := "\n".join(seen)
	assert_true(told.contains("Lampe Eins: defekt, unbehoben"))
	assert_true(told.contains("Die Halle steht trotzdem"))
	assert_true(told.contains("Einzelfälle"))
	assert_false(told.contains("Defekt. Offen."), "not the words of the cue that plays it")
	for word: String in NEVER:
		assert_false(told.contains(word), "he never says %s" % word)


func test_the_answers_of_his_rest_end_on_the_silence_and_the_facet_shows_beside_them() -> void:
	WorldState.set_flag("plant.letgo")
	var plain := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_eq(plain, PackedStringArray(["Es steht noch alles.", "…"]), "nothing else without trust")
	WorldState.set_facet("trust")
	var trusting := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_eq(trusting.size(), 3)
	assert_eq(trusting[0], "Es steht noch alles.", "the unconditional answer stays first")
	assert_true("Nichts einzutragen" in trusting[1], "the facet shows beside it")
	assert_eq(trusting[2], "…", "the silence stays the last")


func test_the_answer_of_the_facet_asks_for_nothing_and_changes_nothing_in_him() -> void:
	WorldState.set_flag("plant.letgo")
	WorldState.set_facet("trust")
	var told := await _told("waechter", PackedStringArray(["Nichts einzutragen"]), ANLAGE)
	assert_true(told.contains("Ohne Eintrag"))
	assert_true(told.contains("noch nie benutzt"), "he has never used it")
	for word: String in ["jetzt", "vielleicht", "heute", "zum ersten Mal", "werde"]:
		assert_false(told.contains(word), "no progress: %s" % word)
	var plain := await _told("waechter", PackedStringArray(["Es steht noch alles"]), ANLAGE)
	assert_true(plain.contains("Erwartung bleibt trotzdem eingetragen"), "and he keeps to it")


func test_the_potato_answer_shows_only_while_she_holds_it_and_he_has_not_entered_it() -> void:
	WorldState.set_flag("plant.letgo")
	assert_false("Die kam aus dem Rohr." in await DialogueWalk.answers(ANLAGE, "waechter"))
	WorldState.set_flag("plant.potato_taken")
	var answers := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_true("Die kam aus dem Rohr." in answers)
	assert_eq(answers[answers.size() - 1], "…", "the silence stays the last")
	WorldState.set_flag("plant.potato_entered")
	assert_false("Die kam aus dem Rohr." in await DialogueWalk.answers(ANLAGE, "waechter"))


func test_the_potato_is_entered_as_average_and_nothing_is_explained() -> void:
	WorldState.set_flag("plant.letgo")
	WorldState.set_flag("plant.potato_taken")
	assert_false(WorldState.has_flag("plant.potato_entered"))
	var told := await _told("waechter", PackedStringArray(["Die kam aus dem Rohr"]), ANLAGE)
	assert_true(told.contains("Mittelgroß"))
	assert_true(told.contains("Nicht eingetragen"))
	assert_true(told.contains("durchschnittlich"))
	assert_true(told.contains("Besonderheiten: keine. Das ist bemerkenswert."), "Bible 33")
	assert_true(told.contains("Verbleib: bei dir"), "she keeps it")
	assert_true(WorldState.has_flag("plant.potato_entered"))
	for word: String in NEVER:
		assert_false(told.contains(word), "no %s" % word)
	var block := _block("potato_entry", ANLAGE)
	assert_gt(
		block.find('set_flag("plant.potato_entered")'), block.find("[ID:anl_potato_7]"), "last"
	)


# --- The journal --------------------------------------------------------------------------------


func test_the_journal_follows_the_walk_and_the_potato_without_a_lesson() -> void:
	for key: String in [
		"QUEST_MAIN_MOUNTAIN_WAY_LETGO",
		"QUEST_SIDE_PLANT_POTATO_TITLE",
		"QUEST_SIDE_PLANT_POTATO_SHOW",
		"QUEST_SIDE_PLANT_POTATO_DONE",
	]:
		var line := tr(key)
		assert_ne(line, key, "%s is translated" % key)
		for digit: String in "0123456789":
			assert_false(line.contains(digit), "%s: numbers are written out" % key)
		for word: String in ["loslassen", "Loslassen", "Vertrauen", "vertrauen", "Kontrolle"]:
			assert_false(line.contains(word), "%s: no %s" % [key, word])
	var quest := ContentDB.quest("side_plant_potato")
	assert_not_null(quest)
	assert_true(quest.can_advance("show", "done"))
	assert_true(quest.stage("done").is_final())
	assert_true(ContentDB.quest("main_mountain_way").can_advance("load", "letgo"))
