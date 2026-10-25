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
	Input.action_release(&"move_down")
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


## Holds `action` until `done` holds or `frames` physics frames have passed; true if it held.
func _hold(action: StringName, done: Callable, frames: int) -> bool:
	Input.action_press(action)
	var left := frames
	while left > 0 and not done.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(action)
	return done.call()


func _doors(scene: GameScene) -> Array:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == "bachlauf" and not node.is_queued_for_deletion()
	)


func test_until_mira_has_visited_the_wet_path_holds_you_back() -> void:
	var scene := await _valley()
	var blocker := _at(scene, BLOCKER_CELL, BLOCKER_SCRIPT)
	assert_not_null(blocker, "mud behind the hedge")
	assert_eq(_doors(scene).size(), 0, "no way down yet")
	# the blocker covers the whole gap (three cells), and nobody walks past it: from the cell above it
	# the player holds south and stays above the hedge line
	scene.player.global_position = scene.map.cell_to_world(Vector2i(42, 34))
	await wait_physics_frames(2)
	var below := func() -> bool:
		return scene.map.world_to_cell(scene.player.global_position).y >= BLOCKER_CELL.y + 1
	assert_false(await _hold(&"move_down", below, 120), "the mud holds the player back")
	assert_lt(scene.map.world_to_cell(scene.player.global_position).y, BLOCKER_CELL.y + 1)


func test_after_her_visit_the_door_leads_down_and_the_blocker_is_gone() -> void:
	SceneTravel.stay = true
	WorldState.set_flag("house.mira_visited")
	SceneTravel.pending_spawn = "bach"
	var scene := await _valley()
	assert_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT))
	var doors := _doors(scene)
	assert_eq(doors.size(), 1)
	assert_eq(
		doors[0].get(&"spawn"), "tal", "arriving where the Bachlauf made the place for the valley"
	)
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "bachlauf"
	assert_true(
		await _hold(&"move_down", gone, 300), "walking south from the arrival reaches the door"
	)


func test_the_way_back_arrives_at_the_gap_and_marks_the_beat_in_the_valley() -> void:
	WorldState.set_flag("house.mira_visited")
	assert_false(Beat.reached("bachlauf_back"))
	SceneTravel.pending_spawn = "bach"
	var scene := await _valley()
	assert_eq(scene.map.world_to_cell(scene.player.global_position), ARRIVAL_CELL)
	assert_true(Beat.reached("bachlauf_back"))


func test_an_ordinary_arrival_in_the_valley_does_not_mark_the_way_back() -> void:
	# the beat says "came back from the stream", not "was in the valley"
	WorldState.set_flag("house.mira_visited")
	SceneTravel.pending_spawn = "rift"
	await _valley()
	assert_false(Beat.reached("bachlauf_back"))
