extends GutTest
## Act V, segment G5: the potato and the hall loaded (docs/akt5/REGIONSBRIEFE.md, O4, O13). A
## potato rolls out of the pipe after the letting go and is taken once; its quest ends when the
## keeper has entered it. A game loaded after the letting go finds the hall as it stood, one loaded
## in the middle begins the course again with the lamp that went out still out and tells nothing
## twice, and afterwards the levers are levers again whatever a lever is made to do. The course
## itself is tested in test_akt5_letgo_szene, the model in test_akt5_letgo.

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
	Settings.set_value("display.screen_shake", true, false)
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)
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


func test_a_game_loaded_after_the_lamp_went_out_does_not_tell_it_twice() -> void:
	var scene := await _hall(["plant.defect", "melody.machine_count"])
	var spoke: Array[bool] = []
	# the scene's own handler is connected first: if it spoke, it is speaking by now
	scene._letgo.defect.connect(func() -> void: spoke.append(scene._speaking))
	await _let_go(scene)
	assert_eq(spoke, [false], "the lamp event came, and nobody spoke at it")
	assert_eq(_lamps(scene), [5, 1], "one dark lamp, not two")
	assert_true(WorldState.has_flag("plant.letgo"), "and the end came as ever")


func test_after_the_letting_go_no_lever_brings_the_overload_back() -> void:
	var scene := await _hall()
	await _let_go(scene)
	await wait_physics_frames(300)
	scene.lever(5).pulled.emit(5)
	scene.lever(6).pulled.emit(6)
	assert_false(scene.lever(5).down, "they are levers again")
	await wait_physics_frames(300)
	assert_lt(scene._trouble, 0.01, "but the hall stays calm: the dials, the steam and the lamps")


func test_the_lamps_are_found_again_when_the_picture_of_one_changes() -> void:
	var scene := await _hall()
	assert_eq(scene._lamps.size(), 6)
	WorldState.set_flag("plant.defect")
	await wait_physics_frames(3)
	assert_eq(scene._lamps.size(), 5, "the dark one is no lamp that casts light")
	for lamp in scene._lamps:
		assert_true(is_instance_valid(lamp), "and none of them is gone")
		assert_false((lamp as Decor).is_queued_for_deletion())


func test_the_burst_comes_from_the_pipe_on_the_left_and_the_trembling_dial_goes_to_its_edge(
) -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var peak := func() -> bool: return scene._surge >= 0.99
	assert_true(await _told(scene, peak))
	var middle: float = scene.map.cell_to_world(Vector2i(16, 0)).x
	var left_scale := 0.0
	var right_scale := 0.0
	for cloud in scene._steam:
		if cloud.global_position.x < middle:
			left_scale = maxf(left_scale, cloud.scale.x)
		else:
			right_scale = maxf(right_scale, cloud.scale.x)
	assert_gt(
		left_scale, right_scale, "the pipe on the left bursts, the flange on the right does not"
	)
	var edge := 0
	for gauge in scene._gauges:
		if gauge.has_meta(&"cue") and gauge.get_meta(&"cue") == "gauges":
			edge += 1
			assert_gt(float(gauge.get(&"_trouble")), 0.99, "the dial that trembles is at its edge")
		else:
			assert_lt(float(gauge.get(&"_trouble")), 0.99, "the others wander with the levers")
	assert_eq(edge, 1)


func test_the_burst_lasts_while_he_speaks_about_it() -> void:
	var scene := await _hall()
	await _put(scene, AWAY)
	var mid := func() -> bool: return scene._surge_left > 0.0
	assert_true(await _told(scene, mid), "the burst begins with his words")
	assert_true(scene._speaking, "he has begun to speak")
	var held: float = scene._surge_left
	await wait_physics_frames(120)
	assert_true(scene._speaking, "and no one has moved the text on")
	assert_almost_eq(scene._surge_left, held, 0.0001, "it does not run down under his words")
