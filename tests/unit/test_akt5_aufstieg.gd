extends GutTest
## Act V, segment G1: the climb (docs/akt5/REGIONSBRIEFE.md). Ten things along a path into the
## mountains: a third arrow in chalk on the road, the first cairn, one of three small traces of Mira
## (a strip of net, never commented), the view with the smoke of the Anlage, two planks, a sign, a
## slate chip to take or leave, an iron ring (a trace of the world) and the scree at the end of the
## path. Nobody speaks. The map and the scene are tested in test_akt5_aufstieg_szene.

const FILE := "res://content/dialogue/akt5/aufstieg.dialogue"
const QUEST := "main_mountain_way"
const CUES: PackedStringArray = [
	"signpost_third",
	"cairn_first",
	"mira_trace_boundary",
	"mira_trace_joined",
	"mira_trace_silent",
	"view_smoke",
	"plank_bridge",
	"trail_sign",
	"slate_chip",
	"iron_ring",
	"ridge_wait",
]
const ITEM := "curiosity_slate_chip"


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
	for hit in RegEx.create_from_string("\\[ID:(auf_[a-z0-9_]+)\\]").search_all(_source()):
		found.append(hit.get_string(1))
	return found


## The text of every line (before its ID), comments and code left out.
func _spoken() -> String:
	var spoken := ""
	for line in _source().split("\n"):
		var at := line.find("[ID:")
		if at > -1 and not line.strip_edges().begins_with("#"):
			spoken += line.substr(0, at) + "\n"
	return spoken


# --- The file ---------------------------------------------------------------------------------


func test_the_file_tells_its_cues_in_draft_with_unique_ids_within_the_budget() -> void:
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z_]+)$").search_all(_source()):
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(_source().count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(_source().contains("[#ph]"), "no placeholder in a story file")
	# the segment plans 25 lines (plus or minus four) and two answers
	assert_lte(ids.size() - 2, 29, "the lines of the segment")
	assert_gte(ids.size() - 2, 21, "and not a path without things")


func test_nobody_speaks_and_every_line_is_told_without_a_number() -> void:
	for line in _spoken().split("\n", false):
		var text := line.strip_edges()
		if text.begins_with("-"):
			continue
		assert_false(text.contains(": "), "narration has no speaker: " + text)
	for digit: String in "0123456789":
		assert_false(_spoken().contains(digit), "no number in the text: " + digit)
	assert_false(_spoken().contains("Mira"), "her trace is a thing, not a name")


func test_every_cue_can_be_read_again_and_the_things_that_set_nothing_set_nothing() -> void:
	for cue: String in [
		"signpost_third",
		"cairn_first",
		"mira_trace_boundary",
		"mira_trace_joined",
		"mira_trace_silent",
		"plank_bridge",
		"trail_sign",
		"ridge_wait",
	]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, "%s: two lines at least" % cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)


# --- The traces of Mira ------------------------------------------------------------------------


func test_the_three_traces_are_three_different_things_and_none_is_a_verdict() -> void:
	var told := {}
	for cue: String in ["mira_trace_boundary", "mira_trace_joined", "mira_trace_silent"]:
		told[cue] = "\n".join(await DialogueWalk.play(FILE, cue))
	assert_true(told["mira_trace_boundary"].contains("Pfosten"), "a post, a little off the path")
	assert_true(told["mira_trace_joined"].contains("Ast"), "a branch, where she walks")
	assert_true(told["mira_trace_silent"].contains("Stein"), "a stone in the middle of the path")
	for cue: String in told:
		for word: String in [
			"Streit", "böse", "verzeih", "Schuld", "traurig", "wütend", "vermisst", "Freund"
		]:
			assert_false(told[cue].contains(word), "%s: no %s" % [cue, word])


# --- The view, the ring, the slate -------------------------------------------------------------


func test_the_view_is_told_once_in_full_and_marks_the_flag_the_scene_reads() -> void:
	var first := await DialogueWalk.play(FILE, "view_smoke")
	assert_true(WorldState.has_flag("mountain.view_seen"))
	assert_true(_has(first, "auf_view_smoke_1") and _has(first, "auf_view_smoke_3"))
	var again := await DialogueWalk.play(FILE, "view_smoke")
	assert_eq(again.size(), 1, "a short line the second time")
	assert_true(_has(again, "auf_view_smoke_4"))


func test_the_ring_is_a_fragment_the_first_time_and_a_short_line_after() -> void:
	var first := await DialogueWalk.play(FILE, "iron_ring")
	assert_true(Collection.has_fragment("iron_ring"))
	assert_eq(Collection.fragments(), 1)
	assert_true(_has(first, "auf_iron_ring_1") and _has(first, "auf_iron_ring_3"))
	var again := await DialogueWalk.play(FILE, "iron_ring")
	assert_eq(again.size(), 1)
	assert_true(_has(again, "auf_iron_ring_4"))
	assert_eq(Collection.fragments(), 1, "once")
	var ring := "\n".join(first)
	for word: String in ["Kind", "Haus", "Ursache", "Grund"]:
		assert_false(ring.contains(word), "a trace of the world, no %s" % word)


func test_the_slate_can_be_taken_or_left_and_either_costs_nothing() -> void:
	var answers := await DialogueWalk.answers(FILE, "slate_chip")
	assert_eq(answers.size(), 2, "take it or leave it")
	var left := await DialogueWalk.play(FILE, "slate_chip", PackedStringArray(["Liegen lassen"]))
	assert_true(_has(left, "auf_slate_chip_1") and _has(left, "auf_slate_chip_3"))
	assert_false(WorldState.has_item(ITEM))
	assert_false(WorldState.has_flag("mountain.slate_taken"))
	var taken := await DialogueWalk.play(FILE, "slate_chip", PackedStringArray(["Einstecken"]))
	assert_true(_has(taken, "auf_slate_chip_2"))
	assert_true(WorldState.has_item(ITEM))
	assert_true(WorldState.has_flag("mountain.slate_taken"))


func test_the_slate_is_a_curiosity_with_a_picture_and_a_sentence() -> void:
	var item := ContentDB.item(ITEM)
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
	assert_true(item.can_be_placed(), "it can stand on a shelf of the house")
	assert_true(ResourceLoader.exists("res://assets/generated/items/%s.png" % ITEM))
	for key: String in ["CURIOSITY_SLATE_CHIP_NAME", "CURIOSITY_SLATE_CHIP_DESC"]:
		assert_ne(tr(key), key, key)


# --- The walk ----------------------------------------------------------------------------------


func test_the_walk_begins_with_the_climb_and_the_valley_follows_it() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_not_null(quest)
	assert_eq(quest.first_stage().id, "climb")
	assert_false(quest.stage("climb").is_final(), "the valley (G2) hangs on it")
	assert_true(quest.can_advance("climb", "valley"))
	assert_false(quest.stage("valley").is_final(), "the plant (G3) hangs on that")
	assert_true(quest.can_advance("valley", "plant"))
	assert_false(quest.stage("plant").is_final(), "the load (G4) hangs on that")
	assert_true(quest.can_advance("plant", "load"))
	assert_true(quest.stage("load").is_final(), "and the next segment hangs a stage on that (G5)")
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_TITLE"), "QUEST_MAIN_MOUNTAIN_WAY_TITLE")
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_CLIMB"), "QUEST_MAIN_MOUNTAIN_WAY_CLIMB")
	assert_true(WorldState.start_quest(QUEST))
	assert_eq(WorldState.quest_stage(QUEST), "climb")
