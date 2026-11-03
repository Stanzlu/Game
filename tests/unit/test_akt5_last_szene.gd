extends GutTest
## Act V, segment G4: the load in the hall (docs/akt5/REGIONSBRIEFE.md, O4, O19, O20). On the
## keeper's offer the run begins at the console: the levers spring up after their period, a wave
## takes the cloths away and calls its levers, the dials wander off their mark, the steam thickens
## and the lamps dim as the load is not kept, and after the fourth wave the keeper reckons it up and
## it stops. Nothing fails and nothing is locked. The run's own arithmetic is tested in
## test_akt5_last, what he says in test_akt5_last_text; the hall without the load in
## test_akt5_anlage_szene.

const MASCHINE := preload("res://world/levels/akt5/maschine.tscn")
const QUEST := "main_mountain_way"
const AT_CONSOLE := Vector2i(12, 10)
const AWAY := Vector2i(8, 15)
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	Settings.set_value("display.screen_shake", true, false)
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The hall after the trial, with the load begun (the keeper's offer taken) unless `begun` is false.
func _hall(begun := true) -> MaschineScene:
	WorldState.set_flag("plant.probe")
	WorldState.set_flag("plant.probe_done")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "valley")
	var scene: MaschineScene = MASCHINE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	await _put(scene, AT_CONSOLE)
	if begun:
		WorldState.set_flag("plant.load")
		await wait_physics_frames(2)
	return scene


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Moves the text on as a player does until `until` holds (the first press types the line out, the
## next moves on).
func _told(scene: GameScene, until: Callable, seconds := 40.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				_confirm()
			return until.call(),
		seconds
	)


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


func _covers(scene: GameScene) -> int:
	var covers := 0
	for node in _alive(scene):
		if node is Decor and (node as Decor).sprite_id == "tal/ma_lever_cover":
			covers += 1
	return covers


func _in_use(scene: MaschineScene) -> Array:
	var used := []
	for number: int in range(1, 13):
		if scene.lever(number).active:
			used.append(number)
	return used


## Runs a wave to its end in one step of play time (the scene's own ticks go on beside it).
func _end_wave(scene: MaschineScene) -> void:
	scene._run.step(LoadRun.wave_seconds(scene._run.wave) + 0.1, true, false)
	await wait_physics_frames(2)


func _quiet(scene: GameScene) -> bool:
	return (
		not scene.dialogue_box.is_open()
		and get_tree().get_nodes_in_group(&"cutscene").is_empty()
		and not scene.player.is_locked()
	)


# --- The offer takes the run in hand ----------------------------------------------------------


func test_the_keepers_offer_begins_the_run_with_the_three_levers_of_the_trial() -> void:
	var scene := await _hall(false)
	assert_eq(scene._run.state, LoadRun.State.IDLE, "nothing runs before the offer")
	WorldState.set_flag("plant.load")
	await wait_physics_frames(2)
	assert_eq(scene._run.state, LoadRun.State.RUNNING)
	assert_eq(scene._run.wave, 1)
	assert_eq(_in_use(scene), [1, 2, 3])
	assert_true(Beat.reached("maschine_load"))
	assert_eq(WorldState.quest_stage(QUEST), "load", "the journal gives the help from here on")
	assert_eq(_covers(scene), 9, "all nine cloths are still on")


func test_a_pull_during_the_run_holds_the_lever_and_it_springs_up_by_itself() -> void:
	var scene := await _hall()
	assert_true(scene.lever(1).down, "the trial left it down: it is held")
	scene.lever(1).set_down(false)
	scene.lever(1).pulled.emit(1)
	assert_true(scene.lever(1).down, "she holds it")
	scene._run.step(LoadRun.period(1, 1.0) + 0.5, true, false)
	assert_false(scene.lever(1).down, "and after its period it asks again")


func test_the_run_never_locks_her_and_the_hall_can_be_left_at_any_time() -> void:
	var scene := await _hall()
	await wait_physics_frames(120)
	assert_false(scene.player.is_locked(), "no cutscene holds her while the run goes on")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)


# --- The waves --------------------------------------------------------------------------------


func test_each_wave_takes_three_cloths_off_calls_its_levers_and_asks_for_more() -> void:
	var scene := await _hall()
	var flags := ["plant.wave_two", "plant.wave_three", "plant.wave_four"]
	var in_use := [[1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6, 7, 8, 9], range(1, 13)]
	for i in 3:
		await _end_wave(scene)
		assert_true(WorldState.has_flag(flags[i]), flags[i])
		assert_true(await _told(scene, func() -> bool: return _quiet(scene)), "the call is spoken")
		assert_eq(_in_use(scene), Array(in_use[i]), "wave %d" % (i + 2))
		assert_eq(_covers(scene), 6 - i * 3, "three cloths fewer")
	assert_eq(scene._run.wave, 4)
	assert_eq(scene._run.state, LoadRun.State.RUNNING)


func test_the_run_stands_still_while_the_keeper_calls_a_wave() -> void:
	var scene := await _hall()
	await _end_wave(scene)
	await wait_physics_frames(2)
	var time: float = scene._run._wave_time
	await wait_physics_frames(30)
	assert_eq(scene._run._wave_time, time, "nothing runs while he speaks")
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	await wait_physics_frames(30)
	assert_gt(scene._run._wave_time, time, "and it goes on after")


# --- What is not kept shows -------------------------------------------------------------------


func test_the_dials_wander_the_steam_thickens_and_the_lamps_dim_with_the_open_levers() -> void:
	var scene := await _hall()
	for number: int in [1, 2, 3]:
		scene.lever(number).set_down(false)
	await wait_physics_frames(150)
	assert_gt(scene._trouble, 0.9, "all three ask")
	for gauge: Gauge in scene._gauges:
		assert_gt(absf(gauge.needle.rotation_degrees - gauge._rest), 20.0, "off its mark")
	var steam: Decor = scene._steam[0]
	assert_gt(steam.scale.x, 1.4)
	var lamp: Decor = scene._lamps[0]
	assert_lt(lamp.light_scale, 0.6, "the lamps dim")
	for number: int in [1, 2, 3]:
		scene.lever(number).pulled.emit(number)
		scene._run.step(LoadRun.HAND_SECONDS, true, false)
	await wait_physics_frames(240)
	assert_lt(scene._trouble, 0.1, "held again: it settles")
	for gauge: Gauge in scene._gauges:
		assert_lt(absf(gauge.needle.rotation_degrees - gauge._rest), 3.0, "back on its mark")
	assert_almost_eq(lamp.light_scale, 1.0, 0.1)


func test_the_dials_wander_slowly_and_without_a_flash() -> void:
	var scene := await _hall()
	for number: int in [1, 2, 3]:
		scene.lever(number).set_down(false)
	var before: float = scene._gauges[0].needle.rotation_degrees
	await wait_physics_frames(6)
	var after: float = scene._gauges[0].needle.rotation_degrees
	assert_lt(absf(after - before), 8.0, "a few ticks move it a little, never a jump")
	assert_eq(
		scene.find_children("*", "PointLight2D", true, false).size() <= 6, true, "no new light"
	)


func test_with_picture_shaking_off_the_dials_still_show_the_load_but_do_not_tremble() -> void:
	Settings.set_value("display.screen_shake", false, false)
	var scene := await _hall()
	for number: int in [1, 2, 3]:
		scene.lever(number).set_down(false)
	await wait_physics_frames(200)
	var trembling: Gauge = null
	for gauge: Gauge in scene._gauges:
		if gauge._amplitude > 0.0:
			trembling = gauge
	var a := trembling.needle.rotation_degrees
	await wait_physics_frames(7)
	assert_eq(trembling.needle.rotation_degrees, a, "it rests where the load put it")
	assert_gt(absf(a - trembling._rest), 20.0, "the information is not lost")


# --- The pause --------------------------------------------------------------------------------


func test_leaving_the_console_stops_the_run_and_the_keeper_enters_the_pause() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	assert_false(scene._run.is_waiting())
	scene._run.step(LoadRun.AWAY_SECONDS + 0.2, false, false)
	await wait_physics_frames(2)
	assert_true(scene._run.is_waiting())
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)), "he enters the pause")
	var time: float = scene._run._wave_time
	await wait_physics_frames(120)
	assert_eq(scene._run._wave_time, time, "nothing runs while she is away")
	await _put(scene, AT_CONSOLE)
	await wait_physics_frames(2)
	assert_false(scene._run.is_waiting())
	assert_true(
		await _told(scene, func() -> bool: return _quiet(scene)), "and he takes it up again"
	)
	assert_false(WorldState.has_flag("plant.overload"), "nothing was lost, nothing ended")


# --- The end of the fourth wave ---------------------------------------------------------------


func test_after_the_fourth_wave_he_reckons_it_up_and_the_run_stops_for_good() -> void:
	var scene := await _hall()
	for i in 3:
		await _end_wave(scene)
		assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	await _end_wave(scene)
	var over := func() -> bool: return WorldState.has_flag("plant.overload")
	assert_true(await _told(scene, over), "he reads the reckoning aloud and enters it")
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	assert_eq(scene._run.state, LoadRun.State.OVER)
	assert_true(Beat.reached("maschine_overload"))
	assert_eq(WorldState.quest_stage(QUEST), "load")
	assert_eq(_covers(scene), 0, "every cloth is off")
	assert_eq(_in_use(scene).size(), 12)
	var open: int = scene._run.open_count()
	scene._run.step(30.0, true, false)
	assert_eq(scene._run.open_count(), open, "nothing moves any more")
	assert_false(scene.player.is_locked(), "nothing is locked")
	assert_eq(scene._run.open_count(), 12, "all twelve stand up and ask")
	scene.lever(5).pulled.emit(5)
	assert_false(scene.lever(5).down, "the levers stand as they stood: a pull moves nothing")
	assert_eq(scene._run.open_count(), 12)
	await wait_physics_frames(240)
	assert_gt(scene._trouble, 0.99, "and the dials stay where the load put them")


# --- A game loaded in the middle --------------------------------------------------------------


func test_a_game_loaded_in_the_third_wave_goes_on_from_there_when_she_is_at_the_console() -> void:
	for flag: String in ["plant.load", "plant.wave_two", "plant.wave_three"]:
		WorldState.set_flag(flag)
	var scene := await _hall(false)
	await _put(scene, AT_CONSOLE)
	assert_eq(scene._run.wave, 3)
	assert_eq(_in_use(scene), range(1, 10))
	assert_eq(_covers(scene), 3, "the cloths of the fourth wave are still on")
	assert_eq(scene.lever(4).down, false, "the new ones stand up and ask")


func test_a_game_loaded_in_the_load_waits_until_she_stands_at_the_console() -> void:
	WorldState.set_flag("plant.load")
	var scene := await _hall(false)
	await _put(scene, AWAY)
	var time: float = scene._run._wave_time
	await wait_physics_frames(240)
	assert_eq(scene._run._wave_time, time, "it does not begin without her")
	assert_false(scene._run.is_waiting(), "and it says nothing about it")
	await _put(scene, AT_CONSOLE)
	await wait_physics_frames(60)
	assert_eq(scene._run._wave_time, time, "she gets a moment at the console first")
	await wait_physics_frames(180)
	assert_gt(scene._run._wave_time, time)


func test_a_game_loaded_after_the_run_finds_every_lever_in_use_the_dials_off_and_nothing_running(
) -> void:
	for flag: String in [
		"plant.load", "plant.wave_two", "plant.wave_three", "plant.wave_four", "plant.overload"
	]:
		WorldState.set_flag(flag)
	var scene := await _hall(false)
	assert_eq(scene._run.state, LoadRun.State.OVER)
	assert_eq(_in_use(scene).size(), 12)
	assert_eq(_covers(scene), 0)
	assert_gt(scene._trouble, 0.99, "the dials stand off their mark from the first picture")
	for gauge: Gauge in scene._gauges:
		assert_gt(absf(gauge.needle.rotation_degrees - gauge._rest), 20.0, "no swing on arrival")
	var time: float = scene._run._wave_time
	await wait_physics_frames(60)
	assert_eq(scene._run._wave_time, time, "and nothing runs")


func test_the_steam_has_its_resting_look_from_the_first_picture_and_thickens_with_the_load(
) -> void:
	var scene := await _hall(false)
	var steam: Decor = scene._steam[0]
	assert_almost_eq(steam.modulate.a, 0.7, 0.01, "no pop when the load begins")
	assert_almost_eq(steam.scale.x, 1.0, 0.01)
	WorldState.set_flag("plant.load")
	for number: int in [1, 2, 3]:
		scene.lever(number).set_down(false)
	await wait_physics_frames(200)
	assert_almost_eq(steam.modulate.a, 1.0, 0.05, "denser with every lever that stands up")


func test_a_game_loaded_in_each_wave_goes_on_from_that_wave() -> void:
	var flags := {
		2: ["plant.wave_two"],
		4: ["plant.wave_two", "plant.wave_three", "plant.wave_four"],
	}
	for wave: int in flags:
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.REAL)
		WorldState.set_flag("plant.load")
		for flag: String in flags[wave]:
			WorldState.set_flag(flag)
		var scene := await _hall(false)
		assert_eq(scene._run.wave, wave, "wave %d" % wave)
		assert_eq(_in_use(scene).size(), wave * 3)
		assert_eq(_covers(scene), 12 - wave * 3 if wave < 4 else 0)
		scene.queue_free()
		await wait_physics_frames(2)
