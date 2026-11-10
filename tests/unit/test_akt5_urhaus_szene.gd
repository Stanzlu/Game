extends GutTest
## Act V, segment G8: the first house (docs/akt5/REGIONSBRIEFE.md, O2, O7, O10). Once the child is
## gone a small house stands on the plateau of the Grat, with a book on a post beside it; inside is
## one room (class S, 33 x 22 cells, zoom 1.5) with a small bed, six rings of chalk on the floor, a
## chalked-over window and a stick of chalk. The scene plays the first look once and moves the walk
## on; the rest is props with cues. What the cues say is tested in test_akt5_urhaus, the ground and
## the reach in tools/art/test_urhaus_map.py.

const URHAUS := preload("res://world/levels/akt5/urhaus.tscn")
const GRAT := preload("res://world/levels/akt5/grat.tscn")
const QUEST := "main_mountain_way"
const SUMMIT := "side_grat_summit"
const SIZE := Vector2i(33, 22)
const START := Vector2i(26, 8)
const FROM_GRAT := Vector2i(7, 15)
const DOOR_CELL := Vector2i(7, 17)
const BED := Vector2i(16, 10)
const WINDOW := Vector2i(16, 6)
const CHALK := Vector2i(11, 15)
## The six spots on the lines of the rings, from the innermost to the outermost.
const RINGS := {
	"ring_room": Vector2i(18, 10),
	"ring_wall": Vector2i(20, 10),
	"ring_garden": Vector2i(22, 10),
	"ring_street": Vector2i(24, 10),
	"ring_town": Vector2i(26, 10),
	"ring_world": Vector2i(27, 10),
}
const HOUSE := Vector2i(88, 4)
const HOUSE_DOOR := Vector2i(88, 5)
const HOUSE_ARRIVAL := Vector2i(88, 7)
const BOOK := Vector2i(90, 6)
const PLATEAU_SPOT := Vector2i(87, 10)
const EDGE := Vector2i(86, 10)
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The walk of the hero after the child (stage `child`), with the first look already seen.
func _house(seen_look := true) -> UrhausScene:
	WorldState.set_flag("grat.child_gone")
	WorldState.start_quest(QUEST)
	for next: String in ["valley", "plant", "load", "letgo", "high", "child"]:
		WorldState.advance_quest(QUEST, next)
	if seen_look:
		Beat.mark("urhaus_look")
	var scene: UrhausScene = URHAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _grat(flags: Array[String] = []) -> GratScene:
	for flag in flags:
		WorldState.set_flag(flag)
	WorldState.set_flag("plant.letgo")
	WorldState.start_quest(QUEST)
	for next: String in ["valley", "plant", "load", "letgo", "high"]:
		WorldState.advance_quest(QUEST, next)
	var scene: GratScene = GRAT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _alive(scene: GameScene) -> Array[Node]:
	var list: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			list.append(node)
	return list


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in _alive(scene):
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


func _with_sprite(scene: GameScene, sprite: String) -> Array[Node]:
	var list: Array[Node] = []
	for node in _alive(scene):
		if node is Decor and (node as Decor).sprite_id == sprite:
			list.append(node)
	return list


func _doors_to(scene: GameScene, target: String) -> Array[Node]:
	var list: Array[Node] = []
	for node in _alive(scene):
		if node.get(&"target") == target:
			list.append(node)
	return list


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Moves the text on as a player does until `until` holds.
func _told(scene: GameScene, until: Callable, seconds := 40.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				_confirm()
			return until.call(),
		seconds
	)


# --- The room -----------------------------------------------------------------------------------


func test_the_room_is_of_class_s_at_the_zoom_of_an_interior_and_has_one_door_to_the_grat() -> void:
	var scene := await _house()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_eq(scene.view_zoom, 1.5)
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_grat")[0]["cell"], FROM_GRAT)
	assert_gt(Vector2(DOOR_CELL).distance_to(Vector2(START)), 20.0, "far from the door")
	assert_eq(
		scene.view.bounds.size,
		Vector2(UrhausScene.ROOM.size * data.tile_size),
		"the camera keeps the room whole"
	)
	var doors := _doors_to(scene, "grat")
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "urhaus")
	assert_true(doors[0].get(&"auto"))
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)


func test_every_thing_of_the_room_stands_on_its_cell_with_its_cue() -> void:
	var scene := await _house()
	var bed := _first(scene, "first_house")
	assert_not_null(bed, "the bed")
	if bed != null:
		assert_eq(scene.map.world_to_cell(bed.global_position), BED)
	var window := _first(scene, "window")
	assert_not_null(window, "the window")
	if window != null:
		assert_eq(scene.map.world_to_cell(window.global_position), WINDOW)
	var chalk := _first(scene, "blue_chalk")
	assert_not_null(chalk, "the chalk")
	if chalk != null:
		assert_eq(scene.map.world_to_cell(chalk.global_position), CHALK)
	for cue: String in RINGS:
		var spot := _first(scene, cue)
		assert_not_null(spot, "%s is on the map" % cue)
		if spot != null:
			assert_eq(scene.map.world_to_cell(spot.global_position), RINGS[cue], cue)
	assert_eq(_with_sprite(scene, "tal/uh_chalk_rings").size(), 1, "one picture of six rings")


# --- The walk and the first look --------------------------------------------------------------


func test_stepping_in_takes_the_walk_one_step_on_and_marks_the_beat() -> void:
	assert_false(Beat.reached("urhaus_enter"))
	await _house()
	assert_eq(WorldState.quest_stage(QUEST), "house", "the walk goes on")
	assert_true(Beat.reached("urhaus_enter"))
	assert_true(ContentDB.quest(QUEST).stage("house").is_final(), "the walk rests here until G9")
	assert_false(ContentDB.quest(QUEST).stage("child").is_final())
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_HOUSE"), "QUEST_MAIN_MOUNTAIN_WAY_HOUSE")


func test_the_first_look_is_played_once_and_nothing_holds_her_afterwards() -> void:
	var scene := await _house(false)
	var seen := func() -> bool: return Beat.reached("urhaus_look")
	assert_true(await _told(scene, seen), "the first look runs to its end")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty(), "no cutscene runs")
	assert_false(scene.player.is_locked(), "she walks as she likes")
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _house()
	await wait_physics_frames(120)
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty(), "nothing is played twice")
	assert_false(again.player.is_locked())


func test_a_game_begun_in_the_room_has_no_walk_and_no_look_that_matters() -> void:
	# --start=urhaus without any story: nothing breaks, the stage is not invented
	var scene: UrhausScene = URHAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(_cell(scene), START)
	assert_false(WorldState.is_quest_started(QUEST), "the room does not start the walk")


# --- What she changes ---------------------------------------------------------------------------


func test_the_window_is_chalked_over_and_shows_the_clear_picture_once_it_is_wiped() -> void:
	var scene := await _house()
	assert_eq(_with_sprite(scene, "tal/uh_window").size(), 1, "chalked over")
	assert_eq(_with_sprite(scene, "tal/uh_window_clear").size(), 0)
	WorldState.set_flag("urhaus.window_clear")
	await wait_physics_frames(3)
	assert_eq(_with_sprite(scene, "tal/uh_window_clear").size(), 1, "live: the pane is clear")
	assert_eq(_with_sprite(scene, "tal/uh_window").size(), 0)
	assert_true(Beat.reached("urhaus_window"))
	scene.queue_free()
	await wait_physics_frames(2)
	var loaded := await _house()
	assert_eq(_with_sprite(loaded, "tal/uh_window_clear").size(), 1, "and after loading")


func test_the_chalk_lies_on_the_floor_until_it_is_taken() -> void:
	var scene := await _house()
	assert_not_null(_first(scene, "blue_chalk"))
	WorldState.set_flag("urhaus.chalk_taken")
	await wait_physics_frames(3)
	assert_null(_first(scene, "blue_chalk"), "gone once it is taken")
	scene.queue_free()
	await wait_physics_frames(2)
	var loaded := await _house()
	assert_null(_first(loaded, "blue_chalk"), "and after loading")
	assert_not_null(_first(loaded, "first_house"), "the bed stays")


func test_the_picture_at_the_bed_marks_its_beat_and_fills_the_sixth_frame() -> void:
	var scene := await _house()
	assert_false(ChildMeeting.held(5))
	WorldState.set_flag("fragment.first_house")
	await wait_physics_frames(2)
	assert_true(Beat.reached("urhaus_house"))
	assert_true(ChildMeeting.held(5), "the sixth frame holds the first house")
	assert_eq(Collection.fragments(), 1)
	assert_true(scene.is_inside_tree())


# --- The plateau --------------------------------------------------------------------------------


func test_before_the_child_is_gone_the_plateau_is_empty_and_the_edge_looks_down() -> void:
	var scene := await _grat()
	assert_eq(_with_sprite(scene, "tal/gb_first_house").size(), 0, "no house yet")
	assert_eq(_with_sprite(scene, "tal/gb_summit_book").size(), 0, "no book")
	assert_eq(_doors_to(scene, "urhaus").size(), 0, "no door")
	assert_not_null(_first(scene, "plateau_edge"), "the first look")
	assert_null(_first(scene, "plateau_after"))


func test_once_the_child_is_gone_a_house_stands_there_live_and_after_loading() -> void:
	var scene := await _grat()
	WorldState.set_flag("grat.child_gone")
	await wait_physics_frames(3)
	var houses := _with_sprite(scene, "tal/gb_first_house")
	assert_eq(houses.size(), 1, "the small house")
	if houses.size() == 1:
		assert_eq(scene.map.world_to_cell(houses[0].global_position), HOUSE)
	var books := _with_sprite(scene, "tal/gb_summit_book")
	assert_eq(books.size(), 1, "the book on its post")
	if books.size() == 1:
		assert_eq(scene.map.world_to_cell(books[0].global_position), BOOK)
	var doors := _doors_to(scene, "urhaus")
	assert_eq(doors.size(), 1)
	if doors.size() == 1:
		assert_eq(doors[0].get(&"spawn"), "grat")
		assert_true(doors[0].get(&"auto"))
		assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), HOUSE_DOOR)
	assert_null(_first(scene, "plateau_edge"), "the first look is replaced")
	var spot := _first(scene, "plateau_after")
	assert_not_null(spot, "by the second")
	if spot != null:
		assert_eq(scene.map.world_to_cell(spot.global_position), PLATEAU_SPOT)
	var loaded := await _grat(["grat.child_gone"])
	assert_eq(_with_sprite(loaded, "tal/gb_first_house").size(), 1, "and after loading")
	assert_eq(_doors_to(loaded, "urhaus").size(), 1)


func test_from_the_house_she_arrives_before_its_door_and_the_door_leads_in() -> void:
	SceneTravel.pending_spawn = "urhaus"
	var scene := await _grat(["grat.child_gone"])
	assert_eq(_cell(scene), HOUSE_ARRIVAL)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	Input.action_press(&"move_up")
	var gone := func() -> bool: return SceneTravel.last_target == "urhaus"
	await wait_until(gone, 6.0)
	Input.action_release(&"move_up")
	assert_eq(SceneTravel.last_target, "urhaus", "north from the arrival reaches the door")


func test_the_house_is_a_body_and_the_door_is_one_cell_in_front_of_its_foot() -> void:
	var scene := await _grat(["grat.child_gone"])
	var houses := _with_sprite(scene, "tal/gb_first_house")
	assert_eq(houses.size(), 1)
	assert_eq(HOUSE_DOOR, HOUSE + Vector2i(0, 1))
	assert_eq(HOUSE_ARRIVAL, HOUSE_DOOR + Vector2i(0, 2))
	assert_true(houses[0] is Decor)
	assert_true((houses[0] as Decor).get_child_count() > 0, "it has its picture and its body")
	assert_gt(
		Vector2(EDGE).distance_to(Vector2(HOUSE_ARRIVAL)), 2.0, "the arrival is not at the edge"
	)


# --- The book -----------------------------------------------------------------------------------


func test_the_summit_quest_begins_with_the_reading_and_ends_with_the_entry() -> void:
	var scene := await _grat(["grat.child_gone"])
	assert_false(WorldState.is_quest_started(SUMMIT))
	WorldState.set_flag("grat.summit_read")
	await wait_physics_frames(2)
	assert_true(WorldState.is_quest_started(SUMMIT), "begun by the reading")
	assert_eq(WorldState.quest_stage(SUMMIT), "read")
	WorldState.set_flag("grat.summit_signed")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(SUMMIT), "done", "ended by the entry")
	assert_true(scene.is_inside_tree())
	for key: String in [
		"QUEST_SIDE_GRAT_SUMMIT_TITLE", "QUEST_SIDE_GRAT_SUMMIT_READ", "QUEST_SIDE_GRAT_SUMMIT_DONE"
	]:
		assert_ne(tr(key), key, key)


func test_a_loaded_game_catches_the_summit_quest_up() -> void:
	var scene := await _grat(["grat.child_gone", "grat.summit_read", "grat.summit_signed"])
	assert_eq(WorldState.quest_stage(SUMMIT), "done")
	assert_true(scene.is_inside_tree())


func test_the_fragment_of_the_book_counts_as_a_trace_of_the_world() -> void:
	assert_eq(Collection.fragments(), 0)
	WorldState.set_flag("fragment.summit_book")
	assert_eq(Collection.fragments(), 1, "a trace, no picture of the child")
	assert_false(ChildMeeting.held_names().has("summit_book"), "it is not one of the six frames")
