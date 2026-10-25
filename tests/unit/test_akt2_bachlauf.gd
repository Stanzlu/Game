extends GutTest
## Act II, segment B3: the Bachlauf. What the stream left behind is told in small finds along the
## track: the post with the empty hook starts the side quest "Die Reuse" (hook, float, weir, done),
## the float and the trap come in that order, three curiosities, two traces of the world (no child,
## no cause), the goat's prints that touch nothing of her quest. All of it is optional. The scene
## (map, spots, beats) is tested in test_akt2_bachlauf_szene.

const BACH := "res://content/dialogue/akt2/bachlauf.dialogue"
const QUEST := "side_valley_trap"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()


func _has(seen: PackedStringArray, id: String) -> bool:
	return LineText.of(id) in seen


## Every line of every cue of the file, each cue played with the first answer.
func _all_lines() -> PackedStringArray:
	var resource := load(BACH) as DialogueResource
	var lines: PackedStringArray = []
	for title: String in resource.get_cues():
		lines.append_array(await DialogueWalk.play(BACH, title))
	return lines


# --- The quest ---------------------------------------------------------------------------------


func test_the_empty_hook_starts_the_quest_once() -> void:
	var seen := await DialogueWalk.play(BACH, "hook")
	assert_true(_has(seen, "bl_hook_1") and _has(seen, "bl_hook_3"))
	assert_eq(WorldState.quest_stage(QUEST), "hook")
	assert_true(WorldState.has_flag("valley.trap_hooked"))
	var again := await DialogueWalk.play(BACH, "hook")
	assert_eq(again, PackedStringArray([LineText.of("bl_hook_4")]), "told once")
	assert_eq(WorldState.quest_stage(QUEST), "hook")


func test_the_float_leads_on_from_the_hook_and_not_from_nowhere() -> void:
	await DialogueWalk.play(BACH, "float")
	assert_eq(WorldState.quest_stage(QUEST), "", "no quest to advance: nothing started")
	WorldState.new_game()
	await DialogueWalk.play(BACH, "hook")
	var seen := await DialogueWalk.play(BACH, "float")
	assert_true(_has(seen, "bl_float_1") and _has(seen, "bl_float_2"))
	assert_eq(WorldState.quest_stage(QUEST), "float")
	assert_true(WorldState.has_flag("valley.trap_floated"))
	assert_eq(
		await DialogueWalk.play(BACH, "float"), PackedStringArray([LineText.of("bl_float_3")])
	)


func test_the_trap_is_seen_first_and_the_answer_lets_it_go_or_leaves_it() -> void:
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "float")
	var answers := await DialogueWalk.answers(BACH, "trap")
	assert_eq(answers.size(), 2)
	WorldState.new_game()  # looking at the answers has seen the trap already
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "float")
	var left := await DialogueWalk.play(BACH, "trap", PackedStringArray(["Klemmen lassen"]))
	assert_true(_has(left, "bl_trap_1") and _has(left, "bl_trap_5"))
	assert_eq(WorldState.quest_stage(QUEST), "weir", "seen, not freed")
	assert_false(WorldState.has_item("curiosity_comb"))
	assert_false(WorldState.has_flag("valley.trap_freed"))
	var back := await DialogueWalk.play(BACH, "trap", PackedStringArray(["Klemmen lassen"]))
	assert_false(_has(back, "bl_trap_1"), "the first sight is not told twice")
	assert_true(_has(back, "bl_trap_2"))


func test_freeing_the_trap_gives_the_comb_ends_the_quest_and_changes_the_stream() -> void:
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "float")
	var seen := await DialogueWalk.play(BACH, "trap")
	assert_true(_has(seen, "bl_trap_3") and _has(seen, "bl_trap_4"))
	assert_true(WorldState.has_item("curiosity_comb"))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(WorldState.has_flag("valley.trap_freed"), "the map shows the freed trap")
	assert_eq(await DialogueWalk.play(BACH, "trap"), PackedStringArray([LineText.of("bl_trap_9")]))


func test_the_journal_tells_every_stage_and_helps_to_find_the_way() -> void:
	for key: String in ["TITLE", "HOOK", "FLOAT", "WEIR", "DONE"]:
		assert_ne(tr("QUEST_SIDE_VALLEY_TRAP_" + key), "QUEST_SIDE_VALLEY_TRAP_" + key, key)
	var help := tr("QUEST_SIDE_VALLEY_TRAP_HOOK")
	assert_string_contains(help, "Wasser", "the stream is what to follow")
	assert_string_contains(help, "Rauch", "the smoke over the trees is the way back")


# --- Things the stream left behind ---------------------------------------------------------------


func test_a_curiosity_is_taken_with_the_first_answer_or_left() -> void:
	var cases := [
		["weight", "curiosity_lead_weight", "valley.weight_taken"],
		["glass", "curiosity_blue_glass", "valley.glass_taken"],
	]
	for entry: Array in cases:
		var left := await DialogueWalk.play(BACH, entry[0], PackedStringArray(["Liegen lassen"]))
		assert_gt(left.size(), 1, "%s: a line and an answer" % entry[0])
		assert_false(WorldState.has_item(entry[1]), "%s stays" % entry[0])
		assert_false(WorldState.has_flag(entry[2]))
		await DialogueWalk.play(BACH, entry[0])
		assert_true(WorldState.has_item(entry[1]), "%s taken" % entry[0])
		assert_true(WorldState.has_flag(entry[2]))


func test_the_three_curiosities_are_in_the_game_and_count_with_the_spoon() -> void:
	WorldState.add_item("curiosity_tiny_spoon", 1, false)
	for id: String in ["curiosity_blue_glass", "curiosity_lead_weight", "curiosity_comb"]:
		assert_true(ContentDB.has_item(id), id)
		assert_ne(tr(id.to_upper() + "_NAME"), id.to_upper() + "_NAME", id)
		assert_ne(tr(id.to_upper() + "_DESC"), id.to_upper() + "_DESC", id)
		WorldState.add_item(id, 1, false)
	assert_eq(Collection.curiosities(), 4, "the spoon and the three, the Cut-First floor of Act II")


func test_the_two_traces_of_the_world_are_fragments_told_once() -> void:
	for entry: Array in [
		["table", "bank_table", "bl_table_4", "bl_table_5"],
		["dry_bed", "dry_bed", "bl_bed_4", "bl_bed_5"]
	]:
		var seen := await DialogueWalk.play(BACH, entry[0])
		assert_true(_has(seen, entry[2]), "%s: the breath of a past" % entry[0])
		assert_true(Collection.has_fragment(entry[1]))
		assert_eq(
			await DialogueWalk.play(BACH, entry[0]), PackedStringArray([LineText.of(entry[3])])
		)
	assert_eq(Collection.fragments(), 2)


func test_the_perception_find_is_seen_once_and_needs_nothing() -> void:
	var seen := await DialogueWalk.play(BACH, "knot")
	assert_true(_has(seen, "bl_knot_1") and _has(seen, "bl_knot_2") and _has(seen, "bl_knot_3"))
	assert_true(WorldState.has_flag("valley.knot_seen"))
	assert_eq(await DialogueWalk.play(BACH, "knot"), PackedStringArray([LineText.of("bl_knot_4")]))
	assert_eq(WorldState.quest_stage(QUEST), "", "the quest never needed it")


func test_the_goats_prints_touch_nothing_of_her_quest() -> void:
	WorldState.start_quest("side_valley_goat")
	var before := WorldState.quest_stage("side_valley_goat")
	var seen := await DialogueWalk.play(BACH, "goat_trace")
	assert_true(_has(seen, "bl_goat_1") and _has(seen, "bl_goat_2"))
	assert_eq(WorldState.quest_stage("side_valley_goat"), before)
	for flag: String in ["valley.goat_met", "valley.goat_traded", "valley.potato_taken"]:
		assert_false(WorldState.has_flag(flag), flag)


func test_the_look_back_names_the_house_and_the_wet_path_waits() -> void:
	var back := await DialogueWalk.play(BACH, "look_back")
	assert_true(_has(back, "bl_back_1"))
	assert_false(LineText.of("bl_back_1").contains("Zuhause"), "the house is not home")
	var wait := await DialogueWalk.play(BACH, "bach_wait")
	assert_eq(wait, PackedStringArray([LineText.of("bl_wait_1")]))


func test_the_valleys_window_invites_in_the_evening_and_only_then() -> void:
	WorldState.set_fire_lit(true)
	WorldState.set_day_preset("abend")
	var evening := await DialogueWalk.play("res://content/dialogue/slice/haus.dialogue", "window")
	assert_true(_has(evening, "haus_window_3") and _has(evening, "haus_window_4"))
	WorldState.set_day_preset("regentag")
	var rain := await DialogueWalk.play("res://content/dialogue/slice/haus.dialogue", "window")
	assert_false(_has(rain, "haus_window_4"))


# --- What it never says ----------------------------------------------------------------------


func test_it_is_all_narration_with_no_question_or_cry() -> void:
	var resource := load(BACH) as DialogueResource
	for title: String in resource.get_cues():
		var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, title)
		while line != null:
			assert_eq(line.character, "", "narration: %s" % line.text)
			for mark: String in ["?", "!", "…"]:
				assert_false(line.text.contains(mark), "%s in %s" % [mark, line.text])
			var next_id := line.next_id
			if not line.responses.is_empty():
				next_id = line.responses[0].next_id
			line = await DialogueManager.get_next_dialogue_line(resource, next_id)


func test_no_trace_names_a_child_a_reason_or_a_memory() -> void:
	# Brief O5: Act II's fragments are traces of the world and of the past, never pictures of the child
	# and never why anyone left
	var lines := await _all_lines()
	assert_gt(lines.size(), 30)
	for line: String in lines:
		for word: String in ["Kind", "Erinnerung", "erinner", "Zuhause", "Meer", "Heim", "verlor"]:
			assert_false(line.contains(word), "'%s' in: %s" % [word, line])
