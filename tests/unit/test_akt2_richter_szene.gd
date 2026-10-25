extends GutTest
## Act II, segment B4, the stones of the valley: the voice speaks after the second fall into the
## stream and only then, once, and never for a game that fell twice before (it has no fall to
## comment on). What it says is tested in test_akt2_richter.

const TAL := preload("res://world/levels/slice/tal.tscn")
const STONE := preload("res://world/props/stepping_stone.gd")
## A round stone on the east bank's side, and the cell next to it from where the player steps on.
const ROUND := Vector2i(40, 19)
const BESIDE := Vector2i(41, 19)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("valley.mira_met")
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _tal() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## Walks onto the round stone from the east, as the first crossing does, and waits until the fall is
## over (the stone is free again and the box closed). Every line the box showed is added to `lines`.
func _fall(scene: TalScene, lines: Array[String]) -> void:
	scene.player.teleport(scene.map.cell_to_world(BESIDE))
	scene.player.velocity = Vector2(-80, 0)
	await wait_physics_frames(2)
	scene.player.teleport(scene.map.cell_to_world(ROUND))
	scene.player.velocity = Vector2(-80, 0)
	var box := scene.dialogue_box
	var started := {"fell": false}
	var over := func() -> bool:
		if box.is_open() and box.line != null:
			if lines.is_empty() or lines[-1] != box.line.text:
				lines.append(box.line.text)
		started["fell"] = started["fell"] or STONE._falling
		return started["fell"] and not STONE._falling and not box.is_open()
	await wait_until(over, 60.0)
	assert_true(started["fell"] and not STONE._falling, "the fall ran to its end")
	await wait_physics_frames(3)


func _heard(lines: Array[String]) -> bool:
	return LineText.of("ric_2") in lines


func test_the_voice_speaks_after_the_second_fall_once_and_not_before_or_after() -> void:
	var scene := await _tal()
	var first: Array[String] = []
	await _fall(scene, first)
	assert_true(WorldState.has_flag("valley.fell_in"))
	assert_false(WorldState.has_flag("valley.fell_twice"))
	assert_true(LineText.of("tal_fell_1") in first, "the first fall is the cold and the funny one")
	assert_false(_heard(first), "no voice for the first fall")
	assert_false(Beat.reached("act2_richter"))
	var second: Array[String] = []
	await _fall(scene, second)
	assert_true(WorldState.has_flag("valley.fell_twice"))
	assert_true(_heard(second), "the second fall is heard")
	assert_true(LineText.of("ric_8") in second, "to the end: the stream has the last word")
	assert_true(Beat.reached("act2_richter"))
	assert_false(scene.player.is_locked(), "and the player is free again")
	var third: Array[String] = []
	await _fall(scene, third)
	assert_false(_heard(third), "once")
	assert_true(LineText.of("tal_fell_3") in third or LineText.of("tal_fell_4") in third)


func test_the_voice_comes_after_the_falls_own_lines_not_before() -> void:
	WorldState.set_flag("valley.fell_in")
	var scene := await _tal()
	var lines: Array[String] = []
	await _fall(scene, lines)
	var own := maxi(lines.find(LineText.of("tal_fell_3")), lines.find(LineText.of("tal_fell_4")))
	assert_gte(own, 0, "the stream's own line")
	assert_gt(
		lines.find(LineText.of("ric_2")), own, "and then the voice: after a fall, never before"
	)


func test_a_game_that_fell_twice_before_never_meets_it() -> void:
	# saves from before B4 have both flags: there is no second fall left to comment on
	WorldState.set_flag("valley.fell_in")
	WorldState.set_flag("valley.fell_twice")
	var scene := await _tal()
	var lines: Array[String] = []
	await _fall(scene, lines)
	assert_true(LineText.of("tal_fell_3") in lines or LineText.of("tal_fell_4") in lines, "it fell")
	assert_false(_heard(lines))
	assert_false(Beat.reached("act2_richter"))


func test_the_voice_is_bound_to_the_stones_and_the_mark_comes_after_its_box() -> void:
	# one site for the mark and one for the cue: the stone, after its own box (no scene, no Mira),
	# and saving is blocked for the whole of the fall, so no save holds the second fall without it
	var source := FileAccess.get_file_as_string("res://world/props/stepping_stone.gd")
	assert_eq(source.count('Beat.mark("act2_richter")'), 1)
	assert_eq(source.count('"judge"'), 1)
	var block := source.find('SaveSystem.block(&"fall")')
	var fell := source.find('"fell_in"')
	var judge := source.find('"judge"')
	var mark := source.find('Beat.mark("act2_richter")')
	var unblock := source.find('SaveSystem.unblock(&"fall")')
	assert_true(block > 0 and block < fell, "blocked before the fall's own cue")
	assert_true(
		judge > fell and mark > judge, "after the fall's own cue, and the mark after the voice"
	)
	assert_gt(unblock, mark, "and released after the mark, so the autosave holds all of it")
