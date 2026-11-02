extends GutTest
## Act IV, segment S5: the list in the city (docs/akt4/REGIONSBRIEFE.md, O5). Each of the six
## tasks of the Gefällige has its place in the city, and the place shows what became of it: a
## fresh slip while the task is taken and not yet done, a struck one (with a small "sorry" beside
## it) once the list is closed and she did not take it, nothing if it is done or the list is not
## closed. The choice and its consequence are never in the same cue: the choice is tested in
## test_akt4_liste, this file only reads the places.

const STADT := preload("res://world/levels/akt4/stadt.tscn")
const FRESH := "tal/st_slip_open"
const STRUCK := "tal/st_slip_struck"
## The six tasks: the cell of the fresh slip and, beside it, of the struck one.
const PLACES := {
	"bouquet": [Vector2i(32, 27), Vector2i(31, 27)],
	"ladder": [Vector2i(24, 39), Vector2i(25, 39)],
	"stage": [Vector2i(44, 26), Vector2i(45, 26)],
	"goat": [Vector2i(46, 19), Vector2i(47, 19)],
	"bread": [Vector2i(68, 26), Vector2i(67, 26)],
	"lost": [Vector2i(42, 19), Vector2i(41, 19)],
}


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


func _scene() -> StadtScene:
	var scene: StadtScene = STADT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## How many slips of this look stand on this cell.
func _slips(scene: GameScene, sprite: String, cell: Vector2i) -> int:
	return (
		scene
		. map
		. entities
		. get_children()
		. filter(
			func(node: Node) -> bool:
				return (
					node is Decor
					and (node as Decor).sprite_id == sprite
					and not node.is_queued_for_deletion()
					and scene.map.world_to_cell((node as Node2D).global_position) == cell
				)
		)
		. size()
	)


func _every_slip(scene: GameScene) -> int:
	var total := 0
	for task: String in PLACES:
		total += _slips(scene, FRESH, PLACES[task][0]) + _slips(scene, STRUCK, PLACES[task][1])
	return total


func test_before_the_list_is_opened_the_city_has_no_slips() -> void:
	var scene := await _scene()
	assert_eq(_every_slip(scene), 0, "the board has sixteen, the places none")


func test_the_list_open_but_not_closed_still_shows_nothing_at_the_places() -> void:
	WorldState.set_flag("list.opened")
	var scene := await _scene()
	assert_eq(_every_slip(scene), 0, "nothing is taken and nothing is refused yet")


func test_a_taken_task_has_a_fresh_slip_at_its_place_until_it_is_done() -> void:
	for task: String in PLACES:
		WorldState.new_game()
		WorldState.set_flag("list.take_" + task)
		var scene := await _scene()
		assert_eq(_slips(scene, FRESH, PLACES[task][0]), 1, "%s: the slip hangs there" % task)
		assert_eq(_slips(scene, STRUCK, PLACES[task][1]), 0, "%s: and no struck one" % task)
		assert_eq(_every_slip(scene), 1, "%s: and only this one" % task)
		WorldState.set_flag("list.done_" + task)
		await wait_physics_frames(3)
		assert_eq(_slips(scene, FRESH, PLACES[task][0]), 0, "%s: done, the slip is gone" % task)
		scene.free()


func test_a_refused_task_has_a_struck_slip_at_its_place_once_the_list_is_closed() -> void:
	for task: String in PLACES:
		WorldState.new_game()
		WorldState.set_flag("list.closed")
		var scene := await _scene()
		assert_eq(_slips(scene, STRUCK, PLACES[task][1]), 1, "%s: struck, with the sorry" % task)
		assert_eq(_slips(scene, FRESH, PLACES[task][0]), 0, "%s: no fresh one" % task)
		scene.free()


func test_a_task_taken_before_the_list_closes_is_never_struck() -> void:
	WorldState.set_flag("list.take_stage")
	WorldState.set_flag("list.closed")
	var scene := await _scene()
	assert_eq(_slips(scene, FRESH, PLACES["stage"][0]), 1, "taken: fresh")
	assert_eq(_slips(scene, STRUCK, PLACES["stage"][1]), 0, "and not struck as well")
	var struck := 0
	for task: String in PLACES:
		struck += _slips(scene, STRUCK, PLACES[task][1])
	assert_eq(struck, 5, "the five she did not take")


func test_the_slips_change_while_she_stands_there() -> void:
	var scene := await _scene()
	WorldState.set_flag("list.take_bread")
	await wait_physics_frames(3)
	assert_eq(_slips(scene, FRESH, PLACES["bread"][0]), 1, "taken: the slip appears")
	WorldState.set_flag("list.closed")
	await wait_physics_frames(3)
	assert_eq(_slips(scene, STRUCK, PLACES["bread"][1]), 0, "the one she took is not struck")
	assert_eq(_slips(scene, STRUCK, PLACES["bouquet"][1]), 1, "the one she did not is")


func test_each_slip_can_be_looked_at_with_its_cue() -> void:
	WorldState.set_flag("list.take_goat")
	WorldState.set_flag("list.closed")
	var scene := await _scene()
	var cues := {}
	for node in scene.map.entities.get_children():
		if node is Decor and node.has_meta(&"cue"):
			var cue := str(node.get_meta(&"cue"))
			if cue == "do_goat" or cue == "slip_struck":
				cues[cue] = int(cues.get(cue, 0)) + 1
	assert_eq(cues.get("do_goat", 0), 1, "the fresh slip is a task to do")
	assert_eq(cues.get("slip_struck", 0), 5, "the five struck ones all say the same")
