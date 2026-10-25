extends GutTest
## Act II, segment B1: the scene of the arrival. After the first steps in the valley a gust goes
## through the wet leaves and the valley answers what Elysia left in the save. It plays once, on the
## way over the rift (Act I reached), never before the picture is back, and gives way when Mira is
## met first. A scene that goes while it waits leaves nothing behind that wakes up without it.
## What it says is tested in test_akt2_ankunft.

const TAL := preload("res://world/levels/slice/tal.tscn")
const MIRA := preload("res://content/dialogue/slice/tal.dialogue")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_down")
	Input.action_release(&"move_up")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	Input.action_release(&"interact")
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The valley where the rift lets the player out (spawn_rift, north-east of Mira's camp).
func _valley() -> TalScene:
	SceneTravel.pending_spawn = "rift"
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The valley as the rift leaves it: Act I reached, nobody met yet.
func _arrive() -> TalScene:
	WorldState.set_flag(Chapter.flag_for("act1"))
	return await _valley()


func _cutscenes() -> int:
	return get_tree().get_nodes_in_group(&"cutscene").size()


## Walks south from the arrival (about three cells in 40 frames): meadow, nothing to interact with.
func _walk(frames: int, action := &"move_down") -> void:
	Input.action_press(action)
	await wait_physics_frames(frames)
	Input.action_release(action)


func _tap(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_physics_frames(2)


func test_the_first_steps_call_up_the_echo_once() -> void:
	Settings.set_value("text.auto_advance", true, false)
	var scene := await _arrive()
	assert_false(scene.dialogue_box.is_open(), "nothing before the first steps")
	assert_false(Beat.reached("arrival_echo"))
	var before := WorldState.state.flags.duplicate()
	await _walk(40)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 12.0)
	assert_true(scene.dialogue_box.is_open(), "the lines come up")
	assert_eq(_cutscenes(), 1, "as a scene of its own: the player stands")
	await wait_until(func() -> bool: return Beat.reached("arrival_echo"), 20.0)
	assert_true(Beat.reached("arrival_echo"))
	assert_false(scene.dialogue_box.is_open())
	assert_eq(_cutscenes(), 0, "and moves on afterwards")
	var added: Array = []
	for flag: String in WorldState.state.flags:
		if not before.has(flag):
			added.append(flag)
	assert_eq(added, ["beat.arrival_echo"], "the echo sets no flag of its own")


func test_the_echo_waits_for_the_picture_to_come_back() -> void:
	# the rift fades the valley in over several seconds, and the player may walk at once
	SceneTravel.arrival_fade = 3.0
	await _arrive()
	await _walk(40)
	var seen := {"up": false, "dark": false}
	var watch := func() -> bool:
		if _cutscenes() == 1 and not seen["up"]:
			seen["up"] = true
			seen["dark"] = ScreenFade.is_covered() or ScreenFade.is_fading()
		return seen["up"]
	await wait_until(watch, 12.0)
	assert_true(seen["up"], "the echo comes")
	assert_false(seen["dark"], "but not into the black")


func test_a_teleport_is_no_step() -> void:
	var scene := await _arrive()
	scene.player.teleport(scene.map.cell_to_world(Vector2i(30, 20)))
	await wait_seconds(1.0)
	assert_eq(_cutscenes(), 0)
	assert_false(Beat.reached("arrival_echo"), "the way is walked, not jumped")


func test_standing_still_calls_up_nothing() -> void:
	await _arrive()
	await wait_seconds(2.0)
	assert_eq(_cutscenes(), 0)
	assert_false(Beat.reached("arrival_echo"))


func test_there_is_no_echo_without_the_rift_behind() -> void:
	# a valley entered any other way (a debug start, an old save) has no Act I to answer
	await _valley()
	await _walk(40)
	await wait_seconds(1.0)
	assert_eq(_cutscenes(), 0)
	assert_false(Beat.reached("arrival_echo"))


func test_the_echo_follows_the_rift_even_when_the_valley_was_already_open() -> void:
	# the scene stands first and Act I is reached after (a segment script, a late autosave)
	var scene := await _valley()
	await _walk(40)
	assert_eq(_cutscenes(), 0, "no rift behind yet")
	WorldState.set_flag(Chapter.flag_for("act1"))
	await _walk(40, &"move_up")
	await wait_until(func() -> bool: return _cutscenes() == 1, 12.0)
	assert_eq(_cutscenes(), 1)


func test_the_echo_gives_way_when_mira_is_met_first() -> void:
	var scene := await _arrive()
	WorldState.set_flag("valley.mira_met")
	await _walk(40)
	await wait_seconds(1.0)
	assert_eq(_cutscenes(), 0)
	assert_false(Beat.reached("arrival_echo"))
	assert_false(scene.dialogue_box.is_open())


func test_the_echo_does_not_come_back_once_it_has_played() -> void:
	Beat.mark("arrival_echo")
	var scene := await _arrive()
	await _walk(40)
	await wait_seconds(1.0)
	assert_eq(_cutscenes(), 0)
	assert_false(scene.dialogue_box.is_open())


func test_the_echo_waits_for_a_conversation_that_is_open() -> void:
	var scene := await _arrive()
	# a conversation is up (the fall into the stream), and the player walks on while it is
	scene.dialogue_box.present(MIRA, "fell_in")
	await wait_physics_frames(3)
	assert_true(scene.dialogue_box.is_open())
	await _walk(40)
	await wait_seconds(0.5)
	assert_eq(_cutscenes(), 0, "the echo does not stack on a conversation")
	# the taps stop with the conversation: the echo that follows is not clicked through. They are
	# ui_accept, for the player is free here and an interact would examine what lies ahead.
	for i in 12:
		if not (scene.dialogue_box.is_open() and scene.dialogue_box.cue == "fell_in"):
			break
		await _tap(&"ui_accept")
	var echo_up := func() -> bool:
		return scene.dialogue_box.is_open() and scene.dialogue_box.cue == "arrival_echo"
	await wait_until(echo_up, 12.0)
	assert_true(echo_up.call(), "and then the echo comes")
	assert_eq(_cutscenes(), 1)


func test_a_scene_freed_while_the_echo_waits_leaves_nothing_that_wakes_up() -> void:
	# freed on the spot, as GUT does at the end of every test: a coroutine that waits on the tree's
	# physics frame outlives its node, and the engine reports it as an error in the next frames
	var scene := await _arrive()
	scene.free()
	await wait_physics_frames(6)
	assert_false(is_instance_valid(scene))


func test_a_scene_freed_while_the_echo_is_up_leaves_nothing_that_wakes_up() -> void:
	var scene := await _arrive()
	await _walk(40)
	await wait_until(func() -> bool: return _cutscenes() == 1, 12.0)
	scene.free()
	await wait_physics_frames(6)
	assert_false(is_instance_valid(scene))
	assert_eq(_cutscenes(), 0, "the scene took its cutscene along")
