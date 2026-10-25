extends GutTest
## Act II, segment B1: the arrival. After the first steps in the valley a gust goes through the wet
## leaves and the valley answers what Elysia left in the save: at the fire nobody calls you to
## stay (or asks twice), on the puddle no ring repeats, the rain hums for a breath. Nothing is
## explained; whoever did none of it hears the gust and the ground. It plays once, on the way over
## the rift, and gives way when Mira is met first.

const TAL := preload("res://world/levels/slice/tal.tscn")
const ARRIVAL := "res://content/dialogue/akt2/ankunft.dialogue"
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


func _lines() -> PackedStringArray:
	return await DialogueWalk.play(ARRIVAL, "arrival_echo")


func _ids(ids: Array[String]) -> PackedStringArray:
	var texts: PackedStringArray = []
	for id in ids:
		texts.append(LineText.of(id))
	return texts


# --- The cue ---------------------------------------------------------------------------------


func test_whoever_did_nothing_in_elysia_hears_the_gust_and_the_ground() -> void:
	assert_eq(await _lines(), _ids(["ank_gust_1", "ank_ground_1"]))


func test_the_fire_says_nobody_calls_you_to_stay_if_you_stayed_at_the_inn() -> void:
	WorldState.set_flag("elysia.inn_stayed")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_1") in seen)
	assert_false(LineText.of("ank_fire_2") in seen)


func test_the_fire_says_nobody_asks_twice_if_you_declined_the_room() -> void:
	WorldState.set_flag("elysia.inn_declined")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_2") in seen)
	assert_false(LineText.of("ank_fire_1") in seen)


func test_staying_wins_over_declining_and_the_fire_is_never_said_twice() -> void:
	# she declined the room and stayed the night after all: one line about the fire, the later act
	WorldState.set_flag("elysia.inn_declined")
	WorldState.set_flag("elysia.inn_stayed")
	var seen := await _lines()
	assert_true(LineText.of("ank_fire_1") in seen)
	assert_false(LineText.of("ank_fire_2") in seen)


func test_no_ring_repeats_on_the_puddle_if_you_said_it_was_the_same_feast() -> void:
	WorldState.set_flag("elysia.feast_noticed")
	assert_true(LineText.of("ank_rings_1") in await _lines())


func test_the_rain_hums_if_you_can_hum_the_childs_tune() -> void:
	WorldState.set_flag("melody.child_hum")
	assert_true(LineText.of("ank_hum_1") in await _lines())


func test_everything_set_the_echoes_follow_the_gust_and_the_ground_in_order() -> void:
	for flag: String in ["elysia.inn_stayed", "elysia.feast_noticed", "melody.child_hum"]:
		WorldState.set_flag(flag)
	var ids: Array[String] = [
		"ank_gust_1", "ank_ground_1", "ank_fire_1", "ank_rings_1", "ank_hum_1"
	]
	assert_eq(await _lines(), _ids(ids))


func test_the_echo_names_no_figure_and_explains_nothing() -> void:
	# narration only: nobody speaks, and no line is a question or an exclamation (STIL.md)
	for flag: String in [
		"elysia.inn_stayed", "elysia.feast_noticed", "melody.child_hum", "elysia.inn_declined"
	]:
		WorldState.set_flag(flag)
	var resource := load(ARRIVAL) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "arrival_echo")
	while line != null:
		assert_eq(line.character, "", "narration: %s" % line.text)
		assert_false(line.text.contains("?") or line.text.contains("!"), line.text)
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)


# --- The scene -------------------------------------------------------------------------------


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
