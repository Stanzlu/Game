extends GutTest
## Act VI, the collectibles (docs/akt6/REGIONSBRIEFE.md, section R10; Plan 5.5; Bible §31, §46,
## §51): three curiosities (the stub of a pencil from the guest book, a coin from the bottom of the
## fountain on the market, a pebble from the bottom of the basin) and three traces of the world
## (the camp in the valley, the shadow of the pillar, the rings on the table in the inn). In
## Elysia the curiosities are what Elysia would give as loot, and here they are only things; the
## traces are things that stand in a place and say what was repeated there, never a child, never
## a figure, never a reason. What the cues say is tested here; the props that carry them are
## tested in test_akt6_sammlung_szene.

const FILE := "res://content/dialogue/akt6/sammlung.dialogue"
const CUES: PackedStringArray = ["guestbook_back", "fountain_back", "pillar_back", "table_look"]
const CURIOSITIES: PackedStringArray = [
	"curiosity_basin_pebble",
	"curiosity_guest_pencil",
	"curiosity_fountain_coin",
]
const FRAGMENTS: PackedStringArray = ["empty_camp", "still_shadow", "table_rings"]
## What the traces never say: a child, a figure, a cause, a verdict, the strategy of the inn.
const NEVER: PackedStringArray = [
	"Kind",
	"Mira",
	"Wirt",
	"Gastwirt",
	"Richter",
	"Betäub",
	"Gefühl",
	"fühlen",
	"Trost",
	"Heilung",
	"Schleife",
	"Wiederholung",
	"Leere",
	"falsch",
	"richtig",
	"weil",
	"Zuhause",
	"Heimat",
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
	for hit: RegExMatch in RegEx.create_from_string("\\[ID:(sam_[a-z0-9_]+)\\]").search_all(
		_source()
	):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments, code and conditions left out.
func _spoken() -> String:
	var spoken := ""
	for line: String in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += RegEx.create_from_string("\\[[^\\]]*/?\\]").sub(line.substr(0, at), "", true)
			spoken += "\n"
	return spoken


## The raw lines of one cue (code and conditions included), comments left out.
func _raw(cue: String) -> String:
	var text := ""
	var inside := false
	for line: String in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and not line.begins_with("#"):
			text += line + "\n"
	return text


## The narration of one cue: the lines that are not an answer and not code.
func _narration(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	for raw: String in _raw(cue).split("\n"):
		if raw.find("[ID:") > -1 and not raw.begins_with("-") and not raw.begins_with("\t-"):
			lines.append(raw.substr(0, raw.find("[ID:")).strip_edges())
	return lines


## True if one of the answers contains the text.
func _offers(answers: PackedStringArray, text: String) -> bool:
	for answer in answers:
		if answer.contains(text):
			return true
	return false


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
	assert_gte(unique.size(), 16)
	assert_lte(unique.size(), 26)


func test_nothing_is_a_digit_a_verdict_or_a_figure_and_the_narration_has_no_voice() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word: String in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	for cue in CUES:
		for text in _narration(cue):
			assert_false(text.contains(": "), "narration has no speaker: " + text)
			for mark: String in ["!", "?", "…"]:
				assert_false(text.contains(mark), "no %s in narration: %s" % [mark, text])


func test_the_traces_are_only_narration_and_set_only_their_fragment() -> void:
	var traces := {"pillar_back": "still_shadow", "table_look": "table_rings"}
	for cue: String in traces:
		var raw := _raw(cue)
		assert_false(raw.contains("\n- "), "%s asks nothing" % cue)
		assert_eq(raw.count("do "), 1, "%s sets one thing" % cue)
		assert_true(raw.contains('set_flag("fragment.%s")' % traces[cue]), cue)
		for call: String in [
			"add_item", "add_xp", "add_gold", "spend_gold", "set_facet", "start_quest"
		]:
			assert_false(raw.contains(call), "%s: no %s" % [cue, call])
		assert_true(
			_narration(cue).size() >= 2 and _narration(cue).size() <= 3, "%s is short" % cue
		)
	var kept := JSON.stringify(WorldState.state.to_dict())
	for cue: String in traces:
		await DialogueWalk.play(FILE, cue)
		assert_true(WorldState.has_flag("fragment.%s" % traces[cue]), "%s was seen" % cue)
		assert_true(Collection.has_fragment(traces[cue]))
	assert_ne(JSON.stringify(WorldState.state.to_dict()), kept)
	assert_eq(WorldState.state.inventory.size(), 0, "no thing came from them")
	assert_eq(WorldState.state.elysia.xp, 0)


func test_a_curiosity_is_one_answer_that_takes_it_and_one_that_leaves_it() -> void:
	# cue: the thing, the flag that says it is gone, the answer that takes it, the one that leaves it
	var takes := {
		"guestbook_back":
		[
			"curiosity_guest_pencil",
			"elysia.pencil_taken",
			"Den Stummel abbinden.",
			"Im Buch blättern."
		],
		"fountain_back":
		[
			"curiosity_fountain_coin",
			"elysia.coin_taken",
			"Eine Münze vom Grund fischen.",
			"Weitergehen."
		],
	}
	for cue: String in takes:
		var raw := _raw(cue)
		assert_eq(raw.count("add_item("), 1, "%s gives one thing" % cue)
		assert_true(raw.contains('add_item("%s")' % takes[cue][0]), cue)
		assert_true(raw.contains('set_flag("%s")' % takes[cue][1]), "%s marks it" % cue)
		assert_true(
			raw.contains('[if not WorldState.has_flag("%s") /]' % takes[cue][1]),
			"%s offers it only while it lies there" % cue
		)
		# the group has the thing and an unconditional way on
		var offered := await DialogueWalk.answers(FILE, cue)
		assert_true(offered.has(takes[cue][2]), "%s: %s" % [cue, takes[cue][2]])
		assert_true(offered.has(takes[cue][3]), "%s: %s" % [cue, takes[cue][3]])
		# leaving it takes nothing and marks nothing
		await DialogueWalk.play(FILE, cue, PackedStringArray([takes[cue][3]]))
		assert_eq(WorldState.state.inventory.size(), 0, "%s: leaving it takes nothing" % cue)
		assert_false(WorldState.has_flag(takes[cue][1]))
		# taking it: she holds it, and the answer is gone while the others stay
		await DialogueWalk.play(FILE, cue, PackedStringArray([takes[cue][2]]))
		assert_eq(WorldState.item_count(takes[cue][0]), 1, "%s: she holds it" % cue)
		assert_true(WorldState.has_flag(takes[cue][1]))
		var after := await DialogueWalk.answers(FILE, cue)
		assert_false(after.has(takes[cue][2]), "%s: nothing lies there any more" % cue)
		assert_true(after.has(takes[cue][3]), "%s: the way on stays" % cue)
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func test_the_guest_book_tells_the_knot_once_the_stub_is_gone() -> void:
	var leaf := PackedStringArray(["Im Buch blättern."])
	var before := "\n".join(await DialogueWalk.play(FILE, "guestbook_back", leaf))
	assert_true(before.contains("heruntergeschrieben"), "the pencil hangs on its string")
	assert_false(before.contains("Knoten"))
	await DialogueWalk.play(FILE, "guestbook_back", PackedStringArray(["Den Stummel abbinden."]))
	var after := "\n".join(await DialogueWalk.play(FILE, "guestbook_back", leaf))
	assert_true(after.contains("loser Knoten"), "now the string holds a knot")
	assert_false(after.contains("heruntergeschrieben"), "and no pencil that is not there")
	var offered := await DialogueWalk.answers(FILE, "guestbook_back")
	assert_eq(offered, PackedStringArray(["Im Buch blättern."]), "only the way on is left")
	assert_eq(WorldState.item_count("curiosity_guest_pencil"), 1, "and no second stub")


func test_the_fountain_keeps_the_trade_of_act_one_with_other_words() -> void:
	# the old cue offered a coin for ten gold; a new cue must not take that away
	assert_true(_raw("fountain_back").contains("spend_gold(10)"), "ten gold, as before")
	assert_false(_offers(await DialogueWalk.answers(FILE, "fountain_back"), "zehn Gold"), "no gold")
	WorldState.add_gold(10)
	assert_true(
		_offers(await DialogueWalk.answers(FILE, "fountain_back"), "zehn Gold"), "the trade"
	)
	var gold := WorldState.state.elysia.gold
	await DialogueWalk.play(FILE, "fountain_back", PackedStringArray(["Eine Münze hineinwerfen"]))
	assert_eq(WorldState.state.elysia.gold, gold - 10, "the coin is spent")
	assert_eq(WorldState.state.inventory.size(), 0, "and nothing comes back")


func test_the_files_that_carry_the_other_collectibles_set_them_once_and_only_there() -> void:
	var garden_file := "res://content/dialogue/akt6/garten.dialogue"
	var garden := FileAccess.get_file_as_string(garden_file)
	assert_eq(garden.count('add_item("curiosity_basin_pebble")'), 1)
	assert_eq(garden.count('set_flag("elysia.pebble_taken")'), 1)
	assert_true(
		garden.contains('[if not WorldState.has_flag("elysia.pebble_taken") /]'),
		"the pebble is offered while it lies there"
	)
	var camp := FileAccess.get_file_as_string("res://content/dialogue/akt6/leere.dialogue")
	assert_eq(camp.count('set_flag("fragment.empty_camp")'), 1)
	# the pebble answer sits between the play and the watching, and the watching stays last
	var offered := await DialogueWalk.answers(garden_file, "basin_back")
	assert_eq(offered.size(), 3, "play, pebble, watching")
	assert_eq(offered[2], "Zusehen.", "the unconditional answer is the last")
	await DialogueWalk.play(garden_file, "basin_back", PackedStringArray(["Einen Kiesel"]))
	assert_eq(WorldState.item_count("curiosity_basin_pebble"), 1)
	assert_false(WorldState.has_facet("aliveness"), "taking a pebble is not playing")
	assert_eq((await DialogueWalk.answers(garden_file, "basin_back")).size(), 2, "it is gone")


func test_the_curiosities_are_things_with_a_picture_a_name_and_a_line_and_the_traces_have_a_picture(
) -> void:
	for id: String in CURIOSITIES:
		var item := ContentDB.item(id)
		assert_not_null(item, "%s is an item" % id)
		assert_true(id.begins_with(Collection.CURIOSITY_PREFIX))
		assert_true(
			FileAccess.file_exists("res://assets/generated/items/%s.png" % id),
			"%s has its icon" % id
		)
		var key := id.to_upper()
		assert_ne(tr(key + "_NAME"), key + "_NAME", "%s has a name" % id)
		assert_ne(tr(key + "_DESC"), key + "_DESC", "%s has a line" % id)
		for digit: String in "0123456789":
			assert_false(tr(key + "_DESC").contains(digit), "numbers are written out in %s" % id)
	for name: String in FRAGMENTS:
		assert_true(
			FileAccess.file_exists("res://assets/generated/fragments/fragment_%s.png" % name),
			"%s has its card" % name
		)
	# carried, they count; the traces count among the fragments
	for id: String in CURIOSITIES:
		WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 3)
	for name: String in FRAGMENTS:
		Collection.collect_fragment(name)
	assert_eq(Collection.fragments(), 3)
