extends GutTest
## Act IV, segment S1: the road west. What stands along it is told in small things: two signposts,
## the goat's hoofprints and bell (the goat itself is never there), a scarecrow and a notice in a
## field, a milestone worn smooth (a trace of the world, a fragment) and the view of the city's
## smoke; at the end of the road the paving works hold the way until S2. The scene (map, quest
## start, beats) is tested in test_akt4_strasse_szene, the valley's door in test_akt4_strasse_tal.

const FILE := "res://content/dialogue/akt4/strasse.dialogue"
const QUEST := "main_city_way"
const CUES: PackedStringArray = [
	"signpost_tal",
	"signpost",
	"goat_prints",
	"goat_bell",
	"scarecrow",
	"field_notice",
	"milestone",
	"view_town",
	"town_wait",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func _ids() -> PackedStringArray:
	var found: PackedStringArray = []
	var source := FileAccess.get_file_as_string(FILE)
	for hit in RegEx.create_from_string("\\[ID:(str_[a-z0-9_]+)\\]").search_all(source):
		found.append(hit.get_string(1))
	return found


func test_the_file_tells_nine_cues_in_draft_with_unique_ids() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	var cues := RegEx.create_from_string("(?m)^~ ([a-z_]+)$").search_all(source)
	var names: PackedStringArray = []
	for hit in cues:
		names.append(hit.get_string(1))
	assert_eq(names, CUES, "the cues of the contract, in this order")
	var ids := _ids()
	assert_eq(ids.size(), 26, "twenty-four lines and two answers")
	var unique := {}
	for id in ids:
		unique[id] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_eq(source.count("[#draft]"), ids.size(), "every line is a draft")
	assert_false(source.contains("[#ph]"), "no placeholder in a story file")


func test_every_cue_can_be_read_again_and_says_the_same_twice() -> void:
	for cue: String in [
		"signpost_tal", "signpost", "goat_prints", "scarecrow", "field_notice", "town_wait"
	]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, "%s: two lines at least" % cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)


func test_the_bell_can_be_taken_or_left_and_either_costs_nothing() -> void:
	var answers := await DialogueWalk.answers(FILE, "goat_bell")
	assert_eq(answers.size(), 2, "take it or leave it")
	var left := await DialogueWalk.play(FILE, "goat_bell", PackedStringArray(["Hängen lassen"]))
	assert_true(_has(left, "str_bell_1") and _has(left, "str_bell_3"))
	assert_false(WorldState.has_item("curiosity_goat_bell"))
	assert_false(WorldState.has_flag("city.bell_taken"))
	var taken := await DialogueWalk.play(FILE, "goat_bell", PackedStringArray(["Einstecken"]))
	assert_true(_has(taken, "str_bell_2"))
	assert_true(WorldState.has_item("curiosity_goat_bell"))
	assert_true(WorldState.has_flag("city.bell_taken"))


func test_the_milestone_is_a_fragment_the_first_time_and_a_short_line_after() -> void:
	var first := await DialogueWalk.play(FILE, "milestone")
	assert_eq(first.size(), 3)
	assert_true(WorldState.has_flag("fragment.milestone"))
	assert_eq(Collection.fragments(), 1, "one trace of the world")
	assert_eq(
		await DialogueWalk.play(FILE, "milestone"), PackedStringArray([LineText.of("str_mile_4")])
	)
	assert_eq(Collection.fragments(), 1, "nothing counted twice")


func test_the_view_is_told_once_in_full_and_marks_the_flag_the_scene_reads() -> void:
	var first := await DialogueWalk.play(FILE, "view_town")
	assert_eq(first.size(), 3)
	assert_true(WorldState.has_flag("city.view_seen"))
	assert_eq(
		await DialogueWalk.play(FILE, "view_town"), PackedStringArray([LineText.of("str_view_4")])
	)


func test_the_goat_is_a_trace_and_the_stone_is_a_trace_of_the_world() -> void:
	var source := FileAccess.get_file_as_string(FILE)
	var spoken := ""
	for hit in RegEx.create_from_string("(?m)^\\s*(?:- )?(.*)\\[ID:str_").search_all(source):
		spoken += hit.get_string(1) + "\n"
	assert_false(
		spoken.contains("Ziege"), "she is never named or shown; the prints and the bell say it"
	)
	for word: String in ["Kind", "Mutter", "Vater", "Mira", "du musst", "Heilung"]:
		assert_false(spoken.contains(word), "no %s on the road" % word)
	var stone := ""
	for cue_lines in await DialogueWalk.play(FILE, "milestone"):
		stone += cue_lines
	for word: String in ["Grund", "weil", "damals"]:
		assert_false(stone.contains(word), "the stone gives no reason: " + word)


func test_the_paving_works_only_hold_the_way_and_promise_nothing() -> void:
	var lines := await DialogueWalk.play(FILE, "town_wait")
	assert_eq(lines.size(), 2)
	for line in lines:
		for word: String in ["bald", "morgen", "gleich", "später", "wieder"]:
			assert_false(line.to_lower().contains(word), "no promise: " + word)


# --- Quest, journal and the bell --------------------------------------------------------------


func test_the_quest_has_one_stage_that_counts_as_the_walk_so_far() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_not_null(quest)
	assert_eq(quest.first_stage().id, "west")
	assert_true(quest.first_stage().is_final(), "S2 hangs the next stage on it")
	assert_ne(tr("QUEST_MAIN_CITY_WAY_TITLE"), "QUEST_MAIN_CITY_WAY_TITLE")
	assert_ne(tr("QUEST_MAIN_CITY_WAY_WEST"), "QUEST_MAIN_CITY_WAY_WEST")
	assert_true(WorldState.start_quest(QUEST))
	assert_eq(WorldState.quest_stage(QUEST), "west")


func test_the_bell_is_a_curiosity_with_a_picture_and_a_sentence() -> void:
	var item := ContentDB.item("curiosity_goat_bell")
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
	assert_ne(tr("CURIOSITY_GOAT_BELL_NAME"), "CURIOSITY_GOAT_BELL_NAME")
	assert_ne(tr("CURIOSITY_GOAT_BELL_DESC"), "CURIOSITY_GOAT_BELL_DESC")
	assert_true(
		FileAccess.file_exists("res://assets/generated/items/curiosity_goat_bell.png"),
		"its picture"
	)
	assert_true(
		FileAccess.file_exists("res://assets/generated/fragments/fragment_milestone.png"),
		"and the stone's"
	)
