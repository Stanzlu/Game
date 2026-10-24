extends GutTest
## Phase 4, the way to the woodshed (Antreiber, beat 5): the shed recedes, standing still
## brings it and the dry wood; taking the wood moves the shelter quest on and leads back.

const WEG := preload("res://encounters/antreiber/slice_antreiber.tscn")


func before_each() -> void:
	WorldState.new_game()
	SceneTravel.stay = true
	SceneTravel.last_target = ""
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	SceneTravel.stay = false
	SceneTravel.pending_spawn = ""
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func test_the_way_looks_like_the_valley() -> void:
	var scene: SliceAntreiber = WEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(scene.player.sheet.texture.resource_path.get_file(), "player.png")
	assert_eq(scene.antreiber.sheet, SliceAntreiber.SHEET)
	assert_eq((scene.flag as Decor).sprite_id, "tal/shed", "the goal is the woodshed")
	assert_true(Beat.reached("shed_path"))


func test_standing_still_brings_the_wood() -> void:
	var scene: SliceAntreiber = WEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.start_quest("main_valley_shelter")
	WorldState.advance_quest("main_valley_shelter", "house")
	WorldState.advance_quest("main_valley_shelter", "wood")
	scene.model.stillness_seconds = 0.2
	# walked long enough and hurried, so stopping counts
	scene.model.distance_walked = 10000.0
	scene.model.sprint_seconds = AntreiberModel.ENGAGE_SPRINT_SECONDS
	await wait_seconds(2.0)
	assert_true(scene.model.is_resolved())
	assert_not_null(scene._wood, "the wood lies on the path")
	scene._wood.call(&"_on_interacted", scene.player)
	assert_true(WorldState.has_item("item_dry_wood"))
	assert_eq(WorldState.quest_stage("main_valley_shelter"), "fire")
	assert_true(Beat.reached("wood"))


func test_a_second_walk_leads_back_without_wood() -> void:
	WorldState.set_flag("valley.wood_taken")
	var scene: SliceAntreiber = WEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	scene.model.stillness_seconds = 0.2
	scene.model.distance_walked = 10000.0
	scene.model.sprint_seconds = AntreiberModel.ENGAGE_SPRINT_SECONDS
	await wait_seconds(2.0)
	assert_true(scene.model.is_resolved())
	assert_null(scene._wood, "no second bundle")
	await wait_seconds(4.0)
	assert_eq(SceneTravel.last_target, "tal", "back to the valley")


func test_the_antreiber_has_a_shadow_and_reads_slowly() -> void:
	var scene: SliceAntreiber = WEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_not_null(scene.antreiber.get_node_or_null("Shadow"), "standing on the ground")
	assert_eq(AntreiberActor.bark_seconds("Gut."), AntreiberActor.BARK_SECONDS)
	var long_line := LineText.of("sl_antr_tired_4")
	assert_gt(AntreiberActor.bark_seconds(long_line), 4.5, "long lines stay longer")


func test_the_second_sign_is_like_the_first() -> void:
	var first := await _sign()
	assert_eq(first, LineText.of("sl_antr_sign_1"))
	assert_eq(await _sign(), LineText.of("sl_antr_sign_2"))


func _sign() -> String:
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(
		SliceAntreiber.DIALOGUE, "sign"
	)
	var text := line.text
	while line != null:
		line = await DialogueManager.get_next_dialogue_line(SliceAntreiber.DIALOGUE, line.next_id)
	return text


func test_the_shed_follows_the_walker_only_while_the_goal_recedes() -> void:
	var scene: SliceAntreiber = WEG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var before := scene.flag.global_position
	scene.player.teleport(scene.player.global_position + Vector2(300, 0))
	await wait_physics_frames(40)
	assert_gt(scene.flag.global_position.x, before.x + 100.0, "the encounter drags the goal along")
	# the performance test's stage: the bot walks both ways, the shed stands
	scene.goal_recedes = false
	var parked := scene.flag.global_position
	scene.player.teleport(scene.player.global_position + Vector2(-300, 0))
	await wait_physics_frames(40)
	assert_eq(scene.flag.global_position, parked)
