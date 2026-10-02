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
	await wait_seconds(4.5)
	assert_false(encounter.model.is_resolved(), "running does not resolve")
	assert_gt(encounter.player.global_position.x, start_x + 300.0, "player ran far")
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


func test_segments_are_recycled_while_running() -> void:
	var encounter: AntreiberEncounter = SCENE.instantiate()
	add_child_autofree(encounter)
	await wait_physics_frames(3)
	Input.action_press(&"move_right")
	Input.action_press(&"sprint")
	await wait_seconds(5.0)
	var segments := encounter.get_node("GameView/WorldViewport/World/Segments")
	assert_between(segments.get_child_count(), 3, 7, "a bounded window of segments")
