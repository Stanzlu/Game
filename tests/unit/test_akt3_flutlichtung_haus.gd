extends GutTest
## Act III, segments W4 and W6: once the Antreiber has gone ahead to the Flutlichtung, the house
## must not send him in through its door (the visit of Act II is still pending for a player who lit
## the fire and did not sit long enough to see it): he would stand in two places at once. The same
## holds when the walk is over (W6): with the workbench in the house (house.workbench) he sits at
## it, in whatever state he came home in, and he is neither at the fire, nor expected through the
## door, nor in the clearing, on the path or in the valley.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const FLUTLICHTUNG := preload("res://world/levels/akt3/flutlichtung.tscn")
const WALDWEG := preload("res://world/levels/akt3/waldweg.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const ANTREIBER_SHEET := "res://entities/character/sheet_antreiber_look.tres"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_the_visit_is_expected_until_he_has_gone_ahead() -> void:
	WorldState.set_flag("valley.wood_taken")
	var scene := await _scene()
	assert_true(scene._antreiber_pending(), "wood taken, not at the fire, not gone: he is expected")
	WorldState.set_flag("forest.antreiber_ahead")
	assert_false(scene._antreiber_pending(), "he is in the clearing: he does not come in")


func test_the_other_states_still_end_the_visit() -> void:
	WorldState.set_flag("valley.wood_taken")
	WorldState.set_flag("house.antreiber_left")
	var scene := await _scene()
	assert_false(scene._antreiber_pending(), "he has left")
	WorldState.new_game()
	WorldState.set_flag("valley.wood_taken")
	WorldState.set_flag("house.antreiber_by_fire")
	assert_false(scene._antreiber_pending(), "he sits by the fire already")
	WorldState.new_game()
	assert_false(scene._antreiber_pending(), "no wood taken: nobody is expected yet")


func test_the_visit_is_never_expected_once_the_workbench_stands() -> void:
	WorldState.set_flag("valley.wood_taken")
	var scene := await _scene()
	assert_true(scene._antreiber_pending(), "wood taken, not at the fire, not gone: he is expected")
	WorldState.set_flag("house.workbench")
	assert_false(
		scene._antreiber_pending(), "he sits at the bench: he does not come in at the door"
	)


## How many men with the Antreiber's sheet stand on the map of this scene.
func _antreiber_in(packed: PackedScene) -> int:
	var scene: GameScene = packed.instantiate()
	if scene is HausScene:
		(scene as HausScene).mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var count := 0
	for node in scene.map.entities.get_children():
		if (
			node is NpcWalker
			and not node.is_queued_for_deletion()
			and (node as NpcWalker).sheet.resource_path == ANTREIBER_SHEET
		):
			count += 1
	scene.queue_free()
	await wait_physics_frames(2)
	return count


func test_with_the_workbench_he_is_in_the_house_and_in_no_other_place() -> void:
	var states: Array[Array] = [
		["house.antreiber_by_fire"],
		["house.antreiber_by_fire", "house.antreiber_refused"],
		["house.antreiber_left"],
		["house.antreiber_left", "house.antreiber_postponed"],
		["valley.antreiber_rests"],
		["forest.antreiber_met", "forest.antreiber_sat"],
		["forest.flood_sat"],
		[],
	]
	for state: Array in states:
		WorldState.new_game()
		for flag: String in ["house.fire_lit", "house.mira_visited", "house.workbench"]:
			WorldState.set_flag(flag)
		for flag: String in state:
			WorldState.set_flag(flag)
		# the walk went through the clearing: whoever did not leave him at the fire has been there
		# (the clearing sets forest.antreiber_ahead), so it comes first, as in the game
		assert_eq(await _antreiber_in(FLUTLICHTUNG), 0, "not in the clearing %s" % [state])
		assert_eq(await _antreiber_in(WALDWEG), 0, "not on the path %s" % [state])
		assert_eq(await _antreiber_in(TAL), 0, "not in the valley %s" % [state])
		assert_eq(await _antreiber_in(HAUS), 1, "once in the house, at the bench %s" % [state])


func test_the_clearing_is_without_him_at_the_tea_too_once_he_sits_at_the_bench() -> void:
	# the scene swaps the standing man for the sitting one when the tea is made (forest.flood_sat);
	# with the bench in the house neither is there, and the swap finds nothing to swap
	WorldState.set_flag("house.workbench")
	var scene: GameScene = FLUTLICHTUNG.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.set_flag("forest.flood_sat")
	await wait_physics_frames(3)
	var walkers := scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return node is NpcWalker and not node.is_queued_for_deletion()
	)
	assert_eq(walkers.size(), 0, "no one stands or sits in the clearing")
	assert_true(Beat.reached("flut_tea"), "the scene marks the tea all the same")
