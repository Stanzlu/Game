extends GutTest
## Act VI, segment R7: the way out (docs/akt6/REGIONSBRIEFE.md, O3, O4, O19, O20). Whoever came
## back through the gap leaves Elysia by the rift at the edge of the picture, and gently: it asks
## nothing, nothing stutters or shakes, the music runs out, the corner lets her go piece by piece,
## and what she carries stays with her. The walk goes home from wherever it stood in Elysia; the
## gap of light in the valley is gone, and the valley says what stands there once. The first
## crossing (Act I) stays the fall it was. What the cues say is tested in test_akt6_ausgang.

const TAL := preload("res://world/levels/slice/tal.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const QUEST := "main_return_way"
const GAP_CELL := Vector2i(59, 9)
var _polls := 0


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


## The state after the quiet house and the way back into Elysia: the walk stands in `stage`.
func _back_in_elysia(stage := "elysia") -> void:
	for flag: String in [
		"chapter.act5",
		"valley.mira_gone",
		"valley.bridge_fixed",
		"valley.mira_leaving",
		"valley.mira_left",
		"valley.rift_light",
		"elysia.woke",
		"elysia.returned",
		"elysia.rift_open",
		"elysia.loops"
	]:
		WorldState.set_flag(flag)
	for beat: String in ["act6_morning", "act6_mira", "act6_quiet", "act6_return"]:
		Beat.mark(beat)
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_day_preset("morgen")
	WorldState.start_quest(QUEST)
	for next: String in ["pull", "elysia", "inn", "stand"]:
		WorldState.advance_quest(QUEST, next)
		if next == stage:
			break


func _elysia() -> ElysiaScene:
	var scene: ElysiaScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


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


## Starts the way out (the rift's touch) with short pauses and no scene change.
func _leave(scene: GameScene) -> RiftSequence:
	var sequence := RiftSequence.play(scene, "tal", false)
	sequence.time_scale = 0.02
	sequence.travel = false
	return sequence


## True while any question (a ConfirmMenu: the pause menu keeps one of its own, closed) is up.
func _question_up(scene: GameScene) -> bool:
	for node in scene.find_children("*", "ConfirmMenu", true, false):
		if (node as ConfirmMenu).is_open():
			return true
	return false


func _gap(scene: GameScene) -> Rift:
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node is Rift:
			return node as Rift
	return null


# --- The way out ------------------------------------------------------------------------------


func test_the_way_out_is_gentle_it_asks_nothing_and_the_corner_goes_piece_by_piece() -> void:
	_back_in_elysia()
	var scene := await _elysia()
	AudioDirector.play_music("elysia", 0.0)
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	var sequence := _leave(scene)
	var done := [false]
	sequence.finished.connect(func() -> void: done[0] = true)
	sequence.run()
	var spoken := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(spoken, 5.0), "the lines of the step are told first")
	assert_eq(scene.dialogue_box.cue, "exit_step")
	assert_false(_question_up(scene), "it asks nothing")
	assert_false(get_tree().paused, "and nothing stands still for a question")
	assert_true(
		MenuLayer.can_pause(get_tree()), "a conversation may be paused, as in every cutscene"
	)
	assert_eq(scene.view._shake_time, 0.0, "nothing shakes")
	var closed := func() -> bool: return not scene.dialogue_box.is_open()
	assert_true(await _told(scene, closed), "the lines are told")
	assert_false(MenuLayer.can_pause(get_tree()), "the rest of the way out holds menus closed")
	assert_true(await _told(scene, func() -> bool: return done[0]), "and then it is over")
	assert_eq(scene.view._shake_time, 0.0, "not once")
	assert_eq(scene.view.viewport.render_target_update_mode, SubViewport.UPDATE_WHEN_VISIBLE)
	assert_eq(
		scene.hud.vanished().size(), Hud.VANISH_ORDER.size(), "every piece of the corner went"
	)
	assert_eq(AudioDirector.current, "", "the music ran out")
	assert_eq(WorldState.ui_mode(), GameState.UiMode.REAL, "the interface is the real world's")
	assert_eq(WorldState.state.elysia.xp, xp, "the experience stands where it stood")
	assert_eq(WorldState.state.elysia.gold, gold, "and the gold")
	assert_true(ScreenFade.is_covered(), "ends in black, the valley fades in")
	assert_false(SaveSystem.blockers().has(String(sequence.key)), "saving is free again")


func test_touching_the_rift_in_elysia_starts_the_gentle_way_and_asks_nothing() -> void:
	_back_in_elysia()
	var scene := await _elysia()
	var rift: Rift = null
	for node in scene.map.entities.get_children():
		if node is Rift and (node as Rift).mode == "":
			rift = node as Rift
	assert_not_null(rift, "the rift at the edge of the picture")
	(rift.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var sequence := scene.get_node_or_null("RiftSequence") as RiftSequence
	assert_not_null(sequence, "touching it starts the way out")
	sequence.time_scale = 0.02
	sequence.travel = false
	var done := [false]
	sequence.finished.connect(func() -> void: done[0] = true)
	assert_true(await _told(scene, func() -> bool: return done[0]))
	assert_true(WorldState.has_flag("elysia.left"))
	assert_false(_question_up(scene), "no question")


func test_a_scene_freed_in_the_middle_of_the_lines_leaves_nothing_held() -> void:
	_back_in_elysia()
	var scene := await _elysia()
	var sequence := _leave(scene)
	sequence.run()
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0), "the lines are up")
	scene.queue_free()
	await wait_physics_frames(5)
	assert_true(SaveSystem.blockers().is_empty(), "saving is free again")
	assert_false(MenuLayer.any_open(get_tree()), "no menu is held closed")
	assert_false(WorldState.has_flag("elysia.left"), "she did not leave")
	assert_eq(WorldState.ui_mode(), GameState.UiMode.ELYSIA, "and the interface is still Elysia's")


func test_what_she_carries_stays_with_her_the_soup_too() -> void:
	_back_in_elysia()
	for item: String in ["item_stone", "item_seed", "item_soup", "curiosity_feather"]:
		WorldState.add_item(item, 1, false)
	var scene := await _elysia()
	var sequence := _leave(scene)
	var done := [false]
	sequence.finished.connect(func() -> void: done[0] = true)
	sequence.run()
	assert_true(await _told(scene, func() -> bool: return done[0]))
	for item: String in ["item_stone", "item_seed", "item_soup", "curiosity_feather"]:
		assert_true(WorldState.has_item(item), "%s stays" % item)
	assert_true(WorldState.has_flag("elysia.rift_crossed"))


func test_the_walk_goes_home_from_wherever_it_stood_in_elysia() -> void:
	for stage: String in ["elysia", "inn", "stand"]:
		WorldState.new_game()
		_back_in_elysia(stage)
		assert_eq(WorldState.quest_stage(QUEST), stage)
		var scene := await _elysia()
		var sequence := _leave(scene)
		var done := [false]
		sequence.finished.connect(func() -> void: done[0] = true)
		sequence.run()
		assert_true(await _told(scene, func() -> bool: return done[0]), stage)
		assert_eq(WorldState.quest_stage(QUEST), "home", "from %s" % stage)
		assert_true(WorldState.has_flag("elysia.left"))
		scene.queue_free()
		await wait_physics_frames(2)
		ScreenFade.fade_in(0.0)


func test_a_walk_that_is_not_in_elysia_is_not_moved() -> void:
	_back_in_elysia("pull")
	var scene := await _elysia()
	assert_eq(WorldState.quest_stage(QUEST), "pull")
	var sequence := _leave(scene)
	var done := [false]
	sequence.finished.connect(func() -> void: done[0] = true)
	sequence.run()
	assert_true(await _told(scene, func() -> bool: return done[0]))
	assert_eq(WorldState.quest_stage(QUEST), "pull", "the stage waits for its own way")
	assert_true(WorldState.has_flag("elysia.left"), "but she has left")
	assert_push_error_count(0)


func test_the_first_crossing_stays_the_fall_it_was() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.rift_open")
	WorldState.add_item("item_compliment", 1, false)
	var scene := await _elysia()
	var sequence := _leave(scene)
	sequence.run()
	await wait_for_signal(sequence.finished, 5.0)
	assert_false(WorldState.has_flag("elysia.left"), "this is not the way out")
	assert_eq(WorldState.state.inventory.size(), 2, "she keeps the two")
	assert_true(WorldState.has_item("item_stone") and WorldState.has_item("item_seed"))
	assert_false(scene.dialogue_box.is_open(), "no lines")


# --- The valley -------------------------------------------------------------------------------


func test_the_gap_of_light_is_gone_once_she_has_left() -> void:
	_back_in_elysia()
	var before := await _valley()
	assert_not_null(_gap(before), "the gap stands while she has not left")
	before.queue_free()
	await wait_physics_frames(2)
	WorldState.set_flag("elysia.left")
	var after := await _valley()
	assert_null(_gap(after), "nothing stands where the light stood")


func test_the_valley_says_what_stands_where_the_light_stood_once() -> void:
	_back_in_elysia("inn")
	ReturnBeat.leave_elysia()
	assert_true(ReturnBeat.exit_due())
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var scene := await _valley()
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 20.0), "after the picture is up, the lines come")
	assert_eq(scene.dialogue_box.cue, "exit_valley")
	var told := func() -> bool: return Beat.reached(ReturnBeat.EXIT_BEAT)
	assert_true(await _told(scene, told), "and the beat is marked")
	assert_false(ReturnBeat.exit_due())
	assert_eq(WorldState.quest_stage(QUEST), "home")
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _valley()
	await wait_physics_frames(60)
	assert_false(again.dialogue_box.is_open(), "never twice")


func test_the_exit_is_not_due_before_she_has_left_and_not_after_it_was_told() -> void:
	_back_in_elysia()
	assert_false(ReturnBeat.exit_due(), "she is still in Elysia")
	ReturnBeat.leave_elysia()
	assert_true(ReturnBeat.exit_due())
	Beat.mark(ReturnBeat.EXIT_BEAT)
	assert_false(ReturnBeat.exit_due())
	ReturnBeat.leave_elysia()
	assert_eq(WorldState.quest_stage(QUEST), "home", "idempotent")


func test_the_walk_has_its_last_stage_with_its_journal_line() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_eq(quest.stage("stand").next, PackedStringArray(["home"]))
	assert_eq(quest.stage("home").next, PackedStringArray(["done"]), "the homecoming follows (R8)")
	var line := tr("QUEST_MAIN_RETURN_WAY_HOME")
	assert_ne(line, "QUEST_MAIN_RETURN_WAY_HOME")
	for word: String in ["Leere", "Gefühl", "heilen", "loslassen", "Elysia"]:
		assert_false(line.contains(word), "no %s" % word)
	for digit: String in "0123456789":
		assert_false(line.contains(digit), "numbers are written out")
