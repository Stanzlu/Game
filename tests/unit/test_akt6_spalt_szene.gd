extends GutTest
## Act VI, segment R2: the gap of light and the way back into Elysia (docs/akt6/REGIONSBRIEFE.md,
## O3, O4, O5, O19). After the quiet house (`valley.rift_light`) a warm gap stands where she
## arrived in the rain; touching it shows it, asks, and going through (`ElysiaReturn`) makes the
## interface Elysia's again; Elysia builds the corner of the picture up on arrival and says what
## is there.
## What the cues say is tested in test_akt6_spalt.

const TAL := preload("res://world/levels/slice/tal.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const QUEST := "main_return_way"
const GAP_CELL := Vector2i(59, 9)
const RETURN_CELL := Vector2i(59, 30)
var _polls := 0


func before_each() -> void:
	# the question pauses the tree (as the shelf does): the test must go on polling while it is open
	process_mode = Node.PROCESS_MODE_ALWAYS
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


## The state after the quiet house: the mountains done, the day told, Mira gone, the light seen.
func _the_light_stands() -> void:
	for flag: String in [
		"chapter.act5",
		"valley.mira_gone",
		"valley.bridge_fixed",
		"valley.mira_leaving",
		"valley.mira_left",
		"valley.rift_light"
	]:
		WorldState.set_flag(flag)
	Beat.mark("act6_morning")
	Beat.mark("act6_mira")
	Beat.mark("act6_quiet")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "pull")
	WorldState.set_day_preset("morgen")


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _elysia() -> ElysiaScene:
	var scene: ElysiaScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene) -> Array[Node]:
	var list: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			list.append(node)
	return list


func _gap(scene: GameScene) -> Rift:
	for node in _alive(scene):
		if node is Rift and (node as Rift).mode == "return":
			return node as Rift
	return null


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


## Starts the way back at the gap and tells the look; returns the sequence and the question.
func _ask(scene: GameScene, gap: Rift) -> ElysiaReturn:
	var sequence := ElysiaReturn.start(gap, scene.player)
	sequence.time_scale = 0.02
	sequence.travel = false
	var asked := func() -> bool: return scene.get_node_or_null("ConfirmReturn") != null
	assert_true(await _told(scene, asked), "the look is told and the question is asked")
	return sequence


# --- The gap -----------------------------------------------------------------------------------


func test_the_gap_stands_in_the_valley_only_once_the_house_has_shown_its_light() -> void:
	var plain := await _valley()
	assert_null(_gap(plain), "no gap in the other acts")
	plain.queue_free()
	await wait_physics_frames(2)
	_the_light_stands()
	var scene := await _valley()
	var gap := _gap(scene)
	assert_not_null(gap, "the gap")
	if gap != null:
		assert_eq(scene.map.world_to_cell(gap.global_position), GAP_CELL)
		assert_eq(gap.target, "elysia")
		assert_eq(gap.spawn, "return")
		assert_gt(gap.tint.r, gap.tint.b, "warm and golden, not the cool blue of the first rift")


func test_the_gap_appears_while_the_scene_runs_when_the_light_has_been_seen() -> void:
	for flag: String in ["chapter.act5", "valley.mira_gone", "valley.bridge_fixed"]:
		WorldState.set_flag(flag)
	Beat.mark("act6_morning")
	var scene := await _valley()
	assert_null(_gap(scene))
	WorldState.set_flag("valley.rift_light")
	await wait_physics_frames(3)
	assert_not_null(_gap(scene), "the map reads the flag live")


func test_the_old_rift_of_elysia_is_untouched() -> void:
	var scene := await _elysia()
	WorldState.set_flag("elysia.rift_open")
	await wait_physics_frames(3)
	var found: Rift = null
	for node in _alive(scene):
		if node is Rift:
			found = node as Rift
	assert_not_null(found, "the rift at the edge of Elysia")
	if found != null:
		assert_eq(found.mode, "", "it leads out as it always did")
		assert_eq(found.target, "tal")
		assert_eq(found.tint, Color.WHITE, "in its own cool colour")


# --- Going through -------------------------------------------------------------------------------


func test_yes_makes_the_interface_elysias_and_takes_nothing_from_her() -> void:
	_the_light_stands()
	WorldState.add_item("item_stone")
	WorldState.add_item("item_seed")
	WorldState.add_item("curiosity_feather")
	WorldState.add_xp(1234)
	var level := WorldState.state.elysia.level()
	var xp := WorldState.state.elysia.xp
	var scene := await _valley()
	var gap := _gap(scene)
	var sequence := await _ask(scene, gap)
	assert_false(WorldState.has_flag("elysia.returned"), "nothing until she says yes")
	assert_eq(WorldState.ui_mode(), GameState.UiMode.REAL)
	(scene.get_node("ConfirmReturn") as ConfirmMenu).answered.emit(true)
	var crossed := [false]
	sequence.finished.connect(func() -> void: crossed[0] = true)
	var over := func() -> bool: return crossed[0]
	assert_true(await _told(scene, over, 30.0), "the step, the light, the black")
	assert_true(WorldState.has_flag("elysia.returned"))
	assert_eq(WorldState.ui_mode(), GameState.UiMode.ELYSIA)
	assert_eq(WorldState.state.elysia.xp, xp, "the experience stands where she left it")
	assert_eq(WorldState.state.elysia.level(), level, "and the level with it")
	assert_true(WorldState.has_item("curiosity_feather"), "nothing of what she carries is taken")
	assert_true(WorldState.has_item("item_stone") and WorldState.has_item("item_seed"))
	assert_true(ScreenFade.is_covered(), "ends in black: Elysia fades in")
	assert_false(SaveSystem.blockers().has(String(sequence.key)), "saving is free again")
	assert_false(SaveSystem.has_pending_autosave(), "no save writes the new mode on the valley")


func test_no_changes_nothing_and_the_gap_can_be_touched_again() -> void:
	_the_light_stands()
	var scene := await _valley()
	var gap := _gap(scene)
	var sequence := await _ask(scene, gap)
	var key := String(sequence.key)
	(scene.get_node("ConfirmReturn") as ConfirmMenu).answered.emit(false)
	await wait_physics_frames(5)
	assert_false(WorldState.has_flag("elysia.returned"))
	assert_eq(WorldState.ui_mode(), GameState.UiMode.REAL)
	assert_false(scene.player.is_locked(), "she is free")
	assert_true((gap.get_node("Interactable") as Interactable).enabled, "and can touch it again")
	assert_false(SaveSystem.blockers().has(key))
	assert_eq(WorldState.quest_stage(QUEST), "pull", "the walk stays where it was: nothing pulls")
	assert_false(get_tree().paused)


func test_the_question_is_a_real_question_and_the_game_waits_for_the_answer() -> void:
	_the_light_stands()
	var scene := await _valley()
	var sequence := await _ask(scene, _gap(scene))
	var menu := scene.get_node("ConfirmReturn") as ConfirmMenu
	assert_eq(menu.question_key, "RETURN_GAP_ASK")
	assert_eq(menu.yes_key, "RETURN_GAP_YES")
	assert_eq(menu.no_key, "RETURN_GAP_NO")
	for key: String in ["RETURN_GAP_ASK", "RETURN_GAP_YES", "RETURN_GAP_NO"]:
		assert_ne(tr(key), key, key)
	assert_true(get_tree().paused, "the game waits for the answer")
	assert_true(MenuLayer.any_open(get_tree()))
	menu.answered.emit(false)
	await wait_physics_frames(3)
	if is_instance_valid(sequence):
		sequence.queue_free()


func _tap(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)


func test_the_real_question_answers_yes_to_the_keys_and_no_to_back() -> void:
	_the_light_stands()
	var scene := await _valley()
	var sequence := await _ask(scene, _gap(scene))
	var crossed := [false]
	sequence.finished.connect(func() -> void: crossed[0] = true)
	await wait_seconds(0.4)
	_tap(&"ui_up")
	await wait_seconds(0.2)
	_tap(&"ui_accept")
	var over := func() -> bool: return crossed[0]
	assert_true(await _told(scene, over, 30.0), "the keys went through the menu")
	assert_true(WorldState.has_flag("elysia.returned"), "yes: the safe answer is one key away")
	# and back is no: the same question, the other way
	WorldState.clear_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	scene.queue_free()
	await wait_physics_frames(3)
	ScreenFade.fade_in(0.0)
	var again := await _valley()
	var second := await _ask(again, _gap(again))
	var key := String(second.key)
	await wait_seconds(0.4)
	_tap(&"cancel")
	await wait_physics_frames(5)
	assert_false(WorldState.has_flag("elysia.returned"), "back is no")
	assert_false(get_tree().paused, "the game goes on")
	assert_false(again.player.is_locked(), "she is free")
	assert_false(SaveSystem.blockers().has(key))


func test_there_is_one_way_back_at_a_time() -> void:
	_the_light_stands()
	var scene := await _valley()
	var first := ElysiaReturn.start(_gap(scene), scene.player)
	assert_not_null(first)
	assert_null(ElysiaReturn.start(_gap(scene), scene.player), "a second touch starts nothing")
	first.travel = false
	first.queue_free()
	await wait_physics_frames(2)


func test_the_pause_menu_stays_open_to_conversations_during_the_look() -> void:
	_the_light_stands()
	var scene := await _valley()
	var sequence := ElysiaReturn.start(_gap(scene), scene.player)
	sequence.travel = false
	var open := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(open, 10.0), "the look is up")
	assert_true(MenuLayer.can_pause(get_tree()), "text size and speed can be changed in it")
	sequence.queue_free()
	await wait_physics_frames(2)


func test_a_sequence_left_in_the_middle_never_keeps_saving_blocked() -> void:
	_the_light_stands()
	var scene := await _valley()
	var sequence := await _ask(scene, _gap(scene))
	(scene.get_node("ConfirmReturn") as ConfirmMenu).answered.emit(true)
	await wait_physics_frames(2)
	var key := String(sequence.key)
	assert_has(SaveSystem.blockers(), key)
	sequence.time_scale = 50.0
	sequence.queue_free()
	await wait_physics_frames(3)
	assert_false(SaveSystem.blockers().has(key), "leaving mid-sequence unblocks saving")


# --- The arrival ---------------------------------------------------------------------------------


func test_the_marker_puts_her_next_to_the_rift_of_elysia() -> void:
	WorldState.set_flag("elysia.woke")
	SceneTravel.pending_spawn = "return"
	var scene := await _elysia()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), RETURN_CELL)


func test_the_arrival_builds_the_corner_up_tells_the_garden_and_moves_the_walk_on() -> void:
	_the_light_stands()
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	var scene := await _elysia()
	assert_false(Beat.reached("act6_return"), "not before the lines have been told")
	var done := func() -> bool: return Beat.reached("act6_return")
	assert_true(await _told(scene, done), "the arrival runs to its end")
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage(QUEST), "elysia")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked(), "she is free in the garden")
	assert_false(Beat.reached("elysia_start"), "she does not wake up again")
	assert_eq(WorldState.ui_mode(), GameState.UiMode.ELYSIA)


func test_an_arrival_that_was_told_is_not_told_again_and_the_waking_is_never_replayed() -> void:
	_the_light_stands()
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	Beat.mark("act6_return")
	var scene := await _elysia()
	await wait_physics_frames(60)
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(Beat.reached("elysia_start"))
	assert_false(scene.player.is_locked())


func test_elysia_without_the_return_is_as_it_was() -> void:
	WorldState.set_flag("elysia.woke")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	var scene := await _elysia()
	await wait_physics_frames(60)
	assert_false(Beat.reached("act6_return"), "no arrival without the way through the gap")
	assert_false(WorldState.is_quest_started(QUEST), "no walk back")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked())


# --- The second crossing and the interface ------------------------------------------------------


func test_the_old_rift_does_not_take_what_she_has_gathered_since_the_return() -> void:
	_the_light_stands()
	WorldState.set_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.add_item("item_stone")
	WorldState.add_item("item_seed")
	WorldState.add_item("curiosity_feather")
	var scene := await _elysia()
	var sequence := RiftSequence.play(scene, "look_tal", false)
	sequence.time_scale = 0.02
	sequence.travel = false
	sequence.run()
	await wait_for_signal(sequence.finished, 5.0)
	assert_eq(WorldState.ui_mode(), GameState.UiMode.REAL, "out again")
	assert_true(WorldState.has_item("curiosity_feather"), "what she carries stays with her")


func test_the_interface_follows_the_world_she_is_in_and_the_hand_is_the_real_worlds() -> void:
	_the_light_stands()
	WorldState.set_flag("chapter.act4")
	var panel := PanelContainer.new()
	add_child_autofree(panel)
	UiSkin.attach(panel)
	await wait_physics_frames(1)
	assert_eq(panel.theme, UiSkin.PERSONAL_SKIN, "the Real world wears the hand")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	assert_eq(panel.theme, UiSkin.ELYSIA_SKIN, "Elysia her own")
	assert_false(UiSkin.personal(), "never the hand in Elysia")
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	assert_eq(panel.theme, UiSkin.PERSONAL_SKIN, "and back again")


func test_a_game_saved_in_elysia_after_the_return_loads_with_elysias_interface() -> void:
	_the_light_stands()
	WorldState.set_flag("elysia.returned")
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.state.player.map = "elysia"
	var text := SaveCodec.encode(WorldState.state)
	var result := SaveCodec.decode(text)
	assert_true(result.ok, result.error)
	assert_eq(result.state.ui_mode, GameState.UiMode.ELYSIA)
	assert_true(result.state.flags.has("elysia.returned"))
	assert_eq(result.state.player.map, "elysia")


func test_the_walk_has_the_stage_elysia_with_its_journal_and_the_gap_its_words() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_eq(quest.stage("pull").next, PackedStringArray(["elysia"]))
	assert_true(quest.stage("elysia").is_final(), "final until the inn (R5)")
	var line := tr("QUEST_MAIN_RETURN_WAY_ELYSIA")
	assert_ne(line, "QUEST_MAIN_RETURN_WAY_ELYSIA")
	for word: String in ["Leere", "Gefühl", "heilen", "loslassen"]:
		assert_false(line.contains(word), "no %s" % word)
	for digit: String in "0123456789":
		assert_false(line.contains(digit), "numbers are written out")
