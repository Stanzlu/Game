extends GutTest
## Act IV, segment S2: the town hall from inside (docs/akt4/REGIONSBRIEFE.md). A room of class S,
## 28 x 20 cells at the zoom of an interior, with a counter, the clerk behind it, a shelf of lost
## property (four things that belong to nobody any more) and the plan of a perfect day. The
## scene only marks the beats of the two side quests. What the clerk says is tested in
## test_akt4_platz.

const RATHAUS := preload("res://world/levels/akt4/rathaus.tscn")
const SIZE := Vector2i(28, 20)
const DOOR_CELL := Vector2i(13, 15)
const ARRIVAL := Vector2i(13, 13)
const START := Vector2i(11, 12)
const CLERK_CELL := Vector2i(13, 8)
const SHELF_THINGS := {
	"tal/rh_glove": "city.lost_glove",
	"tal/rh_key": "city.lost_key",
	"tal/rh_buttons": "city.lost_buttons",
	"tal/rh_cup": "city.lost_cup",
}


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


func _scene() -> RathausScene:
	var scene: RathausScene = RATHAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id == sprite
				and not node.is_queued_for_deletion()
			)
	)


func _clerk(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if node is NpcWalker and (node as NpcWalker).cue == "clerk":
			return node as NpcWalker
	return null


func test_the_town_hall_is_a_room_with_its_markers_and_one_door() -> void:
	var scene := await _scene()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_stadt")[0]["cell"], ARRIVAL)
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") != null
	)
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"target"), "stadt")
	assert_eq(doors[0].get(&"spawn"), "rathaus", "to the place the city made for it")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)
	assert_gte(DOOR_CELL.y - ARRIVAL.y, 2, "an arrival outside the door's zone")


func test_it_is_an_interior_at_the_zoom_of_the_house_and_the_camera_keeps_to_the_room() -> void:
	var scene := await _scene()
	assert_eq(scene.view_zoom, 1.5)
	assert_eq(scene.view.bounds.size, Vector2(RathausScene.ROOM.size * scene.map.data.tile_size))
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0)
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked())


func test_the_clerk_stands_behind_the_counter_and_looks_at_whoever_comes() -> void:
	var scene := await _scene()
	var clerk := _clerk(scene)
	assert_not_null(clerk)
	assert_eq(scene.map.world_to_cell(clerk.global_position), CLERK_CELL)
	assert_eq(clerk.facing, Facing.Dir.S, "towards the door")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 1, "only she")


func test_the_shelf_holds_four_things_and_each_goes_with_its_flag() -> void:
	var scene := await _scene()
	for sprite: String in SHELF_THINGS:
		assert_eq(_decor_with(scene, sprite).size(), 1, sprite)
	WorldState.set_flag("city.lost_key")
	WorldState.set_flag("city.lost_cup")
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/rh_key").size(), 0, "the key is gone from the shelf")
	assert_eq(_decor_with(scene, "tal/rh_cup").size(), 0, "so is the cup")
	assert_eq(_decor_with(scene, "tal/rh_glove").size(), 1, "the glove is still there")
	var again := await _scene()
	assert_eq(_decor_with(again, "tal/rh_key").size(), 0, "and a game loaded later has no key")


func test_the_end_of_each_side_quest_marks_its_beat() -> void:
	var scene := await _scene()
	assert_true(Beat.reached("rathaus_enter"))
	assert_false(Beat.reached("rathaus_lost"))
	WorldState.start_quest("side_city_lost")
	WorldState.advance_quest("side_city_lost", "done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("rathaus_lost"))
	assert_false(Beat.reached("rathaus_day"), "the other quest has not ended")
	WorldState.start_quest("side_city_day")
	WorldState.advance_quest("side_city_day", "done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("rathaus_day"))
	assert_not_null(scene)


func test_from_the_city_she_arrives_inside_and_walking_down_reaches_the_door() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "stadt"
	var scene := await _scene()
	assert_eq(_cell(scene), ARRIVAL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "stadt"
	assert_true(await _hold(&"move_down", gone, 300), "down from the arrival reaches the door")
