extends GutTest
## Act IV, segment S3: the florist's shop from inside (docs/akt4/REGIONSBRIEFE.md). A room of
## class S, 26 x 18 cells at the zoom of an interior, with a work table, Orin behind it and a
## bunch of dried peonies over the table's end. The scene only marks the beats of the two side
## quests. What Orin says is tested in test_akt4_blumenladen and test_akt4_blumenladen_brief.

const BLUMENLADEN := preload("res://world/levels/akt4/blumenladen.tscn")
const SIZE := Vector2i(26, 18)
const DOOR_CELL := Vector2i(13, 14)
const ARRIVAL := Vector2i(13, 12)
const START := Vector2i(11, 12)
const ORIN_CELL := Vector2i(13, 7)
const THINGS := {
	"table": Vector2i(12, 8),
	"dried": Vector2i(15, 8),
	"shelf": Vector2i(5, 6),
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


func _scene() -> BlumenladenScene:
	var scene: BlumenladenScene = BLUMENLADEN.instantiate()
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


func _orin(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if node is NpcWalker and (node as NpcWalker).cue == "orin":
			return node as NpcWalker
	return null


func _thing(scene: GameScene, cue: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node as Decor
	return null


func test_the_shop_is_a_room_with_its_markers_and_one_door() -> void:
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
	assert_eq(doors[0].get(&"spawn"), "blumenladen", "to the place the city made for it")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)
	assert_gte(DOOR_CELL.y - ARRIVAL.y, 2, "an arrival outside the door's zone")


func test_it_is_an_interior_at_the_zoom_of_the_house_and_the_camera_keeps_to_the_room() -> void:
	var scene := await _scene()
	assert_eq(scene.view_zoom, 1.5)
	assert_eq(scene.view.bounds.size, Vector2(288, 192), "18 by 12 cells of 16 pixels")
	assert_eq(BlumenladenScene.ROOM, Rect2i(4, 3, 18, 12))
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0)
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked())


func test_orin_stands_behind_the_table_facing_the_door() -> void:
	var scene := await _scene()
	var orin := _orin(scene)
	assert_not_null(orin)
	assert_eq(scene.map.world_to_cell(orin.global_position), ORIN_CELL)
	assert_eq(orin.facing, Facing.Dir.S, "towards the door")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 1, "only he")


func test_the_table_the_bunch_and_the_shelf_can_be_looked_at() -> void:
	var scene := await _scene()
	for cue: String in THINGS:
		var thing := _thing(scene, cue)
		assert_not_null(thing, cue)
		assert_eq(scene.map.world_to_cell(thing.global_position), THINGS[cue], cue)


func test_the_end_of_each_side_quest_marks_its_beat() -> void:
	await _scene()
	assert_true(Beat.reached("blumenladen_enter"))
	assert_false(Beat.reached("blumenladen_duck"))
	WorldState.start_quest("side_city_duck")
	WorldState.advance_quest("side_city_duck", "done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("blumenladen_duck"))
	assert_false(Beat.reached("blumenladen_letter"), "the other quest has not ended")
	WorldState.start_quest("side_city_letter")
	WorldState.advance_quest("side_city_letter", "done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("blumenladen_letter"))


func test_from_the_city_she_arrives_inside_and_walking_down_reaches_the_door() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "stadt"
	var scene := await _scene()
	assert_eq(_cell(scene), ARRIVAL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "stadt"
	assert_true(await _hold(&"move_down", gone, 300), "down from the arrival reaches the door")
