extends GutTest
## Act IV, segment S1, the valley's side of the road: the west path leaves the valley. From the end
## of Act III (the chapter mark) a signpost stands at the rim and a door leads out onto the road;
## before that nothing is there, and the old pieces of the west path (the door to the Antreiber's
## run and its two blockers) are untouched. The road itself is tested in test_akt4_strasse_szene
## (ADR-071, O2).

const TAL := preload("res://world/levels/slice/tal.tscn")
const END_OF_ACT_TWO := "res://tests/fixtures/saves/v2_akt2_end.json"
const END_OF_ACT_THREE := "res://tests/fixtures/saves/v2_akt3_end.json"
const DOOR_CELL := Vector2i(4, 25)
const ARRIVAL_CELL := Vector2i(6, 25)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_left")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _load(path: String) -> void:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(path))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _doors_to(scene: GameScene, target: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == target and not node.is_queued_for_deletion()
	)


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _signposts(scene: GameScene) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id == "tal/st_sign"
				and not node.is_queued_for_deletion()
			)
	)


func test_before_the_end_of_act_three_the_west_rim_has_no_door_and_no_signpost() -> void:
	_load(END_OF_ACT_TWO)
	var scene := await _valley()
	assert_eq(_doors_to(scene, "strasse").size(), 0, "the evening of Act II does not leave")
	assert_eq(_signposts(scene).size(), 0)
	assert_false(scene.map.data.find_marker("spawn_strasse").is_empty(), "but the place is ready")


func test_from_the_end_of_act_three_a_door_leads_west_out_of_the_valley() -> void:
	_load(END_OF_ACT_THREE)
	var scene := await _valley()
	var doors := _doors_to(scene, "strasse")
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "tal", "to the place the road made for it")
	assert_true(doors[0].get(&"auto"), "walking into it is enough: it is the rim of the map")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)
	var shapes := (doors[0] as Node).get_node("Exit").find_children(
		"*", "CollisionShape2D", true, false
	)
	assert_eq(shapes.size(), 1)
	var rect := (shapes[0] as CollisionShape2D).shape as RectangleShape2D
	assert_eq(rect.size, Vector2(16, 144), "one cell wide, nine high")


func test_the_door_stands_inside_the_old_blockers_so_it_is_met_first() -> void:
	# the west path has three strips (cells 0 to 2 of row 25: the door to the Antreiber's run and
	# its two blockers); the new door is east of them, so nobody reaches the old pieces on the way out
	var text := FileAccess.get_file_as_string("res://content/maps/tal.txt")
	var rows := text.split("[map]\n")[1].split("\n")
	assert_eq(rows[DOOR_CELL.y].substr(0, 4), "XZV3", "the old strips and the old marker stay")
	assert_gt(DOOR_CELL.x, 3, "the door is east of the marker the run arrives at")


func test_a_signpost_names_the_way_from_the_end_of_act_three() -> void:
	_load(END_OF_ACT_THREE)
	var scene := await _valley()
	var posts := _signposts(scene)
	assert_eq(posts.size(), 1)
	assert_eq((posts[0] as Decor).get_meta(&"cue"), "signpost_tal")
	assert_lt(
		scene.map.world_to_cell((posts[0] as Node2D).global_position).x,
		12,
		"at the west rim, where the road starts"
	)


func test_the_way_back_arrives_inside_the_door_zone_and_walking_west_reaches_it() -> void:
	_load(END_OF_ACT_THREE)
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "strasse"
	var scene := await _valley()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	assert_gte(ARRIVAL_CELL.x - DOOR_CELL.x, 2, "an arrival outside the door's zone")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "strasse"
	assert_true(await _hold(&"move_left", gone, 300), "west from the arrival reaches the door")


func test_the_old_west_path_keeps_its_run_while_the_wood_is_needed() -> void:
	# the Antreiber's run keeps its door (while the wood is needed and not yet taken)
	_load(END_OF_ACT_TWO)
	WorldState.clear_flag("valley.wood_taken")
	var scene := await _valley()
	assert_eq(_doors_to(scene, "weg").size(), 1, "with the wood still needed the run is there")
	assert_eq(_doors_to(scene, "strasse").size(), 0, "and the road is not open yet")


func test_the_old_west_path_has_no_run_once_the_wood_is_taken() -> void:
	_load(END_OF_ACT_TWO)
	var scene := await _valley()
	assert_eq(_doors_to(scene, "weg").size(), 0, "wood is taken in the saved evening: no run")
