extends GutTest
## Act I, segment A7: the repetition. From the toast at the feast on, the people of Act I say one
## sentence, the same every time and word for word what they said first (Game Bible §35); what they
## owe the hero (a loaf, a quest, a shop) is not swallowed by it. The music shrinks with the
## progress, not with the clock, and the clock waits longer than Act I takes.

const MARKT := preload("res://world/levels/akt1/markt.tscn")
const MARKT_DIALOGUE := "res://content/dialogue/akt1/markt.dialogue"
const INN_DIALOGUE := "res://content/dialogue/akt1/gasthaus.dialogue"
const GARDEN_DIALOGUE := "res://content/dialogue/slice/elysia.dialogue"
## cue -> [loop line, the line it repeats]: the first thing the person ever says (for those who
## pick at random: the first line of their pool).
const REPEATS := {
	"gatekeeper": ["mk_gate_10", "mk_gate_1"],
	"baker": ["mk_baker_8", "mk_baker_3"],
	"tailor": ["mk_tailor_9", "mk_tailor_2"],
	"florist": ["mk_flower_6", "mk_flower_1"],
	"festmaster": ["mk_fest_9", "mk_fest_2"],
}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


# --- Word for word -----------------------------------------------------------------------


func test_each_person_says_one_sentence_the_same_every_time() -> void:
	WorldState.set_flag("elysia.feast")
	WorldState.set_flag("elysia.feast_toast")
	WorldState.set_flag("elysia.loops")
	for cue: String in REPEATS:
		var ids: Array = REPEATS[cue]
		var first := await DialogueWalk.play(MARKT_DIALOGUE, cue)
		assert_eq(first, PackedStringArray([LineText.of(ids[0])]), "%s: one line" % cue)
		for round in 3:
			var again := await DialogueWalk.play(MARKT_DIALOGUE, cue)
			assert_eq(again, first, "%s says the same again" % cue)


func test_the_loop_line_is_what_they_said_first_word_for_word() -> void:
	for cue: String in REPEATS:
		var ids: Array = REPEATS[cue]
		assert_eq(LineText.of(ids[0]), LineText.of(ids[1]), "%s repeats %s" % [cue, ids[1]])
	assert_eq(LineText.of("gh_host_loop_1"), LineText.of("gh_host_1"))
	assert_eq(LineText.of("gh_host_loop_2"), LineText.of("gh_host_2"))
	assert_eq(LineText.of("mk_shop_8"), LineText.of("mk_shop_1"))
	assert_eq(LineText.of("el_gard_loop"), LineText.of("el_gard_wait_1"))


func test_before_the_repetition_they_still_vary() -> void:
	WorldState.set_flag("elysia.market_greeted")
	var seen := {}
	for round in 12:
		var lines := await DialogueWalk.play(MARKT_DIALOGUE, "gatekeeper")
		seen[lines[0]] = true
	assert_gt(seen.size(), 1, "three lines in turn, not one")


func test_the_repetition_wins_over_the_feast_pool() -> void:
	WorldState.set_flag("elysia.feast")
	WorldState.set_flag("elysia.loops")
	var gate := await DialogueWalk.play(MARKT_DIALOGUE, "gatekeeper")
	assert_eq(gate, PackedStringArray([LineText.of("mk_gate_10")]))
	var merchant := await DialogueWalk.play(MARKT_DIALOGUE, "merchant", ["schaue nur"])
	assert_true(LineText.of("mk_shop_8") in merchant)
	assert_false(LineText.of("mk_shop_7") in merchant, "no festive extra in the loop")


# --- What they owe is not swallowed -------------------------------------------------------


func test_the_board_errand_still_works_while_everything_repeats() -> void:
	WorldState.set_flag("elysia.loops")
	WorldState.start_quest("side_elysia_board")
	var tailor := await DialogueWalk.play(MARKT_DIALOGUE, "tailor")
	assert_true(LineText.of("mk_tailor_1") in tailor, "she still waits for the bread")
	await DialogueWalk.play(MARKT_DIALOGUE, "baker")
	assert_true(WorldState.has_item("item_loaf"), "the loaf comes in the loop too")
	await DialogueWalk.play(MARKT_DIALOGUE, "tailor")
	assert_true(WorldState.is_quest_done("side_elysia_board"))


func test_the_shop_stays_open() -> void:
	WorldState.set_flag("elysia.loops")
	WorldState.add_gold(200)
	await DialogueWalk.play(MARKT_DIALOGUE, "merchant", ["Glücksbringer"])
	assert_true(WorldState.has_item("item_trinket"))
	assert_eq(WorldState.gold(), 50)


func test_the_host_in_the_inn_repeats_himself_once_he_has_been_met() -> void:
	WorldState.set_flag("elysia.loops")
	var first := await DialogueWalk.play(INN_DIALOGUE, "host", ["schau mich nur um"])
	assert_true(LineText.of("gh_host_1") in first, "never met: the first welcome, and the book")
	assert_true(WorldState.has_flag("elysia.inn_met"))
	var later := await DialogueWalk.play(INN_DIALOGUE, "host")
	assert_eq(
		later,
		PackedStringArray([LineText.of("gh_host_loop_1"), LineText.of("gh_host_loop_2")]),
		"from now on the same two sentences",
	)
	assert_eq(await DialogueWalk.play(INN_DIALOGUE, "host"), later)


func test_the_gardener_repeats_while_the_butterflies_are_loose_and_still_offers_the_quest() -> void:
	WorldState.set_flag("elysia.loops")
	var offer := await DialogueWalk.play(GARDEN_DIALOGUE, "gardener", ["fang sie dir"])
	assert_true(WorldState.is_quest_active("side_elysia_butterflies"), "the quest is still offered")
	assert_false(LineText.of("el_gard_loop") in offer)
	var waiting := await DialogueWalk.play(GARDEN_DIALOGUE, "gardener")
	assert_eq(waiting, PackedStringArray([LineText.of("el_gard_loop")]))


# --- The music and the clock ---------------------------------------------------------------


func test_entering_the_market_shrinks_the_loop_once() -> void:
	var scene: MarktScene = MARKT.instantiate()
	add_child_autofree(scene)
	await wait_process_frames(3)
	assert_true(WorldState.has_flag("elysia.market_seen"))
	assert_true(WorldState.has_flag(ElysiaDirector.stage_flag(1)), "half as long from here on")
	assert_false(WorldState.has_flag(ElysiaDirector.stage_flag(2)))
	assert_false(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG), "the sentences wait for the feast")


func test_the_toast_in_the_market_starts_the_sentences_there_and_then() -> void:
	WorldState.start_quest("main_elysia_hero")
	for stage: String in ["celebrated", "market", "hall"]:
		WorldState.advance_quest("main_elysia_hero", stage)
	WorldState.set_flag("elysia.hall_mirror_seen")
	var scene: MarktScene = MARKT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_false(WorldState.has_flag("elysia.loops"))
	await DialogueWalk.play(MARKT_DIALOGUE, "festmaster", ["Glas heben"])
	await wait_physics_frames(2)
	assert_true(WorldState.has_flag("elysia.loops"))
	assert_eq(ElysiaDirector.stage(), 3)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "repeat")


func test_the_fallback_times_are_longer_than_act_one_and_in_order() -> void:
	var stages := AudioDirectorService.ELYSIA_STAGES
	assert_gte(float(stages[1]["after"]), 20.0 * 60.0, "not before twenty minutes")
	assert_gt(float(stages[2]["after"]), float(stages[1]["after"]))
	assert_gt(ElysiaDirector.LOOPS_AFTER, float(stages[2]["after"]), "the sentences come last")
	assert_gte(ElysiaDirector.RIFT_AFTER_LOOPS, 10.0 * 60.0, "time to follow the child")


func test_a_save_from_the_feast_moves_the_hero_quest_on_when_the_market_is_entered() -> void:
	WorldState.start_quest("main_elysia_hero")
	for stage: String in ["celebrated", "market", "hall", "feast"]:
		WorldState.advance_quest("main_elysia_hero", stage)
	WorldState.set_flag("elysia.feast_toast")
	var scene: MarktScene = MARKT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "repeat")
	assert_true(WorldState.has_flag("elysia.loops"), "and the sentences began on load")


func test_the_wait_for_the_rift_runs_from_the_toast_across_scenes() -> void:
	# the rift opens a quarter hour after the sentences began, not a quarter hour after the last door
	var first := ElysiaDirector.attach(Node.new())
	add_child_autofree(first.get_parent())
	WorldState.state.playtime_seconds = 1000.0
	WorldState.set_flag(ElysiaDirector.FEAST_FLAG)
	await wait_process_frames(2)
	assert_true(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))
	WorldState.state.playtime_seconds = 1000.0 + ElysiaDirector.RIFT_AFTER_LOOPS - 100.0
	var second := ElysiaDirector.attach(Node.new())
	add_child_autofree(second.get_parent())
	await wait_process_frames(2)
	assert_false(WorldState.has_flag(ElysiaDirector.RIFT_FLAG), "not yet")
	WorldState.state.playtime_seconds = 1000.0 + ElysiaDirector.RIFT_AFTER_LOOPS + 1.0
	await wait_process_frames(2)
	assert_true(
		WorldState.has_flag(ElysiaDirector.RIFT_FLAG), "from the toast, not from the new scene"
	)
	assert_true(Beat.reached("rift_found"), "and the beat is marked wherever the hero is")
