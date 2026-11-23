extends GutTest
## Act VI, segment R5: the inn as it was, and the table in the middle (docs/akt6/REGIONSBRIEFE.md,
## O6). Whoever came back finds the host waiting, the hearth with the one night on it (the why of
## his strategy, as a thing) and a table with two benches on the middle axis. Whoever sits down
## there is asked once per sitting; every answer "stay" brings the next of three offers (food,
## music, rest) and closes the picture in one step while she sits; standing up gives it back at
## once. Staying has no end and nothing gets better or worse. What the cues say is tested in
## test_akt6_gasthaus.

const GASTHAUS := preload("res://world/levels/akt1/gasthaus.tscn")
const QUEST := "main_return_way"
const STAY_FLAGS: PackedStringArray = ["elysia.stay_1", "elysia.stay_2", "elysia.stay_3"]
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("elysia.inn_met")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "pull")
	WorldState.advance_quest(QUEST, "elysia")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


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


func _scene() -> GasthausScene:
	var scene: GasthausScene = GASTHAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The props of the map by the file of their scene (the benches have no cue).
func _props(scene: GameScene, file: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node.scene_file_path.ends_with(file):
			found.append(node)
	return found


## The prop (walker or decor) with this cue on the map, or null; the first one found.
func _prop(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if str(node.get(&"cue")) == cue:
			return node
	return null


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Talks to the prop as the player does and returns the cue that the box shows.
func _talk(scene: GameScene, cue: String) -> String:
	var prop := _prop(scene, cue)
	assert_not_null(prop, "the prop with the cue %s is on the map" % cue)
	if prop == null:
		return ""
	(prop.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0), "it says something")
	return scene.dialogue_box.cue


## She sits down on a bench as the player does: the bench seats whoever uses it.
func _sit(scene: GameScene) -> void:
	var bench := _props(scene, "bench.tscn")[0]
	(bench.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	await wait_physics_frames(3)


## Answers the box with these answers, in order, as they come up, until `done` holds.
func _answering(
	scene: GameScene, answers: PackedStringArray, done: Callable, timeout := 60.0
) -> void:
	var next := [0]
	var watch := func() -> bool:
		_polls += 1
		if scene.dialogue_box.is_open():
			var want := answers[next[0]] if next[0] < answers.size() else ""
			if next[0] < answers.size() and BoxAnswers.pick(scene.dialogue_box, want):
				next[0] += 1
			elif _polls % 6 == 0:
				_confirm()
		return done.call()
	assert_true(await wait_until(watch, timeout), "the box asked, and %s were taken" % [answers])
	assert_eq(next[0], answers.size(), "every answer was taken")


func _closed(scene: GameScene) -> Callable:
	return func() -> bool: return not scene.dialogue_box.is_open()


func _stays() -> int:
	var count := 0
	for flag in STAY_FLAGS:
		if WorldState.has_flag(flag):
			count += 1
	return count


func _wait_open(scene: GameScene) -> void:
	var asked: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(asked, "sitting down opens the question")


# --- The inn for whoever did not come back ----------------------------------------------------


func test_whoever_did_not_come_back_finds_no_table_and_the_old_host() -> void:
	WorldState.clear_flag("elysia.returned")
	var scene := await _scene()
	assert_null(scene.get_node_or_null("InnTable"), "no table at all")
	assert_eq(_props(scene, "bench.tscn").size(), 0, "no bench")
	assert_eq(await _talk(scene, "host"), "host", "the host of Act I")
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(await _talk(scene, "hearth"), "hearth")
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(WorldState.quest_stage(QUEST), "elysia", "and the walk does not move on")


# --- The inn for whoever came back ------------------------------------------------------------


func test_the_table_and_two_benches_stand_in_the_middle_of_the_hall() -> void:
	var scene := await _scene()
	var benches := _props(scene, "bench.tscn")
	assert_eq(benches.size(), 2, "two benches")
	var xs: Array[float] = []
	for bench in benches:
		xs.append(bench.global_position.x)
	xs.sort()
	# the middle of the two (each is two cells wide) is the axis of the hall, the middle of cell 20
	assert_almost_eq((xs[0] + xs[1]) / 2.0 + 8.0, 20.5 * 16.0, 1.0, "mirrored")
	assert_not_null(scene.get_node_or_null("InnTable"))


func test_the_host_waits_and_the_hearth_shows_the_night_to_whoever_came_back() -> void:
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host_back", "the host waits")
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(await _talk(scene, "hearth"), "hearth_back", "the thing at the hearth")
	await _answering(scene, PackedStringArray(), _closed(scene))


func test_the_host_keeps_the_old_cue_for_a_game_that_never_spoke_to_him() -> void:
	# a game that came back by the clock (the rift opens by itself) may never have met him: his
	# first words, the guest book and the meal are in Act I's cue
	WorldState.clear_flag("elysia.inn_met")
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host", "his meal and the book are in Act I's cue")
	await _answering(scene, PackedStringArray(["Ich schau mich nur um."]), _closed(scene))
	assert_true(WorldState.has_flag("elysia.inn_met"), "now they have met")
	assert_eq(await _talk(scene, "host"), "host_back", "and from then on he waits")
	await _answering(scene, PackedStringArray(), _closed(scene))


func test_the_first_visit_moves_the_walk_from_the_garden_to_the_inn_once() -> void:
	var scene := await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "inn")
	assert_true(Beat.reached(InnTable.ENTER_BEAT))
	scene.queue_free()
	await wait_physics_frames(2)
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "inn", "and it stays there")


func test_a_game_in_an_earlier_stage_does_not_skip_ahead() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.loops")
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "", "no walk, no stage")
	assert_push_error_count(0)


# --- Sitting and staying ----------------------------------------------------------------------


func test_sitting_down_asks_once_and_declining_changes_nothing() -> void:
	var scene := await _scene()
	var opened := [0]
	scene.dialogue_box.opened.connect(func() -> void: opened[0] += 1)
	var xp := WorldState.state.elysia.xp
	await _sit(scene)
	await _wait_open(scene)
	assert_eq(scene.dialogue_box.cue, "stay", "the question of the sitting")
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	await wait_physics_frames(3)
	assert_eq(opened[0], 1, "one question for one sitting")
	assert_eq(_stays(), 0, "no step")
	assert_eq(scene.view.zoom, scene.view_zoom, "the picture as it was")
	assert_eq(scene.player.state, Player.State.SIT, "she sits on, free to stand up")
	assert_false(scene.player.is_locked())
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")
	scene.player.stand_up()
	await wait_physics_frames(3)
	await _sit(scene)
	await _wait_open(scene)
	assert_eq(opened[0], 2, "a second sitting asks again")
	await _answering(scene, PackedStringArray(["…"]), _closed(scene))
	assert_eq(WorldState.state.elysia.xp, xp, "nothing was given")


func test_each_answer_to_staying_closes_the_picture_in_one_step_while_she_sits() -> void:
	var scene := await _scene()
	await _sit(scene)
	var zooms: Array[float] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in STAY_FLAGS:
			zooms.append(scene.view.zoom)
	WorldState.flag_changed.connect(on_flag)
	await _answering(
		scene, PackedStringArray(["Bleiben.", "Noch bleiben.", "Noch bleiben."]), _closed(scene)
	)
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(_stays(), 3, "three offers, three steps")
	assert_eq(zooms, [1.75, 2.0, 2.0], "a step each time, never a tween")
	assert_true(Beat.reached(InnTable.STAY_BEAT), "after the third the game saves once")
	assert_eq(scene.view.zoom, 2.0, "the tightest")


func test_standing_up_gives_the_picture_back_at_once() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _answering(scene, PackedStringArray(["Bleiben.", "Nur sitzen."]), _closed(scene))
	assert_eq(scene.view.zoom, 1.75, "one answer, one step")
	scene.player.stand_up()
	await wait_physics_frames(2)
	assert_eq(scene.view.zoom, scene.view_zoom, "no wait, no hold")
	assert_eq(_stays(), 1, "what was stayed stays written")


func test_the_picture_only_closes_in_while_she_sits() -> void:
	var scene := await _scene()
	WorldState.set_flag("elysia.stay_1")
	assert_eq(scene.view.zoom, scene.view_zoom, "a flag from elsewhere moves nothing")
	WorldState.set_flag("elysia.stay_2")
	assert_eq(scene.view.zoom, scene.view_zoom)


func test_after_the_third_offer_staying_has_no_end_and_nothing_changes() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _answering(
		scene, PackedStringArray(["Bleiben.", "Noch bleiben.", "Noch bleiben."]), _closed(scene)
	)
	scene.player.stand_up()
	await wait_physics_frames(3)
	# standing up with all three behind her is the host's scene (test_akt6_aufstehen_szene)
	await _answering(scene, PackedStringArray(), _closed(scene))
	await wait_physics_frames(3)
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	await _sit(scene)
	await _wait_open(scene)
	assert_eq(scene.dialogue_box.cue, "stay", "the same question, with the table as it stands")
	var rounds := PackedStringArray()
	for _round in 6:
		rounds.append("Bleiben.")
	rounds.append("Nur sitzen.")
	await _answering(scene, rounds, _closed(scene), 90.0)
	assert_eq(_stays(), 3, "no fourth step")
	assert_eq(scene.view.zoom, scene.view_zoom, "staying on again does not close the picture in")
	assert_eq(WorldState.state.elysia.xp, xp, "staying gives nothing")
	assert_eq(WorldState.state.elysia.gold, gold)
	assert_eq(
		WorldState.quest_stage(QUEST), "stand", "and takes nothing: the walk stays where it is"
	)
	assert_eq(scene.player.state, Player.State.SIT, "nobody has stood her up")


func test_a_loaded_game_never_begins_tight() -> void:
	WorldState.set_flag("elysia.stay_1")
	WorldState.set_flag("elysia.stay_2")
	WorldState.set_flag("elysia.stay_3")
	var scene := await _scene()
	assert_eq(scene.view.zoom, scene.view_zoom, "sitting is not saved")
	assert_ne(scene.player.state, Player.State.SIT)
