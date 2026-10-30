# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W3, the scene of the hermit's hut: a small warm room at the room's own zoom,
## a stool to sit on, and while she stays the picture closes in by one step with each answer (1.75,
## 2.0, 2.0), never on a timer. After the third the door stands open and the game saves once.
## Standing up gives the picture back in the same moment, a loaded game never starts tight, and the
## door out is never locked or blocked. What is said is tested in test_akt3_huette.

const HUETTE := preload("res://world/levels/akt3/huette.tscn")
const QUEST := "main_forest_way"
const STAY_FLAGS: Array[String] = ["forest.hut_stay_1", "forest.hut_stay_2", "forest.hut_stay_3"]
const ROOM := Rect2i(9, 5, 14, 10)
const FORBIDDEN_IN_THE_SCENE: Array[String] = [
	"NodeTimer",
	"create_timer",
	"Time.get_ticks",
	"timing_factor",
	"Cutscene",
	"Blocker",
	".lock(",
	"create_tween",
	"flash",
	"flicker",
	"strobe",
	"shake",
]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Input.action_release(&"move_down")
	Input.action_release(&"move_left")
	Settings.set_value("access.captions", false, false)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> HuetteScene:
	var scene: HuetteScene = HUETTE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


func _decor_with(scene: GameScene, sprite: String) -> Array:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and node.sprite_id == sprite
	)


## Where she sits: the stool's own seat (its position and the seat offset of the map).
func _seat(scene: GameScene) -> Vector2:
	return _decor_with(scene, "haus/stool")[0].global_position + Vector2(0, 4)


func _sit(scene: GameScene) -> void:
	scene.player.sit_on(_seat(scene), Facing.Dir.E)
	await wait_physics_frames(3)


## Answers the box with these answers, in order, as they come up, until `done` holds.
func _answering(
	scene: GameScene, answers: PackedStringArray, done: Callable, timeout := 60.0
) -> void:
	var next := [0]
	var watch := func() -> bool:
		if next[0] < answers.size() and BoxAnswers.pick(scene.dialogue_box, answers[next[0]]):
			next[0] += 1
		return done.call()
	var reached: bool = await wait_until(watch, timeout)
	assert_true(reached, "the box asked, and the answers %s were taken" % [answers])
	assert_eq(next[0], answers.size(), "every answer was taken")


## The room is smaller than the picture at every zoom, so the camera stands at its middle.
func _room_centre() -> Vector2:
	return Vector2(ROOM.position * 16) + Vector2(ROOM.size * 16) / 2.0


func _stays() -> int:
	var count := 0
	for flag: String in STAY_FLAGS:
		if WorldState.has_flag(flag):
			count += 1
	return count


func _closed(scene: GameScene) -> Callable:
	return func() -> bool: return not scene.dialogue_box.is_open()


# --- The room --------------------------------------------------------------------------


func test_the_room_is_small_warm_and_at_its_own_zoom() -> void:
	var scene := await _scene()
	assert_true(SceneRegistry.has("huette"))
	assert_eq(scene.view.zoom, 1.5, "like the house (ADR-045)")
	assert_eq(scene.map.data.width, 32)
	assert_eq(scene.map.data.height, 20)
	assert_true(Beat.reached("huette_enter"))
	var room := Vector2(ROOM.size * scene.map.data.tile_size)
	assert_lte(room.x, 320.0, "the whole room is in the picture at the tightest zoom")
	assert_lte(room.y, 180.0)
	assert_eq(
		scene.view.bounds, Rect2(Vector2(ROOM.position * 16), room), "the camera keeps to the room"
	)
	assert_eq(scene.music, "silence", "the flute is the only tune here")


func test_the_door_is_never_locked_or_blocked() -> void:
	var scene := await _scene()
	for node in _alive(scene):
		var script: Script = node.get_script()
		assert_false(script != null and "blocker" in script.resource_path, "no blocker anywhere")
	var doors := _alive(scene).filter(
		func(node: Node) -> bool: return node.get(&"target") == "waldweg"
	)
	assert_eq(doors.size(), 1)
	assert_eq(doors[0].get(&"spawn"), "huette")
	assert_true(doors[0].get(&"auto"))


func test_one_stool_one_hermit_and_he_sits_already() -> void:
	var scene := await _scene()
	var seats := _decor_with(scene, "haus/stool")
	assert_eq(seats.size(), 1, "one place to sit, the one he put out")
	var hermits := _alive(scene).filter(func(node: Node) -> bool: return node is NpcWalker)
	assert_eq(hermits.size(), 1)
	assert_eq((hermits[0] as NpcWalker).cue, "hermit")
	assert_true((hermits[0] as NpcWalker).seated)


func test_the_objective_of_the_smoke_is_done_on_entering_and_the_flood_is_not_asked_for() -> void:
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "brook")
	WorldState.advance_quest(QUEST, "wood")
	await _scene()
	assert_true(WorldState.is_objective_done(QUEST, "hermit"))
	assert_false(WorldState.is_objective_done(QUEST, "flood"))
	assert_eq(WorldState.quest_stage(QUEST), "wood", "the way goes on")


func test_with_the_flood_seen_first_the_hut_ends_the_wood() -> void:
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "brook")
	WorldState.advance_quest(QUEST, "wood")
	WorldState.complete_objective(QUEST, "flood")
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "night")
	assert_true(WorldState.is_quest_done(QUEST))


func test_the_pipe_is_on_the_sill_until_it_is_taken() -> void:
	var scene := await _scene()
	assert_eq(_decor_with(scene, "haus/hut_pipe").size(), 1, "the pipe lies on the sill")
	scene.queue_free()
	await wait_physics_frames(2)
	WorldState.set_flag("forest.pipe_taken")
	var after := await _scene()
	assert_eq(_decor_with(after, "haus/hut_pipe").size(), 0, "nothing lies on the sill any more")


func test_a_game_without_the_walk_gets_no_quest_from_the_hut() -> void:
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "")


# --- Sitting and staying ---------------------------------------------------------------


func test_sitting_down_asks_once_and_declining_changes_nothing() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	var opened := [0]
	scene.dialogue_box.opened.connect(func() -> void: opened[0] += 1)
	await _sit(scene)
	var asked: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(asked, "sitting down opens the question")
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	await wait_physics_frames(3)
	assert_eq(opened[0], 1, "one question for one sitting")
	assert_eq(_stays(), 0, "no step")
	assert_eq(scene.view.zoom, 1.5, "the picture as it was")
	assert_eq(scene.player.state, Player.State.SIT, "she sits on, free to stand up")
	assert_false(scene.player.is_locked())
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")
	scene.player.stand_up()
	await wait_physics_frames(3)
	await _sit(scene)
	var again: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(again, "a second sitting asks again")
	assert_eq(opened[0], 2)
	await _answering(scene, PackedStringArray(["…"]), _closed(scene))


func test_the_first_sitting_plays_the_flute_and_writes_it_out_once() -> void:
	Settings.set_value("access.captions", true, false)
	var captions: Array[String] = []
	var on_caption := func(key: String, _at: Variant) -> void: captions.append(key)
	AudioDirector.caption_requested.connect(on_caption)
	var scene := await _scene()
	await _sit(scene)
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	AudioDirector.caption_requested.disconnect(on_caption)
	assert_true(WorldState.has_flag("melody.hermit_flute"))
	assert_eq(captions.count("CAPTION_FLUTE"), 1, "the tune is written out once, when it comes")
	assert_eq(Collection.melodies(), 1)


func test_each_answer_to_staying_closes_the_picture_in_one_step() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	await _sit(scene)
	var zooms: Array[float] = []
	var eyes: Array[Vector2] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in STAY_FLAGS:
			zooms.append(scene.view.zoom)
			eyes.append(scene.view.camera_position)
	WorldState.flag_changed.connect(on_flag)
	await _answering(
		scene, PackedStringArray(["Bleiben.", "Noch bleiben.", "Noch bleiben."]), _closed(scene)
	)
	WorldState.flag_changed.disconnect(on_flag)
	await wait_physics_frames(3)
	assert_eq(_stays(), 3)
	assert_eq(scene.view.zoom, 2.0, "the tightest")
	assert_eq(scene.view.view_size, Vector2i(320, 180))
	assert_eq(scene.view.display.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "sharp")
	assert_gte(zooms.size(), 3)
	assert_eq(zooms[zooms.size() - 3], 1.75, "the first answer: a step closer, with the line")
	assert_eq(zooms[zooms.size() - 2], 2.0)
	assert_eq(zooms[zooms.size() - 1], 2.0, "the third opens the door and goes no further")
	assert_eq(eyes.size(), 3)
	for eye: Vector2 in eyes:
		assert_almost_eq(eye, _room_centre(), Vector2.ONE, "the camera stays at the room's middle")
	assert_almost_eq(scene.view.camera_position, _room_centre(), Vector2.ONE)


func test_the_third_step_opens_the_door_and_the_game_saves_once() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	await _sit(scene)
	assert_eq(_decor_with(scene, "haus/hut_door_open").size(), 0, "the door is shut")
	var saves: Array[String] = []
	var on_saved := func(slot: String) -> void: saves.append(slot)
	SaveSystem.saved.connect(on_saved)
	await _answering(
		scene,
		PackedStringArray(["Bleiben.", "Noch bleiben."]),
		func() -> bool: return _stays() == 2
	)
	await wait_physics_frames(3)
	assert_false(Beat.reached("huette_stay"))
	assert_eq(saves.count(SaveSystem.AUTOSAVE), 0, "no save while she is still choosing")
	await _answering(scene, PackedStringArray(["Noch bleiben."]), _closed(scene))
	await wait_physics_frames(5)
	SaveSystem.saved.disconnect(on_saved)
	assert_true(Beat.reached("huette_stay"))
	assert_eq(_decor_with(scene, "haus/hut_door_open").size(), 1, "the door stands open")
	assert_eq(saves.count(SaveSystem.AUTOSAVE), 1, "one autosave once the box has closed")


func test_standing_up_gives_the_picture_back_in_the_same_moment() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	await _sit(scene)
	await _answering(
		scene,
		PackedStringArray(["Bleiben.", "Noch bleiben."]),
		func() -> bool: return _stays() == 2
	)
	assert_eq(scene.view.zoom, 2.0)
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	scene.player.stand_up()
	assert_eq(scene.view.zoom, 1.5, "no wait, no hold")
	assert_eq(scene.view.view_size, Vector2i(427, 240))
	assert_almost_eq(scene.view.camera_position, _room_centre(), Vector2.ONE)
	assert_eq(_stays(), 2, "nothing is taken back and nothing is lost")


func test_walking_away_from_the_stool_does_the_same() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	await _sit(scene)
	await _answering(scene, PackedStringArray(["Bleiben.", "Nur sitzen."]), _closed(scene))
	assert_eq(scene.view.zoom, 1.75)
	Input.action_press(&"move_left")
	await wait_until(func() -> bool: return scene.player.state != Player.State.SIT, 5.0)
	Input.action_release(&"move_left")
	assert_eq(scene.view.zoom, 1.5)


func test_a_flag_set_while_standing_does_not_tighten_the_picture() -> void:
	var scene := await _scene()
	WorldState.set_flag("forest.hut_stay_1")
	WorldState.set_flag("forest.hut_stay_2")
	await wait_physics_frames(3)
	assert_eq(scene.view.zoom, 1.5, "the picture only closes in while she sits")


func test_a_loaded_game_never_starts_tight_and_keeps_the_open_door() -> void:
	for flag: String in STAY_FLAGS:
		WorldState.set_flag(flag)
	WorldState.set_flag("melody.hermit_flute")
	# the autosave of the third step is written while she sits: the stool's seat (cell 15, 11)
	var seat := Vector2(15 * 16 + 8, 11 * 16 + 8 + 4)
	SaveSystem._arrival = {"map": "huette", "position": seat}
	SaveSystem.loading = true
	var scene := await _scene()
	assert_false(SaveSystem.loading, "the arrival was taken")
	assert_almost_eq(scene.player.global_position, seat, Vector2(2, 4), "she is where she sat")
	assert_eq(scene.view.zoom, 1.5)
	assert_ne(scene.player.state, Player.State.SIT, "standing, not sitting")
	assert_false(scene.dialogue_box.is_open(), "no question is open")
	assert_eq(_decor_with(scene, "haus/hut_door_open").size(), 1, "the door is still open")


func test_after_the_third_step_stay_only_gives_calm_lines_and_nothing_else() -> void:
	for flag: String in STAY_FLAGS:
		WorldState.set_flag(flag)
	WorldState.set_flag("melody.hermit_flute")
	var scene := await _scene()
	await _sit(scene)
	var asked: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(asked, "even after the third step sitting asks, and the answer is calm")
	var saves: Array[String] = []
	var on_saved := func(slot: String) -> void: saves.append(slot)
	SaveSystem.saved.connect(on_saved)
	var items := WorldState.state.inventory.duplicate()
	await _answering(
		scene,
		PackedStringArray(
			["Bleiben.", "Bleiben.", "Bleiben.", "Bleiben.", "Bleiben.", "Nur sitzen."]
		),
		_closed(scene)
	)
	await wait_physics_frames(5)
	SaveSystem.saved.disconnect(on_saved)
	assert_eq(scene.view.zoom, 1.5, "the picture is as it is")
	assert_eq(_stays(), 3)
	assert_eq(WorldState.state.inventory, items)
	assert_eq(saves.count(SaveSystem.AUTOSAVE), 0, "no new save for more of the same")


func test_nothing_in_the_scene_is_timed() -> void:
	var scene := await _scene()
	WorldState.set_flag("melody.hermit_flute")
	await _sit(scene)
	var asked: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(asked, "the question is open")
	await wait_seconds(10.0)
	assert_true(scene.dialogue_box.is_open(), "and it waits as long as she does")
	assert_eq(_stays(), 0, "ten seconds of game time at the open question change nothing")
	assert_eq(scene.view.zoom, 1.5)
	var source := FileAccess.get_file_as_string("res://world/levels/akt3/huette_scene.gd")
	for word: String in FORBIDDEN_IN_THE_SCENE:
		assert_false(source.contains(word), "'%s' in huette_scene.gd" % word)


# --- The way out -----------------------------------------------------------------------


func test_the_door_out_is_reached_from_the_arrival_and_leads_to_the_forest_path() -> void:
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "door"
	var scene := await _scene()
	var cell := scene.map.world_to_cell(scene.player.global_position)
	assert_eq(cell, Vector2i(12, 12), "the arrival is at the door's marker")
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	var gone := func() -> bool: return SceneTravel.last_target == "waldweg"
	Input.action_press(&"move_down")
	var left := 240
	while left > 0 and not gone.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_down")
	assert_true(gone.call(), "south from the arrival reaches the door")


func test_even_after_the_third_step_the_door_out_is_free() -> void:
	for flag: String in STAY_FLAGS:
		WorldState.set_flag(flag)
	SceneTravel.stay = true
	SceneTravel.pending_spawn = "door"
	var scene := await _scene()
	assert_eq(SceneTravel.last_target, "", "nothing has travelled yet")
	assert_eq(_decor_with(scene, "haus/hut_door_open").size(), 1, "the door stands open")
	var gone := func() -> bool: return SceneTravel.last_target == "waldweg"
	Input.action_press(&"move_down")
	var left := 240
	while left > 0 and not gone.call():
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_down")
	assert_true(gone.call(), "nothing holds her, with the door open or shut")
