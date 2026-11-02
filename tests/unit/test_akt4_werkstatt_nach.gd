extends GutTest
## Act IV, segment S4: what happens in the workshop after the board and outside it. Tess talks
## shorter to whoever asked for help (the flag) and the facet "connection" adds the answer about
## the ladder beside the unconditional ones; outside she sits on her crate and says "Setz dich",
## and "Nichts" (Bible §44) is a sitting, lines of things and no lesson; the things in the room;
## the quest, the journal and the board. The first half (the introduction, the offer, the
## sawing and the asking for help) is tested in test_akt4_werkstatt.

const FILE := "res://content/dialogue/akt4/werkstatt.dialogue"
const NOTHING := "side_city_nothing"
const BOARD := "curiosity_crooked_board"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## The board is sawn, the way the player did it.
func _board_done(asked: bool) -> void:
	WorldState.set_flag("city.tess_met")
	WorldState.set_flag("city.board_done")
	if asked:
		WorldState.set_facet("connection")
		WorldState.set_flag("city.asked_help")


# --- After the board --------------------------------------------------------------------------


func test_after_the_board_she_talks_shorter_to_whoever_asked_for_help() -> void:
	_board_done(true)
	var asked := await DialogueWalk.play(FILE, "tess", PackedStringArray(["…"]))
	assert_true(_has(asked, "wer_again_1"))
	assert_false(_has(asked, "wer_again_2"))
	WorldState.new_game()
	_board_done(false)
	var alone := await DialogueWalk.play(FILE, "tess", PackedStringArray(["…"]))
	assert_true(_has(alone, "wer_again_2"))
	assert_false(_has(alone, "wer_again_1"))


func test_the_facet_adds_an_answer_beside_the_unconditional_ones_and_the_silence_stays_last(
) -> void:
	_board_done(false)
	var plain := await DialogueWalk.answers(FILE, "tess")
	assert_eq(plain.size(), 3, "wood, watching, silence")
	assert_eq(plain[plain.size() - 1], "…")
	WorldState.new_game()
	_board_done(true)
	var held := await DialogueWalk.answers(FILE, "tess")
	assert_eq(held.size(), 4, "and the ladder")
	assert_true("Hältst du mir die Leiter?" in held)
	assert_eq(held[held.size() - 1], "…", "the silence is still the last answer")


func test_the_ladder_is_held_by_her_and_asks_nothing_of_the_player() -> void:
	_board_done(true)
	var before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(FILE, "tess", PackedStringArray(["Leiter"]))
	for id: String in ["wer_again_7", "wer_again_8", "wer_again_9", "wer_again_11"]:
		assert_true(_has(seen, id), id)
	assert_eq(WorldState.state.flags, before, "nothing is set, nothing is counted")


# --- Outside: the bench and "Nichts" ----------------------------------------------------------


func test_outside_she_says_one_line_and_the_cue_sets_nothing() -> void:
	var before := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(FILE, "bench")
	assert_eq(seen, PackedStringArray([LineText.of("wer_bench_1")]), "Setz dich.")
	assert_eq(WorldState.state.flags, before)


func test_the_sitting_is_three_lines_of_things_and_a_shorter_one_the_next_time() -> void:
	var before := WorldState.state.flags.duplicate()
	var first := await DialogueWalk.play(FILE, "nothing")
	assert_eq(first.size(), 3)
	assert_eq(WorldState.state.flags, before, "the scene keeps the quest, the cue sets nothing")
	WorldState.set_flag("city.sat_with_tess")
	var again := await DialogueWalk.play(FILE, "nothing")
	assert_eq(again.size(), 2, "the short version")
	assert_false(_has(again, "wer_nothing_1"))
	assert_eq(
		await DialogueWalk.play(FILE, "bench"),
		PackedStringArray([LineText.of("wer_after_1")]),
		"and what she says after, which explains nothing"
	)


# --- The things in the workshop ---------------------------------------------------------------


func test_the_saws_the_ladder_and_the_dust_are_read_again_and_set_nothing() -> void:
	for cue: String in ["saws", "ladder", "dust"]:
		var before := WorldState.state.flags.duplicate()
		var first := await DialogueWalk.play(FILE, cue)
		assert_gte(first.size(), 2, cue)
		assert_eq(await DialogueWalk.play(FILE, cue), first, "%s: the same twice" % cue)
		assert_eq(WorldState.state.flags, before, "%s sets nothing" % cue)


func test_the_board_on_the_trestle_is_marked_before_and_only_shavings_after() -> void:
	var before := await DialogueWalk.play(FILE, "board")
	assert_true(_has(before, "wer_board_1") and _has(before, "wer_board_2"))
	WorldState.set_flag("city.board_done")
	var after := await DialogueWalk.play(FILE, "board")
	assert_true(_has(after, "wer_board_3") and _has(after, "wer_board_4"))
	assert_false(_has(after, "wer_board_1"))


# --- Quest, journal and the board -------------------------------------------------------------


func test_the_quest_nothing_has_two_stages_and_its_texts() -> void:
	var quest := ContentDB.quest(NOTHING)
	assert_not_null(quest)
	assert_eq(quest.first_stage().id, "sit")
	assert_true(quest.can_advance("sit", "done"))
	for key: String in [
		"QUEST_SIDE_CITY_NOTHING_TITLE",
		"QUEST_SIDE_CITY_NOTHING_SIT",
		"QUEST_SIDE_CITY_NOTHING_DONE",
		"MEMORY_TESS_BOARD",
	]:
		assert_ne(tr(key), key, key)


func test_the_board_is_a_curiosity_with_a_picture_and_a_sentence() -> void:
	var item := ContentDB.item(BOARD)
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
	assert_ne(tr("CURIOSITY_CROOKED_BOARD_NAME"), "CURIOSITY_CROOKED_BOARD_NAME")
	assert_ne(tr("CURIOSITY_CROOKED_BOARD_DESC"), "CURIOSITY_CROOKED_BOARD_DESC")
	assert_true(
		FileAccess.file_exists("res://assets/generated/items/curiosity_crooked_board.png"),
		"its picture"
	)
	assert_false(tr("CURIOSITY_CROOKED_BOARD_DESC").contains("Tess"), "the board is the board")
