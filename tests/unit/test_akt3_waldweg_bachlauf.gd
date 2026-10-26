extends GutTest
## Act III, segment W2, the Bachlauf's side of the forest path: in the south the stream has a pocket
## with a gap in the hedge, and from the morning after (the beat of W1) a door leads down into the
## wood. Before that, in the evening of Act II, there is no door: the hedge is closed. The way back
## from the forest arrives at the place made for it. The Waldweg itself is tested in
## test_akt3_waldweg_szene.

const BACHLAUF := preload("res://world/levels/akt2/bachlauf.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const DOOR_CELL := Vector2i(45, 64)
const ARRIVAL_CELL := Vector2i(45, 60)
const BLOCKER_CELL := Vector2i(45, 65)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_down")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> BachlaufScene:
	var scene: BachlaufScene = BACHLAUF.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _doors(scene: GameScene) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == "waldweg" and not node.is_queued_for_deletion()
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


func _blocker(scene: GameScene) -> Node:
	var spot := scene.map.cell_to_world(BLOCKER_CELL)
	for node in scene.map.entities.get_children():
		if (
			not node.is_queued_for_deletion()
			and node.get_script() == BLOCKER_SCRIPT
			and node.global_position.distance_to(spot) < 2.0
		):
			return node
	return null


func test_until_the_morning_after_the_south_has_no_door_and_a_blocker_shuts_the_edge() -> void:
	var scene := await _scene()
	assert_eq(_doors(scene).size(), 0, "the evening of Act II does not walk into Act III")
	assert_false(scene.map.data.find_marker("spawn_waldweg").is_empty(), "but the place is ready")
	assert_not_null(_blocker(scene), "the gap ends in a blocker, as the valley's gap does")


func test_in_the_evening_the_way_south_ends_inside_the_map() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "waldweg"
	var scene := await _scene()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	var never := func() -> bool: return false
	await _hold(&"move_down", never, 360)
	var cell := scene.map.world_to_cell(scene.player.global_position)
	assert_lt(cell.y, BLOCKER_CELL.y, "stopped above the blocker, never out of the map")
	assert_gte(cell.y, ARRIVAL_CELL.y + 3, "and she did walk down the pocket")
	assert_eq(SceneTravel.last_target, "", "no door before the morning")


func test_from_the_morning_after_a_door_leads_down_into_the_wood() -> void:
	WorldState.set_flag("beat.act3_morning")
	var scene := await _scene()
	var doors := _doors(scene)
	assert_null(_blocker(scene), "the way is open: the blocker is gone with the flag")
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "bachlauf", "to the place the forest made for it")
	assert_eq(
		scene.map.world_to_cell((doors[0] as Node2D).global_position),
		DOOR_CELL,
		"in the gap of the hedge, south of the pocket"
	)


func test_the_way_back_arrives_at_the_pocket_and_walking_south_reaches_the_door() -> void:
	WorldState.set_flag("beat.act3_morning")
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "waldweg"
	var scene := await _scene()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	assert_gte(DOOR_CELL.y - ARRIVAL_CELL.y, 4, "an arrival outside the door's zone")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "waldweg"
	assert_true(await _hold(&"move_down", gone, 300), "south from the arrival reaches the door")


func test_the_hedge_in_the_south_still_keeps_the_stream_and_the_west_path() -> void:
	# the gap is carved into the hedge only; the stream and the ford keep their water and the path
	# from the west leg still meets it
	WorldState.set_flag("beat.act3_morning")
	var scene := await _scene()
	var data := scene.map.data
	var water := 0
	for x in range(data.width):
		for y in range(55, data.height):
			if data.tile_symbol_at(Vector2i(x, y)) == "~":
				water += 1
	assert_gt(water, 0, "the stream is still there")
