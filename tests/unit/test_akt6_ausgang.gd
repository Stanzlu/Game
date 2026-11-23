extends GutTest
## Act VI, segment R7: what the way out says (docs/akt6/REGIONSBRIEFE.md, O3, O4, O12, O19, O20).
## The rift at the edge of the picture asks nothing; the step is hers, and the corner of the
## picture lets her go. In the valley the light is gone, and the text names what stands there.
## Only things and gestures are shown: nothing says what Elysia is, what she leaves behind, or how
## she is; nothing praises the step. The scenes (the sequence, the walk, the valley) are tested in
## test_akt6_ausgang_szene.

const FILE := "res://content/dialogue/akt6/ausgang.dialogue"
const CUES: PackedStringArray = ["exit_step", "exit_valley"]
## What the text never says: the names of things, any verdict on going or staying, and the people
## and places of other segments.
const NEVER: PackedStringArray = [
	"Kind",
	"Gefühl",
	"fühlen",
	"Betäub",
	"Wirt",
	"Flucht",
	"Sucht",
	"Trost",
	"Heilung",
	"Leere",
	"falsch",
	"richtig",
	"mutig",
	"stolz",
	"endlich",
	"Richter",
	"Mira",
	"Gebirge",
	"Stufe",
	"Gold",
	"Erfahrung",
	"Level",
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
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:(aus_[a-z0-9_]+)\\]").search_all(
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
	assert_gte(unique.size(), 8)
	assert_lte(unique.size(), 20)


func test_nothing_is_a_digit_a_verdict_or_a_word_for_what_she_leaves_behind() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word: String in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bElysia\\b").search(spoken), "the place is not named")


func test_it_is_things_only_with_no_speaker_no_answer_and_nothing_set() -> void:
	for line: String in _spoken().split("\n", false):
		var text := line.strip_edges()
		assert_false(text.contains(": "), "no speaker, no colon: " + text)
		for mark: String in ["!", "?", "…"]:
			assert_false(text.contains(mark), "no %s in narration: %s" % [mark, text])
	for line: String in _source().split("\n"):
		assert_false(line.begins_with("- "), "no answer: " + line)
	for call_name: String in [
		"set_flag", "clear_flag", "add_item", "add_xp", "add_gold", "set_facet", "start_quest"
	]:
		assert_false(_source().contains(call_name), "%s does not occur" % call_name)
	var kept := _written_down()
	await DialogueWalk.play(FILE, "exit_step")
	await DialogueWalk.play(FILE, "exit_valley")
	assert_eq(_written_down(), kept, "nothing was set, nothing given")


func test_the_rift_asks_nothing_and_does_not_pull_and_the_corner_lets_her_go() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "exit_step"))
	assert_true(told.contains("Riss"), "the thing is named")
	assert_true(told.contains("Er fragt nichts."), "it asks nothing")
	assert_true(told.contains("zieht nicht"), "it does not pull")
	assert_true(told.contains("Zählwerk"), "the corner of the picture")
	assert_true(told.contains("ohne zu zittern"), "and it goes quietly")
	for word: String in ["Sog", "Wirt", "Frage", "Entscheid", "Abschied", "Wiedersehen"]:
		assert_false(told.contains(word), "no pull, no goodbye: " + word)


func test_the_soup_is_named_only_for_whoever_carries_it() -> void:
	var without := "\n".join(await DialogueWalk.play(FILE, "exit_step"))
	var valley_without := "\n".join(await DialogueWalk.play(FILE, "exit_valley"))
	assert_false(without.contains("Suppe") or valley_without.contains("Schale"), "not carried")
	WorldState.add_item("item_soup", 1, false)
	var carried := "\n".join(await DialogueWalk.play(FILE, "exit_step"))
	var valley_with := "\n".join(await DialogueWalk.play(FILE, "exit_valley"))
	assert_true(carried.contains("Suppe"), "carried: it is still warm")
	assert_true(valley_with.contains("Schale"), "and in the valley too")
	assert_eq(_raw("exit_step").count('has_item("item_soup")'), 1, "a literal, once")
	assert_eq(_raw("exit_valley").count('has_item("item_soup")'), 1)
	assert_gt(carried.length(), without.length())
	assert_gt(valley_with.length(), valley_without.length())


func test_the_valley_names_what_stands_where_the_light_stood_and_asks_nothing() -> void:
	var told := "\n".join(await DialogueWalk.play(FILE, "exit_valley"))
	assert_true(told.contains("Das Licht ist fort."), "the light is gone")
	assert_true(told.contains("Bach"), "the brook runs on, as it would have in both cases")
	assert_true(told.contains("Haus"), "and the house stands where it stood")
	var lines := await DialogueWalk.play(FILE, "exit_valley")
	assert_false(lines[lines.size() - 1].contains("?"), "the last line asks nothing")
	assert_false(lines[lines.size() - 1].contains("musst"), "and wants nothing")
