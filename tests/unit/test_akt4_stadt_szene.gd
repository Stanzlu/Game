extends GutTest
## Act IV, segment S2: the city (docs/akt4/REGIONSBRIEFE.md). A walled town seen from the south,
## 108 x 62 cells of class M: a gate with its keeper, the square with the fountain, the board of
## the Gefällige's slips, the town hall, two shops that are still shut, Lio in his corner, three
## stations of a perfect day, a goat on a roof. A morning without lights. The scene only goes on
## with the hero's walk, plays Lio's tune once and marks two beats. What the cues say is tested in
## test_akt4_platz, the town hall in test_akt4_rathaus_szene, the road's door in
## test_akt4_strasse_szene.

const STADT := preload("res://world/levels/akt4/stadt.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const BENCH_SCRIPT := preload("res://world/props/bench.gd")
const GOAT_SCRIPT := preload("res://world/props/goat.gd")
const QUEST := "main_city_way"
const SIZE := Vector2i(108, 62)
const START := Vector2i(64, 28)
const FROM_ROAD := Vector2i(99, 54)
const ROAD_DOOR := Vector2i(106, 54)
const HALL_DOOR := Vector2i(44, 19)
const MARKERS := {
	"player_spawn": Vector2i(64, 28),
	"spawn_strasse": Vector2i(99, 54),
	"spawn_rathaus": Vector2i(43, 22),
	"spawn_blumenladen": Vector2i(30, 29),
	"spawn_werkstatt": Vector2i(22, 41),
}
const WALKERS := {
	"gate": Vector2i(83, 45),
	"mira_square": Vector2i(56, 31),
	"gef_square": Vector2i(55, 22),
	"citizen_1": Vector2i(37, 22),
	"lio_street": Vector2i(79, 36),
}
const PROPS: PackedStringArray = [
	"list_board",
	"fountain_rim",
	"day_wreath",
	"day_lectern",
	"day_table",
]
const FLORIST_DOOR := Vector2i(30, 27)
const WORKSHOP_DOOR := Vector2i(22, 39)
const BENCH_CELL := Vector2i(25, 41)
const TESS_CELL := Vector2i(28, 41)
const CRATE_CELL := Vector2i(28, 40)
const DUCK_CELL := Vector2i(33, 28)
const POTS_CELL := Vector2i(31, 28)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_right")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> StadtScene:
	var scene: StadtScene = STADT.instantiate()
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


func _cell_of(scene: GameScene, node: Node) -> Vector2i:
	return scene.map.world_to_cell((node as Node2D).global_position)


func _walker(scene: GameScene, cue: String) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if (
			node is NpcWalker
			and (node as NpcWalker).cue == cue
			and not node.is_queued_for_deletion()
		):
			return node as NpcWalker
	return null


func _prop(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if (
			not node.is_queued_for_deletion()
			and node.has_meta(&"cue")
			and node.get_meta(&"cue") == cue
		):
			return node
	return null


func _doors_to(scene: GameScene, target: String) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == target and not node.is_queued_for_deletion()
	)


# --- The map ------------------------------------------------------------------------------------


func test_the_city_is_a_map_of_class_m_with_its_markers() -> void:
	var scene := await _scene()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_lte(data.width * data.height, 120 * 70, "class M (ADR-068)")
	for marker: String in MARKERS:
		assert_eq(data.find_marker(marker)[0]["cell"], MARKERS[marker], marker)
	assert_eq(_cell(scene), START, "a game begun here stands on the square")


func test_the_start_is_far_from_every_door_because_the_benchmark_walks_right_first() -> void:
	var scene := await _scene()
	for door: Node in scene.map.entities.get_children():
		if door.get(&"target") != null:
			var cell := _cell_of(scene, door)
			var distance := Vector2(cell - START).length()
			assert_gt(distance, 20.0, "door to %s" % door.get(&"target"))


func test_every_walker_stands_at_its_place_with_its_cue() -> void:
	var scene := await _scene()
	for cue: String in WALKERS:
		var walker := _walker(scene, cue)
		assert_not_null(walker, cue)
		assert_eq(_cell_of(scene, walker), WALKERS[cue], cue)
	assert_true(_walker(scene, "mira_square").seated, "Mira sits at the rim of the fountain")
	assert_true(_walker(scene, "lio_street").seated, "Lio sits on his crate")
	assert_eq(_walker(scene, "gef_square").facing, Facing.Dir.N, "he looks at his board")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 5, "five, no crowd")


func test_the_things_of_the_square_are_there_with_their_cues() -> void:
	var scene := await _scene()
	for cue in PROPS:
		assert_not_null(_prop(scene, cue), cue)
	var goat: Node = null
	for node in scene.map.entities.get_children():
		if node.get_script() == GOAT_SCRIPT and not node.is_queued_for_deletion():
			goat = node
	assert_not_null(goat, "the goat is on the roof of the town hall")
	assert_eq(_cell_of(scene, goat), Vector2i(40, 19))


func test_both_shops_have_a_door_on_the_cell_of_their_former_blocker() -> void:
	var scene := await _scene()
	for pair: Array in [
		["blumenladen", FLORIST_DOOR, "to the place the florist made for it"],
		["werkstatt", WORKSHOP_DOOR, "to the place the workshop made for it"],
	]:
		var doors := _doors_to(scene, pair[0])
		assert_eq(doors.size(), 1, pair[0])
		assert_eq(doors[0].get(&"spawn"), "stadt", pair[2])
		assert_eq(_cell_of(scene, doors[0]), pair[1], pair[0])
	for node in scene.map.entities.get_children():
		assert_ne(node.get_script(), BLOCKER_SCRIPT, "no blocker is left in the city")


func _decor_at(scene: GameScene, sprite: String, cell: Vector2i) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id == sprite
				and not node.is_queued_for_deletion()
				and _cell_of(scene, node) == cell
			)
	)


func test_a_duck_stands_before_the_florist_in_both_endings_and_the_pots_come_out_with_one() -> void:
	var scene := await _scene()
	var duck := _prop(scene, "duck")
	assert_not_null(duck, "she is a thing to look at, with the florist's cue")
	assert_eq(_cell_of(scene, duck), DUCK_CELL)
	assert_eq((duck as Decor).sprite_id, "tal/st_duck")
	assert_eq(_decor_at(scene, "tal/st_pots", POTS_CELL).size(), 0, "no pots before the report")
	scene.free()
	for flag: String in ["city.duck_passed", "city.duck_stayed"]:
		WorldState.new_game()
		WorldState.set_flag(flag)
		var later := await _scene()
		assert_not_null(_prop(later, "duck"), "unmoved: " + flag)
		var pots := _decor_at(later, "tal/st_pots", POTS_CELL).size()
		assert_eq(pots, 1 if flag == "city.duck_passed" else 0, flag)
		later.free()


func test_before_the_board_is_sawn_the_bench_stands_alone_and_tess_is_not_outside() -> void:
	var scene := await _scene()
	var benches := scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get_script() == BENCH_SCRIPT and _cell_of(scene, node) == BENCH_CELL
	)
	assert_eq(benches.size(), 1, "the bench before the workshop is there from the first day")
	assert_null(_walker(scene, "bench"), "Tess works inside")
	assert_eq(
		_decor_at(scene, "tal/st_seat_crate", CRATE_CELL).size(), 0, "and has no crate out here"
	)


func test_once_the_board_is_sawn_tess_sits_on_her_crate_beside_the_bench() -> void:
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	var tess := _walker(scene, "bench")
	assert_not_null(tess)
	assert_eq(_cell_of(scene, tess), TESS_CELL)
	assert_eq(_decor_at(scene, "tal/st_seat_crate", CRATE_CELL).size(), 1, "the crate she sits on")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 6, "five and she")


func test_it_is_a_morning_without_lights_and_without_a_cutscene() -> void:
	var scene := await _scene()
	assert_eq(scene.day_light.preset, "morgen")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-071 O3")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked(), "nothing holds her in the city")


func test_the_space_before_the_town_hall_stays_free_for_the_stage_of_s6() -> void:
	# the stage of the concert stands between x 40 and 48, y 20 to 25, before the hall: nothing may be
	# built there but the lectern and the arrival marker
	var scene := await _scene()
	var lectern := _prop(scene, "day_lectern")
	var allowed := [_cell_of(scene, lectern), MARKERS["spawn_rathaus"]]
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion() or not (node is Node2D) or node is Sprite2D:
			continue
		var cell := _cell_of(scene, node)
		if cell.x >= 40 and cell.x <= 48 and cell.y >= 20 and cell.y <= 25:
			assert_true(
				cell in allowed or node.get_script() == GOAT_SCRIPT or node is NpcWalker,
				"%s at %s" % [node.name, cell]
			)


# --- The doors ----------------------------------------------------------------------------------


func test_two_doors_one_to_the_road_and_one_to_the_town_hall() -> void:
	var scene := await _scene()
	var road := _doors_to(scene, "strasse")
	assert_eq(road.size(), 1)
	assert_eq(road[0].get(&"spawn"), "stadt")
	assert_true(road[0].get(&"auto"), "the end of the map")
	assert_eq(_cell_of(scene, road[0]), ROAD_DOOR)
	var hall := _doors_to(scene, "rathaus")
	assert_eq(hall.size(), 1)
	assert_eq(hall[0].get(&"spawn"), "stadt")
	assert_false(hall[0].get(&"auto"), "a house door: one asks to go in")
	assert_eq(_cell_of(scene, hall[0]), HALL_DOOR)


func test_from_the_road_she_arrives_outside_the_wall_and_east_returns_to_it() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "strasse"
	var scene := await _scene()
	assert_eq(_cell(scene), FROM_ROAD)
	assert_gte(ROAD_DOOR.x - FROM_ROAD.x, 5, "an arrival outside the door's zone")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "strasse"
	assert_true(await _hold(&"move_right", gone, 300), "east from the arrival reaches the door")


# --- The walk and the beats ------------------------------------------------------------------


func test_entering_the_city_takes_the_walk_from_the_road_to_the_town_and_marks_the_beat() -> void:
	WorldState.start_quest(QUEST)
	assert_eq(WorldState.quest_stage(QUEST), "west")
	var scene := await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "town")
	assert_true(Beat.reached("stadt_enter"))
	assert_false(Beat.reached("stadt_lio"), "nobody has played yet")
	assert_not_null(scene)


func test_a_game_begun_in_the_city_has_no_walk_and_that_is_no_error() -> void:
	var scene := await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "", "the road was never walked")
	assert_true(Beat.reached("stadt_enter"))
	assert_not_null(scene)


func test_the_town_is_not_left_again_by_a_second_visit() -> void:
	WorldState.start_quest(QUEST)
	await _scene()
	var history := WorldState.state.quests[QUEST].history.duplicate()
	var again := await _scene()
	assert_eq(WorldState.state.quests[QUEST].history, history, "nothing restarted")
	assert_not_null(again)


func test_lios_tune_marks_its_beat_when_the_melody_is_set() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.lio_street")
	await wait_physics_frames(2)
	assert_true(Beat.reached("stadt_lio"))
	assert_not_null(scene)
