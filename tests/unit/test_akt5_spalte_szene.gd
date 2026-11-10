extends GutTest
## Act V, segment G6: the Grat over the valley (docs/akt5/REGIONSBRIEFE.md, O7, O10). The ramp is
## free once the keeper has written the letting go down (`plant.letgo`): the blocker and the heap
## of scree at its foot go. On the ledge the walk of the hero takes its next step (`high`); at the
## very end of the cleft over the Anlage the scene sets the facet `courage` (nobody has to: the
## detour round the rock island leads to the plateau as well). What the cues say is tested in
## test_akt5_spalte_text, the ground and the reach of every thing in test_layout_akt5.py.

const GRAT := preload("res://world/levels/akt5/grat.tscn")
const QUEST := "main_mountain_way"
const RAMP_CELL := Vector2i(16, 19)
const HEAP_CELL := Vector2i(16, 18)
const ON_LEDGE := Vector2i(30, 8)
const MOUTH := Vector2i(74, 10)
const HALF := Vector2i(74, 13)
const BOTTOM := Vector2i(74, 16)
const VALLEY := Vector2i(50, 46)
## The things of the Grat by cue: the cell each one stands on.
const SPOTS := {
	"ledge_view": Vector2i(18, 9),
	"fork_sign": Vector2i(65, 9),
	"cleft_mouth": Vector2i(74, 10),
	"hiding_place": Vector2i(74, 16),
	"candle": Vector2i(75, 16),
	"plateau_edge": Vector2i(86, 10),
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


## The Grat, with the walk of the hero on `stage` ("letgo" after the letting go).
func _grat(stage := "letgo", flags: Array[String] = []) -> GratScene:
	for flag in flags:
		WorldState.set_flag(flag)
	WorldState.start_quest(QUEST)
	for next in ["valley", "plant", "load", "letgo", "high"]:
		if WorldState.quest_stage(QUEST) == stage:
			break
		WorldState.advance_quest(QUEST, next)
	var scene: GratScene = GRAT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


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


## The blocker whose middle is on this cell (blockers keep no cue), or null.
func _blocker_at(scene: GameScene, cell: Vector2i) -> Node:
	var at := scene.map.cell_to_world(cell)
	for node in _alive(scene):
		var script := node.get_script() as Script
		if script != null and script.resource_path.ends_with("blocker.gd"):
			if node.global_position.distance_to(at) < 20.0:
				return node
	return null


func _heap(scene: GameScene) -> Node:
	var at := scene.map.cell_to_world(HEAP_CELL)
	for node in _alive(scene):
		if node is Decor and (node as Decor).sprite_id == "tal/gb_rockfall":
			if node.global_position.distance_to(at) < 20.0:
				return node
	return null


# --- The ramp ----------------------------------------------------------------------------------


func test_before_the_letting_go_the_ramp_is_shut_by_a_blocker_and_a_heap_of_scree() -> void:
	var scene := await _grat("valley")
	assert_not_null(_blocker_at(scene, RAMP_CELL), "the blocker ramp_wait")
	assert_not_null(_heap(scene), "and the heap behind it")


func test_with_the_letting_go_the_blocker_and_the_heap_are_gone_live_and_after_loading() -> void:
	var scene := await _grat("valley")
	WorldState.set_flag("plant.letgo")
	await wait_physics_frames(3)
	assert_null(_blocker_at(scene, RAMP_CELL), "the keeper's entry opens the way")
	assert_null(_heap(scene), "and the scree is cleared")
	var loaded := await _grat("letgo", ["plant.letgo"])
	assert_null(_blocker_at(loaded, RAMP_CELL))
	assert_null(_heap(loaded))


func test_every_thing_of_the_grat_stands_on_its_cell_with_its_cue() -> void:
	var scene := await _grat("letgo", ["plant.letgo"])
	for cue: String in SPOTS:
		var node := _first(scene, cue)
		assert_not_null(node, "%s is on the map" % cue)
		if node != null:
			assert_eq(scene.map.world_to_cell(node.global_position), SPOTS[cue], cue)


func test_the_candle_lies_in_the_hollow_until_it_is_taken() -> void:
	var scene := await _grat("letgo", ["plant.letgo"])
	assert_not_null(_first(scene, "candle"))
	WorldState.set_flag("grat.candle_taken")
	await wait_physics_frames(3)
	assert_null(_first(scene, "candle"), "gone once it is taken")
	var again := await _grat("letgo", ["plant.letgo", "grat.candle_taken"])
	assert_null(_first(again, "candle"), "and after loading")
	assert_not_null(_first(again, "hiding_place"), "the hollow itself stays")


# --- The walk of the hero, the facet -----------------------------------------------------------


func test_standing_on_the_ledge_takes_the_walk_one_step_on_and_marks_the_beat_once() -> void:
	var scene := await _grat("letgo", ["plant.letgo"])
	assert_eq(WorldState.quest_stage(QUEST), "letgo")
	assert_false(Beat.reached("grat_ledge"))
	await _put(scene, VALLEY)
	assert_eq(WorldState.quest_stage(QUEST), "letgo", "not in the valley")
	await _put(scene, ON_LEDGE)
	assert_eq(WorldState.quest_stage(QUEST), "high")
	assert_true(Beat.reached("grat_ledge"))
	await _put(scene, VALLEY)
	await _put(scene, ON_LEDGE)
	assert_eq(WorldState.quest_stage(QUEST), "high", "and it stays there")


func test_the_hero_stage_high_is_the_end_of_the_walk_for_now() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_true(quest.can_advance("letgo", "high"))
	assert_false(quest.stage("letgo").is_final(), "the way over the Grat hangs on it (G6)")
	assert_true(quest.stage("high").is_final(), "and the child on that (G7)")
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_HIGH"), "QUEST_MAIN_MOUNTAIN_WAY_HIGH")


func test_courage_is_set_at_the_very_end_of_the_cleft_and_not_before() -> void:
	var scene := await _grat("letgo", ["plant.letgo"])
	for cell in [ON_LEDGE, MOUTH, HALF]:
		await _put(scene, cell)
		assert_false(WorldState.has_facet("courage"), "not at %s" % cell)
	assert_false(Beat.reached("grat_cleft"))
	await _put(scene, BOTTOM)
	assert_true(WorldState.has_facet("courage"), "the narrow way taken to its end")
	assert_true(Beat.reached("grat_cleft"))


func test_the_hollow_can_be_left_alone_and_the_plateau_is_reached_by_the_detour() -> void:
	# nothing is a duty: whoever does not go into the cleft has no facet and misses no scene
	var scene := await _grat("letgo", ["plant.letgo"])
	await _put(scene, Vector2i(86, 8))
	assert_false(WorldState.has_facet("courage"))
	assert_eq(WorldState.quest_stage(QUEST), "high", "the walk goes on without it")
	assert_false(WorldState.has_flag("fragment.hiding"), "and the picture waits in the hollow")
	assert_false(scene.player.is_locked(), "nothing is locked")


func test_a_flashback_marks_its_beat_and_counts_as_a_fragment() -> void:
	var scene := await _grat("letgo", ["plant.letgo"])
	assert_eq(Collection.fragments(), 0)
	WorldState.set_flag("fragment.hiding")
	await wait_physics_frames(2)
	assert_true(Beat.reached("grat_hiding"))
	assert_eq(Collection.fragments(), 1, "a picture of the child, and the second one")
	assert_true(scene.is_inside_tree())
