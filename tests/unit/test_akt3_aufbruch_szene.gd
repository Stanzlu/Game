extends GutTest
## Act III, segment W1: "Weiter" after the end of Act II begins the morning after (ADR-070).
## The valley opens in the light of the next day, Mira and her fire are gone, the lines come when
## the picture is back, the quest starts and the morning is marked once. It plays from the frozen
## save at the end of Act II (tests/fixtures/saves/v2_akt2_end.json) as "Weiter" would. What the
## lines say is tested in test_akt3_aufbruch.

const TAL := preload("res://world/levels/slice/tal.tscn")
const HAUS := preload("res://world/levels/slice/haus.tscn")
const FIXTURE := "res://tests/fixtures/saves/v2_akt2_end.json"
const HAUS_DIALOGUE := "res://content/dialogue/slice/haus.dialogue"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The state "Weiter" loads at the end of Act II.
func _load_end() -> void:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _cutscenes() -> int:
	return get_tree().get_nodes_in_group(&"cutscene").size()


## Everything on the map whose name starts with `prefix` (live props, no queued ones).
func _alive(scene: GameScene, prefix: String) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return str(node.name).begins_with(prefix) and not node.is_queued_for_deletion()
	)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene, "Decor").filter(
		func(node: Node) -> bool: return (node as Decor).sprite_id == sprite
	)


func _mira(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if (
			node is NpcWalker
			and (node as NpcWalker).cue == "mira"
			and not node.is_queued_for_deletion()
		):
			return node as NpcWalker
	return null


func test_the_end_of_act_two_opens_on_the_morning_after() -> void:
	_load_end()
	var scene := await _valley()
	assert_eq(WorldState.day_preset(), "morgen")
	assert_eq(scene.day_light.preset, "morgen")
	assert_false(scene.day_light.rain.is_raining(), "the rain is over")
	assert_eq(AudioDirector.ambience_stream.resource_path.get_file(), "tal_morgen.tres")
	assert_true(WorldState.has_flag("valley.mira_gone"))
	assert_null(_mira(scene), "her seat across the fire is empty")
	assert_eq(_decor_with(scene, "tal/campfire").size(), 0, "the fire is out")
	assert_eq(_decor_with(scene, "tal/tarp").size(), 1, "the tarp stays (its shadow is baked)")
	assert_eq(scene.player.facing, Facing.Dir.E, "the player looks at the empty place")
	assert_false(Beat.reached("act3_morning"), "marked when the lines are told")


func test_the_hedge_door_to_the_stream_is_there_and_open() -> void:
	_load_end()
	var scene := await _valley()
	var doors := scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node.get(&"target") == "bachlauf" and not node.is_queued_for_deletion()
	)
	assert_eq(doors.size(), 1, "the way south is the stream")


func test_the_lines_come_once_the_picture_is_back() -> void:
	_load_end()
	# the picture is black when the valley opens (as after "Weiter") and comes back over three seconds
	await ScreenFade.fade_out(0.0)
	SceneTravel.arrival_fade = 3.0
	var scene := await _valley()
	assert_true(ScreenFade.is_covered() or ScreenFade.is_fading(), "the fade-in is under way")
	var seen := {"up": false, "dark": false}
	var watch := func() -> bool:
		if scene.dialogue_box.is_open() and not seen["up"]:
			seen["up"] = true
			seen["dark"] = ScreenFade.is_covered() or ScreenFade.is_fading()
		return seen["up"]
	await wait_until(watch, 15.0)
	assert_true(seen["up"], "the morning is told")
	assert_false(seen["dark"], "but not into the dark")
	assert_eq(_cutscenes(), 1, "as a scene of its own: the player stands")


func test_the_morning_is_told_once_and_marked_with_the_quest() -> void:
	_load_end()
	Settings.set_value("text.auto_advance", true, false)
	var scene := await _valley()
	await wait_until(func() -> bool: return Beat.reached("act3_morning"), 30.0)
	assert_true(Beat.reached("act3_morning"))
	assert_eq(WorldState.quest_stage("main_forest_way"), "leave", "the way begins")
	assert_eq(_cutscenes(), 0, "and the player moves on")
	assert_false(scene.dialogue_box.is_open())
	assert_eq(WorldState.day_preset(), "morgen")


func test_after_the_morning_the_valley_stays_as_the_morning_left_it() -> void:
	_load_end()
	Settings.set_value("text.auto_advance", true, false)
	var first := await _valley()
	await wait_until(func() -> bool: return Beat.reached("act3_morning"), 30.0)
	assert_true(Beat.reached("act3_morning"))
	var text := SaveCodec.encode(WorldState.state)
	var back := SaveCodec.decode(text)
	assert_true(back.ok, back.error)
	assert_eq(back.warnings, PackedStringArray(), "morgen is a known time of day")
	first.free()
	WorldState.new_game()
	WorldState.replace_state(back.state)
	var again := await _valley()
	await wait_physics_frames(2)
	assert_eq(_cutscenes(), 0, "the lines are not told again")
	assert_eq(WorldState.day_preset(), "morgen")
	assert_null(_mira(again), "and she is still gone")
	assert_eq(WorldState.quest_stage("main_forest_way"), "leave")


func test_a_valley_before_the_end_is_what_it_was() -> void:
	WorldState.set_flag("house.mira_visited")
	WorldState.set_day_preset("regentag")
	await _valley()
	assert_eq(WorldState.day_preset(), "abend", "after Mira's visit it is evening")
	assert_false(WorldState.has_flag("valley.mira_gone"))
	assert_eq(_cutscenes(), 0)
	assert_false(Beat.reached("act3_morning"))


func test_the_house_in_the_morning_is_as_dry_as_in_the_evening() -> void:
	_load_end()
	WorldState.set_day_preset("morgen")
	WorldState.set_flag("house.fire_lit")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 0.2
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(WorldState.day_preset(), "morgen")
	assert_true(scene._dry())
	assert_eq(scene.music, "silence", "the valley's theme is Mira's: not in the house this morning")
	assert_eq(scene.ambience.resource_path.get_file(), "haus_morgen.tres", "a bird, no crickets")
	assert_eq(
		scene._window_light.color, HausScene.WINDOW_LIGHT_MORNING, "clear cold light in the window"
	)
	var window := await DialogueWalk.play(HAUS_DIALOGUE, "window")
	assert_true(LineText.of("haus_window_3") in window, "no rain in the window")
	assert_false(LineText.of("haus_window_2") in window)
	var rest := await DialogueWalk.play(HAUS_DIALOGUE, "fire_rest")
	assert_true(LineText.of("haus_rest_6") in rest, "and none outside while you sit at the fire")
	assert_false(LineText.of("haus_rest_2") in rest)
