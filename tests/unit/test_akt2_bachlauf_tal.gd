extends GutTest
## Act II, segment B3, the valley's side of the Bachlauf: the hedge opens by the stream and a path
## leads south. Until Mira's visit the rain has made it mud and a blocker keeps you back; after it a
## door leads down, and the way back arrives at the place made for it. The Bachlauf itself is tested
## in test_akt2_bachlauf_szene.

const TAL := preload("res://world/levels/slice/tal.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const BLOCKER_CELL := Vector2i(42, 35)
const DOOR_CELL := Vector2i(42, 37)
const ARRIVAL_CELL := Vector2i(42, 33)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


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


func _doors(scene: GameScene) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == "bachlauf" and not node.is_queued_for_deletion()
	)


func test_until_mira_has_visited_the_wet_path_holds_you_back() -> void:
	var scene := await _valley()
	assert_not_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "mud behind the hedge")
	assert_eq(_doors(scene).size(), 0, "no way down yet")


func test_after_her_visit_the_door_leads_down_and_the_blocker_is_gone() -> void:
	SceneTravel.stay = true
	WorldState.set_flag("house.mira_visited")
	var scene := await _valley()
	assert_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT))
	var doors := _doors(scene)
	assert_eq(doors.size(), 1)
	assert_eq(
		doors[0].get(&"spawn"), "tal", "arriving where the Bachlauf made the place for the valley"
	)
	scene.player.global_position = scene.map.cell_to_world(DOOR_CELL)
	await wait_physics_frames(4)
	assert_eq(SceneTravel.last_target, "bachlauf")


func test_the_way_back_arrives_at_the_gap_and_marks_the_beat_in_the_valley() -> void:
	WorldState.set_flag("house.mira_visited")
	assert_false(Beat.reached("bachlauf_back"))
	SceneTravel.pending_spawn = "bach"
	var scene := await _valley()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	assert_true(Beat.reached("bachlauf_back"))
