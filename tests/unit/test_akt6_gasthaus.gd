extends GutTest
## Act VI, segment R5: what the host says and what the hearth shows (docs/akt6/REGIONSBRIEFE.md,
## O6, O12; docs/writing/stimmen/gastwirt.md and betaeuber.md). The host waits, warm and funny and
## not a bit sinister; the table in the middle brings three offers, each a different thing (food,
## music, rest), each free to refuse and with lines of its own; he says once, plainly, that she can
## go whenever she likes, and never holds her; and the why of his strategy is a thing at the hearth,
## not an explanation. Nothing here says that staying is good or bad. The scene (the table, the
## sitting, the picture) is tested in test_akt6_gasthaus_szene.

const FILE := "res://content/dialogue/akt6/gasthaus.dialogue"
const CUES: PackedStringArray = [
	"host_back",
	"hearth_back",
	"stay",
	"stay_ask",
	"stay_next",
	"stay_1",
	"stay_2",
	"stay_3",
	"stay_done",
	"stay_more",
	"stay_calm",
]
const FLAGS: PackedStringArray = ["elysia.stay_1", "elysia.stay_2", "elysia.stay_3"]
## What the text never says: the names of things the strategy is about, any verdict on staying
## or on Elysia, the Richter, and what happened in the mountains.
const NEVER: PackedStringArray = [
	"Kind",
	"Gefühl",
	"fühlen",
	"Betäub",
	"Flucht",
	"Sucht",
	"Trost",
	"trösten",
	"Heilung",
	"Leere",
	"Muster",
	"Schleife",
	"Vermeidung",
	"Ausweichen",
	"zurück",
	"falsch",
	"gefährlich",
	"Lüge",
	"endlich",
	"schon wieder",
	"zu lange",
	"Richter",
	"Mira",
	"Gebirge",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()


func _source() -> String:
	return FileAccess.get_file_as_string(FILE)


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:(inn_[a-z0-9_]+)\\]").search_all(
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


## The lines of a cue as written (answers without the dash), comments and code left out.
func _written(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line: String in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges().trim_prefix("- "))
	return lines


## Everything the game remembers, but for the play time that runs on by itself.
func _written_down() -> String:
	var state := WorldState.state.to_dict()
	state.erase("playtime_seconds")
	return JSON.stringify(state)


## The raw lines of a cue, code and conditions included, comments left out.
func _raw(cue: String) -> String:
	var block := ""
	var inside := false
	for line: String in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and not line.begins_with("#"):
			block += line + "\n"
	return block


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
	assert_gte(unique.size(), 37)
	assert_lte(unique.size(), 53)


func test_nothing_is_a_digit_a_verdict_or_a_word_for_what_the_strategy_is() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word: String in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bElysia\\b").search(spoken), "the place is not named")
	assert_null(RegEx.create_from_string("\\bFalle\\b").search(spoken))


func test_only_the_three_offers_set_anything_each_its_own_flag_first() -> void:
	var all := _source()
	assert_eq(all.count("set_flag("), 3, "three flags, nothing else")
	for call_name: String in ["set_facet", "add_xp", "add_gold", "add_item", "start_quest"]:
		assert_false(all.contains(call_name), "%s does not occur" % call_name)
	for step in 3:
		var raw := _raw("stay_%d" % (step + 1))
		assert_true(
			raw.begins_with('do WorldState.set_flag("%s")' % FLAGS[step]),
			"stay_%d sets its flag before anything is said" % (step + 1)
		)
		for other in 3:
			if other != step:
				assert_false(raw.contains(FLAGS[other]), "and no other flag")
	# the cues that read the flags set none, and the ones that set them read none
	for cue: String in ["stay", "stay_next"]:
		assert_false(_raw(cue).contains("set_flag"), "%s only reads" % cue)
	for step in 3:
		assert_false(
			_raw("stay_%d" % (step + 1)).contains("has_flag"), "and the setters do not read"
		)


func test_the_host_waits_and_the_hearth_shows_and_neither_changes_anything() -> void:
	var kept := _written_down()
	var host := await DialogueWalk.play(FILE, "host_back")
	var hearth := await DialogueWalk.play(FILE, "hearth_back")
	assert_eq(host.size(), 3)
	assert_eq(hearth.size(), 4)
	assert_eq(_written_down(), kept, "nothing set")
	var told := "\n".join(_written("host_back"))
	assert_true(told.contains("Suppe"), "his soup, his joke")
	for word: String in ["Bleib", "bleib", "musst", "darfst", "Gefühl"]:
		assert_false(told.contains(word), "he shows, she decides: " + word)


func test_the_hearth_is_only_things_and_names_no_cause_and_no_culprit() -> void:
	var lines := _written("hearth_back")
	for line in lines:
		assert_false(line.contains(": "), "narration only: " + line)
		for mark: String in ["!", "?", "…"]:
			assert_false(line.contains(mark), "no %s in narration: %s" % [mark, line])
	var told := "\n".join(lines)
	assert_true(told.contains("Zettel"), "a note, in the host's hand")
	for word: String in ["früher", "damals", "Krankheit", "Vater", "Mutter", "schuld", "Schuld"]:
		assert_false(told.contains(word), "no cause, no culprit: " + word)
	assert_false(told.contains("gut") or told.contains("schlecht"), "it does not say what it is")


func test_three_offers_each_a_different_thing_and_each_with_lines_of_its_own() -> void:
	var food := "\n".join(_written("stay_1"))
	var music := "\n".join(_written("stay_2"))
	var rest := "\n".join(_written("stay_3"))
	assert_true(food.contains("Suppe") and not food.contains("Musik"), "the first is the soup")
	assert_true(music.contains("Musik") and not music.contains("Suppe"), "the second is the music")
	assert_true(rest.contains("Feuer") and not rest.contains("Suppe"), "the third is the quiet")
	assert_false(rest.contains("Musik"))
	var seen := {}
	var answers: PackedStringArray = ["Noch bleiben.", "Nur sitzen.", "…", "Bleiben."]
	for cue: String in ["stay_1", "stay_2", "stay_3"]:
		for line in _written(cue):
			if line in answers:
				continue
			assert_false(seen.has(line), "no line twice: " + line)
			seen[line] = true


func test_every_choice_has_three_ways_and_none_of_them_is_standing_up() -> void:
	for cue: String in ["stay", "stay_1", "stay_2", "stay_done"]:
		# the quiet answer ends the walk: "Bleiben." would go on, and in stay_more for ever
		var groups := await DialogueWalk.groups(FILE, cue, PackedStringArray(["Nur sitzen."]))
		assert_eq(groups.size(), 1, "%s asks once, when it is answered quietly" % cue)
		assert_eq(groups[0].size(), 3, "%s: three answers" % cue)
		assert_true(groups[0][2].begins_with("…"), "the silence is the last")
		# the first answer goes on (and in stay_more for ever: it is not walked here)
		var texts: Array[String] = []
		for index: int in [1, 2]:
			var walked := await DialogueWalk.play(FILE, cue, PackedStringArray([groups[0][index]]))
			texts.append("\n".join(walked.slice(1)))
		assert_ne(texts[0], texts[1], "%s: the two quiet answers have lines of their own" % cue)
	for answer in _all_answers():
		for word: String in ["Aufstehen", "Gehen", "gehen", "Weg", "Tür", "Schluss", "Genug"]:
			assert_false(answer.contains(word), "no answer is leaving: " + answer)


func _all_answers() -> PackedStringArray:
	var answers := PackedStringArray()
	for line: String in _source().split("\n"):
		if line.begins_with("- ") and line.find("[ID:") > -1:
			answers.append(line.substr(2, line.find("[ID:") - 2).strip_edges())
	return answers


func test_he_says_once_that_she_can_go_whenever_she_likes_and_never_holds_her() -> void:
	var told := "\n".join(_written("stay_3"))
	assert_true(told.contains("jederzeit"), "he says it, plainly")
	var host_lines := PackedStringArray()
	for cue in CUES:
		for line in _written(cue):
			if line.begins_with("Gastwirt:"):
				host_lines.append(line)
	assert_lte(host_lines.size(), 12, "he speaks little")
	for line in host_lines:
		for word: String in [
			"nicht gehen", "darfst nicht", "bleib ", "Bleib ", "Musst", "musst", "Bitte bleib"
		]:
			assert_false(line.contains(word), "he never holds, never pulls: " + line)
		assert_true(RegEx.create_from_string("^Gastwirt: [A-ZÄÖÜ]").search(line) != null)


func test_after_the_third_offer_staying_goes_on_with_short_changing_lines_and_nothing_more(
) -> void:
	var calm := _written("stay_calm")
	assert_eq(calm.size(), 3, "three lines, taken at random")
	for line in calm:
		assert_true(line.trim_prefix("% ").begins_with("Du bleibst."), "the same start: " + line)
		assert_lte(line.split(" ", false).size(), 16, "short: " + line)
	var raw := _raw("stay_calm")
	assert_eq(raw.count("%"), 3, "random lines")
	assert_true(raw.contains("=> stay_more"), "and the choice comes round again")
	assert_false(raw.contains("do "), "and sets nothing")
