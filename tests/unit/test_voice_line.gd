extends GutTest
## Act VI, R4: the voice without a body (VoiceLine, docs/akt6/REGIONSBRIEFE.md, O9). A line typed
## over the picture in play time; when the one it speaks to has gone far enough from where she
## stood as it began, it breaks off in the middle of a word; whoever stands still reads it to
## the end. It follows its own pace, not the text speed of the dialogue box.

const HALL := preload("res://world/levels/akt1/spiegelhalle.tscn")
const TEXT := "Zu Protokoll: Die Angeklagte hat den Saal betreten, ohne zu grüßen und ohne –"
var _scene: GameScene
var _done: Array = []


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	Settings.set_value("text.speed", 3, false)
	Settings.set_value("access.timing", 0, false)
	_done = []
	_scene = HALL.instantiate()
	add_child_autofree(_scene)
	await wait_physics_frames(3)


func after_each() -> void:
	Settings.set_value("text.speed", 1, false)
	Settings.set_value("access.timing", 0, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)


func _speak(distance := 0.0) -> VoiceLine:
	var line := VoiceLine.speak(_scene, _scene.player, "Richter", TEXT, distance)
	line.finished.connect(func(cut: bool) -> void: _done.append(cut))
	return line


func _run(seconds: float) -> void:
	await wait_physics_frames(int(seconds * float(Engine.physics_ticks_per_second)))


func test_it_types_the_text_in_play_time_and_not_all_at_once() -> void:
	var line := _speak()
	await wait_physics_frames(1)
	assert_lt(line.typed_characters(), TEXT.length(), "instant text speed does not skip a voice")
	var seen := [0]
	await _run(1.0)
	seen[0] = line.typed_characters()
	assert_gt(seen[0], 10, "about twenty characters in a second at the normal pace")
	assert_lt(seen[0], 40)
	assert_true(line.text.begins_with("Richter\n"), "the speaker's name stands over the text")
	assert_true(_done.is_empty(), "and it is not over yet")


func test_whoever_stands_still_reads_it_to_the_end_and_it_fades() -> void:
	var line := _speak(96.0)
	await _run(5.0)
	assert_eq(_done, [false], "it was read out, not cut")
	assert_true(line.text.ends_with(TEXT), "all of it")
	assert_false(line.was_cut())
	await _run(4.0)
	assert_false(is_instance_valid(line), "then it lets go")


func test_it_breaks_off_in_the_middle_once_she_has_gone_far_enough() -> void:
	var line := _speak(96.0)
	await _run(1.0)
	_scene.player.global_position += Vector2(200.0, 0.0)
	await wait_physics_frames(2)
	assert_eq(_done, [true], "cut")
	assert_true(line.was_cut())
	assert_true(line.text.ends_with(VoiceLine.CUT_MARK), "it ends on a dash, not on a full stop")
	assert_lt(line.typed_characters(), TEXT.length(), "in the middle of the text")
	var shown := line.text.length()
	await _run(1.0)
	assert_eq(line.text.length(), shown, "and says nothing more")


func test_a_line_without_a_distance_is_never_cut() -> void:
	var line := _speak()
	_scene.player.global_position += Vector2(900.0, 0.0)
	await _run(5.0)
	assert_eq(_done, [false])
	assert_false(line.was_cut())


func test_walking_a_little_does_not_cut_it() -> void:
	var line := _speak(96.0)
	_scene.player.global_position += Vector2(60.0, 0.0)
	await _run(1.0)
	assert_true(_done.is_empty(), "inside the range it goes on")
	assert_false(line.is_done())


func test_more_time_types_it_faster_so_more_is_read_before_she_is_gone() -> void:
	var slow := _speak()
	await _run(1.0)
	var at_normal := slow.typed_characters()
	slow.queue_free()
	Settings.set_value("access.timing", 2, false)
	var quick := _speak()
	await _run(1.0)
	assert_gt(quick.typed_characters(), at_normal, "much longer: faster")


func test_a_line_that_outlives_the_one_it_speaks_to_does_not_fail() -> void:
	var stranger := Node2D.new()
	add_child_autofree(stranger)
	var line := VoiceLine.speak(_scene, stranger, "Richter", TEXT, 96.0)
	stranger.free()
	await wait_physics_frames(3)
	assert_false(line.was_cut(), "nobody left to walk away: it runs on")
