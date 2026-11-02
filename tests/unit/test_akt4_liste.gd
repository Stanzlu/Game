extends GutTest
## Act IV, segment S5: the list of the Gefällige (Bible §14, docs/akt4/REGIONSBRIEFE.md O5, O7). The
## board grows from sixteen to nineteen slips while he apologises for each; he does not ask, he only
## asks; the player takes up to three of six tasks and says no to the rest, without a reason. Each
## task carries one of the values of Act II, and taking one that is hers sets the facet "integrity",
## which the no reads as one more answer beside the unconditional ones. What happens after the no
## (the bread, the kitchen, Mira, the board, the tasks, the quests) is in test_akt4_liste_nach,
## the places in the city in test_akt4_liste_szene.

const STADT := "res://content/dialogue/akt4/stadt.dialogue"
const NEW_CUES: PackedStringArray = [
	"mira_list",
	"gef_list",
	"list_pick_1",
	"list_pick_2",
	"list_pick_3",
	"list_none",
	"list_enough",
	"list_wait",
	"list_close",
	"list_sit",
	"list_kitchen",
	"gef_after",
	"do_bouquet",
	"do_ladder",
	"do_stage",
	"do_goat",
	"do_bread",
	"do_lost",
	"slip_struck",
]
## The answer that picks each task (the text is the same in every group) and the value it carries.
const TASKS := {
	"bouquet": ["Den Strauß", "closeness"],
	"ladder": ["Die Leiter", "closeness"],
	"stage": ["Die Bühne", "freedom"],
	"goat": ["Die Ziege", "freedom"],
	"bread": ["Das Brot", "calm"],
	"lost": ["Das Fundbüro", "calm"],
}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## The source of one cue of the file (from its `~` line to the next).
func _cue_source(cue: String) -> String:
	var source := FileAccess.get_file_as_string(STADT)
	var start := source.find("\n~ %s\n" % cue)
	assert_ne(start, -1, "the cue %s is there" % cue)
	var end := source.find("\n~ ", start + 3)
	return source.substr(start, (end if end != -1 else source.length()) - start)


## Everything the new cues say in lines and answers (not the comments), for word checks.
func _list_text() -> String:
	var spoken := ""
	for cue in NEW_CUES:
		for hit in (
			RegEx
			. create_from_string("(?m)^[ \\t]*(?:- )?([^#\\n][^\\n]*?)[ \\t]*\\[ID:stadt_list_")
			. search_all(_cue_source(cue))
		):
			spoken += hit.get_string(1) + "\n"
	return spoken


# --- The file ---------------------------------------------------------------------------------


func test_the_new_cues_end_the_file_and_tell_sixty_six_lines_and_thirty_answers_in_draft() -> void:
	var source := FileAccess.get_file_as_string(STADT)
	var names: PackedStringArray = []
	for hit in RegEx.create_from_string("(?m)^~ ([a-z0-9_]+)$").search_all(source):
		names.append(hit.get_string(1))
	for cue in NEW_CUES:
		assert_true(cue in names, cue)
	var ids := RegEx.create_from_string("\\[ID:(stadt_list_[a-z0-9_]+)\\]").search_all(source)
	assert_eq(ids.size(), 96, "sixty-six lines and thirty answers")
	var unique := {}
	for hit in ids:
		unique[hit.get_string(1)] = true
	assert_eq(unique.size(), ids.size(), "no ID twice")
	assert_false(source.contains("[#ph]"), "no placeholder in a story file")


func test_the_gefaellige_never_gets_a_therapy_word_a_self_hatred_or_a_joke_at_his_cost() -> void:
	var all := _list_text()
	assert_gt(all.length(), 6000, "the whole text of the list is read")
	for word: String in [
		"People",
		"Pleaser",
		"Grenzen",
		"Muster",
		"Trauma",
		"Selbstwert",
		"ich hasse",
		"lächerlich",
		"Schwäche",
		"setz endlich",
		"Setz endlich",
	]:
		assert_false(all.contains(word), "no jargon, no self-hatred: " + word)


# --- The opening ------------------------------------------------------------------------------


func test_the_list_opens_with_three_more_slips_each_one_apologised_for() -> void:
	var seen := await DialogueWalk.play(STADT, "gef_list", PackedStringArray(["Keine", "…", "…"]))
	var joined := " ".join(seen).to_lower()
	for number: String in ["siebzehn", "achtzehn", "neunzehn"]:
		assert_true(joined.contains(number), number + " is written out")
	assert_gte(joined.count("entschuldige"), 3, "he apologises before each one")
	assert_true(WorldState.has_flag("list.opened"))
	assert_true(WorldState.is_quest_started("side_city_list"))
	assert_true(joined.contains("ich bitte dich nicht"), "he does not ask, he only asks")


func test_the_walk_to_the_town_goes_on_to_the_list_from_every_stage_before_it() -> void:
	for stage: String in ["town", "help"]:
		WorldState.new_game()
		WorldState.start_quest("main_city_way")
		WorldState.advance_quest("main_city_way", "town")
		if stage == "help":
			WorldState.advance_quest("main_city_way", "help")
		await DialogueWalk.play(STADT, "gef_list", PackedStringArray(["Keine", "…", "…"]))
		assert_eq(WorldState.quest_stage("main_city_way"), "list", "from " + stage)


# --- The choice -------------------------------------------------------------------------------


func test_the_first_group_names_the_six_tasks_none_and_the_silence_last() -> void:
	var answers := await DialogueWalk.answers(STADT, "list_pick_1")
	assert_eq(answers.size(), 8, "six tasks, none, the silence")
	assert_eq(answers[answers.size() - 2], "Keine.")
	assert_eq(answers[answers.size() - 1], "…", "the silence is the last answer")
	for task: String in TASKS:
		assert_true((TASKS[task][0] + ".") in answers, task)


func test_a_taken_task_leaves_the_next_group_and_up_to_three_can_be_taken() -> void:
	var picks := PackedStringArray(["Den Strauß", "Die Bühne", "Das Brot", "…", "…"])
	var groups := await DialogueWalk.groups(STADT, "list_pick_1", picks)
	assert_eq(groups[0].size(), 8)
	assert_eq(groups[1].size(), 7, "five tasks left, enough, the silence")
	assert_false("Den Strauß." in groups[1])
	assert_eq(groups[2].size(), 6, "four tasks left, enough, the silence")
	assert_eq(groups[2][groups[2].size() - 2], "Das reicht.")
	assert_eq(groups[3].size(), 2, "after the third: the no (the facet answer needs a value)")
	assert_true(WorldState.has_flag("list.take_bouquet"))
	assert_true(WorldState.has_flag("list.take_stage"))
	assert_true(WorldState.has_flag("list.take_bread"))
	assert_false(WorldState.has_flag("list.take_ladder"))
	assert_eq(
		(
			WorldState
			. state
			. flags
			. keys()
			. filter(func(id: String) -> bool: return id.begins_with("list.take_"))
			. size()
		),
		3
	)


func test_that_is_enough_takes_two_and_none_takes_nothing_and_both_go_to_the_no() -> void:
	var two := await DialogueWalk.play(
		STADT, "list_pick_1", PackedStringArray(["Das Brot", "Die Ziege", "Das reicht", "…"])
	)
	assert_true(WorldState.has_flag("list.take_bread") and WorldState.has_flag("list.take_goat"))
	assert_true(_has(two, "stadt_list_19"), "he takes enough as enough")
	assert_true(WorldState.has_flag("list.closed"))
	WorldState.new_game()
	var none := await DialogueWalk.play(
		STADT, "list_pick_1", PackedStringArray(["Keine", "…", "…"])
	)
	assert_true(_has(none, "stadt_list_18"))
	assert_true(WorldState.has_flag("list.closed"), "a list with no task is closed as well")
	for task: String in TASKS:
		assert_false(WorldState.has_flag("list.take_" + task), task)
	WorldState.new_game()
	var silence := await DialogueWalk.play(STADT, "list_pick_1", PackedStringArray(["…", "…", "…"]))
	assert_true(_has(silence, "stadt_list_20"), "he waits and does not fill the silence")
	assert_true(WorldState.has_flag("list.closed"))


# --- The values and the facet -----------------------------------------------------------------


func test_each_task_carries_one_value_and_each_value_has_two_tasks() -> void:
	var counts := {}
	for task: String in TASKS:
		var value: String = TASKS[task][1]
		counts[value] = int(counts.get(value, 0)) + 1
	assert_eq(counts.size(), 3)
	for value: String in counts:
		assert_eq(counts[value], 2, value)


func test_taking_a_task_of_her_value_sets_integrity_and_any_other_task_does_not() -> void:
	for task: String in TASKS:
		for value: String in ["freedom", "closeness", "calm"]:
			WorldState.new_game()
			WorldState.set_flag("value." + value)
			await DialogueWalk.play(
				STADT, "list_pick_1", PackedStringArray([TASKS[task][0], "Das reicht", "…"])
			)
			var hers: bool = TASKS[task][1] == value
			assert_eq(WorldState.has_facet("integrity"), hers, "%s with %s" % [task, value])
			assert_true(WorldState.has_flag("list.take_" + task))


func test_without_a_value_from_act_two_no_task_sets_the_facet() -> void:
	for task: String in TASKS:
		WorldState.new_game()
		await DialogueWalk.play(
			STADT, "list_pick_1", PackedStringArray([TASKS[task][0], "Das reicht", "…"])
		)
		assert_false(WorldState.has_facet("integrity"), task)
		assert_true(WorldState.has_flag("list.take_" + task), "the tasks are the same")


# --- The no -----------------------------------------------------------------------------------


func test_the_no_has_no_reason_and_the_facet_answer_stands_beside_the_unconditional_ones() -> void:
	var plain := await DialogueWalk.answers(STADT, "list_close")
	assert_eq(plain.size(), 2, "the no and the silence")
	assert_eq(plain[0], "Die anderen nicht.")
	assert_eq(plain[plain.size() - 1], "…", "the silence is the last answer")
	WorldState.new_game()
	WorldState.set_facet("integrity")
	var owned := await DialogueWalk.answers(STADT, "list_close")
	assert_eq(owned.size(), 3, "and one more with the facet")
	assert_true("Das sind meine." in owned)
	assert_eq(owned[owned.size() - 1], "…")


func test_every_answer_to_the_question_closes_the_list_and_the_question_asks_no_reason() -> void:
	for pick: String in ["Die anderen", "Das sind meine", "…"]:
		WorldState.new_game()
		WorldState.set_facet("integrity")
		WorldState.start_quest("side_city_list")
		var seen := await DialogueWalk.play(STADT, "list_close", PackedStringArray([pick, "…"]))
		assert_true(WorldState.has_flag("list.closed"), pick)
		assert_eq(WorldState.quest_stage("side_city_list"), "closed", pick)
		assert_true(WorldState.has_flag("list.sat"), "and he sits beside her: " + pick)
		var all := " ".join(seen).to_lower()
		for word: String in ["warum", "wieso", "weshalb", "begründ"]:
			assert_false(all.contains(word), "nobody asks for a reason: " + word)


func test_the_choice_and_its_consequence_are_never_in_the_same_cue() -> void:
	for cue in NEW_CUES:
		var source := _cue_source(cue)
		var picks := source.contains('set_flag("list.take_')
		var doing := source.contains('set_flag("list.done_')
		assert_false(picks and doing, "%s sets a choice and a consequence" % cue)
		if cue.begins_with("list_pick"):
			assert_false(
				source.contains("list.closed"), "%s does not read what the choice causes" % cue
			)
