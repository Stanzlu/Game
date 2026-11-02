extends GutTest
## Act IV, segment S4: the workshop from inside (docs/akt4/REGIONSBRIEFE.md). A room of class S,
## 26 x 18 cells at the zoom of an interior, with a long bench, Tess behind it, a board on two
## trestles, a half-built ladder, saws on the wall and sawdust with two kinds of footprints. The
## scene plays her whistle once she has whistled it and marks the beats; once the board is sawn
## she is gone from the next visit (she sits outside). What she says is tested in
## test_akt4_werkstatt and test_akt4_werkstatt_nach.

const WERKSTATT := preload("res://world/levels/akt4/werkstatt.tscn")
const SIZE := Vector2i(26, 18)
const DOOR_CELL := Vector2i(13, 14)
const ARRIVAL := Vector2i(13, 12)
const START := Vector2i(11, 12)
const TESS_CELL := Vector2i(11, 7)
const BOARD_CELL := Vector2i(8, 10)
const THINGS := {
	"board": Vector2i(7, 10),
	"ladder": Vector2i(6, 6),
	"saws": Vector2i(16, 6),
	"dust": Vector2i(10, 11),
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


func _scene() -> WerkstattScene:
	var scene: WerkstattScene = WERKSTATT.instantiate()
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


func _tess(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if (
			node is NpcWalker
			and (node as NpcWalker).cue == "tess"
			and not node.is_queued_for_deletion()
		):
			return node as NpcWalker
	return null


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id == sprite
				and not node.is_queued_for_deletion()
			)
	)


func _thing(scene: GameScene, cue: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node as Decor
	return null


func test_the_workshop_is_a_room_with_its_markers_and_one_door() -> void:
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
	assert_eq(doors[0].get(&"spawn"), "werkstatt", "to the place the city made for it")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)
	assert_gte(DOOR_CELL.y - ARRIVAL.y, 2, "an arrival outside the door's zone")


func test_it_is_an_interior_at_the_zoom_of_the_house_and_the_camera_keeps_to_the_room() -> void:
	var scene := await _scene()
	assert_eq(scene.view_zoom, 1.5)
	assert_eq(scene.view.bounds.size, Vector2(288, 192), "18 by 12 cells of 16 pixels")
	assert_eq(WerkstattScene.ROOM, Rect2i(4, 3, 18, 12))
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0)
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked())


func test_tess_stands_behind_the_bench_facing_the_door() -> void:
	var scene := await _scene()
	var tess := _tess(scene)
	assert_not_null(tess)
	assert_eq(scene.map.world_to_cell(tess.global_position), TESS_CELL)
	assert_eq(tess.facing, Facing.Dir.S, "towards the door")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 1, "only she")


func test_the_board_the_ladder_the_saws_and_the_sawdust_can_be_looked_at() -> void:
	var scene := await _scene()
	for cue: String in THINGS:
		var thing := _thing(scene, cue)
		assert_not_null(thing, cue)
		assert_eq(scene.map.world_to_cell(thing.global_position), THINGS[cue], cue)


func test_the_board_leaves_the_trestles_when_it_is_sawn_and_tess_stays_for_that_visit() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "tal/wk_board").size(), 1)
	assert_eq(
		scene.map.world_to_cell(_decor_with(scene, "tal/wk_board")[0].global_position), BOARD_CELL
	)
	WorldState.set_flag("city.board_done")
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/wk_board").size(), 0, "only the shavings are left")
	assert_not_null(_tess(scene), "she does not vanish in the middle of the talk")
	assert_not_null(_thing(scene, "board"), "the trestles stay")


func test_at_the_next_visit_she_is_not_here_but_outside() -> void:
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	assert_null(_tess(scene), "she sits on her crate outside")
	assert_eq(_decor_with(scene, "tal/wk_board").size(), 0, "and the board is sawn")
	assert_not_null(_thing(scene, "ladder"), "the room is the same")


func test_her_whistle_is_a_melody_with_a_caption_and_the_beats_are_marked() -> void:
	await _scene()
	assert_true(Beat.reached("werkstatt_enter"))
	assert_false(Beat.reached("werkstatt_board"))
	assert_true(AudioDirector.CAPTIONS.has("tess_whistle"), "a sound with a story value has a text")
	assert_ne(tr("CAPTION_WHISTLE"), "CAPTION_WHISTLE")
	WorldState.set_flag("city.board_done")
	await wait_physics_frames(2)
	assert_true(Beat.reached("werkstatt_board"))


func test_from_the_city_she_arrives_inside_and_walking_down_reaches_the_door() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "stadt"
	var scene := await _scene()
	assert_eq(_cell(scene), ARRIVAL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "stadt"
	assert_true(await _hold(&"move_down", gone, 300), "down from the arrival reaches the door")
