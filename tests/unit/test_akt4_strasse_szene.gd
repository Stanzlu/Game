extends GutTest
## Act IV, segment S1: the road west (docs/akt4/REGIONSBRIEFE.md). A cart road from the valley
## through fields and an orchard, over a brook, to a hill from which the city's smoke is seen; at
## its end a rope and paving works hold the way until S2. The map is the third of class M (96 x 56
## cells), a morning without lights. The scene only starts the hero's walk and marks two beats. What
## the cues say is tested in test_akt4_strasse, the valley's door in test_akt4_strasse_tal.

const STRASSE := preload("res://world/levels/akt4/strasse.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const QUEST := "main_city_way"
const SIZE := Vector2i(96, 56)
const START := Vector2i(88, 30)
const FROM_VALLEY := Vector2i(89, 30)
const FROM_CITY := Vector2i(11, 32)
const DOOR_CELL := Vector2i(94, 30)
const BLOCKER_CELL := Vector2i(4, 32)
const BRIDGE_ROW := 31
const CUES: PackedStringArray = [
	"signpost",
	"goat_prints",
	"field_notice",
	"scarecrow",
	"milestone",
	"goat_bell",
	"view_town",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> StrasseScene:
	var scene: StrasseScene = STRASSE.instantiate()
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


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


func _cell(scene: GameScene) -> Vector2i:
	return scene.map.world_to_cell(scene.player.global_position)


func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


## A prop with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


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


# --- The map ------------------------------------------------------------------------------------


func test_the_road_is_a_map_of_class_m_with_its_places_and_markers() -> void:
	var scene := await _scene()
	var data := scene.map.data
	assert_eq(Vector2i(data.width, data.height), SIZE)
	assert_lte(data.width * data.height, 120 * 70, "class M (ADR-068)")
	assert_eq(data.find_marker("player_spawn")[0]["cell"], START)
	assert_eq(data.find_marker("spawn_tal")[0]["cell"], FROM_VALLEY)
	assert_eq(data.find_marker("spawn_stadt")[0]["cell"], FROM_CITY)
	assert_eq(_cell(scene), START, "a game begun here stands at the east end")


func test_every_thing_of_the_road_is_there_with_its_cue() -> void:
	var scene := await _scene()
	for cue: String in CUES:
		assert_not_null(_first(scene, cue), cue)
	assert_eq(_decor_with(scene, "tal/st_milestone").size(), 1, "one milestone")
	assert_eq(_decor_with(scene, "tal/st_scarecrow").size(), 1, "one scarecrow")
	assert_eq(_decor_with(scene, "tal/st_sign_two").size(), 1, "one signpost with two arrows")
	assert_gte(_decor_with(scene, "tal/st_prints").size(), 4, "prints in the dust, one with a cue")
	assert_eq(scene.find_children("*", "NpcWalker", true, false).size(), 0, "nobody is here")


func test_it_is_a_morning_without_lights_and_without_a_cutscene() -> void:
	var scene := await _scene()
	assert_eq(scene.day_light.preset, "morgen")
	assert_eq(scene.find_children("*", "PointLight2D", true, false).size(), 0, "ADR-071 O3")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(scene.player.is_locked(), "nothing holds her on the road")


# --- The walk and the beats -----------------------------------------------------------------


func test_entering_the_road_starts_the_walk_and_marks_the_beat() -> void:
	assert_eq(WorldState.quest_stage(QUEST), "", "not before")
	var scene := await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "west")
	assert_true(Beat.reached("strasse_enter"))
	assert_false(Beat.reached("strasse_view"), "the view is not seen yet")
	assert_not_null(scene)


func test_coming_back_does_not_start_the_walk_again() -> void:
	WorldState.start_quest(QUEST)
	var before := WorldState.state.quests[QUEST].history.duplicate()
	var scene := await _scene()
	assert_eq(WorldState.state.quests[QUEST].history, before, "nothing restarted")
	assert_not_null(scene)


func test_the_view_marks_the_beat_when_it_is_seen() -> void:
	var scene := await _scene()
	WorldState.set_flag("city.view_seen")
	await wait_physics_frames(2)
	assert_true(Beat.reached("strasse_view"))
	assert_not_null(scene)


func test_the_bell_hangs_until_it_is_taken_and_the_post_stays() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "tal/st_bell").size(), 1)
	assert_eq(_decor_with(scene, "tal/st_post").size(), 1)
	WorldState.set_flag("city.bell_taken")
	await wait_physics_frames(3)
	assert_eq(_decor_with(scene, "tal/st_bell").size(), 0, "the nail is empty")
	assert_eq(_decor_with(scene, "tal/st_post").size(), 1, "the post stays")
	var again := await _scene()
	assert_eq(_decor_with(again, "tal/st_bell").size(), 0, "and a game loaded after that has none")


# --- The doors and the end of the road ---------------------------------------------------------


func test_the_only_door_leads_back_to_the_valley() -> void:
	var scene := await _scene()
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node.get(&"target") != null
	)
	assert_eq(doors.size(), 1, "the city has no door yet: S2 sets it in")
	assert_eq(doors[0].get(&"target"), "tal")
	assert_eq(doors[0].get(&"spawn"), "strasse")
	assert_eq(scene.map.world_to_cell((doors[0] as Node2D).global_position), DOOR_CELL)


func test_from_the_valley_she_arrives_at_the_east_end_and_walking_east_returns() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "tal"
	var scene := await _scene()
	assert_eq(_cell(scene), FROM_VALLEY)
	assert_gte(DOOR_CELL.x - FROM_VALLEY.x, 3, "an arrival outside the door's zone")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "tal"
	assert_true(await _hold(&"move_right", gone, 300), "east from the arrival reaches the door")


func test_the_way_west_crosses_the_brook_on_the_bridge() -> void:
	var scene := await _scene()
	await _put(scene, Vector2i(66, BRIDGE_ROW))
	var across := func() -> bool: return _cell(scene).x < 55
	assert_true(await _hold(&"move_left", across, 400), "over the stones to the other bank")
	assert_eq(SceneTravel.last_target, "", "no scene change on the way")


func test_a_rope_and_the_paving_works_hold_the_whole_width_of_the_road() -> void:
	var scene := await _scene()
	assert_not_null(_blocker(scene), "the blocker across the road")
	var map_text := FileAccess.get_file_as_string("res://content/maps/strasse.txt")
	assert_true(map_text.contains('"cue": "town_wait"'), "with the cue of the paving works")
	assert_gte(FROM_CITY.x - BLOCKER_CELL.x, 5, "the arrival from the city is outside it")
	for row: int in [30, 32, 34]:
		await _put(scene, Vector2i(14, row))
		var never := func() -> bool: return false
		await _hold(&"move_left", never, 120)
		assert_gt(_cell(scene).x, BLOCKER_CELL.x, "row %d is held in front of the rope" % row)
		assert_lt(_cell(scene).x, 12, "and she did walk west on it")
	assert_eq(SceneTravel.last_target, "", "and there is no way on")
