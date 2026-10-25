## Act II, segment B6, the scene of the valley: the real ending plays Mira's reading of the value
## between her question and 'Morgen gehe ich weiter.', Act II is not over before 'Zum Meer.', and
## the chapter marks come as one block with the save. What is said is tested in test_akt2_abend.

const TAL := preload("res://world/levels/slice/tal.tscn")
const SCENE_SOURCE := "res://world/levels/slice/tal_scene.gd"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", true, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The ending of the real scene, as a save from the last scene replays it (the mountains seen):
## every line shown on the way to 'Zum Meer.' is noted, the first answer is taken wherever asked.
func _ending_until_the_sea(flags: Array) -> Dictionary:
	WorldState.set_flag("house.mira_visited")
	WorldState.set_flag("valley.mountains_seen")
	for flag: String in flags:
		WorldState.set_flag(flag)
	WorldState.set_flag("valley.ending")
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var box := scene.dialogue_box
	var seen := {"lines": [], "answered": false}
	var at_sea := func() -> bool:
		var line: DialogueLine = box.line if box.is_open() else null
		if line != null:
			if seen["lines"].is_empty() or seen["lines"][-1] != line.text:
				seen["lines"].append(line.text)
			if not line.responses.is_empty():
				BoxAnswers.pick(box)
		return line != null and line.text.begins_with("Zum Meer")
	await wait_until(at_sea, 120.0)
	seen["at_sea"] = at_sea.call()
	return seen


func _lines_have(lines: Array, id: String) -> bool:
	return LineText.of(id) in lines


func test_the_door_is_read_in_the_real_ending_before_the_goodbye() -> void:
	var seen := await _ending_until_the_sea(["value.freedom"])
	var lines: Array = seen["lines"]
	assert_true(seen["at_sea"], "the ending reached her answer")
	for id: String in ["tal_eve_val_1", "tal_eve_val_2", "tal_eve_val_3", "tal_eve_val_4"]:
		assert_true(_lines_have(lines, id), id)
	assert_false(_lines_have(lines, "tal_eve_val_12"), "not the smoke")
	var goodbye := lines.find(LineText.of("tal_end_2"))
	assert_gt(
		goodbye, lines.find(LineText.of("tal_eve_val_4")), "and before 'Morgen gehe ich weiter.'"
	)
	assert_true(WorldState.has_memory("mira", "saw_door_ajar"))
	assert_false(Chapter.reached("act2"), "Act II is not over before 'Zum Meer.'")
	assert_false(Chapter.reached("slice"))


func test_a_game_without_a_value_still_reaches_the_sea_with_the_smoke() -> void:
	var seen := await _ending_until_the_sea([])
	var lines: Array = seen["lines"]
	assert_true(seen["at_sea"])
	assert_true(_lines_have(lines, "tal_eve_val_12"))
	assert_true(_lines_have(lines, "tal_eve_val_13"))
	for id: String in ["tal_eve_val_2", "tal_eve_val_5", "tal_eve_val_9"]:
		assert_false(_lines_have(lines, id), id)
	assert_false(Chapter.reached("act2"))


func test_act_two_is_marked_before_the_slice_and_as_one_block_with_the_save() -> void:
	# nothing waits between the marks and the autosave, so no save holds the one without the other
	var source := FileAccess.get_file_as_string(SCENE_SOURCE)
	var act2 := source.find('Chapter.mark("act2")')
	var slice := source.find('Chapter.mark("slice")')
	var unblock := source.find("SaveSystem.unblock(cut.key)")
	assert_true(act2 > 0 and slice > act2 and unblock > slice, "act2, then slice, then the save")
	var between := source.substr(act2, unblock - act2)
	assert_false(between.contains("await"), "no waiting between the marks and the save")
	assert_eq(source.count('Chapter.mark("act2")'), 1, "one site")
