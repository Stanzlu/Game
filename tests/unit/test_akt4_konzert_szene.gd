# gdlint: ignore=max-public-methods
extends GutTest
## Act IV, segment S6: the evening of the concert in the scene of the city. Once Lio has been said
## yes to (the quest stage "evening") the scene is loaded again as an evening: the night look is
## exports of the scene and not the time of day of the world (that is global state), six
## PointLight2D at most eight (four lamp posts, two stage lamps), the stage before the town hall
## with Lio and the goat on it, the crowd (Orin at the post of the lamp if she asked him, Tess if
## the board is sawn), the shops and the hall shut, the day's people gone. The concert plays
## itself as a cutscene (nine cues in turn), sets the beat and leaves the room free. The lines are
## tested in test_akt4_konzert, the layout of the map in tools/art/test_layout_akt4.py.

const STADT := preload("res://world/levels/akt4/stadt.tscn")
const CITY := "res://content/dialogue/akt4/stadt.dialogue"
const GOAT_SCRIPT := preload("res://world/props/goat.gd")
const QUEST := "main_city_way"
const STAGE_CELL := Vector2i(44, 23)
const ARRIVAL := Vector2i(44, 24)
const LIT_LAMPS := 4
const STAGE_LAMPS := 2
## The lines of the nine parts, by ID: the tape of a run is made of them.
const PART_LINES: Array[String] = [
	"kon_arr_1",
	"kon_intro_2",
	"kon_snap_2",
	"kon_hold_2",
	"kon_goat_1",
	"kon_entry_2",
	"kon_wind_1",
	"kon_song_1",
	"kon_fin_1",
]
var _saved_dir := ""
var _polls := 0


func before_each() -> void:
	# no scene of these tests leaves its room for another: the doors only note where they lead
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	_saved_dir = SaveSystem.save_dir
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "konzert_test_saves"
	_clear_saves()


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false
	_clear_saves()
	SaveSystem.save_dir = _saved_dir


func _clear_saves() -> void:
	for slot in SaveService.SLOTS:
		for backup: bool in [false, true]:
			var path := SaveSystem.path_for(slot, backup)
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)


## The hero's walk has come to the evening; the concert is played (no cutscene) unless said so.
func _evening(played := true) -> void:
	WorldState.start_quest(QUEST)
	for stage: String in ["town", "help", "list", "evening"]:
		assert_true(WorldState.advance_quest(QUEST, stage), "to " + stage)
	if played:
		WorldState.set_flag("beat.city_concert")


func _scene() -> StadtScene:
	var scene: StadtScene = STADT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			found.append(node)
	return found


func _decor(scene: GameScene, sprite: String) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and node.sprite_id == sprite
	)


func _walker(scene: GameScene, cue: String) -> NpcWalker:
	for node in _alive(scene):
		if node is NpcWalker and (node as NpcWalker).cue == cue:
			return node as NpcWalker
	return null


## The walkers with this sheet ("tess" for sheet_tess_look.tres).
func _with_sheet(scene: GameScene, name: String) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool:
			return node is NpcWalker and node.sheet.resource_path.contains("sheet_%s_look" % name)
	)


func _doors_to(scene: GameScene, target: String) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool: return "target" in node and node.target == target
	)


func _lights(scene: Node) -> int:
	var found := 0
	var stack: Array[Node] = [scene]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is PointLight2D:
			found += 1
		stack.append_array(node.get_children())
	return found


func _cell(scene: GameScene, node: Node) -> Vector2i:
	return scene.map.world_to_cell((node as Node2D).global_position)


# --- The day and the evening of the same map ----------------------------------------------------


func test_by_day_there_is_no_stage_no_light_and_no_evening() -> void:
	var scene := await _scene()
	assert_false(WorldState.has_flag("city.evening"))
	assert_eq(_decor(scene, "tal/st_stage").size(), 0)
	assert_eq(_decor(scene, "tal/st_lamp_post_lit").size(), 0, "the posts are dark")
	assert_eq(_lights(scene), 0, "the town by day has no PointLight2D")
	assert_eq(scene.world_tint, Color.WHITE)
	assert_eq(scene.day_preset, "morgen", "the day is as it was")
	assert_not_null(_walker(scene, "lio_street"))
	assert_null(_walker(scene, "con_lio"))
	assert_eq(_doors_to(scene, "rathaus").size(), 1)
	assert_eq(_doors_to(scene, "blumenladen").size(), 1)
	assert_eq(_doors_to(scene, "werkstatt").size(), 1)


func test_in_the_stage_evening_the_scene_is_an_evening_with_lights_set_by_its_exports() -> void:
	_evening()
	var preset_before := WorldState.day_preset()
	var scene := await _scene()
	assert_true(StadtScene.in_evening())
	assert_true(WorldState.has_flag("city.evening"), "the map reads it")
	assert_eq(scene.day_preset, "keine", "the look is the scene's own")
	assert_eq(
		WorldState.day_preset(), preset_before, "and the time of day of the world is not touched"
	)
	assert_ne(scene.world_tint, Color.WHITE, "dusk")
	assert_not_null(scene.view.world_root.get_node_or_null("WorldTint"))
	assert_eq(_decor(scene, "tal/st_lamp_post_lit").size(), LIT_LAMPS, "four posts are lit")
	assert_eq(_decor(scene, "tal/st_stage_lamp").size(), STAGE_LAMPS)
	assert_eq(_lights(scene), LIT_LAMPS + STAGE_LAMPS, "six lights")
	assert_lte(_lights(scene), 8, "O3: at most eight PointLight2D")
	assert_true(Beat.reached("stadt_abend"))


func test_the_stage_stands_before_the_hall_with_lio_and_the_goat_on_it() -> void:
	_evening()
	var scene := await _scene()
	assert_eq(_decor(scene, "tal/st_stage").size(), 1)
	assert_eq(_cell(scene, _decor(scene, "tal/st_stage")[0]), STAGE_CELL)
	assert_eq(_decor(scene, "tal/st_lantern_line").size(), 1)
	var lio := _walker(scene, "con_lio")
	assert_not_null(lio, "Lio plays on the stage")
	assert_true(lio.seated)
	assert_eq(_cell(scene, lio), Vector2i(44, 22))
	assert_null(_walker(scene, "lio_street"), "not in his corner of the gate street")
	assert_eq(_goats(scene), 1, "one goat, on the stage and not on the roof")
	var goats := _alive(scene).filter(
		func(node: Node) -> bool: return node.get_script() == GOAT_SCRIPT
	)
	var goat: Node = goats[0]
	assert_eq(_cell(scene, goat), Vector2i(46, 22))
	assert_not_null(_walker(scene, "con_mira"))
	assert_not_null(_walker(scene, "con_gef"))
	assert_null(_walker(scene, "gef_square"), "he left his board")
	assert_null(_walker(scene, "mira_square"), "and she her place at the rim")


func _goats(scene: GameScene) -> int:
	return (
		_alive(scene)
		. filter(func(node: Node) -> bool: return node.get_script() == GOAT_SCRIPT)
		. size()
	)


func test_the_shops_and_the_hall_are_shut_in_the_evening_and_open_by_day() -> void:
	_evening()
	var scene := await _scene()
	for target: String in ["rathaus", "blumenladen", "werkstatt"]:
		assert_eq(_doors_to(scene, target).size(), 0, "shut: " + target)
	assert_eq(_doors_to(scene, "strasse").size(), 1, "the road is open")


func test_orin_holds_the_lamp_if_she_asked_him_and_stands_in_the_crowd_if_not() -> void:
	_evening()
	WorldState.set_flag("city.orin_met")
	var scene := await _scene()
	var crowd := _with_sheet(scene, "orin")
	assert_eq(crowd.size(), 1)
	assert_eq(_cell(scene, crowd[0]), Vector2i(39, 26), "in the crowd")
	WorldState.set_flag("city.stage_orin")
	await wait_physics_frames(3)
	var post := _with_sheet(scene, "orin")
	assert_eq(post.size(), 1, "never in two places")
	assert_eq(_cell(scene, post[0]), Vector2i(48, 21), "at the post of the right lamp")


func test_orin_is_not_in_the_crowd_for_someone_who_never_met_him() -> void:
	_evening()
	var scene := await _scene()
	assert_eq(_with_sheet(scene, "orin").size(), 0, "no stranger who knows her name and the duck")
	assert_null(_walker(scene, "con_orin"))


func test_the_slips_of_the_day_do_not_lie_in_the_crowd_of_the_evening() -> void:
	for task: String in ["bouquet", "ladder", "stage", "goat", "bread", "lost"]:
		WorldState.set_flag("list.take_" + task)
	_evening()
	var scene := await _scene()
	assert_eq(_decor(scene, "tal/st_slip_open").size(), 0, "taken, not done: they wait for the day")
	WorldState.set_flag("list.closed")
	await wait_physics_frames(3)
	assert_eq(_decor(scene, "tal/st_slip_open").size(), 0)


func test_tess_is_in_the_crowd_only_with_the_board_and_then_not_on_her_crate() -> void:
	_evening()
	var scene := await _scene()
	assert_eq(_with_sheet(scene, "tess").size(), 0)
	WorldState.set_flag("city.board_done")
	await wait_physics_frames(3)
	var tess := _with_sheet(scene, "tess")
	assert_eq(tess.size(), 1, "she came to the square; the crate is empty")
	assert_eq(_cell(scene, tess[0]), Vector2i(49, 26))


func test_the_day_returns_when_the_walk_goes_on_and_the_flag_follows_it() -> void:
	WorldState.set_flag("city.evening")
	var scene := await _scene()
	assert_false(WorldState.has_flag("city.evening"), "the stage is not the evening")
	assert_not_null(_walker(scene, "lio_street"))
	assert_eq(_lights(scene), 0)


func test_the_evening_arrives_before_the_stage_and_the_music_is_lios() -> void:
	_evening()
	SceneTravel.pending_spawn = "abend"
	SceneTravel.stay = false
	var scene := await _scene()
	assert_eq(_cell(scene, scene.player), ARRIVAL)
	assert_eq(scene.music, "silence", "Lio's tune is the music")


func test_a_game_loaded_in_the_evening_is_put_before_the_stage_looking_at_it() -> void:
	_evening(false)
	var scene: StadtScene = STADT.instantiate()
	add_child_autofree(scene)
	# saved at Lio's corner of the gate street, before the scene was loaded again as the evening
	# (the concert has not begun: it waits for the first physics step)
	scene.player.teleport(scene.map.cell_to_world(Vector2i(79, 37)))
	var locked: bool = await wait_until(func() -> bool: return scene.player.is_locked(), 30.0)
	assert_true(locked, "the concert has begun")
	assert_eq(_cell(scene, scene.player), ARRIVAL, "and she stands where it is seen")
	assert_eq(scene.player.facing, Facing.Dir.N, "looking at the stage")


func test_sitting_beside_tess_is_a_thing_of_the_day() -> void:
	_evening()
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	assert_false(scene._beside_tess(), "she is at the concert; the bench is empty")


# --- The invitation takes her over into the evening ---------------------------------------------


func test_yes_to_lio_ends_the_day_as_soon_as_the_talk_is_over() -> void:
	WorldState.start_quest(QUEST)
	for stage: String in ["town", "help", "list"]:
		WorldState.advance_quest(QUEST, stage)
	WorldState.set_flag("list.closed")
	var scene := await _scene()
	await wait_until(func() -> bool: return scene.quiet(), 10.0)
	assert_eq(SceneTravel.last_target, "")
	# Lio's invitation, answered "Ich komme." in the real box: the day goes when the talk is over
	Talk.present(scene, CITY, "lio_invite", scene.player)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	var over := func() -> bool:
		if _asked(scene):
			BoxAnswers.pick(scene.dialogue_box, "Ich komme.")
		elif scene.dialogue_box.is_open():
			_confirm()
		return not scene.dialogue_box.is_open()
	await wait_until(over, 30.0)
	assert_true(WorldState.has_flag("city.concert_invited"))
	assert_eq(WorldState.quest_stage(QUEST), "evening")
	await wait_physics_frames(5)
	assert_eq(SceneTravel.last_target, "stadt", "the scene is loaded again, as the evening")


func test_the_invitation_does_not_travel_while_it_is_already_evening() -> void:
	_evening()
	await _scene()
	WorldState.set_flag("city.concert_invited")
	await wait_physics_frames(3)
	assert_eq(SceneTravel.last_target, "")


# --- The concert ----------------------------------------------------------------------------------


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


func _asked(scene: GameScene) -> bool:
	var box := scene.dialogue_box
	return box.is_open() and box.line != null and box._responses.visible


func _line_on_show(scene: GameScene, ids: Dictionary) -> String:
	var box := scene.dialogue_box
	if box.is_open() and box.line != null:
		return str(ids.get(box.line.text, ""))
	return ""


## Plays the concert to its end. Returns the tape: the first line of every part in the order shown,
## the sounds' flags, the beat and the save, and whether the room was free at the end.
func _play_out(scene: StadtScene, answer := "", timeout := 240.0) -> Dictionary:
	var ids := {}
	for id in PART_LINES:
		ids[LineText.of(id)] = id
	var run := {"tape": [] as Array[String], "free": false}
	var tape: Array = run["tape"]
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in ["city.string_snapped", "melody.lio_concert", "beat.city_concert"]:
			tape.append("flag:" + id)
	var on_saved := func(slot: String) -> void:
		if slot == SaveSystem.AUTOSAVE:
			tape.append("saved")
	WorldState.flag_changed.connect(on_flag)
	SaveSystem.saved.connect(on_saved)
	var watch := func() -> bool:
		_polls += 1
		var box := scene.dialogue_box
		if _asked(scene):
			BoxAnswers.pick(box, answer)
		elif box.is_open() and _polls % 8 == 0:
			_confirm()
		var shown := _line_on_show(scene, ids)
		if not shown.is_empty() and (tape.is_empty() or tape[-1] != shown):
			tape.append(shown)
		return Beat.reached("city_concert")
	var done: bool = await wait_until(watch, timeout)
	await wait_physics_frames(3)
	WorldState.flag_changed.disconnect(on_flag)
	SaveSystem.saved.disconnect(on_saved)
	assert_true(done, "the concert ended: " + str(tape))
	run["free"] = not scene.player.is_locked()
	return run


func test_the_concert_plays_its_nine_parts_in_turn_and_leaves_the_room_free() -> void:
	_evening(false)
	var scene := await _scene()
	var run := await _play_out(scene)
	var tape: Array = run["tape"]
	var parts: Array = tape.filter(
		func(entry: String) -> bool: return not entry.contains(":") and entry != "saved"
	)
	assert_eq(parts, PART_LINES, "in this order, every part once")
	assert_true(run["free"], "she is free again")
	assert_eq(tape.count("flag:city.string_snapped"), 1)
	assert_eq(tape.count("flag:melody.lio_concert"), 1)
	assert_true(WorldState.has_flag("melody.lio_concert"))
	assert_lt(tape.find("flag:city.string_snapped"), tape.find("kon_hold_2"), "the string first")
	assert_lt(
		tape.find("flag:melody.lio_concert"), tape.find("kon_fin_1"), "the finale after the tune"
	)


func test_the_beat_comes_with_the_last_part_and_one_save() -> void:
	_evening(false)
	var scene := await _scene()
	var run := await _play_out(scene)
	var tape: Array = run["tape"]
	assert_gte(tape.count("saved"), 1, "the beat saves")
	assert_gt(tape.find("saved"), tape.find("kon_fin_1"), "nothing is saved while it plays")
	assert_true(Beat.reached("city_concert"))


func test_the_concert_is_not_played_a_second_time() -> void:
	_evening()
	var scene := await _scene()
	await wait_physics_frames(30)
	assert_false(scene.dialogue_box.is_open(), "nothing starts")
	assert_false(scene.player.is_locked())
	assert_null(scene.get_node_or_null("Concert"))


func test_asking_orin_in_the_cutscene_puts_him_at_the_post() -> void:
	WorldState.set_facet("connection")
	WorldState.set_flag("city.orin_met")
	_evening(false)
	var scene := await _scene()
	await _play_out(scene, "Orin! Hältst du die Lampe?")
	assert_true(WorldState.has_flag("city.stage_orin"))
	await wait_physics_frames(3)
	assert_eq(_cell(scene, _with_sheet(scene, "orin")[0]), Vector2i(48, 21), "he holds it")


func test_a_game_left_during_the_concert_plays_it_again_from_the_start() -> void:
	_evening(false)
	var scene := await _scene()
	var begun: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 30.0)
	assert_true(begun, "the first part is up")
	assert_false(Beat.reached("city_concert"))
	scene.queue_free()
	await wait_physics_frames(3)
	var again := await _scene()
	var run := await _play_out(again)
	var parts: Array = run["tape"].filter(
		func(entry: String) -> bool: return not entry.contains(":") and entry != "saved"
	)
	assert_eq(parts, PART_LINES, "and it starts at the first part")


func test_while_it_plays_the_player_stands_still_and_saving_waits() -> void:
	_evening(false)
	var scene := await _scene()
	var locked: bool = await wait_until(func() -> bool: return scene.player.is_locked(), 30.0)
	assert_true(locked, "the cutscene holds her")
	assert_gt(SaveSystem.blockers().size(), 0, "and the game does not save while it plays")
