extends GutTest
## Act VI, segment R4: the Richter in the hall of mirrors (HallVoice, docs/akt6/REGIONSBRIEFE.md,
## O9). The great mirror shows her; when she turns from it a voice begins a sentence over the
## picture, and she is faster than he is: it breaks off in the middle of a word once she has gone
## far enough, and he calls after her. Whoever stands still reads it out. The next time she comes
## into the hall, and only there, he says one sentence in a tone he never had. Once each.

const HALL := preload("res://world/levels/akt1/spiegelhalle.tscn")
const FILE := "res://content/dialogue/akt6/richter.dialogue"
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.hall_mirror_seen")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	Settings.set_value("access.timing", 0, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _hall() -> GameScene:
	var scene: GameScene = HALL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _voice(scene: GameScene) -> VoiceLine:
	return scene.hud.get_node_or_null("VoiceLine") as VoiceLine


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## She looks into the great mirror (its new cue) and the box closes.
func _look_into_the_mirror(scene: GameScene) -> void:
	var mirror: Node = null
	for node in scene.map.entities.get_children():
		if node.has_meta(&"cue") and node.get_meta(&"cue") == "mirror":
			mirror = node
	assert_not_null(mirror, "the great mirror is on the map")
	(mirror.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0))
	assert_eq(scene.dialogue_box.cue, "mirror_back")
	var closed := func() -> bool:
		_polls += 1
		if scene.dialogue_box.is_open():
			if not BoxAnswers.pick(scene.dialogue_box, "Wegsehen.") and _polls % 6 == 0:
				_confirm()
		return not scene.dialogue_box.is_open()
	assert_true(await wait_until(closed, 30.0), "the conversation ends")


## Waits (in play time) until `check` holds.
func _until(check: Callable, seconds := 6.0) -> bool:
	return await wait_until(check, seconds)


func test_nobody_speaks_in_the_hall_to_whoever_did_not_come_back() -> void:
	WorldState.clear_flag("elysia.returned")
	var scene := await _hall()
	assert_null(scene.get_node_or_null("HallVoice"), "no voice at all")


func test_nothing_is_said_before_she_has_looked_into_the_mirror() -> void:
	var scene := await _hall()
	assert_not_null(scene.get_node_or_null("HallVoice"))
	await wait_physics_frames(int(4.0 * float(Engine.physics_ticks_per_second)))
	assert_null(_voice(scene), "the hall is quiet")
	assert_false(WorldState.has_flag(HallVoice.FIRST_FLAG))
	assert_false(WorldState.has_flag(HallVoice.LATE_FLAG), "and the quiet sentence is not yet due")


func test_when_she_turns_from_the_mirror_a_voice_begins_over_the_picture() -> void:
	var scene := await _hall()
	await _look_into_the_mirror(scene)
	var came := func() -> bool: return _voice(scene) != null
	assert_true(await _until(came), "a line is typed over the picture")
	assert_true(WorldState.has_flag(HallVoice.FIRST_FLAG), "he has begun: once")
	assert_false(scene.dialogue_box.is_open(), "and it is not in a box: she is free")
	assert_false(scene.player.is_locked(), "nothing holds her")
	assert_true(_voice(scene).text.begins_with("Richter"), "it says who speaks")


func test_she_is_faster_than_he_is_and_he_calls_after_her() -> void:
	var scene := await _hall()
	await _look_into_the_mirror(scene)
	var came := func() -> bool: return _voice(scene) != null
	assert_true(await _until(came))
	var first := _voice(scene)
	await wait_physics_frames(30)
	scene.player.global_position += Vector2(240.0, 0.0)
	var cut := func() -> bool: return first.was_cut()
	assert_true(await _until(cut), "the line breaks off")
	assert_true(first.text.ends_with(VoiceLine.CUT_MARK), "in the middle of a word")
	var lines := await DialogueWalk.play(FILE, "voice_first")
	assert_gt(lines.size(), 1, "and there is more to say")
	var first_id := first.get_instance_id()
	var after := func() -> bool:
		var now := _voice(scene)
		return now != null and now.get_instance_id() != first_id
	assert_true(await _until(after, 8.0), "he calls after her with the next line")
	assert_false(_voice(scene).was_cut(), "that one is not cut")
	var marked := func() -> bool: return Beat.reached(HallVoice.FIRST_BEAT)
	assert_true(await _until(marked, 30.0), "when it is over the game saves")


func test_whoever_stands_still_reads_it_to_the_end_and_he_has_nothing_to_add() -> void:
	var scene := await _hall()
	await _look_into_the_mirror(scene)
	var came := func() -> bool: return _voice(scene) != null
	assert_true(await _until(came))
	var first := _voice(scene)
	var done := func() -> bool: return first.is_done()
	assert_true(await _until(done, 30.0), "it is typed out")
	assert_false(first.was_cut(), "not cut")
	var marked := func() -> bool: return Beat.reached(HallVoice.FIRST_BEAT)
	assert_true(await _until(marked, 30.0))
	assert_eq(
		scene.hud.find_children("VoiceLine*", "VoiceLine", true, false).size(), 0, "no second"
	)


func test_he_speaks_once_in_this_visit_and_the_quiet_sentence_waits_for_the_next() -> void:
	var scene := await _hall()
	await _look_into_the_mirror(scene)
	var marked := func() -> bool: return Beat.reached(HallVoice.FIRST_BEAT)
	assert_true(await _until(marked, 40.0))
	await wait_physics_frames(int(5.0 * float(Engine.physics_ticks_per_second)))
	await _look_into_the_mirror(scene)
	await wait_physics_frames(int(4.0 * float(Engine.physics_ticks_per_second)))
	assert_null(_voice(scene), "not again")
	assert_false(WorldState.has_flag(HallVoice.LATE_FLAG), "the next visit")


func test_the_next_time_she_enters_the_hall_he_says_one_quiet_sentence_and_never_again() -> void:
	WorldState.set_flag(HallVoice.FIRST_FLAG)
	var scene := await _hall()
	var came := func() -> bool: return _voice(scene) != null
	assert_true(await _until(came, 8.0), "the quiet sentence, a little after she came in")
	var late := _voice(scene)
	assert_true(WorldState.has_flag(HallVoice.LATE_FLAG))
	assert_eq(late.cut_distance, 0.0, "it is not cut: nobody walks away from it")
	var told := await DialogueWalk.play(FILE, "voice_late")
	assert_eq(told.size(), 1, "one sentence")
	var marked := func() -> bool: return Beat.reached(HallVoice.LATE_BEAT)
	assert_true(await _until(marked, 15.0))
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _hall()
	await wait_physics_frames(int(4.0 * float(Engine.physics_ticks_per_second)))
	assert_null(_voice(again), "not a third time")


func test_the_quiet_sentence_waits_while_something_else_is_going_on() -> void:
	WorldState.set_flag(HallVoice.FIRST_FLAG)
	var scene := await _hall()
	scene.player.lock(&"test")
	await wait_physics_frames(int(4.0 * float(Engine.physics_ticks_per_second)))
	assert_null(_voice(scene), "not over a cutscene")
	scene.player.unlock(&"test")
	var came := func() -> bool: return _voice(scene) != null
	assert_true(await _until(came, 8.0), "when it is quiet again")


func test_the_first_part_is_never_the_quiet_sentence_of_the_same_visit() -> void:
	var scene := await _hall()
	assert_false(scene.get_node("HallVoice")._late_due, "decided when she came in")
