extends GutTest
## Act IV, segment S5: after the no. The Gefällige sits down beside her and holds out a bread
## (Grenzen III: a limit can make closeness possible; refusing the bread is allowed and stays
## warm), whoever takes it sees his kitchen and the row of slips over the stove, and nothing
## explains them. Mira at the edge says no to a slip with no effort. The board counts nineteen.
## Each task has its short errand at its place, and the struck slips all read alike. What leads
## here (the opening, the choice, the values, the no) is in test_akt4_liste, the places in the
## city in test_akt4_liste_szene.

const STADT := "res://content/dialogue/akt4/stadt.dialogue"
const TASKS: PackedStringArray = ["bouquet", "ladder", "stage", "goat", "bread", "lost"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


func test_he_sits_beside_her_and_holds_out_a_bread_she_may_take() -> void:
	var seen := await DialogueWalk.play(STADT, "list_sit", PackedStringArray(["Nehmen"]))
	assert_true(_has(seen, "stadt_list_29"), "he sits down beside her")
	assert_true(_has(seen, "stadt_list_31"), "too much bread, always")
	assert_true(WorldState.has_flag("list.sat"))
	assert_true(WorldState.has_item("item_loaf"), "the bread of Act I, a gift and not a trade")
	assert_true(WorldState.has_flag("list.kitchen_seen"), "and she follows him")


func test_refusing_the_bread_is_allowed_and_he_stays_warm() -> void:
	for pick: String in ["Nein, danke", "…"]:
		WorldState.new_game()
		var seen := await DialogueWalk.play(STADT, "list_sit", PackedStringArray([pick]))
		assert_true(WorldState.has_flag("list.sat"), "he sat beside her all the same: " + pick)
		assert_false(WorldState.has_item("item_loaf"), pick)
		assert_false(
			WorldState.has_flag("list.kitchen_seen"), "no kitchen without the bread: " + pick
		)
		var all := " ".join(seen)
		assert_false(all.contains("!"), "a no to the bread is no scene: " + pick)
		for word: String in ["beleidigt", "gekränkt", "schade", "undankbar", "Aber"]:
			assert_false(all.contains(word), "no hurt in his answer: " + word)
		assert_true(
			all.contains("esse ich es selbst") or all.contains("isst"), "he eats it himself"
		)


func test_the_group_of_the_bread_has_the_silence_last_and_every_answer_goes_somewhere_else(
) -> void:
	var answers := await DialogueWalk.answers(STADT, "list_sit")
	assert_eq(answers.size(), 3)
	assert_eq(answers[0], "Nehmen.")
	assert_eq(answers[answers.size() - 1], "…")
	assert_eq(WorldState.has_item("item_loaf"), false, "listing the answers takes nothing")


func test_the_kitchen_shows_things_and_explains_nothing() -> void:
	var seen := await DialogueWalk.play(STADT, "list_kitchen")
	var all := " ".join(seen)
	for slip: String in ["Kein Salz", "Nur das Weiche", "Nicht vor acht"]:
		assert_true(all.contains(slip), slip)
	assert_true(all.contains("Einen Namen trägt er nicht"), "the oldest has no name")
	for word: String in [
		"Mutter",
		"Vater",
		"Eltern",
		"Kind",
		"Strafe",
		"schlug",
		"Angst",
		"früher",
		"damals",
		"weil",
		"Grund",
		"Ursache",
		"deshalb",
	]:
		assert_false(all.contains(word), "the kitchen gives no reason: " + word)
	assert_true(WorldState.has_item("curiosity_old_slip"), "the oldest slip goes with her")
	assert_true(WorldState.has_flag("list.kitchen_seen"))


func test_he_has_one_short_line_after_the_list_and_never_a_lesson() -> void:
	WorldState.set_flag("list.closed")
	var neither := await DialogueWalk.play(STADT, "gef_after")
	assert_eq(neither.size(), 1, "the bread is not mentioned if he has not given it")
	WorldState.set_flag("list.sat")
	var sat := await DialogueWalk.play(STADT, "gef_after")
	assert_eq(sat.size(), 2)
	assert_true(_has(sat, "stadt_list_47"))
	WorldState.set_flag("list.kitchen_seen")
	var kitchen := await DialogueWalk.play(STADT, "gef_after")
	assert_true(_has(kitchen, "stadt_list_46"))
	assert_false(_has(kitchen, "stadt_list_47"), "the kitchen line replaces the next-baking one")
	for line in kitchen:
		for word: String in ["gelernt", "Grenze", "gut so", "stolz", "richtig"]:
			assert_false(line.contains(word), "no lesson, no praise: " + word)


# --- Mira and the board -----------------------------------------------------------------------


func test_mira_says_no_to_a_slip_with_no_effort_and_nobody_comments_on_it() -> void:
	WorldState.set_flag("list.opened")
	var flags := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(STADT, "mira_square")
	assert_eq(seen.size(), 3)
	assert_true(_has(seen, "stadt_list_5"), "Nein.")
	assert_eq(WorldState.state.flags, flags, "no flag")
	assert_false(WorldState.has_memory("mira", "said_no"), "and no new memory: the last is S7's")
	assert_true(WorldState.state.relationships.is_empty(), "nothing between them changes")
	var all := " ".join(seen)
	for word: String in ["stark", "mutig", "Vorbild", "beneide", "wie du"]:
		assert_false(all.contains(word), "the text never remarks on it: " + word)


func test_the_board_counts_nineteen_once_the_list_is_open_and_says_the_s2_words_before() -> void:
	var before := await DialogueWalk.play(STADT, "list_board")
	assert_true(_has(before, "stadt_board_2"), "sixteen, as in S2")
	WorldState.set_flag("list.opened")
	var after := await DialogueWalk.play(STADT, "list_board")
	assert_true(_has(after, "stadt_list_1"))
	assert_true(" ".join(after).to_lower().contains("neunzehn"))
	assert_false(_has(after, "stadt_board_2"))


# --- The errands and the struck slips ---------------------------------------------------------


func test_each_task_is_a_short_errand_at_its_place_that_sets_only_its_done_flag() -> void:
	for task: String in TASKS:
		WorldState.new_game()
		WorldState.set_flag("list.take_" + task)
		var flags := WorldState.state.flags.duplicate()
		var seen := await DialogueWalk.play(STADT, "do_" + task)
		assert_between(seen.size(), 2, 3, task)
		assert_true(WorldState.has_flag("list.done_" + task), task)
		flags["list.done_" + task] = true
		assert_eq(WorldState.state.flags, flags, "%s sets nothing else" % task)
		assert_eq(WorldState.state.inventory.size(), 0, "%s gives nothing for it" % task)
		var all := " ".join(seen)
		for word: String in ["Danke", "gut gemacht", "Lob", "Wert", "Freiheit", "Nähe", "Ruhe"]:
			assert_false(all.contains(word), "no praise, no value word in %s: %s" % [task, word])


func test_the_struck_slips_all_read_alike_and_set_nothing() -> void:
	var flags := WorldState.state.flags.duplicate()
	var seen := await DialogueWalk.play(STADT, "slip_struck")
	assert_eq(seen.size(), 2)
	assert_true(" ".join(seen).contains("Tut mir leid"))
	assert_eq(WorldState.state.flags, flags)
	assert_eq(await DialogueWalk.play(STADT, "slip_struck"), seen, "the same twice")


# --- Quests, journal and the old slip ---------------------------------------------------------


func test_the_list_is_a_quest_with_two_stages_and_the_walk_ends_in_it() -> void:
	var list := ContentDB.quest("side_city_list")
	assert_not_null(list)
	assert_eq(list.first_stage().id, "open")
	assert_true(list.can_advance("open", "closed"))
	assert_true(list.stage("closed").is_final())
	var way := ContentDB.quest("main_city_way")
	assert_true(way.can_advance("help", "list"))
	assert_true(way.stage("list").is_final(), "this is as far as S5 goes")
	for key: String in [
		"QUEST_MAIN_CITY_WAY_LIST",
		"QUEST_SIDE_CITY_LIST_TITLE",
		"QUEST_SIDE_CITY_LIST_OPEN",
		"QUEST_SIDE_CITY_LIST_CLOSED",
	]:
		assert_ne(tr(key), key, key)
	for key: String in ["QUEST_SIDE_CITY_LIST_OPEN", "QUEST_SIDE_CITY_LIST_CLOSED"]:
		for digit: String in "0123456789":
			assert_false(tr(key).contains(digit), "no number in the journal: " + key)


func test_the_old_slip_is_a_curiosity_with_a_picture_and_a_sentence_and_no_cause() -> void:
	var item := ContentDB.item("curiosity_old_slip")
	assert_not_null(item)
	assert_eq(item.kind, ItemDef.Kind.CURIOSITY)
	assert_ne(tr("CURIOSITY_OLD_SLIP_NAME"), "CURIOSITY_OLD_SLIP_NAME")
	assert_ne(tr("CURIOSITY_OLD_SLIP_DESC"), "CURIOSITY_OLD_SLIP_DESC")
	assert_true(
		FileAccess.file_exists("res://assets/generated/items/curiosity_old_slip.png"), "its picture"
	)
	for word: String in ["Gefällige", "Mutter", "Vater", "weil"]:
		assert_false(
			tr("CURIOSITY_OLD_SLIP_DESC").contains(word), "the slip names no cause: " + word
		)
