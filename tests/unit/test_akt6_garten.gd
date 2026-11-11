extends GutTest
## Act VI, segment R3: what the garden says to someone who comes back (docs/akt6/REGIONSBRIEFE.md,
## O5, O7, O8, O12, O17; docs/writing/STIL.md, stimmen/gaertnerin.md and elysianer.md). The people
## of Elysia are as they were; what is new is who listens. The gardener hands over a compliment
## for nothing and is calmer than before, the Elysians say their sentences without a reason, and
## the basin gives nothing. Nothing here speaks of a child, of the mountains, of a cause, and
## nobody says what the playing at the basin is. The scenes (the new cues on the map, the gift, the
## basin, the old lines for everyone who has not come back) are tested in test_akt6_garten_szene.

const FILE := "res://content/dialogue/akt6/garten.dialogue"
const CUES: PackedStringArray = [
	"gardener_back",
	"gardener_gift",
	"gardener_keep",
	"gardener_again",
	"favor_back",
	"elysian_back",
	"basin_back",
	"basin_play",
]
## What the text never says: what happened in the mountains, the child, the names of feelings, the
## verdicts on Elysia, the word for what the basin is, anything that explains.
const NEVER: PackedStringArray = [
	"Kind",
	"Kreide",
	"Gebirge",
	"Berg",
	"Wächter",
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
	"Richter",
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
	"Spiel",
	"Spaß",
	"Freude",
	"lebendig",
	"Leben",
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
	for hit in RegEx.create_from_string("\\[ID:(gar_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += _plain(line.substr(0, at)) + "\n"
	return spoken


## A line without its tags ([rainbow freq=0.6], [if ... /]): what is read, not how.
func _plain(line: String) -> String:
	return RegEx.create_from_string("\\[[^\\]]*\\]").sub(line, "", true)


## The lines of a cue as written, comments and code left out (answers included, without the dash).
func _written(cue: String) -> PackedStringArray:
	var lines := PackedStringArray()
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and line.find("[ID:") > -1 and not line.begins_with("#"):
			lines.append(line.substr(0, line.find("[ID:")).strip_edges().trim_prefix("- "))
	return lines


## The raw lines of a cue, code and conditions included, comments left out.
func _raw(cue: String) -> String:
	var block := ""
	var inside := false
	for line in _source().split("\n"):
		if line.begins_with("~ "):
			inside = line.substr(2).strip_edges() == cue
		elif inside and not line.begins_with("#"):
			block += line + "\n"
	return block


## The quest of the butterflies as Act I leaves it for someone who never handed them in.
func _butterflies_waiting() -> void:
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "butterflies")
	WorldState.start_quest("side_elysia_butterflies")
	WorldState.advance_quest("side_elysia_butterflies", "return")


func _words(line: String) -> int:
	return line.split(" ", false).size()


func test_the_file_has_the_cues_in_draft_with_unique_ids() -> void:
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
	assert_gte(ids.size(), 35)
	assert_lte(ids.size(), 47)


func test_nothing_is_a_digit_a_verdict_or_a_word_for_what_happens_at_the_basin() -> void:
	var spoken := _spoken()
	for digit: String in "0123456789":
		assert_false(spoken.contains(digit), "numbers are written out: " + digit)
	for word in NEVER:
		assert_false(spoken.contains(word), "the text never says %s" % word)
	assert_null(RegEx.create_from_string("\\bElysia\\b").search(spoken), "the place is not named")
	assert_null(RegEx.create_from_string("\\bweil\\b").search(spoken), "no reason is given")
	assert_lte(spoken.count("wieder"), 1, "hardly anything comes back, and then as a hand's move")


func test_what_is_set_is_the_gift_and_the_facet_and_each_only_where_it_belongs() -> void:
	var source := _source()
	assert_eq(source.count("set_flag("), 1, "one flag, the gift")
	assert_eq(source.count('set_flag("elysia.back_gift")'), 1)
	assert_eq(source.count("set_facet("), 1, "one facet")
	assert_eq(source.count('set_facet("aliveness")'), 1)
	# the setter of a thing and its reader never stand in the same cue
	for cue in CUES:
		var raw := _raw(cue)
		assert_false(
			(
				raw.contains('set_flag("elysia.back_gift")')
				and raw.contains('has_flag("elysia.back_gift")')
			),
			"%s sets the gift and reads it" % cue
		)
		assert_false(
			raw.contains('set_facet("aliveness")') and raw.contains('has_facet("aliveness")'),
			"%s sets the facet and reads it" % cue
		)
	assert_true(_raw("gardener_back").contains('has_flag("elysia.back_gift")'), "it reads the gift")
	assert_true(_raw("gardener_again").contains('has_facet("aliveness")'), "it reads the facet")
	var xp := WorldState.state.elysia.xp
	for cue: String in ["gardener_keep", "favor_back", "elysian_back", "basin_back"]:
		await DialogueWalk.play(FILE, cue, PackedStringArray(["Zusehen."]))
	assert_false(WorldState.has_flag("elysia.back_gift"), "leaving it and watching set nothing")
	assert_false(WorldState.has_facet("aliveness"))
	assert_eq(WorldState.state.elysia.xp, xp, "no experience")
	assert_eq((await DialogueWalk.groups(FILE, "basin_play")).size(), 0, "playing asks nothing")


func test_the_gardener_is_calm_and_the_gift_is_a_gift_for_nothing() -> void:
	var back := _written("gardener_back")
	assert_eq(back.size(), 6, "four lines and two answers")
	assert_true(back[3].contains("Kompliment"), "the compliment itself")
	assert_true(back[3].contains("Legendär"), "in the word she always used")
	assert_eq(back[4], "Annehmen.")
	assert_eq(back[5], "Lass nur.")
	for cue: String in ["gardener_back", "gardener_gift", "gardener_keep", "gardener_again"]:
		for line in _written(cue):
			if line.begins_with("Gärtnerin:"):
				assert_false(line.contains("!"), "she is calmer than before: " + line)
				assert_lte(_words(line), 24, "short sentences: " + line)
	# no thanks asked, no price named, no reason for the gift
	var asked := "\n".join(_written("gardener_back")) + "\n".join(_written("gardener_gift"))
	for word: String in ["Dank", "danke", "verdient", "Belohnung", "Preis", "schuldest"]:
		assert_false(asked.contains(word), "a gift for nothing: " + word)


func test_both_answers_to_the_gift_have_lines_of_their_own_and_neither_is_praised() -> void:
	var left := await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Lass nur."]))
	assert_false(WorldState.has_flag("elysia.back_gift"), "leaving it sets nothing")
	var taken := await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Annehmen."]))
	assert_gte(taken.size(), 7, "the four lines and the answer's own")
	assert_gte(left.size(), 7)
	assert_ne(taken.slice(4), left.slice(4), "each its own")
	for told: PackedStringArray in [taken.slice(4), left.slice(4)]:
		var text := "\n".join(told)
		for word: String in ["gut", "richtig", "klug", "schade", "Mut", "mutig"]:
			assert_false(text.contains(word), "neither way is judged: " + word)
		assert_false(text.contains("?"), "and she asks nothing")


func test_taking_it_gives_the_old_systems_back_and_leaving_it_changes_nothing() -> void:
	var xp := WorldState.state.elysia.xp
	await DialogueWalk.play(FILE, "gardener_keep")
	assert_eq(WorldState.state.elysia.xp, xp, "leaving it lying: nothing")
	assert_false(WorldState.has_item("item_compliment"))
	await DialogueWalk.play(FILE, "gardener_gift")
	assert_true(WorldState.has_item("item_compliment"), "taking it: the compliment, a real one")
	assert_eq(WorldState.state.elysia.xp, xp + 2000, "and the number in the corner")
	assert_true(WorldState.has_flag("elysia.back_gift"))
	var gift := "\n".join(_written("gardener_gift"))
	var reward := RegEx.create_from_string("\\b(Erfahrung|Gold|Punkte)\\b")
	assert_null(reward.search(gift), "the text names no reward")


func test_the_gardener_after_the_gift_has_the_answer_for_the_basin_only_with_the_facet() -> void:
	WorldState.set_flag("elysia.back_gift")
	var plain := await DialogueWalk.answers(FILE, "gardener_again")
	assert_eq(plain.size(), 2, "without the facet: the plain one and the silence")
	WorldState.set_facet("aliveness")
	var with_facet := await DialogueWalk.answers(FILE, "gardener_again")
	assert_eq(with_facet.size(), 3, "with it: one more")
	assert_true(with_facet[1].contains("Brunnen"), "the one for the basin stands in the middle")
	assert_true(with_facet[with_facet.size() - 1].begins_with("…"), "the silence is the last")
	var told := "\n".join(_written("gardener_again"))
	assert_false(told.contains("Becken"), "she does not name what happened there")
	assert_false(told.contains("gespritzt") or told.contains("gespielt"), "not what she saw")


func test_the_gardener_says_nothing_new_about_the_gift_once_it_is_taken() -> void:
	WorldState.set_flag("elysia.back_gift")
	var seen := await DialogueWalk.play(FILE, "gardener_back")
	var again := await DialogueWalk.play(FILE, "gardener_again")
	assert_eq(seen, again, "gardener_back hands on to gardener_again")
	assert_false("\n".join(seen).contains("Kompliment"), "no second gift")


func test_the_elysians_say_their_sentences_as_always_and_never_that_she_was_gone() -> void:
	var favor := _written("favor_back")
	var way := _written("elysian_back")
	assert_eq(favor.size(), 3)
	assert_eq(way.size(), 3)
	assert_true(way[0].contains("Schön, dich zu sehen"), "the sentence of the loops, unchanged")
	var told := "\n".join(favor) + "\n".join(way)
	for word: String in ["Nein", "Wetter", "Zeit", "fort", "weg", "vermisst", "zurück"]:
		assert_false(told.contains(word), "no refusal, no weather, no time, no absence: " + word)
	for line in favor + way:
		assert_true(line.begins_with("Elysianer:"), "only the Elysians speak here")
		assert_true(line.contains("{{WorldState.player_name()}}") or not line.contains("{{"))


func test_the_basin_shows_the_water_and_gives_nothing_and_says_nothing_about_it() -> void:
	var back := _written("basin_back")
	assert_eq(back.size(), 7, "three lines, two answers, the watching's two lines")
	assert_eq(back[3], "Wasser spritzen.")
	assert_eq(back[4], "Zusehen.")
	for line: String in back.slice(0, 3):
		assert_false(line.contains(":"), "narration only: " + line)
		assert_false(line.contains("!") or line.contains("?"), line)
	var play := await DialogueWalk.play(FILE, "basin_play")
	assert_eq(play.size(), 4)
	var told := "\n".join(play)
	assert_true(told.contains("Zahl") and told.contains("Balken"), "the corner does not change")
	var reward := RegEx.create_from_string("\\b(Erfahrung|Gold|Punkte)\\b")
	assert_null(reward.search(told), "no reward is named")
	assert_false(told.contains("Wasser spritzen"), "the action is not repeated as an event")
	assert_true(WorldState.has_facet("aliveness"), "and the facet is set after the last line")


# --- The butterflies that were never handed in ----------------------------------------------------


func test_the_gift_is_the_reward_of_butterflies_that_were_never_handed_in() -> void:
	_butterflies_waiting()
	await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Annehmen."]))
	assert_true(WorldState.is_quest_done("side_elysia_butterflies"), "the quest closes as in Act I")
	assert_true(WorldState.is_quest_started("side_elysia_fountain"), "and the next one begins")
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "reward", "the chest is next")
	assert_true(WorldState.has_item("item_compliment"))


func test_with_the_chest_open_the_hero_quest_is_left_where_it_stands() -> void:
	_butterflies_waiting()
	WorldState.set_flag("elysia.chest_tree_opened")
	await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Annehmen."]))
	assert_true(WorldState.is_quest_done("side_elysia_butterflies"))
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "butterflies")


func test_leaving_the_gift_leaves_the_waiting_butterflies_alone() -> void:
	_butterflies_waiting()
	await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Lass nur."]))
	assert_eq(WorldState.quest_stage("side_elysia_butterflies"), "return", "still to hand in")
	assert_false(WorldState.is_quest_started("side_elysia_fountain"))


func test_a_gift_taken_before_does_not_hide_the_hand_in_that_comes_later() -> void:
	WorldState.set_flag("elysia.back_gift")
	_butterflies_waiting()
	var seen := await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Annehmen."]))
	assert_gte(seen.size(), 7, "she offers it again: the lines and the gift's own")
	assert_true(WorldState.is_quest_done("side_elysia_butterflies"))


func test_a_gift_alone_does_not_touch_a_quest_that_is_not_waiting() -> void:
	WorldState.start_quest("side_elysia_butterflies")
	await DialogueWalk.play(FILE, "gardener_back", PackedStringArray(["Annehmen."]))
	assert_eq(WorldState.quest_stage("side_elysia_butterflies"), "catch", "the quest runs on")
	assert_false(WorldState.is_quest_started("side_elysia_fountain"))
