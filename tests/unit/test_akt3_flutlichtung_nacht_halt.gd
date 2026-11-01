extends GutTest
## Act III, segment W5, the way on to the south of the Flutlichtung before the night: whoever has
## not walked the wood to its night (no walk at all, or the walk at the leave, the brook or the
## wood) is held by the blocker in the gap, and the door behind it is not reached by walking on.
## That the way opens at the night, the arrival from the night wood and the door itself are tested
## in test_akt3_flutlichtung_nacht.

const FLUT := preload("res://world/levels/akt3/flutlichtung.tscn")
const BLOCKER_SCRIPT := preload("res://world/props/blocker.gd")
const DOOR_SCRIPT := preload("res://world/props/door.gd")
const QUEST := "main_forest_way"
const FLAG := "forest.night_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night", "home", "done"]
const BLOCKER_CELL := Vector2i(34, 50)
const DOOR_CELL := Vector2i(34, 52)
## Four rows north of the blocker, on the path itself.
const BEFORE_BLOCKER := Vector2i(34, 46)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")
	SceneTravel.stay = true


func after_each() -> void:
	Input.action_release(&"move_down")
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


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


## Walks south from `BEFORE_BLOCKER` for `frames` physics frames, as far as she gets.
func _walk_south(scene: GameScene, frames: int) -> void:
	scene.player.global_position = scene.map.cell_to_world(BEFORE_BLOCKER)
	scene.player.velocity = Vector2.ZERO
	await wait_physics_frames(2)
	Input.action_press(&"move_down")
	var left := frames
	while left > 0:
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_down")


func test_whoever_has_not_walked_to_the_night_is_held_before_the_door_to_the_night_wood() -> void:
	for stage: String in ["", "leave", "brook", "wood"]:
		WorldState.new_game()
		if not stage.is_empty():
			_walk_to(stage)
		var scene := await _scene()
		var label := "walk '%s'" % stage if not stage.is_empty() else "no walk"
		assert_not_null(_at(scene, BLOCKER_CELL, BLOCKER_SCRIPT), "%s: the blocker stands" % label)
		assert_not_null(_at(scene, DOOR_CELL, DOOR_SCRIPT), "%s: the door lies behind it" % label)
		await _walk_south(scene, 360)
		var row := scene.map.world_to_cell(scene.player.global_position).y
		assert_lt(row, BLOCKER_CELL.y, "%s: she stands before the blocker" % label)
		assert_eq(SceneTravel.last_target, "", "%s: the door is not reached" % label)
		assert_false(WorldState.has_flag(FLAG), "%s: and walking on opens nothing" % label)
		scene.queue_free()
		await wait_physics_frames(2)
	assert_push_error_count(0)


func test_with_the_night_reached_the_same_walk_goes_through_to_the_door() -> void:
	_walk_to("night")
	var scene := await _scene()
	await _walk_south(scene, 360)
	assert_eq(SceneTravel.last_target, "nachtwald", "nothing holds her at the night")
