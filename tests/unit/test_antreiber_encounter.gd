extends GutTest
## Plays the encounter scene with real physics: running never reaches the goal,
## stopping after the race resolves it and puts the goal right next to the player.

const SCENE := preload("res://encounters/antreiber/antreiber_encounter.tscn")


func after_each() -> void:
	for action: StringName in [&"move_right", &"sprint"]:
		Input.action_release(action)
	get_tree().paused = false


func test_running_never_reaches_the_goal_but_stopping_resolves() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	encounter.stillness_seconds = 1.0
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	var start_x := encounter.player.global_position.x
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await wait_seconds(9.0)
	assert_false(encounter.model.is_resolved(), "running does not resolve")
	assert_gt(
		encounter.player.global_position.x,
		start_x + AntreiberModel.ENGAGE_DISTANCE,
		"player ran far"
	)
	assert_gt(
		encounter.flag.global_position.x, encounter.player.global_position.x + 60.0, "goal ahead"
	)
	assert_true(encounter.model.is_engaged())
	assert_lt(encounter.player.speed_scale, 1.0, "fatigue slows the player")
	Input.action_release(&"sprint")
	Input.action_release(&"move_right")
	await wait_seconds(1.8)
	assert_true(encounter.model.is_resolved(), "standing still resolved it")
	assert_eq(encounter.player.speed_scale, 1.0, "fatigue lifted")
	await wait_seconds(1.5)
	var gap := encounter.flag.global_position.x - encounter.player.global_position.x
	assert_between(gap, 10.0, 50.0, "goal is right beside the player")
	assert_true(encounter.antreiber.silent, "Antreiber fell silent")


func test_a_long_sprint_stays_a_run_and_tires_all_the_way() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await wait_seconds(2.0)
	watch_signals(encounter.player)
	await wait_seconds(13.0)
	# fatigue slows the run below the speed of a walk (144 * (1 - 0.45 * 0.9) < 96); the
	# state followed the measured speed and flickered between walk and run 20 times a second
	assert_lte(get_signal_emit_count(encounter.player, "state_changed"), 2, "no flicker")
	assert_gte(encounter.model.fatigue, 0.85, "the sprint kept counting")
	assert_eq(encounter.player.state, Player.State.RUN)


func test_stopping_ends_the_music_with_a_fade_not_a_tape_stop() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	encounter.stillness_seconds = 1.0
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	assert_eq(AudioDirector.current, "antreiber", "the chase has its music")
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await wait_seconds(9.0)
	assert_eq(AudioDirector.current, "antreiber", "still playing while running")
	Input.action_release(&"sprint")
	Input.action_release(&"move_right")
	await wait_seconds(1.8)
	assert_true(encounter.model.is_resolved())
	assert_eq(AudioDirector.current, "", "the music ended with the stopping")


func test_segments_are_recycled_while_running() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await wait_seconds(5.0)
	var segments := encounter.get_node("GameView/WorldViewport/World/Segments")
	assert_between(encounter._segments.size(), 3, 7, "a bounded window of segments")
	assert_lte(
		segments.get_child_count(),
		7 + 2 * AntreiberEncounter.POOL_SIZE,
		"pieces that left the window are reused, not piled up"
	)


func test_a_stop_right_at_the_start_is_only_a_pause() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	encounter.stillness_seconds = 1.0
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	Input.action_press(&"move_right")
	await wait_seconds(2.0)
	Input.action_release(&"move_right")
	await wait_seconds(3.0)
	assert_false(encounter.model.is_resolved(), "the race has not begun yet")
	assert_eq(
		encounter.model.mood(0.0, encounter.player.tuning.walk_speed),
		AntreiberModel.Mood.PUZZLED_EARLY
	)


func test_parked_path_pieces_are_hidden_and_idle() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	var parked := 0
	for pieces: Array in encounter._pool.values():
		for segment: MapView in pieces:
			parked += 1
			assert_false(segment.visible, "a parked piece is not drawn")
			assert_eq(segment.process_mode, Node.PROCESS_MODE_DISABLED, "nor processed")
	assert_gt(parked, 0)
	for segment: MapView in encounter._segments.values():
		assert_true(segment.visible, "pieces in use are visible")
		assert_ne(segment.process_mode, Node.PROCESS_MODE_DISABLED)
