extends GutTest
## Act IV, segment S7 in the scene of the city: Mira stands in the crowd until she says she goes to
## the gate, and then she stands at the gate (never in two places) until the quarrel has sent her
## ahead (whichever way it ended). At the gate the Richter speaks, once, as soon as the player comes
## near and before Mira can be talked to; nothing starts while a line is up. The lines are tested in
## test_akt4_streit and test_akt4_konzert.

const STADT := preload("res://world/levels/akt4/stadt.tscn")
const STREIT := "res://content/dialogue/akt4/streit.dialogue"
const QUEST := "main_city_way"
const GATE_MIRA := Vector2i(80, 43)
const CROWD_MIRA := Vector2i(61, 28)
const NEAR_THE_GATE := Vector2i(81, 41)
const FAR_FROM_THE_GATE := Vector2i(64, 28)
const PARTED: PackedStringArray = [
	"city.mira_parted_boundary", "city.mira_parted_joined", "city.mira_parted_silent"
]


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
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


## The walk is at the night after the concert: Mira has said she goes to the gate (or has not yet).
func _night(at_the_gate := true) -> void:
	WorldState.start_quest(QUEST)
	for stage: String in ["town", "help", "list", "evening"]:
		assert_true(WorldState.advance_quest(QUEST, stage), "to " + stage)
	WorldState.set_flag("beat.city_concert")
	if at_the_gate:
		assert_true(WorldState.advance_quest(QUEST, "night"))
		WorldState.set_flag("city.mira_gate")


func _scene() -> StadtScene:
	var scene: StadtScene = STADT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _miras(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is NpcWalker
				and not node.is_queued_for_deletion()
				and node.sheet.resource_path.contains("sheet_mira_look")
			)
	)


func _cell(scene: GameScene, node: Node) -> Vector2i:
	return scene.map.world_to_cell((node as Node2D).global_position)


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


func _asked(scene: GameScene) -> bool:
	var box := scene.dialogue_box
	return box.is_open() and box.line != null and box._responses.visible


## Moves the lines on, taking `answer` when a group is up, until the box is shut.
func _read_through(scene: GameScene, answer := "") -> void:
	var watch := func() -> bool:
		if _asked(scene):
			BoxAnswers.pick(scene.dialogue_box, answer)
		elif scene.dialogue_box.is_open():
			_confirm()
		return not scene.dialogue_box.is_open()
	var done: bool = await wait_until(watch, 60.0)
	assert_true(done, "the box closed")
	await wait_physics_frames(3)


# --- Where Mira stands ------------------------------------------------------------------------


func test_in_the_crowd_until_she_says_she_goes_to_the_gate() -> void:
	_night(false)
	var scene := await _scene()
	var crowd := _miras(scene)
	assert_eq(crowd.size(), 1)
	assert_eq(_cell(scene, crowd[0]), CROWD_MIRA, "listening at the edge of the crowd")
	assert_eq((crowd[0] as NpcWalker).cue, "con_mira")
	WorldState.set_flag("city.mira_gate")
	await wait_physics_frames(3)
	var gate := _miras(scene)
	assert_eq(gate.size(), 1, "never in two places")
	assert_eq(_cell(scene, gate[0]), GATE_MIRA)
	assert_eq((gate[0] as NpcWalker).cue, "mira_gate")


func test_the_night_looks_as_the_evening_and_the_concert_is_not_played_again() -> void:
	_night()
	var scene := await _scene()
	assert_true(StadtScene.in_evening(), "the night is the evening's stage")
	assert_true(WorldState.has_flag("city.evening"))
	assert_ne(scene.world_tint, Color.WHITE)
	assert_null(scene.get_node_or_null("Concert"))
	assert_false(scene.player.is_locked())


func test_she_is_gone_once_the_quarrel_has_sent_her_ahead_whichever_way_it_ended() -> void:
	for flag: String in PARTED:
		WorldState.new_game()
		_night()
		var scene := await _scene()
		assert_eq(_miras(scene).size(), 1, "she waits at the gate")
		WorldState.set_flag(flag)
		await wait_physics_frames(3)
		assert_eq(_miras(scene).size(), 0, "ahead of her, for good: " + flag)
		assert_true(Beat.reached("stadt_tor"), "the beat that saves it")
		scene.free()


func test_after_the_night_she_is_not_back_on_the_square_whichever_way_it_ended() -> void:
	for flag: String in PARTED:
		for stage: String in ["night", "home", "done"]:
			WorldState.new_game()
			_night()
			WorldState.set_flag(flag)
			for next: String in ["home", "done"]:
				if stage != "night" and WorldState.quest_stage(QUEST) != stage:
					assert_true(WorldState.advance_quest(QUEST, next))
			var scene := await _scene()
			assert_eq(StadtScene.in_evening(), stage == "night", "the day is back from home on")
			assert_eq(_miras(scene).size(), 0, "ahead of her for good: %s, %s" % [flag, stage])
			scene.free()
	# and the day before the quarrel has her at the fountain, as it had
	WorldState.new_game()
	WorldState.start_quest(QUEST)
	var day := await _scene()
	assert_eq(_miras(day).size(), 1, "at the fountain until she has gone")


# --- The Richter -------------------------------------------------------------------------------


func test_he_speaks_once_when_she_comes_near_and_before_mira_can_be_talked_to() -> void:
	_night()
	var scene := await _scene()
	scene.player.teleport(scene.map.cell_to_world(FAR_FROM_THE_GATE))
	await wait_physics_frames(30)
	assert_false(scene.dialogue_box.is_open(), "not from afar")
	assert_false(WorldState.has_flag("city.richter_met"))
	scene.player.teleport(scene.map.cell_to_world(NEAR_THE_GATE))
	var up: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 20.0)
	assert_true(up, "he clears his throat")
	assert_true(scene.player.is_locked(), "a cutscene: she stands still")
	await _read_through(scene)
	assert_true(WorldState.has_flag("city.richter_met"))
	var free: bool = await wait_until(func() -> bool: return not scene.player.is_locked(), 10.0)
	assert_true(free, "and she is free again after a breath, Mira is still there")
	assert_true(Beat.reached("stadt_richter"))
	assert_eq(_miras(scene).size(), 1)
	# once: standing there longer, or coming back, brings no second sitting
	await wait_physics_frames(40)
	assert_false(scene.dialogue_box.is_open())


func test_he_does_not_speak_before_mira_has_said_she_goes_to_the_gate() -> void:
	_night(false)
	var scene := await _scene()
	scene.player.teleport(scene.map.cell_to_world(NEAR_THE_GATE))
	await wait_physics_frames(60)
	assert_false(scene.dialogue_box.is_open())
	assert_false(WorldState.has_flag("city.richter_met"))


func test_he_does_not_start_while_a_line_is_up() -> void:
	_night()
	var scene := await _scene()
	await wait_until(func() -> bool: return scene.quiet(), 10.0)
	Talk.present(scene, STREIT, "gate_leaves", scene.player)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	scene.player.teleport(scene.map.cell_to_world(NEAR_THE_GATE))
	await wait_physics_frames(30)
	assert_false(WorldState.has_flag("city.richter_met"), "he waits for the line")
	await _read_through(scene)
	var up: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 20.0)
	assert_true(up, "and speaks after it")


# --- The quarrel in the real box ---------------------------------------------------------------


func test_the_quarrel_in_the_box_sets_what_the_answer_says_and_mira_walks_ahead() -> void:
	_night()
	WorldState.set_flag("city.richter_met")
	var scene := await _scene()
	scene.player.teleport(scene.map.cell_to_world(NEAR_THE_GATE))
	await wait_until(func() -> bool: return scene.quiet(), 10.0)
	Talk.present(scene, STREIT, "mira_gate", scene.player)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	await _read_through(scene, "Dann komme ich mit.")
	assert_true(WorldState.has_flag("city.mira_parted_joined"))
	assert_eq(WorldState.relationship_state("mira"), "close")
	assert_eq(_miras(scene).size(), 0, "she is through the gate")
	assert_true(Beat.reached("stadt_tor"))
	assert_eq(WorldState.quest_stage(QUEST), "night", "the way home is S8")


func test_a_game_loaded_at_night_has_her_at_the_gate_until_she_has_gone() -> void:
	_night()
	var scene := await _scene()
	assert_eq(_cell(scene, _miras(scene)[0]), GATE_MIRA)
	scene.free()
	WorldState.set_flag("city.mira_parted_silent")
	var again := await _scene()
	assert_eq(_miras(again).size(), 0)
