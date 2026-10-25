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
	Settings.set_value("access.captions", false, false)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The room with a burning fire and the player sitting by it. Without `antreiber`, nobody has taken
## wood from the shed: he does not come and Mira follows the rest by the fire; `mira_after` is long.
func _visit(sitting := true, mira_after := 120.0, antreiber := false) -> HausScene:
	if antreiber:
		WorldState.set_flag("valley.wood_taken")
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
## one otherwise, until `done` holds. The silence "…" is also offered by the Antreiber and Mira, so
## a silent visit answers them with silence too (which is what the deed is).
func _answering(scene: HausScene, deed: String, done: Callable, timeout := 150.0) -> void:
	var text := LineText.of(deed)
	var watch := func() -> bool:
		if not BoxAnswers.pick(scene.dialogue_box, text):
			BoxAnswers.pick(scene.dialogue_box)
		return done.call()
	await wait_until(watch, timeout)


## The visit to its end with this deed: the beat is marked, and the room is free again.
func _through(scene: HausScene, deed: String) -> void:
	var over := func() -> bool: return Beat.reached("act2_werte")
	await _answering(scene, deed, over)
	assert_true(Beat.reached("act2_werte"), "the visit ran to its end")
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
	# Mira knocks after mira_after in any case: the moment must not depend on sitting down, and
	# it must not take the rest by the fire's own flag, or that cue could never be told later
	var scene := await _visit(false, 0.2)
	assert_false(Beat.reached("act2_safe"))
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_knocked"), 40.0)
	assert_true(Beat.reached("act2_safe"))
	assert_false(WorldState.has_flag("house.rested"), "the rest by the fire is still to be told")
	assert_not_null(scene)


func test_the_tune_is_answered_before_the_antreiber_and_mira_and_silence_is_free() -> void:
	# the default way into Act II: the shed's wood is taken, so he comes, and then Mira
	WorldState.set_flag("melody.child_hum")
	Settings.set_value("access.captions", true, false)
	var order: Array[String] = []
	var captions: Array[String] = []
	var on_flag := func(id: String, value: bool) -> void:
		var story := ["house.rested", "melody.house_hum", "house.antreiber_by_fire"]
		if value and (id in story or id == "house.mira_knocked"):
			order.append(id)
	var on_caption := func(key: String, _at: Variant) -> void: captions.append(key)
	WorldState.flag_changed.connect(on_flag)
	AudioDirector.caption_requested.connect(on_caption)
	var scene := await _visit(true, 120.0, true)
	await _through(scene, "feu_r4")
	WorldState.flag_changed.disconnect(on_flag)
	AudioDirector.caption_requested.disconnect(on_caption)
	assert_eq(
		order, ["house.rested", "melody.house_hum", "house.antreiber_by_fire", "house.mira_knocked"]
	)
	assert_true(Collection.has_melody("house_hum"))
	assert_eq(captions.count("CAPTION_HUM"), 1, "the song is written out once, when it comes")
	# the silence is an answer: nothing in the room changes, and the choice is not asked again
	assert_true(WorldState.state.flags.keys().filter(_is_value).is_empty())
	assert_null(_decor(scene, "haus/stool"))
	assert_not_null(_decor(scene, "haus/table"))
	assert_ne(WorldState.day_preset(), "abend")
	assert_false(scene.player.is_locked())
	var asked := {"again": false}
	var watch := func() -> bool:
		asked["again"] = asked["again"] or scene.dialogue_box.is_open()
		return false
	await wait_until(watch, 5.0)
	assert_false(asked["again"], "the room does not ask twice")


func test_the_song_is_not_sung_to_anyone_who_has_heard_it() -> void:
	WorldState.set_flag("melody.child_hum")
	WorldState.set_flag("melody.house_hum")
	var scene := await _visit(false)
	var opened := {"box": false}
	var watch := func() -> bool:
		opened["box"] = opened["box"] or scene.dialogue_box.is_open()
		return false
	scene._sing()
	# the pause before the song is a second, its two lines follow: four seconds would show them
	await wait_until(watch, 4.0)
	assert_false(opened["box"], "nothing is said again")
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


func test_a_visit_without_a_rest_ends_with_the_song_for_whoever_hums() -> void:
	WorldState.set_flag("melody.child_hum")
	var order: Array[String] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in ["house.mira_knocked", "house.mira_left", "melody.house_hum"]:
			order.append(id)
	WorldState.flag_changed.connect(on_flag)
	var scene := await _visit(false, 0.2)
	await _through(scene, "feu_r4")
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(order, ["house.mira_knocked", "house.mira_left", "melody.house_hum"])
	assert_false(WorldState.has_flag("house.rested"))


# --- The deeds -------------------------------------------------------------------------------


func _is_value(flag: String) -> bool:
	return flag.begins_with("value.")


func test_the_door_left_open_lets_the_light_in_and_nothing_is_asked_before_mira_has_gone() -> void:
	var scene := await _visit()
	var seen := {"glare": 0.0, "early": false}
	var over := func() -> bool:
		var box := scene.dialogue_box
		if box.is_open() and box.line != null and box.line.text == LineText.of("feu_1"):
			seen["early"] = seen["early"] or not WorldState.has_flag("house.mira_left")
		if WorldState.has_flag("value.freedom"):
			seen["glare"] = maxf(seen["glare"], scene._window_light.energy)
		return Beat.reached("act2_werte")
	await _answering(scene, "feu_r1", over)
	assert_true(Beat.reached("act2_werte"), "the visit ran to its end")
	assert_false(seen["early"], "the question comes when Mira has gone")
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
	var at_flip := {}
	var on_flag := func(id: String, _value: bool) -> void:
		if id == "value.calm":
			at_flip["color"] = scene._window_light.color
	WorldState.flag_changed.connect(on_flag)
	await _through(scene, "feu_r3")
	WorldState.flag_changed.disconnect(on_flag)
	assert_true(WorldState.has_flag("value.calm"))
	assert_eq(WorldState.day_preset(), "abend", "the time of day goes on from here")
	assert_ne(at_flip.get("color"), HausScene.WINDOW_LIGHT_EVENING, "it was still grey when asked")
	await wait_seconds(HausScene.EVENING_FALLS_SECONDS + 0.5)
	assert_eq(scene._window_light.color, HausScene.WINDOW_LIGHT_EVENING)
	assert_almost_eq(scene._window_light.energy, HausScene.WINDOW_ENERGY_EVENING, 0.02)
	assert_false(scene.player.is_locked())


# --- What a later visit sees ------------------------------------------------------------------


func test_a_room_built_after_the_stool_has_the_stool_and_the_table_with_one() -> void:
	WorldState.set_flag("value.closeness")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_not_null(_decor(scene, "haus/stool"))
	assert_not_null(_decor(scene, "haus/table_one"))
	assert_null(_decor(scene, "haus/table"))


func test_a_room_built_after_the_evening_has_the_evening_in_the_window() -> void:
	WorldState.set_flag("value.calm")
	WorldState.set_day_preset("abend")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(scene._window_light.color, HausScene.WINDOW_LIGHT_EVENING)
	assert_null(_decor(scene, "haus/stool"), "and no other value rides along")


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
