extends GutTest
## Act V, segment G5: the letting go in the hall (docs/akt5/REGIONSBRIEFE.md, O4, O10, O13). The
## load has stopped and every lever stands up. At the console nothing happens; whoever steps away
## and waits sees the levers go down by themselves, a burst of steam, a lamp that goes out and
## stays out, and the dials come back. The keeper enters it all and doubts it; the facet `trust` is
## set, the walk of the hero goes on, a potato rolls out of the pipe. Nothing is locked, nothing
## fails, and a game loaded in any of the states finds the hall as it stood. The model's own
## arithmetic is in test_akt5_letgo, the keeper's words in test_akt5_letgo_text.

const MASCHINE := preload("res://world/levels/akt5/maschine.tscn")
const QUEST := "main_mountain_way"
const POTATO_QUEST := "side_plant_potato"
const AT_CONSOLE := Vector2i(12, 10)
const AWAY := Vector2i(9, 13)
const FLAGS_AFTER_LOAD: Array[String] = [
	"plant.probe",
	"plant.probe_done",
	"plant.load",
	"plant.wave_two",
	"plant.wave_three",
	"plant.wave_four",
	"plant.overload",
]
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
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The hall as a game loaded after the load shows it: every flag of the load set, the walk of the
## hero on `load`, every lever in use and up, she at the console.
func _hall(extra: Array[String] = [], at := AT_CONSOLE) -> MaschineScene:
	for flag in FLAGS_AFTER_LOAD:
		WorldState.set_flag(flag)
	for flag in extra:
		WorldState.set_flag(flag)
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "valley")
	WorldState.advance_quest(QUEST, "plant")
	WorldState.advance_quest(QUEST, "load")
	var scene: MaschineScene = MASCHINE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	await _put(scene, at)
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


## Moves the text on as a player does until `until` holds.
func _told(scene: GameScene, until: Callable, seconds := 90.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				_confirm()
			return until.call(),
		seconds
	)


func _quiet(scene: GameScene) -> bool:
	return (
		not scene.dialogue_box.is_open()
		and get_tree().get_nodes_in_group(&"cutscene").is_empty()
		and not scene.player.is_locked()
	)


func _alive(scene: GameScene) -> Array[Node]:
	var list: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			list.append(node)
	return list


func _down(scene: MaschineScene) -> int:
	var count := 0
	for number in range(1, 13):
		if scene.lever(number).down:
			count += 1
	return count


## The hanging lamps and the standing ones: [lit, dark].
func _lamps(scene: GameScene) -> Array[int]:
	var lit := 0
	var dark := 0
	for node in _alive(scene):
		if node is Decor:
			var decor := node as Decor
			if decor.sprite_id == "tal/ma_lamp_hang_dark":
				dark += 1
			elif decor.sprite_id == "tal/ma_lamp_hang" or decor.sprite_id == "tal/ma_lamp":
				lit += 1
	return [lit, dark]


func _potato(scene: GameScene) -> Node:
	for node in _alive(scene):
		if node.get(&"item") == "item_potato":
			return node
	return null


## Plays the whole letting go: she steps away and waits until the keeper has told it to the end.
func _let_go(scene: MaschineScene) -> void:
	await _put(scene, AWAY)
	var through := func() -> bool: return WorldState.has_flag("plant.letgo")
	assert_true(await _told(scene, through), "the course ends with plant.letgo")
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))


# --- At the console nothing happens ---------------------------------------------------------------


func test_at_the_console_nothing_is_asked_and_nothing_falls() -> void:
	var scene := await _hall()
	await wait_physics_frames(600)
	assert_eq(scene._letgo.state, LetGo.State.IDLE, "the course waits for her to step away")
	assert_eq(_down(scene), 0, "all twelve stand up")
	assert_false(WorldState.has_flag("plant.defect"))
	assert_false(WorldState.has_flag("plant.letgo"))
	assert_false(WorldState.has_facet("trust"))
	assert_true(_quiet(scene), "and nobody speaks")
	assert_eq(_lamps(scene), [6, 0], "all six lamps are lit")


func test_a_pull_at_the_console_still_moves_nothing_before_the_letting_go() -> void:
	var scene := await _hall()
	scene.lever(5).pulled.emit(5)
	assert_false(scene.lever(5).down, "the levers stand as they stood")


# --- The course ---------------------------------------------------------------------------------


func test_stepping_away_begins_it_and_the_keeper_enters_that_the_console_is_empty() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var began := func() -> bool: return scene._letgo.state == LetGo.State.RUNNING
	assert_true(await _told(scene, began, 10.0))
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	assert_false(scene.player.is_locked(), "nothing is locked")


func test_the_levers_go_down_by_themselves_in_the_order_of_the_trial() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var order: Array[int] = []
	scene._letgo.fell.connect(func(number: int, _i: int) -> void: order.append(number))
	var through := func() -> bool: return WorldState.has_flag("plant.letgo")
	assert_true(await _told(scene, through))
	assert_eq(order, LetGo.ORDER, "Three, One, Two and then Four to Twelve")
	assert_eq(_down(scene), 12, "all of them are down")


func test_the_course_sets_trust_and_the_flags_and_the_walk_goes_on() -> void:
	var scene := await _hall()
	assert_false(WorldState.has_facet("trust"))
	await _let_go(scene)
	assert_true(WorldState.has_facet("trust"), "the letting go is what sets trust")
	assert_true(WorldState.has_flag("plant.defect"))
	assert_true(WorldState.has_flag("plant.letgo"))
	assert_true(WorldState.has_flag("melody.machine_count"), "the bar of clicks")
	assert_true(Beat.reached("maschine_letgo"))
	assert_eq(WorldState.quest_stage(QUEST), "letgo")
	assert_false(scene.player.is_locked(), "nothing is locked")


func test_trust_is_not_set_before_the_end() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var defect := func() -> bool: return WorldState.has_flag("plant.defect")
	assert_true(await _told(scene, defect))
	assert_false(WorldState.has_facet("trust"), "not while it is still going on")
	assert_false(WorldState.has_flag("plant.letgo"))
	assert_false(Beat.reached("maschine_letgo"))


func test_coming_back_to_the_console_stops_the_clock_where_it_stood() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var first := func() -> bool: return scene._letgo.fallen >= 2
	assert_true(await _told(scene, first))
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	await _put(scene, AT_CONSOLE)
	var elapsed: float = scene._letgo.elapsed
	await wait_physics_frames(300)
	assert_eq(scene._letgo.elapsed, elapsed, "it waits for her at the console")
	assert_false(WorldState.has_flag("plant.letgo"))
	await _put(scene, AWAY)
	await _let_go(scene)
	assert_eq(_down(scene), 12, "and goes on from where it stood")


func test_the_levers_after_the_letting_go_are_only_levers_again() -> void:
	var scene := await _hall()
	await _let_go(scene)
	scene.lever(5).pulled.emit(5)
	assert_false(scene.lever(5).down, "a lever goes up and down as in the free phase")
	scene.lever(5).pulled.emit(5)
	assert_true(scene.lever(5).down)


# --- What the hall shows --------------------------------------------------------------------------


func test_a_burst_of_steam_half_way_and_it_dies_down_again() -> void:
	var scene := await _hall()
	var rest := 0.0
	await _put(scene, AWAY)
	var mid := func() -> bool: return scene._surge_left > 0.0
	assert_true(await _told(scene, mid))
	var peak := 0.0
	var through := func() -> bool:
		peak = maxf(peak, scene._surge)
		return WorldState.has_flag("plant.letgo")
	assert_true(await _told(scene, through))
	assert_gt(peak, 0.5, "the steam rose")
	assert_true(await _told(scene, func() -> bool: return _quiet(scene)))
	await wait_physics_frames(600)
	assert_eq(scene._surge, rest, "and it died down")


func test_the_left_hanging_lamp_goes_out_and_stays_out_and_nobody_mends_it() -> void:
	var scene := await _hall()
	assert_eq(_lamps(scene), [6, 0])
	await _let_go(scene)
	await wait_physics_frames(300)
	assert_eq(_lamps(scene), [5, 1], "one lamp is dark, five are lit")
	var lights := 0
	for node in _alive(scene):
		if node is Decor and (node as Decor).sprite_id == "tal/ma_lamp_hang_dark":
			lights += (node as Decor).lights.size()
	assert_eq(lights, 0, "the dark one casts no light")
	assert_true(WorldState.has_flag("plant.defect"))


func test_the_dials_the_steam_and_the_lamps_come_back_once_the_levers_are_down() -> void:
	var scene := await _hall()
	assert_gt(scene._trouble, 0.99, "the load left the dials at the edge")
	await _let_go(scene)
	await wait_physics_frames(600)
	assert_lt(scene._trouble, 0.01, "the hall is calm")
	for lamp in scene._lamps:
		if is_instance_valid(lamp):
			assert_almost_eq(lamp.light_scale, 1.0, 0.01, "the lamps shine as before")


func test_the_hall_never_flashes_while_it_goes_on() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var worst := [0.0, 0.0]
	var last := [1.0, 0.7]
	var through := func() -> bool:
		for lamp in scene._lamps:
			if is_instance_valid(lamp):
				assert_lte(lamp.light_scale, 1.0001, "no lamp ever shines brighter than at rest")
				worst[0] = maxf(worst[0], absf(lamp.light_scale - last[0]))
				last[0] = lamp.light_scale
				break
		for cloud in scene._steam:
			worst[1] = maxf(worst[1], absf(cloud.modulate.a - last[1]))
			last[1] = cloud.modulate.a
			break
		return WorldState.has_flag("plant.letgo")
	assert_true(await _told(scene, through))
	assert_lt(worst[0], 0.05, "the lamps change by small steps")
	assert_lt(worst[1], 0.05, "and so does the steam")


func test_the_course_is_as_long_with_more_time_and_a_slower_pace() -> void:
	Settings.set_value("access.timing", 2, false)
	Settings.set_value("access.encounter_speed", 2, false)
	var scene := await _hall()
	await _put(scene, AWAY)
	var through := func() -> bool: return WorldState.has_flag("plant.letgo")
	assert_true(await _told(scene, through))
	assert_almost_eq(scene._letgo.elapsed, LetGo.seconds(), 0.1, "waiting is no skill")


# --- The potato ---------------------------------------------------------------------------------


func test_a_potato_lies_by_the_pipe_only_after_the_letting_go() -> void:
	var scene := await _hall()
	assert_null(_potato(scene), "nothing before")
	await _let_go(scene)
	assert_not_null(_potato(scene), "a potato has rolled out of the pipe")


func test_the_potato_is_taken_once_and_begins_its_quest() -> void:
	var scene := await _hall(["plant.letgo"])
	var potato := _potato(scene)
	assert_not_null(potato)
	assert_false(WorldState.has_item("item_potato"))
	potato._on_interacted(scene.player)
	assert_true(WorldState.has_item("item_potato"))
	assert_true(WorldState.has_flag("plant.potato_taken"))
	assert_true(WorldState.is_quest_active(POTATO_QUEST))
	assert_eq(WorldState.quest_stage(POTATO_QUEST), "show")
	await wait_physics_frames(2)
	assert_null(_potato(scene), "and it is gone from the floor")


func test_the_quest_is_done_when_the_keeper_has_entered_it() -> void:
	var scene := await _hall(["plant.letgo", "plant.potato_taken"])
	assert_eq(WorldState.quest_stage(POTATO_QUEST), "show", "caught up for a loaded game")
	WorldState.set_flag("plant.potato_entered")
	await wait_physics_frames(2)
	assert_false(WorldState.is_quest_active(POTATO_QUEST))
	assert_eq(scene._letgo.state, LetGo.State.DONE)


func test_a_potato_already_taken_does_not_lie_there_again() -> void:
	var scene := await _hall(["plant.letgo", "plant.potato_taken"])
	assert_null(_potato(scene))


# --- Loading ------------------------------------------------------------------------------------


func test_a_game_loaded_after_the_letting_go_finds_the_hall_as_it_stood() -> void:
	WorldState.set_facet("trust")
	var scene := await _hall(["plant.letgo", "plant.defect", "melody.machine_count"])
	assert_eq(scene._letgo.state, LetGo.State.DONE, "nothing is told twice")
	assert_eq(_down(scene), 12, "the levers stand as they fell")
	assert_lt(scene._trouble, 0.01, "the dials are calm from the first picture")
	assert_eq(_lamps(scene), [5, 1])
	assert_eq(WorldState.quest_stage(QUEST), "letgo")
	await _put(scene, AWAY)
	await wait_physics_frames(300)
	assert_true(_quiet(scene), "and nobody begins to speak")


func test_a_game_loaded_in_the_middle_of_it_begins_the_course_again_with_the_lamp_out() -> void:
	var scene := await _hall(["plant.defect"])
	assert_eq(_lamps(scene), [5, 1], "the lamp that went out is out")
	assert_eq(_down(scene), 0, "the levers stand up as the load left them")
	await _let_go(scene)
	assert_eq(_down(scene), 12)
	assert_true(WorldState.has_facet("trust"))
	assert_eq(_lamps(scene), [5, 1], "still one dark lamp, not two")
