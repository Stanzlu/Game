extends GutTest
## Act V, segment G3: the Anlage and the keeper (docs/akt5/REGIONSBRIEFE.md, O4, O6, O13, O17). A
## voice behind the fence that has to break off counting, a hall with twelve levers (three in use),
## the keeper who counts, numbers and enters what was not planned, a trial of three levers, a small
## closed door that is seen and not talked about, a dial with a groove in its glass. Nobody is
## cured and nobody is comforted. The hall's map and scene are tested in test_akt5_anlage_szene.

const FILE := "res://content/dialogue/akt5/anlage.dialogue"
const CUES: PackedStringArray = [
	"gate",
	"gate_knock",
	"waechter",
	"probe_offer",
	"waechter_wait",
	"waechter_again",
	"lever_wrong",
	"lever_right",
	"lever_idle",
	"small_door",
	"gauges",
	"worn_dial",
	"steam_pipe",
	"load_offer",
	"waechter_run",
	"waechter_over",
	"waechter_done",
	"potato_entry",
]
const SPEAKER := "Wächter: "


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit in RegEx.create_from_string("\\[ID:(anl_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line and answer (before its ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += line.substr(0, at) + "\n"
	return spoken


## What the keeper says, line by line (the speaker's name left out).
func _said() -> PackedStringArray:
	var said: PackedStringArray = []
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with(SPEAKER):
			said.append(text.trim_prefix(SPEAKER))
	return said


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


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
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
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# G3 plans 45 lines (plus or minus eight), G4 adds the keeper's offer, his run and his rest here
	# (the lines the scene plays during the load are in last.dialogue), and the answers on top
	# G5 adds his rest after the letting go and the potato (the cues the scene plays are in loslassen.dialogue)
	assert_lte(ids.size() - answers, 96, "the lines of the segments")
	assert_gte(ids.size() - answers, 37, "and not a hall without things")


func test_narration_has_no_speaker_and_nothing_in_the_text_is_a_digit() -> void:
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with("-") or text.begins_with(SPEAKER):
			continue
		assert_false(text.contains(": "), "narration has no speaker: " + text)
	for digit: String in "0123456789":
		assert_false(_spoken().contains(digit), "numbers are written out: " + digit)
	assert_false(_source().contains("Du heißt"), "he never asks her name")


func test_the_keeper_is_short_dry_and_never_cured_comforted_or_diagnosed() -> void:
	var said := _said()
	assert_gte(said.size(), 18, "all of his speech is read")
	for line in said:
		assert_lte(line.split(" ", false).size(), 16, "short: " + line)
		assert_false(line.contains("!"), "no shout: " + line)
	var all := "\n".join(said)
	for word: String in [
		"Kind",
		"Tür",
		"Riegel",
		"Angst",
		"Zwang",
		"Kontrollzwang",
		"Sucht",
		"geheilt",
		"Danke",
		"danke",
		"froh",
		"Gefühl",
		"Heilung",
		"Therapie",
		"gut gemacht",
		"toll",
		"super",
		"Kontrolle",
		"loslassen",
		"Lebe",
	]:
		assert_false(all.contains(word), "the keeper never says %s" % word)


func test_the_small_door_is_seen_and_not_explained_and_nobody_speaks_of_it() -> void:
	var told := await _told("small_door")
	for word: String in ["Kind", "wem", "warum", "Warum", "gehört", "Grund", "weil"]:
		assert_false(told.contains(word), "the door is seen, not explained: %s" % word)
	assert_false(_block("small_door").contains(SPEAKER), "nobody speaks of it")


# --- The gate ---------------------------------------------------------------------------------


func test_the_gate_is_a_sign_a_chain_and_a_choice_to_knock_or_to_walk_on() -> void:
	var answers := await DialogueWalk.answers(FILE, "gate")
	assert_eq(answers.size(), 2)
	assert_true("Klopfen" in answers[0] and "Weitergehen" in answers[1])
	var before := WorldState.state.flags.duplicate()
	var left := await DialogueWalk.play(FILE, "gate", PackedStringArray(["Weitergehen"]))
	assert_eq(left.size(), 2, "walking on tells nothing more")
	assert_eq(WorldState.state.flags, before, "and sets nothing")
	var told := "\n".join(left)
	assert_true(told.contains("Messingschild") and told.contains("Kette"), "what the picture has")
	assert_true(told.contains("tickt"), "the ticking is first heard here (the cue of G2 is silent)")
	assert_true(told.contains("Wächter"), "the sign is where his name is first read")


func test_knocking_opens_the_gate_with_the_last_line_and_nothing_else() -> void:
	var block := _block("gate_knock")
	var flag := 'set_flag("grat.gate_open")'
	assert_gt(block.find(flag), -1)
	assert_gt(block.find(flag), block.find("[ID:anl_knock_5]"), "the gate opens late")
	assert_lt(block.find(flag), block.find("[ID:anl_knock_6]"), "and before the last line")
	var before_flags := WorldState.state.flags.size()
	var seen := await DialogueWalk.play(FILE, "gate", PackedStringArray(["Klopfen"]))
	assert_true(WorldState.has_flag("grat.gate_open"))
	assert_true(_has(seen, "anl_knock_2") and _has(seen, "anl_knock_6"))
	assert_eq(WorldState.state.flags.size(), before_flags + 1, "it sets nothing else")
	var voice := "\n".join(seen)
	assert_true(voice.contains("Moment"), "he has to break off counting")
	assert_true(voice.contains("Eintritt"))


# --- The keeper ---------------------------------------------------------------------------------


func test_the_first_meeting_counts_her_and_offers_the_trial_and_the_silence_stays_the_last(
) -> void:
	var answers := await DialogueWalk.answers(FILE, "waechter")
	assert_eq(answers.size(), 3)
	assert_true("Hebel" in answers[0])
	assert_eq(answers[2], "…", "the silence is the last answer")
	var told := "\n".join(
		await DialogueWalk.play(FILE, "waechter", PackedStringArray(["Ich schaue"]))
	)
	assert_true(told.contains("Eins. Du."), "he counts her")
	assert_true(told.contains("Dampf"), "a control question he answers himself")
	assert_false(WorldState.has_flag("plant.probe"), "looking around asks for nothing")
	assert_false(WorldState.has_flag("plant.probe_done"))


func test_the_offer_calls_the_order_in_the_words_the_scene_checks_and_sets_its_flag_last() -> void:
	var seen := await DialogueWalk.play(FILE, "waechter", PackedStringArray(["Zeig mir"]))
	assert_true(_has(seen, "anl_probe_5"), "the order is called")
	var order := LineText.of("anl_probe_5")
	var drei := order.find("Drei")
	var eins := order.find("Eins")
	var zwei := order.find("Zwei")
	assert_true(drei > -1 and drei < eins and eins < zwei, "Three, then One, then Two")
	assert_eq(Array(MaschineScene.ORDER), [3, 1, 2], "the scene checks the same")
	assert_true(WorldState.has_flag("plant.probe"))
	var block := _block("probe_offer")
	assert_gt(block.find('set_flag("plant.probe")'), block.find("[ID:anl_probe_6]"), "flag last")
	assert_true("\n".join(seen).contains("Keine Frist"), "no deadline, no penalty")


func test_the_states_of_the_keeper_follow_the_flags_and_the_last_one_asks_for_nothing() -> void:
	WorldState.set_flag("plant.probe")
	var waiting := await DialogueWalk.play(FILE, "waechter")
	assert_true(_has(waiting, "anl_wait_2") and _has(waiting, "anl_wait_3"), "the repetition")
	assert_false(_has(waiting, "anl_w_2"), "no second introduction")
	assert_eq((await DialogueWalk.answers(FILE, "waechter")).size(), 0, "nothing is asked of her")
	WorldState.set_flag("plant.probe_done")
	var after := await DialogueWalk.play(FILE, "waechter", PackedStringArray(["Noch nicht"]))
	assert_true(_has(after, "anl_again_2"), "after the trial")
	assert_false(_has(after, "anl_wait_2"))
	var told := "\n".join(after)
	for word: String in ["bald", "gleich geht", "später", "Last", "Hebel Vier", "nächste"]:
		assert_false(told.contains(word), "nothing is announced: %s" % word)


func test_the_wrong_order_costs_nothing_and_does_not_give_the_order_away() -> void:
	var told := await _told("lever_wrong")
	assert_true(told.contains("Nein"))
	for word: String in ["Drei", "Eins", "Zwei", "Strafe", "Fehler", "falsch gemacht"]:
		assert_false(told.contains(word), "no %s" % word)
	var before := WorldState.state.flags.duplicate()
	await DialogueWalk.play(FILE, "lever_wrong")
	assert_eq(WorldState.state.flags, before, "the scene decides, the text sets nothing")


func test_the_right_order_is_entered_as_something_that_was_not_planned_never_warmly() -> void:
	var told := await _told("lever_right")
	assert_true(told.contains("Eingetragen"))
	assert_true(told.contains("nicht eingeplant"), "the line of his sheet")
	for word: String in ["Gut", "gut", "Bravo", "Glückwunsch", "stolz", "schön", "geschafft"]:
		assert_false(told.contains(word), "no praise: %s" % word)
	assert_false(WorldState.has_flag("plant.probe_done"), "the scene sets it, not the cue")


func test_the_keeper_has_a_voice_and_the_journal_a_line() -> void:
	var voices := FileAccess.get_file_as_string("res://content/dialogue/voices.json")
	assert_true(voices.contains('"Wächter": "neutral"'))
	for key: String in ["QUEST_MAIN_MOUNTAIN_WAY_PLANT"]:
		assert_ne(tr(key), key, key)
	var quest := ContentDB.quest("main_mountain_way")
	assert_true(quest.can_advance("valley", "plant"))
	assert_false(quest.stage("plant").is_final(), "the load (G4) hangs on it")


# --- The things of the hall ----------------------------------------------------------------------


func test_the_things_that_only_look_can_be_read_again_and_set_nothing() -> void:
	for cue: String in ["lever_idle", "small_door", "gauges", "steam_pipe"]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, "%s: two lines at least" % cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)


func test_a_lever_under_a_cloth_stands_and_promises_nothing() -> void:
	var told := await _told("lever_idle")
	assert_true(told.contains("Tuch") and told.contains("Steht"))
	for word: String in ["später", "bald", "noch nicht", "gleich", "wartet", "Aufgabe"]:
		assert_false(told.contains(word), "no promise: %s" % word)


func test_the_small_door_is_seen_with_its_rods_to_all_twelve_levers_and_stays_shut() -> void:
	var told := await _told("small_door")
	assert_true(told.contains("zwölf Hebel") and told.contains("Stangen"))
	assert_true(told.contains("Riegel"))
	assert_true(told.contains("zu"), "it stays shut")


func test_the_worn_dial_is_a_trace_of_the_world_the_first_time_and_a_line_after() -> void:
	var first := await DialogueWalk.play(FILE, "worn_dial")
	assert_true(Collection.has_fragment("worn_dial"))
	assert_eq(Collection.fragments(), 1)
	assert_eq(first.size(), 3)
	var again := await DialogueWalk.play(FILE, "worn_dial")
	assert_eq(again.size(), 1)
	assert_true(_has(again, "anl_dial_4"))
	assert_eq(Collection.fragments(), 1, "once")
	var told := "\n".join(first)
	for word: String in ["Kind", "Hand", "Haus", "weil", "Ursache", "damals"]:
		assert_false(told.contains(word), "a trace of the world, no %s" % word)
	assert_true(ResourceLoader.exists("res://assets/generated/fragments/fragment_worn_dial.png"))
