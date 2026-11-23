extends GutTest
## Act VI, segment R6: what the host says when she stands up (docs/akt6/REGIONSBRIEFE.md, O6, O7,
## O12; docs/writing/stimmen/gastwirt.md and betaeuber.md). Standing up is her own step and never an
## answer: the host asks once, lightly ("Musst du? Wirklich?"), lets go and hands her the soup,
## and holds nothing. Afterwards he is the same host without an offer, and a facet that nothing
## else reads yet (aliveness) shows as one more answer. The scene (the step, the soup, the walk)
## is tested in test_akt6_aufstehen_szene.

const FILE := "res://content/dialogue/akt6/aufstehen.dialogue"
const CUES: PackedStringArray = ["stand_first", "host_after"]
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
	"trösten",
	"Heilung",
	"Leere",
	"Muster",
	"Schleife",
	"Vermeidung",
	"Ausweichen",
	"falsch",
	"richtig",
	"gefährlich",
	"Lüge",
	"endlich",
	"schon wieder",
	"zu lange",
	"Richter",
	"Mira",
	"Gebirge",
	"Lebendigkeit",
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
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:(up_[a-z0-9_]+)\\]").search_all(
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
	assert_gte(unique.size(), 14)
	assert_lte(unique.size(), 30)


func test_nothing_is_a_digit_a_verdict_or_a_word_for_what_the_strategy_is() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word: String in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bElysia\\b").search(spoken), "the place is not named")
	assert_null(RegEx.create_from_string("\\bFalle\\b").search(spoken))


func test_the_standing_up_sets_one_flag_first_and_gives_the_soup_and_nothing_else() -> void:
	var raw := _raw("stand_first")
	assert_true(
		raw.begins_with('do WorldState.set_flag("elysia.stood_up")'),
		"the flag first, before anything is said"
	)
	assert_eq(_source().count("set_flag("), 1, "one flag in the whole file")
	assert_eq(raw.count("add_item("), 1, "one thing")
	assert_true(raw.contains('add_item("item_soup")'), "the soup")
	for call_name: String in ["add_xp", "add_gold", "set_facet", "start_quest", "advance_quest"]:
		assert_false(_source().contains(call_name), "%s does not occur" % call_name)
	assert_false(raw.contains("has_flag"), "the setter does not read its own flag")
	assert_false(_raw("host_after").contains("set_flag"), "and the host afterwards sets nothing")
	assert_false(_raw("host_after").contains("add_item"))


func test_standing_up_is_never_an_answer_and_the_host_asks_once_and_lets_go() -> void:
	var raw := _raw("stand_first")
	for line in raw.split("\n"):
		assert_false(line.begins_with("- "), "no answer in the scene: " + line)
	assert_false(raw.contains("=> stand_first"))
	var told := "\n".join(_written("stand_first"))
	assert_eq(told.count("Musst du? Wirklich?"), 1, "his old question, once")
	assert_true(told.contains("Na gut."), "and he lets go")
	assert_true(told.contains("nimm die Suppe mit"), "with the soup")
	var host_lines := PackedStringArray()
	for line in _written("stand_first"):
		if line.begins_with("Gastwirt:"):
			host_lines.append(line)
	assert_lte(host_lines.size(), 5, "he says little")
	for line in host_lines:
		for word: String in [
			"nicht gehen", "darfst nicht", "bleib ", "Bleib ", "Bitte bleib", "warte"
		]:
			assert_false(line.contains(word), "he never holds, never pulls: " + line)
		assert_true(RegEx.create_from_string("^Gastwirt: [A-ZÄÖÜ…]").search(line) != null)
	for answer in _all_answers():
		for word: String in ["Aufstehen", "aufstehen", "Gehen", "gehen", "Weg", "Tür", "Schluss"]:
			assert_false(answer.contains(word), "no answer is leaving: " + answer)


func test_the_narration_of_the_scene_is_things_and_never_praises_or_blames() -> void:
	for cue: String in CUES:
		for line in _written(cue):
			if (
				line.begins_with("Gastwirt:")
				or line.begins_with("Tanzen")
				or line.begins_with("Danke")
			):
				continue
			if line == "…":
				continue
			assert_false(line.contains(": "), "narration only: " + line)
			for mark: String in ["!", "?", "…"]:
				assert_false(line.contains(mark), "no %s in narration: %s" % [mark, line])
	var told := "\n".join(_written("stand_first"))
	for word: String in ["gut so", "gelobt", "stolz", "Mut", "mutig", "richtig", "brav", "endlich"]:
		assert_false(told.contains(word), "standing up is not praised: " + word)
	assert_true(told.contains("Suppe"), "the soup is the joke, and not the guest")


func test_he_is_the_same_host_afterwards_and_offers_nothing() -> void:
	var told := "\n".join(_written("host_after"))
	assert_true(told.contains("wisch") and told.contains("Wirts"), "his own joke about his work")
	for word: String in ["Bleib", "bleib", "Setz", "setz", "Musst", "musst", "Angebot", "Hunger"]:
		assert_false(told.contains(word), "he offers nothing, he asks nothing: " + word)


func test_the_facet_shows_as_one_more_answer_next_to_the_plain_ones_and_the_silence_is_last(
) -> void:
	var plain := await DialogueWalk.answers(FILE, "host_after")
	assert_eq(plain.size(), 2, "without the facet, two answers")
	assert_true(plain[1].begins_with("…"), "the silence last")
	assert_false("Tanzen?" in plain)
	WorldState.set_facet("aliveness")
	var shown := await DialogueWalk.answers(FILE, "host_after")
	assert_eq(shown.size(), 3, "with the facet, one more")
	assert_eq(shown[0], "Tanzen?", "an idea of her own")
	assert_true(shown[2].begins_with("…"), "the silence is still last")
	assert_true(_raw("host_after").contains('has_facet("aliveness")'), "and it is a literal")
	assert_false(_raw("stand_first").contains("has_facet"), "the scene reads nothing")


func test_every_answer_has_lines_of_its_own_and_none_sets_anything() -> void:
	WorldState.set_facet("aliveness")
	var kept := _written_down()
	var texts: Array[String] = []
	for pick: String in ["Tanzen?", "Danke für die Suppe.", "…"]:
		var walked := await DialogueWalk.play(FILE, "host_after", PackedStringArray([pick]))
		assert_gt(walked.size(), 1, "%s is answered" % pick)
		texts.append("\n".join(walked.slice(1)))
	assert_ne(texts[0], texts[1])
	assert_ne(texts[1], texts[2])
	assert_ne(texts[0], texts[2])
	assert_eq(_written_down(), kept, "nothing was set, nothing given")
	assert_true(texts[0].contains("Tanzen"), "he picks it up")
	assert_false(texts[0].contains("Lebendig"), "and has no word for what it is")


func test_the_scene_gives_the_soup_and_the_flag_when_it_is_walked() -> void:
	var kept := WorldState.item_count("item_soup")
	var walked := await DialogueWalk.play(FILE, "stand_first")
	assert_eq(walked.size(), 9, "nine lines, no answer")
	assert_true(WorldState.has_flag("elysia.stood_up"))
	assert_eq(WorldState.item_count("item_soup"), kept + 1, "one soup")


func _all_answers() -> PackedStringArray:
	var answers := PackedStringArray()
	for line: String in _source().split("\n"):
		if line.begins_with("- ") and line.find("[ID:") > -1:
			answers.append(line.substr(2, line.find("[ID:") - 2).strip_edges())
	return answers
