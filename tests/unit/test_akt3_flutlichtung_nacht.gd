extends GutTest
## Act III, segment W5, the way on to the south of the Flutlichtung: a blocker stands in the gap of
## the southern edge until the walk through the wood has reached the night (the hut seen and the
## trunk seen), the flag "forest.night_way" takes it away, and behind it a door leads into the night
## wood. A walk that was never started opens nothing. What the clearing shows is tested in
## test_akt3_flutlichtung_szene, the night wood in test_akt3_nachtwald_szene.

const FLUT := preload("res://world/levels/akt3/flutlichtung.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const DOOR_SCRIPT := preload("res://world/props/door.gd")
const QUEST := "main_forest_way"
const FLAG := "forest.night_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night"]
const BLOCKER_CELL := Vector2i(34, 50)
const DOOR_CELL := Vector2i(34, 52)
const ARRIVAL_CELL := Vector2i(34, 48)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> FlutlichtungScene:
	var scene: FlutlichtungScene = FLUT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The prop with this script on this cell, or null (a prop that is leaving does not count).
func _at(scene: GameScene, cell: Vector2i, script: Script) -> Node:
	var spot := scene.map.cell_to_world(cell)
	for node in scene.map.entities.get_children():
		if (
			not node.is_queued_for_deletion()
			and node.get_script() == script
			and node.global_position.distance_to(spot) < 2.0
		):
			return node
	return null


func _is_blocker(node: Node) -> bool:
	return not node.is_queued_for_deletion() and node.get_script() == BLOCKER_SCRIPT


func _cell_of(scene: GameScene, node: Node2D) -> Vector2i:
	return scene.map.world_to_cell(node.global_position)


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _go_to(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	scene.player.velocity = Vector2.ZERO
	await wait_physics_frames(2)


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


func test_the_way_stays_shut_in_every_stage_before_the_night() -> void:
	for stage: String in ["leave", "brook", "wood"]:
		WorldState.new_game()
		_walk_to(stage)
		var scene := await _scene()
		assert_false(WorldState.has_flag(FLAG), "stage %s: not open" % stage)
		assert_not_null(
			_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "stage %s: the blocker stands" % stage
		)
		scene.queue_free()
		await wait_physics_frames(2)
	assert_push_error_count(0)


func test_a_game_without_the_walk_opens_nothing_even_when_the_trunk_is_seen() -> void:
	var scene := await _scene()
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_false(WorldState.has_flag(FLAG), "a walk that was never started does not open the way")
	assert_not_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT))
	assert_push_error_count(0)


func test_the_trunk_alone_without_the_hut_does_not_open_it() -> void:
	_walk_to("wood")
	var scene := await _scene()
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "wood")
	assert_false(WorldState.has_flag(FLAG))
	assert_not_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "it still stands")


func test_the_trunk_with_the_hut_done_takes_the_blocker_away_while_she_is_there() -> void:
	_walk_to("wood")
	WorldState.complete_objective(QUEST, "hermit")
	var scene := await _scene()
	assert_not_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "it stands until the trunk is seen")
	WorldState.set_flag("forest.flood_seen")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_true(WorldState.has_flag(FLAG), "the way is open")
	assert_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "and the blocker is gone")
	assert_not_null(_at(scene, DOOR_CELL, DOOR_SCRIPT), "the door behind it is there")


func test_coming_back_at_the_night_finds_no_blocker_at_all() -> void:
	_walk_to("night")
	var scene := await _scene()
	assert_true(WorldState.has_flag(FLAG), "the scene opens it for whoever returns")
	assert_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT))
	assert_eq(
		scene.map.entities.get_children().filter(_is_blocker).size(), 0, "no blocker anywhere"
	)
	assert_push_error_count(0)


func test_with_the_way_open_she_walks_down_the_path_into_the_door_to_the_night_wood() -> void:
	_walk_to("night")
	SceneTravel.stay = true
	var scene := await _scene()
	await _go_to(scene, ARRIVAL_CELL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "nachtwald"
	assert_true(await _hold(&"move_down", gone, 360), "south from the arrival reaches the door")
	assert_true(SceneRegistry.has("nachtwald"), "and the door has somewhere to go")


func test_the_arrival_from_the_night_wood_lies_four_rows_before_the_door_and_is_not_thrown_back(
) -> void:
	_walk_to("night")
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "nachtwald"
	var scene := await _scene()
	assert_eq(scene.map.data.find_marker("spawn_nachtwald")[0]["cell"], ARRIVAL_CELL)
	assert_eq(_cell_of(scene, scene.player), ARRIVAL_CELL, "she arrives where the marker is")
	assert_gte(DOOR_CELL.y - ARRIVAL_CELL.y, 4, "an arrival outside the door's zone")
	await wait_physics_frames(10)
	assert_eq(SceneTravel.last_target, "", "no way back in at once")
	assert_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "nothing stands between her and the path")


func test_the_door_to_the_night_wood_is_never_locked_and_never_asks_a_question() -> void:
	_walk_to("night")
	var scene := await _scene()
	var door := _at(scene, DOOR_CELL, DOOR_SCRIPT)
	assert_not_null(door)
	assert_eq(door.get(&"target"), "nachtwald")
	assert_eq(door.get(&"spawn"), "flutlichtung")
	assert_true(door.get(&"auto"), "the path itself leads through it")
	assert_false(scene.dialogue_box.is_open(), "no one speaks to her before she goes")
	assert_false(scene.player.is_locked())
