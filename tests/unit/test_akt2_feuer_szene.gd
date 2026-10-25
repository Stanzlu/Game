extends GutTest
## Act II, segment B5, the scene of the house: the rest by the fire is the first safe moment,
## whoever hums the child's tune hears it answered once, and when Mira has gone there is one small
## thing left to do by the fire: three deeds and a silence, each answered by the room in its own
## way. What is said is tested in test_akt2_feuer.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const FEUER := "res://content/dialogue/akt2/feuer.dialogue"
const SEAT := Vector2i(17, 11)
const HERBS_CUE := "herbs"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The room with a burning fire and the player sitting by it. Nobody has taken wood from the shed,
## so the Antreiber does not come and Mira follows the rest by the fire; `mira_after` is long.
func _visit(sitting := true, mira_after := 120.0) -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = mira_after
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	if sitting:
		scene.player.sit_on(scene.map.cell_to_world(SEAT), Facing.Dir.N)
	return scene


## Answers every group the scene asks: the answer with this ID when it is up, the first allowed
## one otherwise (Mira's), until `done` holds.
func _answering(scene: HausScene, deed: String, done: Callable, timeout := 150.0) -> void:
	var text := LineText.of(deed)
	var watch := func() -> bool:
		if not BoxAnswers.pick(scene.dialogue_box, text):
			BoxAnswers.pick(scene.dialogue_box)
		return done.call()
	await wait_until(watch, timeout)


## The visit to its end with this deed: the room is free again and the beat is marked.
func _through(scene: HausScene, deed: String) -> void:
	var over := func() -> bool: return Beat.reached("act2_werte")
	await _answering(scene, deed, over)
	await wait_physics_frames(3)


## A prop with this cue (a Decor keeps it as meta, a walker as a property), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.get(&"cue") == cue or (node.has_meta(&"cue") and node.get_meta(&"cue") == cue):
			return node
	return null


## The room's decor with this sprite, or null.
func _decor(scene: GameScene, sprite_id: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and not node.is_queued_for_deletion():
			if (node as Decor).sprite_id == sprite_id:
				return node as Decor
	return null


# --- The first safe moment and the song ------------------------------------------------------


func test_the_rest_by_the_fire_is_the_first_safe_moment() -> void:
	var scene := await _visit()
	assert_false(Beat.reached("act2_safe"), "not before anyone has stayed")
	await wait_until(func() -> bool: return WorldState.has_flag("house.rested"), 40.0)
	assert_true(WorldState.has_flag("house.rested"))
	assert_true(Beat.reached("act2_safe"), "marked with the moment")
	assert_not_null(scene)


func test_with_nobody_sitting_mira_staying_is_the_first_safe_moment() -> void:
	# Mira knocks after mira_after in any case: the moment must not depend on sitting down
	var scene := await _visit(false, 0.2)
	assert_false(Beat.reached("act2_safe"))
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_knocked"), 40.0)
	assert_true(Beat.reached("act2_safe"))
	assert_not_null(scene)


func test_whoever_hums_the_tune_hears_it_answered_after_the_rest_and_before_mira() -> void:
	WorldState.set_flag("melody.child_hum")
	var order: Array[String] = []
	WorldState.flag_changed.connect(
		func(id: String, value: bool) -> void:
			if value and id in ["house.rested", "melody.house_hum", "house.mira_knocked"]:
				order.append(id)
	)
	var scene := await _visit()
	await _through(scene, "feu_r4")
	assert_eq(order, ["house.rested", "melody.house_hum", "house.mira_knocked"])
	assert_true(Collection.has_melody("house_hum"))


func test_without_the_tune_the_house_stays_quiet() -> void:
	var scene := await _visit()
	await _through(scene, "feu_r4")
	assert_false(Collection.has_melody("house_hum"))
	assert_eq(Collection.melodies(), 0)


func test_the_song_is_sung_once_and_not_to_anyone_who_has_heard_it() -> void:
	WorldState.set_flag("melody.child_hum")
	WorldState.set_flag("melody.house_hum")
	var scene := await _visit(false)
	await scene._sing()
	assert_false(scene.dialogue_box.is_open(), "it is over: nothing is said again")
	assert_eq(Collection.melodies(), 2)


func test_the_song_waits_for_the_tune_and_is_then_heard() -> void:
	var scene := await _visit(false)
	await scene._sing()
	assert_false(Collection.has_melody("house_hum"), "no tune, no song")
	WorldState.set_flag("melody.child_hum")
	var heard := func() -> bool: return Collection.has_melody("house_hum")
	scene._sing()
	await wait_until(heard, 10.0)
	assert_true(Collection.has_melody("house_hum"))
	assert_eq(Collection.fragments(), 0, "and it brings no picture")


func test_a_visit_after_no_rest_still_ends_with_the_song_for_whoever_hums() -> void:
	WorldState.set_flag("melody.child_hum")
	var scene := await _visit(false, 0.2)
	await _through(scene, "feu_r4")
	assert_true(Collection.has_melody("house_hum"), "when Mira has gone, if it was not sung before")


# --- The deeds -------------------------------------------------------------------------------


func test_nothing_is_asked_before_mira_has_gone() -> void:
	var scene := await _visit()
	var asked := func() -> bool:
		BoxAnswers.pick(scene.dialogue_box)
		return WorldState.has_flag("house.mira_seated")
	await wait_until(asked, 100.0)
	assert_true(WorldState.has_flag("house.mira_seated"))
	assert_false(Beat.reached("act2_werte"))
	assert_true(WorldState.state.flags.keys().filter(_is_value).is_empty())


func _is_value(flag: String) -> bool:
	return flag.begins_with("value.")


func test_the_door_left_open_lets_the_light_in_and_the_fire_leans() -> void:
	var scene := await _visit()
	var seen := {"glare": 0.0}
	var over := func() -> bool:
		if WorldState.has_flag("value.freedom"):
			seen["glare"] = maxf(seen["glare"], scene._window_light.energy)
		return Beat.reached("act2_werte")
	await _answering(scene, "feu_r1", over)
	assert_true(WorldState.has_flag("value.freedom"))
	assert_false(WorldState.has_flag("value.closeness") or WorldState.has_flag("value.calm"))
	assert_gt(seen["glare"], HausScene.WINDOW_ENERGY + 0.2, "the window light swells at the gap")
	assert_false(scene.player.is_locked(), "the player is free again")


func test_the_second_stool_stands_by_the_fire_and_the_table_has_one_less() -> void:
	var scene := await _visit()
	assert_null(_decor(scene, "haus/stool"), "no stool by the fire yet")
	assert_not_null(_decor(scene, "haus/table"), "the table with both")
	await _through(scene, "feu_r2")
	assert_true(WorldState.has_flag("value.closeness"))
	assert_not_null(_decor(scene, "haus/stool"), "the stool by the fire")
	assert_not_null(_decor(scene, "haus/table_one"), "the table with one")
	assert_null(_decor(scene, "haus/table"))
	assert_false(scene.player.is_locked())


func test_watching_the_fire_lets_the_evening_fall() -> void:
	var scene := await _visit()
	assert_ne(WorldState.day_preset(), "abend")
	await _through(scene, "feu_r3")
	assert_true(WorldState.has_flag("value.calm"))
	assert_eq(WorldState.day_preset(), "abend", "the time of day goes on from here")
	await wait_seconds(HausScene.EVENING_FALLS_SECONDS + 0.5)
	assert_eq(scene._window_light.color, HausScene.WINDOW_LIGHT_EVENING)
	assert_almost_eq(scene._window_light.energy, HausScene.WINDOW_ENERGY_EVENING, 0.02)
	assert_false(scene.player.is_locked())


func test_the_silence_changes_nothing_in_the_room() -> void:
	var scene := await _visit()
	await _through(scene, "feu_r4")
	assert_true(WorldState.state.flags.keys().filter(_is_value).is_empty())
	assert_null(_decor(scene, "haus/stool"))
	assert_not_null(_decor(scene, "haus/table"))
	assert_ne(WorldState.day_preset(), "abend")
	assert_true(Beat.reached("act2_werte"), "it was asked, and that was the answer")
	assert_false(scene.player.is_locked())


func test_the_choice_is_asked_once() -> void:
	var scene := await _visit()
	await _through(scene, "feu_r4")
	var asked := {"again": false}
	var watch := func() -> bool:
		asked["again"] = asked["again"] or scene.dialogue_box.is_open()
		return false
	await wait_until(watch, 5.0)
	assert_false(asked["again"], "the room does not ask twice")


# --- The herbs under the beam ------------------------------------------------------------------


func test_the_herbs_are_there_only_once_the_fire_burns() -> void:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_null(_first(scene, HERBS_CUE), "a cold room smells of nothing")
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(3)
	assert_not_null(_first(scene, HERBS_CUE), "the fire wakes them")


func test_looking_at_the_herbs_gives_the_third_fragment_once() -> void:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 600.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(3)
	var herbs := _first(scene, HERBS_CUE)
	assert_not_null(herbs)
	(herbs.get_node("Interactable") as Interactable).interacted.emit(null)
	await wait_until(func() -> bool: return Collection.has_fragment("beam_herbs"), 30.0)
	assert_true(Collection.has_fragment("beam_herbs"))
	assert_eq(Collection.fragments(), 1)
	assert_false(WorldState.has_flag("melody.house_hum"), "a trace of the world, not the song")
