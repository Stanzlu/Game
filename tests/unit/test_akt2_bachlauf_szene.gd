extends GutTest
## Act II, segment B3, the scene of the Bachlauf: a big map with a track along the stream, a fog,
## the spots of the walk that appear one after the other (the float after the hook, the trap after
## the float), the trap that changes in the stream when it is freed, curiosities that leave the map
## when taken, one spot more for whoever looks closely, the beats of the walk and the door back to
## the valley. What is said is tested in test_akt2_bachlauf, the valley's side in
## test_akt2_bachlauf_tal.

const BACHLAUF := preload("res://world/levels/akt2/bachlauf.tscn")
const QUEST := "side_valley_trap"
const DOOR_CELL := Vector2i(35, 1)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> BachlaufScene:
	var scene: BachlaufScene = BACHLAUF.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


func _look(prop: Node) -> void:
	(prop.get_node("Interactable") as Interactable).interacted.emit(null)


func test_it_is_a_big_map_with_a_fog_and_the_stream_to_hear() -> void:
	var scene := await _scene()
	assert_true(SceneRegistry.has("bachlauf"))
	assert_lte(scene.map.data.width, 120, "class M, ADR-068")
	assert_lte(scene.map.data.height, 70)
	assert_gt(scene.map.data.width * scene.map.data.height, 4000, "bigger than the valley")
	assert_true(Beat.reached("bachlauf_enter"))
	var fog := scene.view.world_root.get_node_or_null("Fog")
	assert_not_null(fog, "banks of fog over the water")
	assert_eq(fog.get_child_count(), scene.fog_banks)
	assert_gte(
		scene.find_children("Stream*", "AudioStreamPlayer2D", true, false).size(),
		8,
		"the stream is heard"
	)


func test_the_player_arrives_at_the_gap_in_the_forest_below_the_door() -> void:
	SceneTravel.pending_spawn = "tal"
	var scene := await _scene()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), Vector2i(35, 6))
	assert_true(WorldState.day_preset() in ["", "abend"], "evening")


func test_without_the_facet_the_post_has_no_spot_more() -> void:
	var scene := await _scene()
	assert_false(WorldState.has_flag("valley.looks_closely"))
	assert_null(_first(scene, "knot"))
	assert_not_null(_first(scene, "hook"), "the post is there for everyone")


func test_with_the_facet_the_spot_is_there_and_seen_once_and_marks_the_beat() -> void:
	WorldState.set_facet("perception")
	var scene := await _scene()
	assert_true(WorldState.has_flag("valley.looks_closely"))
	var knot := _first(scene, "knot")
	assert_not_null(knot, "one spot more at the post")
	assert_false(Beat.reached("bachlauf_blick"))
	Settings.set_value("text.auto_advance", true, false)
	_look(knot)
	await wait_until(func() -> bool: return WorldState.has_flag("valley.knot_seen"), 30.0)
	assert_true(Beat.reached("bachlauf_blick"))


func test_the_float_and_the_trap_appear_one_after_the_other() -> void:
	var scene := await _scene()
	assert_null(_first(scene, "float"), "no float before the hook")
	assert_null(_first(scene, "trap"))
	WorldState.set_flag("valley.trap_hooked")
	await wait_physics_frames(3)
	assert_not_null(_first(scene, "float"))
	assert_null(_first(scene, "trap"), "no trap before the float")
	WorldState.set_flag("valley.trap_floated")
	await wait_physics_frames(3)
	var trap := _first(scene, "trap") as Decor
	assert_not_null(trap)
	assert_eq(trap.sprite_id, "tal/bl_trap_stuck", "wedged behind the weir")


func test_the_quest_marks_a_beat_at_each_stage() -> void:
	await _scene()
	WorldState.start_quest(QUEST)
	assert_true(Beat.reached("bachlauf_hook"))
	WorldState.advance_quest(QUEST, "float")
	assert_true(Beat.reached("bachlauf_float"))
	assert_false(Beat.reached("bachlauf_weir"))
	WorldState.advance_quest(QUEST, "weir")
	assert_true(Beat.reached("bachlauf_weir"))
	assert_false(Beat.reached("bachlauf_freed"))
	WorldState.advance_quest(QUEST, "done")
	assert_true(Beat.reached("bachlauf_freed"))


func test_letting_the_trap_go_changes_the_stream_and_gives_the_comb() -> void:
	Settings.set_value("text.auto_advance", true, false)
	var scene := await _scene()
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "float")
	WorldState.set_flag("valley.trap_hooked")
	WorldState.set_flag("valley.trap_floated")
	await wait_physics_frames(3)
	_look(_first(scene, "trap"))
	var freed := func() -> bool:
		BoxAnswers.pick(scene.dialogue_box, "Sie lösen.")
		return WorldState.has_flag("valley.trap_freed")
	await wait_until(freed, 40.0)
	assert_true(WorldState.has_item("curiosity_comb"))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	await wait_physics_frames(3)
	var trap := _first(scene, "trap") as Decor
	assert_not_null(trap)
	assert_eq(trap.sprite_id, "tal/bl_trap_free", "it lies free in the stream, mouth downstream")


func test_a_taken_curiosity_is_gone_from_the_map_and_a_left_one_stays() -> void:
	var scene := await _scene()
	assert_not_null(_first(scene, "glass"))
	assert_not_null(_first(scene, "weight"))
	WorldState.set_flag("valley.glass_taken")
	await wait_physics_frames(3)
	assert_null(_first(scene, "glass"), "taken")
	assert_not_null(_first(scene, "weight"), "left where it lies")


func test_the_door_leads_back_to_the_valley_and_nothing_stops_the_walk() -> void:
	SceneTravel.stay = true
	var scene := await _scene()
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") == "tal"
	)
	assert_eq(doors.size(), 1, "one door, and it goes to the valley")
	assert_eq(doors[0].get(&"spawn"), "bach", "to the place the valley made for it")
	scene.player.global_position = scene.map.cell_to_world(DOOR_CELL)
	await wait_physics_frames(4)
	assert_eq(SceneTravel.last_target, "tal")
	assert_false(
		WorldState.has_flag("valley.ending"), "the evening's end is no business of the stream"
	)
