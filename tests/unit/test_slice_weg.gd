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
	scene.model.distance_walked = 10000.0  # walked long enough for stopping to count
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
	await wait_seconds(2.0)
	assert_true(scene.model.is_resolved())
	assert_null(scene._wood, "no second bundle")
	await wait_seconds(4.0)
	assert_eq(SceneTravel.last_target, "tal", "back to the valley")
