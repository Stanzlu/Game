extends GutTest
## Act II, segment B2: Nein und Blick. The Antreiber at the fire may be answered: "Heute nicht."
## is taken (he sits, his Zweitens falls out) and opens the facet Grenzen; "Morgen." is a date for
## him; silence leaves it to the sitting. Two later conversations have an answer more with the
## facet, each next to answers that always apply. Mira is unfair once, dry, and takes nothing back.
## Whoever looks closely finds a little more in the house. The scene is tested in
## test_akt2_nein_szene.

const NEIN := "res://content/dialogue/akt2/nein.dialogue"
const HAUS := "res://content/dialogue/slice/haus.dialogue"
const TAL := "res://content/dialogue/slice/tal.dialogue"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


# --- The Antreiber at the fire ---------------------------------------------------------------


func test_the_antreiber_may_be_answered_three_ways() -> void:
	var answers := await DialogueWalk.answers(NEIN, "antreiber_ask")
	var expected := PackedStringArray(
		[LineText.of("nein_antr_r1"), LineText.of("nein_antr_r2"), LineText.of("nein_antr_r3")]
	)
	assert_eq(answers, expected, "always the same three, no facet needed")


func test_heute_nicht_is_taken_and_opens_the_facet() -> void:
	var seen := await DialogueWalk.play(NEIN, "antreiber_ask", ["Heute nicht"])
	assert_true(_has(seen, "nein_antr_1"), "he repeats it, as if noting it down")
	assert_true(_has(seen, "nein_antr_2"), "and his Zweitens falls out")
	assert_true(WorldState.has_facet("boundaries"))
	assert_true(WorldState.has_flag("house.antreiber_refused"))
	assert_false(WorldState.has_flag("house.antreiber_postponed"))


func test_morgen_is_a_date_and_changes_no_facet() -> void:
	var seen := await DialogueWalk.play(NEIN, "antreiber_ask", ["Morgen"])
	assert_true(_has(seen, "nein_antr_3") and _has(seen, "nein_antr_4"))
	assert_true(WorldState.has_flag("house.antreiber_postponed"))
	assert_false(WorldState.has_flag("house.antreiber_refused"))
	assert_false(WorldState.has_facet("boundaries"), "deferring is not saying no")


func test_silence_is_its_own_answer_and_sets_nothing() -> void:
	var seen := await DialogueWalk.play(NEIN, "antreiber_ask", ["…"])
	assert_true(_has(seen, "nein_antr_5"))
	assert_false(WorldState.has_facet("boundaries"))
	assert_false(WorldState.has_flag("house.antreiber_refused"))
	assert_false(WorldState.has_flag("house.antreiber_postponed"))


func test_he_neither_asks_why_nor_praises_nor_shouts() -> void:
	# a No is taken at once: no reason demanded, no applause, no "!" while he sits still
	var forbidden := ["?", "!", "Warum", "weil ", "Gut gemacht", "richtig", "stark"]
	for id: String in ["nein_antr_1", "nein_antr_2", "nein_antr_3", "nein_antr_4", "nein_antr_5"]:
		for word: String in forbidden:
			assert_false(LineText.of(id).contains(word), "%s says '%s'" % [id, word])


func test_whoever_said_heute_nicht_hears_him_settle_for_it_by_the_fire() -> void:
	WorldState.set_flag("house.antreiber_refused")
	var heard := {}
	for round in 60:
		for line: String in await DialogueWalk.play(HAUS, "antreiber_rest"):
			heard[line] = true
	assert_true(heard.has(LineText.of("haus_antr_10")), "the roof can wait, on his list")
	assert_true(heard.has(LineText.of("haus_antr_11")), "and he counts nothing on his fingers")


func test_without_the_refusal_he_says_none_of_it() -> void:
	var heard := {}
	for round in 40:
		for line: String in await DialogueWalk.play(HAUS, "antreiber_rest"):
			heard[line] = true
	assert_false(heard.has(LineText.of("haus_antr_10")))
	assert_false(heard.has(LineText.of("haus_antr_11")))


# --- The two readers -------------------------------------------------------------------------


func test_where_do_you_come_from_has_an_answer_more_with_the_facet() -> void:
	var without := await DialogueWalk.groups(HAUS, "mira_visit")
	assert_eq(without[1].size(), 3, "three answers without it")
	assert_false(LineText.of("haus_mira_r15") in without[1])
	WorldState.set_facet("boundaries")
	var with := await DialogueWalk.groups(HAUS, "mira_visit")
	assert_eq(with[1].size(), 4)
	assert_eq(with[1][-1], LineText.of("haus_mira_r15"), "after the answers that always apply")


func test_that_answer_is_taken_without_a_why_and_the_evening_does_not_ask_again() -> void:
	WorldState.set_facet("boundaries")
	var seen := await DialogueWalk.play(HAUS, "mira_visit", ["", "Das sag ich nicht"])
	assert_true(_has(seen, "haus_mira_39") and _has(seen, "haus_mira_40"))
	assert_true(WorldState.has_memory("mira", "kept_origin"))
	var evening := await DialogueWalk.play(TAL, "evening_elysia")
	assert_eq(evening, PackedStringArray([LineText.of("tal_eve_ely_12")]), "she does not ask twice")
	var ending := await DialogueWalk.play(TAL, "ending")
	assert_true(_has(ending, "tal_eve_ely_12"), "inside the evening as well")
	assert_true(_has(ending, "tal_end_2"), "and the evening goes on to its end")


func test_without_that_answer_the_evening_asks_after_elysia_as_before() -> void:
	var seen := await DialogueWalk.play(TAL, "evening_elysia")
	assert_false(_has(seen, "tal_eve_ely_12"))
	assert_gt(seen.size(), 1, "the question and an answer")


func test_tell_me_something_has_an_answer_more_with_the_facet() -> void:
	var without := await DialogueWalk.groups(TAL, "evening_day")
	assert_eq(without[0], PackedStringArray([LineText.of("tal_eve_day_r6")]), "only the silence")
	WorldState.set_facet("boundaries")
	var with := await DialogueWalk.groups(TAL, "evening_day")
	assert_eq(with[0].size(), 2)
	assert_true(LineText.of("tal_eve_day_r7") in with[0])
	assert_true(LineText.of("tal_eve_day_r6") in with[0], "the silence stays")


func test_that_answer_is_met_with_the_net_by_the_fire_and_nothing_more() -> void:
	WorldState.set_facet("boundaries")
	var seen := await DialogueWalk.play(TAL, "evening_day", ["Heute nicht mehr"])
	assert_true(_has(seen, "tal_eve_day_13"))
	assert_false(_has(seen, "tal_eve_day_10"), "she does not fill the silence with her day")
	assert_true(WorldState.has_memory("mira", "kept_day"))
	var silent := await DialogueWalk.play(TAL, "evening_day", ["…"])
	assert_true(_has(silent, "tal_eve_day_10"), "the silence is another answer with its own turn")


# --- Mira is unfair, and the finds -----------------------------------------------------------


func test_mira_is_unfair_once_dry_and_the_same_with_or_without_the_facet() -> void:
	var ids := ["haus_mira_41", "haus_mira_42", "haus_mira_43"]
	var plain := await DialogueWalk.play(HAUS, "mira_visit")
	WorldState.new_game()
	WorldState.set_facet("boundaries")
	var with := await DialogueWalk.play(HAUS, "mira_visit", ["", "Das sag ich nicht"])
	for seen: PackedStringArray in [plain, with]:
		var at := -1
		for id: String in ids:
			assert_true(_has(seen, id), id)
			assert_gt(seen.find(LineText.of(id)), at, "in order")
			at = seen.find(LineText.of(id))
		assert_lt(at, seen.find(LineText.of("haus_mira_19")), "before the goat")


func test_the_bed_shows_more_to_whoever_looks_closely_and_the_prints_once() -> void:
	var plain := await DialogueWalk.play(HAUS, "bed")
	assert_false(_has(plain, "haus_bed_6"))
	WorldState.set_facet("perception")
	assert_true(_has(await DialogueWalk.play(HAUS, "bed"), "haus_bed_6"))
	var first := await DialogueWalk.play(HAUS, "haus_prints")
	assert_true(_has(first, "haus_prints_1") and _has(first, "haus_prints_2"))
	assert_true(WorldState.has_flag("house.prints_seen"))
	var again := await DialogueWalk.play(HAUS, "haus_prints")
	assert_eq(again, PackedStringArray([LineText.of("haus_prints_3")]), "told once")


func test_the_journal_remembers_both_nos_and_hints_at_the_long_way() -> void:
	for key: String in ["MEMORY_MIRA_KEPT_ORIGIN", "MEMORY_MIRA_KEPT_DAY"]:
		assert_ne(tr(key), key, "%s has a sentence" % key)
	assert_string_contains(tr("QUEST_MAIN_VALLEY_SHELTER_WOOD"), "eilig")
