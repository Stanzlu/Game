extends GutTest
## Act II, segment B2, the scene of the house: the player answers the Antreiber at the fire with
## the dialogue box ("Heute nicht." makes him sit whatever the body does, "Morgen." sends him to
## look at the roof, silence leaves it to the sitting as before), and whoever looks closely sees one
## spot more in the room. What is said is tested in test_akt2_nein.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const PRINTS_CUE := "haus_prints"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The room with a burning fire and the player sitting by it, the Antreiber about to come.
func _visit() -> HausScene:
	Settings.set_value("text.auto_advance", true, false)
	WorldState.set_flag("valley.wood_taken")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	scene.player.sit_on(scene.map.cell_to_world(Vector2i(17, 11)), Facing.Dir.N)
	return scene


## Answers the group with this text as soon as it is asked and waits until `done` holds.
func _answer(scene: HausScene, text: String, done: Callable, timeout: float) -> void:
	var watch := func() -> bool:
		BoxAnswers.pick(scene.dialogue_box, text)
		return done.call()
	await wait_until(watch, timeout)


## A prop with this cue (a Decor keeps it as meta, a walker as a property), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.get(&"cue") == cue or (node.has_meta(&"cue") and node.get_meta(&"cue") == cue):
			return node
	return null


func test_heute_nicht_makes_him_sit_and_opens_the_facet() -> void:
	var scene := await _visit()
	var sat := func() -> bool: return WorldState.has_flag("house.antreiber_by_fire")
	await _answer(scene, "Heute nicht.", sat, 75.0)
	assert_true(WorldState.has_flag("house.antreiber_by_fire"))
	assert_true(WorldState.has_flag("house.antreiber_refused"))
	assert_true(WorldState.has_facet("boundaries"))
	assert_false(WorldState.has_flag("house.antreiber_left"))
	await wait_physics_frames(3)
	assert_true(Beat.reached("act2_nein"), "marked when the visit is over")
	assert_not_null(_first(scene, "antreiber_rest"), "he stays by the fire")


func test_the_answer_decides_and_not_the_body() -> void:
	# the player says no and gets up at once: he sits all the same, the answer was the answer
	var scene := await _visit()
	var state := {"said": false}
	var stood := func() -> bool:
		if BoxAnswers.pick(scene.dialogue_box, "Heute nicht."):
			state["said"] = true
		if state["said"] and scene.player.state == Player.State.SIT:
			scene.player.stand_up()
		return (
			WorldState.has_flag("house.antreiber_by_fire")
			or WorldState.has_flag("house.antreiber_left")
		)
	await wait_until(stood, 75.0)
	assert_true(WorldState.has_flag("house.antreiber_by_fire"))
	assert_false(WorldState.has_flag("house.antreiber_left"))


func test_a_no_is_followed_by_mira_as_ever() -> void:
	var scene := await _visit()
	var sat := func() -> bool: return WorldState.has_flag("house.antreiber_by_fire")
	await _answer(scene, "Heute nicht.", sat, 75.0)
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_knocked"), 40.0)
	assert_true(WorldState.has_flag("house.mira_knocked"), "nothing is held back for a no")


func test_morgen_sends_him_to_look_at_the_roof_and_sets_no_facet() -> void:
	var scene := await _visit()
	var gone := func() -> bool: return WorldState.has_flag("house.antreiber_left")
	await _answer(scene, "Morgen.", gone, 75.0)
	assert_true(WorldState.has_flag("house.antreiber_left"))
	assert_true(WorldState.has_flag("house.antreiber_postponed"))
	assert_false(WorldState.has_flag("house.antreiber_by_fire"))
	assert_false(WorldState.has_facet("boundaries"))
	assert_false(Beat.reached("act2_nein"))


func test_silence_still_leaves_it_to_the_sitting() -> void:
	var scene := await _visit()
	var sat := func() -> bool: return WorldState.has_flag("house.antreiber_by_fire")
	await _answer(scene, "…", sat, 75.0)
	assert_true(WorldState.has_flag("house.antreiber_by_fire"))
	assert_false(WorldState.has_flag("house.antreiber_refused"))
	assert_false(WorldState.has_facet("boundaries"), "sitting still is not a no")


# --- The spot only whoever looks closely sees ------------------------------------------------


func test_without_the_facet_the_room_has_no_such_spot() -> void:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_false(WorldState.has_flag("house.looks_closely"))
	assert_null(_first(scene, PRINTS_CUE))


func test_with_the_facet_the_room_has_the_spot_and_it_is_seen_once() -> void:
	WorldState.set_facet("perception")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_true(WorldState.has_flag("house.looks_closely"))
	var prints := _first(scene, PRINTS_CUE)
	assert_not_null(prints, "one spot more in the room")
	assert_false(Beat.reached("act2_blick"))
	# the lines come one after the other; the cue sets the flag at its end
	Settings.set_value("text.auto_advance", true, false)
	(prints.get_node("Interactable") as Interactable).interacted.emit(null)
	await wait_until(func() -> bool: return WorldState.has_flag("house.prints_seen"), 30.0)
	assert_true(WorldState.has_flag("house.prints_seen"))
	assert_true(Beat.reached("act2_blick"))


func test_the_spot_is_no_prerequisite_for_anything() -> void:
	# with the facet and the spot in the room, the fire, the Antreiber and Mira come without a look
	WorldState.set_facet("perception")
	var scene := await _visit()
	assert_not_null(_first(scene, PRINTS_CUE), "the spot is there")
	var visited := func() -> bool:
		BoxAnswers.pick(scene.dialogue_box)
		return WorldState.has_flag("house.mira_knocked")
	await wait_until(visited, 120.0)
	assert_true(WorldState.has_flag("house.fire_lit"))
	assert_true(WorldState.has_flag("house.mira_knocked"), "Mira comes")
	assert_false(WorldState.has_flag("house.prints_seen"), "and the prints were never looked at")
