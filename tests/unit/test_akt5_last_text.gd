extends GutTest
## Act V, segment G4: what the keeper says in the load (docs/akt5/REGIONSBRIEFE.md, O4, O13, O19,
## O20). The offer, his word at the console while it runs, the call of each wave, the pause and the
## return, the reckoning at the end of the fourth wave (which he reads aloud and keeps to), and his
## rest afterwards. He is never cured, never comforted, never warned of danger; the help that says
## the load is too much for two hands is always there and says what is allowed, nothing more.
## The run itself (the levers, the waves) is tested in test_akt5_last, the hall in
## test_akt5_last_szene.

const ANLAGE := "res://content/dialogue/akt5/anlage.dialogue"
const FILE := "res://content/dialogue/akt5/last.dialogue"
const CUES: PackedStringArray = [
	"wave_two", "wave_three", "wave_four", "load_wait", "load_back", "load_over"
]
const SPEAKER := "Wächter: "


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _source(path := FILE) -> String:
	return FileAccess.get_file_as_string(path)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(lst_[a-z0-9_]+)\\]").search_all(_source()):
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


# --- The file ---------------------------------------------------------------------------------


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
	# the segment plans 40 lines (plus or minus eight) in all; 22 of them are played by the scene
	assert_gte(ids.size(), 16)
	assert_lte(ids.size(), 28)
	assert_false(_source().contains("[if "), "no cue of the run reads a flag")
	assert_false(_source().contains("do "), "and none sets one: the scene does")


func test_nothing_in_the_load_is_a_digit_and_narration_has_no_speaker() -> void:
	for path: String in [FILE, ANLAGE]:
		for digit: String in "0123456789":
			assert_false(_spoken(path).contains(digit), "numbers are written out: " + digit)
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with(SPEAKER):
			continue
		assert_false(text.contains(": "), "narration has no speaker: " + text)


func test_the_keeper_stays_dry_short_and_never_warns_comforts_or_teaches() -> void:
	var said := PackedStringArray()
	for path: String in [FILE, ANLAGE]:
		for line in _spoken(path).split("\n", false):
			var text := line.strip_edges()
			if text.begins_with(SPEAKER):
				said.append(text.trim_prefix(SPEAKER))
	var all := "\n".join(said)
	for line in said:
		assert_lte(line.split(" ", false).size(), 16, "short: " + line)
		assert_false(line.contains("!"), "no shout: " + line)
	for word: String in [
		"Kind",
		"Tür",
		"Riegel",
		"Angst",
		"Gefahr",
		"Last",
		"gefährlich",
		"Vorsicht",
		"loslassen",
		"vertrau",
		"Vertrauen",
		"Kontrolle",
		"Zwang",
		"Danke",
		"danke",
		"geheilt",
		"gut gemacht",
		"toll",
		"Lehre",
		"verstanden",
		"Einsicht",
	]:
		assert_false(all.contains(word), "the keeper never says %s" % word)


# --- The waves ------------------------------------------------------------------------------------


func test_each_wave_calls_its_three_levers_and_an_order_in_words() -> void:
	var expected := {
		"wave_two": ["Vier bis Sechs", "Erst Sechs, dann Fünf, dann Vier"],
		"wave_three": ["Sieben bis Neun", "Erst Neun, dann Acht, dann Sieben"],
		"wave_four": ["Zehn bis Zwölf", "Erst Zwölf, dann Elf, dann Zehn"],
	}
	for cue: String in expected:
		var told := await _told(cue)
		for phrase: String in expected[cue]:
			assert_true(told.contains(phrase), "%s: %s" % [cue, phrase])
		var before := WorldState.state.flags.duplicate()
		await DialogueWalk.play(FILE, cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing: the scene does" % cue)


func test_the_waves_say_nothing_about_what_comes_of_not_keeping_up() -> void:
	for cue: String in ["wave_two", "wave_three", "wave_four"]:
		var told := await _told(cue)
		for word: String in [
			"schief", "Strafe", "Folge", "droht", "scheitert", "verloren", "schaffst", "musst"
		]:
			assert_false(told.contains(word), "%s: no %s" % [cue, word])


func test_the_fourth_wave_is_counted_in_breaths() -> void:
	var told := await _told("wave_four")
	assert_true(told.contains("Atemzügen"))
	assert_true(told.contains("Das sind alle"))


# --- The pause ------------------------------------------------------------------------------------


func test_the_pause_is_entered_dryly_without_a_reproach_and_costs_nothing() -> void:
	var told := await _told("load_wait")
	assert_true(told.contains("Ich halte an"))
	assert_true(told.contains("Die Hebel bleiben"), "what the run does: it waits")
	var back := await _told("load_back")
	assert_true(back.contains("Stand wie vor der Pause"))
	for text: String in [told, back]:
		for word: String in ["endlich", "zu spät", "wo warst", "Vorwurf", "wieder da", "gut"]:
			assert_false(text.contains(word), "no reproach and no praise: %s" % word)
	assert_false(_block("load_back").contains("Hebel Eins"), "the cue does not know a lever")


# --- The reckoning --------------------------------------------------------------------------------


func test_the_keeper_reckons_it_up_aloud_enters_it_and_keeps_to_it() -> void:
	var seen := await DialogueWalk.play(FILE, "load_over")
	var told := "\n".join(seen)
	assert_true(told.contains("Zwölf Hebel") and told.contains("Zwei Hände"), "the sum")
	assert_true(told.contains("zweimal gerechnet"), "he checks it")
	assert_true(told.contains("nicht erfüllt"), "and enters what it is")
	assert_true(_has(seen, "lst_over_9"))
	assert_true(LineText.of("lst_over_9").contains("Ich bleibe dabei"), "his last word stands")
	assert_true(LineText.of("lst_over_9").contains("Das Verfahren verlangt es trotzdem"))
	assert_lte(seen.size(), 10)
	assert_gte(seen.size(), 8)


func test_the_reckoning_holds_at_every_pace_because_it_names_no_number_of_seconds() -> void:
	var told := await _told("load_over")
	for word: String in ["Sekunden", "Minute", "schnell", "langsam"]:
		assert_false(told.contains(word), "the sum is the same for every setting: no %s" % word)
	assert_true(told.contains("alle paar Atemzüge"))


func test_the_reckoning_has_no_lesson_no_thanks_and_no_word_for_what_follows() -> void:
	var told := await _told("load_over")
	for word: String in [
		"weniger", "lassen", "Pult verlassen", "wegtreten", "Hilfe", "Dank", "Trost", "Einsicht"
	]:
		assert_false(told.contains(word), "no %s: that is for G5" % word)


# --- The offer, his word at the console, his rest ----------------------------------------------


func test_the_offer_after_the_trial_sets_the_flag_last_and_is_never_needed() -> void:
	WorldState.set_flag("plant.probe_done")
	var answers := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_eq(answers.size(), 3)
	assert_true("Fang an" in answers[0])
	assert_eq(answers[2], "…", "the silence stays the last")
	var block := _block("load_offer", ANLAGE)
	assert_gt(block.find('set_flag("plant.load")'), block.find("[ID:anl_load_6]"), "flag last")
	var left := await DialogueWalk.play(ANLAGE, "waechter", PackedStringArray(["Noch nicht"]))
	assert_false(WorldState.has_flag("plant.load"), "not now costs nothing")
	assert_gte(left.size(), 5)
	var begun := await DialogueWalk.play(ANLAGE, "waechter", PackedStringArray(["Fang an"]))
	assert_true(WorldState.has_flag("plant.load"))
	assert_true("\n".join(begun).contains("Wer das Pult verlässt, hält den Betrieb an"))


func test_while_the_run_goes_on_he_answers_and_the_help_is_always_one_answer_away() -> void:
	WorldState.set_flag("plant.probe_done")
	WorldState.set_flag("plant.load")
	var answers := await DialogueWalk.answers(ANLAGE, "waechter")
	assert_eq(answers.size(), 3)
	assert_true("Weiter" in answers[0] and "Wie schaffe ich das" in answers[1])
	assert_eq(answers[2], "…", "the silence stays the last")
	var help := await _told("waechter", PackedStringArray(["Wie schaffe"]), ANLAGE)
	assert_true(help.contains("zwei Hände zu viele"), "straight, without detours")
	assert_true(help.contains("Vom Pult zu treten ist zulässig"), "what is allowed")
	assert_true(help.contains("Ich rate nicht dazu"), "he does not advise it and stays")
	for word: String in ["loslassen", "vertrau", "weniger", "Kontrolle", "musst", "solltest"]:
		assert_false(help.contains(word), "no lesson: %s" % word)
	var intro := await _told("waechter", PackedStringArray(["Weiter"]), ANLAGE)
	assert_false(intro.contains("Eins. Du."), "no second introduction")


func test_the_help_is_in_the_journal_too_and_says_the_same_without_the_word_for_it() -> void:
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_LOAD"), "QUEST_MAIN_MOUNTAIN_WAY_LOAD")
	var line := tr("QUEST_MAIN_MOUNTAIN_WAY_LOAD")
	assert_true(line.contains("Hände") or line.contains("Hand"), "more than two hands can do")
	for word: String in ["loslassen", "Loslassen", "vertrauen"]:
		assert_false(line.contains(word), "no %s" % word)
	var quest := ContentDB.quest("main_mountain_way")
	assert_true(quest.can_advance("plant", "load"))
	assert_true(quest.stage("load").is_final(), "G5 hangs the next stage on it")
	assert_false(quest.stage("plant").is_final())


func test_after_the_run_has_stopped_he_asks_nothing_and_offers_nothing_and_keeps_a_reservation(
) -> void:
	WorldState.set_flag("plant.probe_done")
	WorldState.set_flag("plant.load")
	WorldState.set_flag("plant.overload")
	assert_eq((await DialogueWalk.answers(ANLAGE, "waechter")).size(), 0, "nothing is asked")
	var seen := await DialogueWalk.play(ANLAGE, "waechter")
	assert_true(_has(seen, "anl_over_3"))
	assert_true(
		LineText.of("anl_over_3").contains("vorbehaltlich"), "the last line is a reservation"
	)
	assert_false(_has(seen, "anl_run_2"), "the run is over")
	var told := "\n".join(seen)
	for word: String in ["Fang an", "Betrieb aufnehmen", "Danke", "bald"]:
		assert_false(told.contains(word), "nothing is offered: %s" % word)


func test_the_latest_state_wins_when_several_flags_stand() -> void:
	for flag: String in ["plant.probe", "plant.probe_done", "plant.load"]:
		WorldState.set_flag(flag)
	var running := await DialogueWalk.play(ANLAGE, "waechter")
	assert_true(_has(running, "anl_run_2"), "the load beats the rest after the trial")
	WorldState.set_flag("plant.overload")
	var over := await DialogueWalk.play(ANLAGE, "waechter")
	assert_true(_has(over, "anl_over_2"), "and the end beats the load")
