extends GutTest
## Act IV, segment S7: the quarrel at the gate (docs/akt4/REGIONSBRIEFE.md, O11, O12). After the
## concert Mira says she stands at the gate (a line in konzert.dialogue); there the Richter
## speaks, once, about the evening and never about her, and then Mira tells the gate that the
## player said yes until it was dark. Three answers, all possible, none wrong: the boundary,
## going along, the silence. The map's reading of the flags and the Richter's moment are tested
## in test_akt4_streit_szene.

const FILE := "res://content/dialogue/akt4/streit.dialogue"
const CITY := "res://content/dialogue/akt4/stadt.dialogue"
const CUES: PackedStringArray = ["richter", "mira_gate", "gate_leaves"]
## The way out: the answer, the flag it sets and the state of the bond it leaves.
const WAYS := {
	"Den Rest nicht": ["city.mira_parted_boundary", "familiar"],
	"Dann komme ich mit": ["city.mira_parted_joined", "close"],
	"…": ["city.mira_parted_silent", "strained"],
}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _blocks() -> Dictionary:
	var blocks := {}
	var name := ""
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			name = line.substr(2).strip_edges()
			blocks[name] = ""
		elif not name.is_empty():
			blocks[name] += line + "\n"
	return blocks


func _said_by(who: String) -> String:
	var spoken := ""
	for hit in RegEx.create_from_string("(?m)^\\s*%s: (.*)\\[ID:" % who).search_all(_source()):
		spoken += hit.get_string(1) + "\n"
	return spoken


func _told(cue: String, picks: PackedStringArray = []) -> String:
	var told := ""
	for line in await DialogueWalk.play(FILE, cue, picks):
		told += line + "\n"
	return told


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES)
	var ids: PackedStringArray = []
	var lines := 0
	for hit in RegEx.create_from_string("\\[ID:(tor_[a-z0-9_]+)\\]").search_all(_source()):
		ids.append(hit.get_string(1))
		if not RegEx.create_from_string("_r\\d+$").search(hit.get_string(1)):
			lines += 1
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# the segment: 40 planned, and the way home (S8) needs room in the act's 400
	assert_lte(lines + 4, 40, "the lines of the segment (with the night at the gate and Mira's)")


# --- The Richter -----------------------------------------------------------------------------


func test_he_introduces_himself_to_whoever_never_heard_him_and_knows_whoever_did() -> void:
	var stranger := await DialogueWalk.play(FILE, "richter")
	assert_true(_has(stranger, "tor_ric_4"), "we have not been introduced")
	assert_false(_has(stranger, "tor_ric_3"))
	WorldState.set_flag("beat.act2_richter")
	var known := await DialogueWalk.play(FILE, "richter")
	assert_true(_has(known, "tor_ric_3"), "we know each other: the stone, the brook")
	assert_false(_has(known, "tor_ric_4"))
	for seen: PackedStringArray in [stranger, known]:
		assert_true(
			_has(seen, "tor_ric_5") and _has(seen, "tor_ric_8"), "the evening, then the world"
		)
	assert_true(WorldState.has_flag("city.richter_met"), "once: the scene reads it")


func test_he_speaks_of_the_evening_and_never_of_her_or_of_mira() -> void:
	var said := _said_by("Richter")
	assert_gt(said.length(), 500, "all of his speech is read")
	for word: String in [
		"du ",
		"dir",
		"dich",
		"Angeklagte",
		"Mira",
		"wertlos",
		"versagt",
		"Versagen",
		"Schuld",
		"schuldig",
		"Heilung",
		"Gefühl",
		"Therapie",
	]:
		assert_false(said.contains(word), "no %s: he reads out things" % word)
	assert_false(_source().contains("Stimme:"), "he is named now, the Stimme of Act II")
	for line in said.split("\n", false):
		assert_gte(line.split(" ", false).size(), 6, "no short verdict, he is long: " + line)


func test_he_stumbles_he_overdoes_the_trivial_and_the_world_has_the_last_word() -> void:
	var said := _said_by("Richter")
	assert_gte(said.count("—"), 5, "he stumbles on his own sentences")
	for thing: String in ["Saite", "Lampe", "Einsatz", "Wind"]:
		assert_true(said.contains(thing), "he makes a case of the " + thing)
	var seen := await DialogueWalk.play(FILE, "richter")
	var last := seen[seen.size() - 1]
	assert_false(last.contains(":"), "narration")
	assert_eq(last, LineText.of("tor_ric_8"))
	assert_true(last.contains("summen"), "the square hums, he says no more")
	for line in seen:
		assert_false(line.contains("gut"), "he does not take the side of the evening: " + line)


# --- Mira at the gate ----------------------------------------------------------------------------


func test_mira_says_it_to_the_gate_and_is_unfair_without_a_number_or_a_therapy_word() -> void:
	var seen := await DialogueWalk.groups(FILE, "mira_gate")
	assert_eq(seen.size(), 1, "one choice")
	var told := await _told("mira_gate")
	assert_true(told.contains("Ja gesagt, bis es dunkel wurde"), "witness, not a measure")
	assert_true(told.contains("Ich hab zugesehen"))
	var mira := _said_by("Mira")
	assert_gt(mira.length(), 250, "all of her speech is read")
	assert_false(mira.contains("!"), "never a !")
	for word: String in [
		"Gefühl",
		"Beziehung",
		"Grenze",
		"verletzt",
		"Angst",
		"heilen",
		"verstehe dich",
		"für dich da",
		"Freund",
		"Liebe",
	]:
		assert_false(mira.contains(word), "no %s from Mira" % word)
	for digit: String in "0123456789":
		assert_false(told.contains(digit), "no number in what she says: " + digit)


func test_three_answers_all_possible_the_silence_last_and_each_has_its_way_out() -> void:
	var groups := await DialogueWalk.groups(FILE, "mira_gate")
	assert_eq(groups[0].size(), 3)
	assert_eq(groups[0][2], "…", "the silence is the last answer")
	for answer: String in WAYS:
		WorldState.new_game()
		var way: Array = WAYS[answer]
		await DialogueWalk.play(FILE, "mira_gate", PackedStringArray([answer]))
		assert_true(WorldState.has_flag(way[0]), "%s sets %s" % [answer, way[0]])
		assert_eq(WorldState.relationship_state("mira"), way[1], answer)
		assert_true(WorldState.has_memory("mira", "gate"), "the same memory in every way out")
		for other: String in WAYS:
			if other != answer:
				assert_false(WorldState.has_flag(WAYS[other][0]), "only its own flag: " + other)


func test_every_way_goes_on_to_the_gate_leaving_and_none_is_wrong() -> void:
	for answer: String in WAYS:
		WorldState.new_game()
		var seen := await DialogueWalk.play(FILE, "mira_gate", PackedStringArray([answer]))
		assert_true(_has(seen, "tor_out_1") and _has(seen, "tor_out_2"), answer)
		assert_gte(seen.size(), 8, "the question and an answer of her own: " + answer)
	var silence := await DialogueWalk.play(FILE, "mira_gate", PackedStringArray(["…"]))
	assert_true(_has(silence, "tor_mira_10"), "she thought so")
	assert_false(_has(silence, "tor_mira_5"), "no other answer's lines")


func test_the_choice_and_what_follows_from_it_are_never_in_the_same_cue() -> void:
	var setter := RegEx.create_from_string('set_flag\\("([a-z_.]+)"')
	var reader := RegEx.create_from_string('has_flag\\("([a-z_.]+)"')
	var blocks := _blocks()
	for cue: String in blocks:
		var text: String = blocks[cue]
		var sets := {}
		for hit in setter.search_all(text):
			sets[hit.get_string(1)] = true
		for hit in reader.search_all(text):
			assert_false(
				sets.has(hit.get_string(1)), "%s sets and reads %s" % [cue, hit.get_string(1)]
			)
	assert_false(
		(blocks["gate_leaves"] as String).contains("mira_parted"), "what follows reads no flag"
	)


# --- The gate by night, the journal, the memory -----------------------------------------------


func test_the_keeper_at_night_says_the_gate_is_shut_and_by_day_nothing_changed() -> void:
	var by_day := await DialogueWalk.play(CITY, "gate")
	assert_true(_has(by_day, "stadt_gate_2"), "the day's words")
	assert_false(_has(by_day, "stadt_gnt_2"))
	WorldState.set_flag("city.evening")
	var by_night := await DialogueWalk.play(CITY, "gate")
	assert_true(_has(by_night, "stadt_gnt_1") and _has(by_night, "stadt_gnt_2"))
	assert_eq(by_night.size(), 3)
	assert_false(_has(by_night, "stadt_gate_2"))


func test_the_night_is_the_last_stage_of_the_walk_so_far_and_is_written_down() -> void:
	var quest := ContentDB.quest("main_city_way")
	assert_true(quest.can_advance("evening", "night"))
	assert_true(quest.stage("night").is_final(), "until the way home (S8)")
	for key: String in ["QUEST_MAIN_CITY_WAY_NIGHT", "MEMORY_MIRA_GATE"]:
		assert_ne(tr(key), key, key)
		for digit: String in "0123456789":
			assert_false(tr(key).contains(digit), "no number in " + key)
	assert_true(tr("MEMORY_MIRA_GATE").contains("Ja gesagt"), "the memory is the witness")
