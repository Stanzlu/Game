extends GutTest
## Act IV, segment S8 in the scene of the house: the first time she enters it in the stage "home"
## of `main_city_way`, Tess comes in with boards, hangs the shelves with her, says one sentence
## about the bench, brings the loaf, sits and goes; the chair stays. The act ends quietly in one
## block: "done", the mark of the chapter, the beat and one save. Before the stage nothing plays;
## after the end it never plays again. The road that ends the night is tested here too. The lines
## are tested in test_akt4_heimkehr, the four places in test_akt4_regal.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const STRASSE := preload("res://world/levels/akt4/strasse.tscn")
const FIXTURE := "res://tests/fixtures/saves/v2_akt3_end.json"
const QUEST := "main_city_way"
const WAY: Array[String] = ["west", "town", "help", "list", "evening", "night", "home", "done"]
const PARTED: PackedStringArray = [
	"city.mira_parted_boundary", "city.mira_parted_joined", "city.mira_parted_silent"
]
## The lines the homecoming can show, by ID: the tape of a run is made of them.
const HOME_LINES: Array[String] = [
	"hk4_in_1",
	"hk4_in_2",
	"hk4_tess_1",
	"hk4_tess_2",
	"hk4_tess_3",
	"hk4_tess_4",
	"hk4_tess_5",
	"hk4_tess_6",
	"hk4_build_1",
	"hk4_build_2",
	"hk4_bench_1",
	"hk4_bench_2",
	"hk4_bread_1",
	"hk4_bread_2",
	"hk4_close_1",
	"hk4_close_2",
	"hk4_close_3",
]
const FLAGS: Array[String] = [
	"house.shelves",
	"house.bread",
	"house.guest_tess",
	"chapter.act4",
	"beat.act4_home",
]
const SLOTS: Array[String] = ["shelf_3", "shelf_4", "wall_1", "wall_2"]
## Her chair (the hermit's stands at another place).
const HER_CHAIR := Vector2i(18, 12)
var _saved_dir := ""
var _line_ids: Dictionary = {}
var _polls := 0


func before_each() -> void:
	# no scene of these tests leaves its room for another: the doors only note where they lead
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	# saves of its own: the autosave of these runs is read back from the disk
	_saved_dir = SaveSystem.save_dir
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "heimkehr4_test_saves"
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


## The state "Weiter" loads at the end of Act III (still in the house).
func _end_of_act_three() -> void:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)


## Starts the walk to the city and takes it up to `stage` ("west" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


func _house() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _gone(scene: Node) -> void:
	scene.queue_free()
	await wait_physics_frames(2)


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


func _guests(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(func(node: Node) -> bool: return node is GuestWalker)


func _decor(scene: GameScene, sprite: String) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and node.sprite_id == sprite
	)


func _slots(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(func(node: Node) -> bool: return node is CuriositySlot)


func _her_chairs(scene: GameScene) -> Array[Node]:
	return _decor(scene, "haus/guest_chair").filter(
		func(node: Node) -> bool: return scene.map.world_to_cell(node.global_position) == HER_CHAIR
	)


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


func _asked(scene: GameScene) -> bool:
	var box := scene.dialogue_box
	return box.is_open() and box.line != null and box._responses.visible


## Moves the text on as a player does, every few ticks (the first press types the line out, the next
## moves on). The lines are told and not waited for: waiting for the automatic advance takes a
## minute of play time.
func _move_on(scene: GameScene) -> void:
	_polls += 1
	if _polls % 8 == 0 and scene.dialogue_box.is_open() and not _asked(scene):
		_confirm()


func _line_on_show(scene: GameScene) -> String:
	if _line_ids.is_empty():
		for id in HOME_LINES:
			_line_ids[LineText.of(id)] = id
	var box := scene.dialogue_box
	if box.is_open() and box.line != null:
		return str(_line_ids.get(box.line.text, ""))
	return ""


## Plays the homecoming to the end of the act and writes a tape of what a player sees and what the
## game sets, in the order it happens: every line as its ID, the flags, the stage "done", the save.
## Also what the room looked like three ticks after she sat.
func _play_out(scene: HausScene, timeout := 120.0) -> Dictionary:
	var run := {
		"tape": [] as Array[String],
		"sat": false,
		"guests": 0,
		"chairs_after_sitting": -1,
		"ticks": 0,
		"locked_at_the_end": true,
	}
	var tape: Array = run["tape"]
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in FLAGS:
			tape.append("flag:" + id)
	var on_quest := func(quest: String, stage: String) -> void:
		if quest == QUEST:
			tape.append("quest:" + stage)
	var on_saved := func(slot: String) -> void:
		if slot == SaveSystem.AUTOSAVE:
			tape.append("saved")
	WorldState.flag_changed.connect(on_flag)
	WorldState.quest_changed.connect(on_quest)
	SaveSystem.saved.connect(on_saved)
	var watch := func() -> bool:
		_move_on(scene)
		var id := _line_on_show(scene)
		if not id.is_empty() and (tape.is_empty() or tape[-1] != id):
			tape.append(id)
		var guests := _guests(scene)
		run["guests"] = maxi(run["guests"], guests.size())
		if WorldState.has_flag("house.guest_tess"):
			run["ticks"] += 1
			if run["ticks"] == 1:
				run["sat"] = (
					not guests.is_empty() and str(guests[0].sprite.animation).begins_with("sit")
				)
			if run["ticks"] == 3:
				run["chairs_after_sitting"] = _her_chairs(scene).size()
		return Chapter.reached("act4")
	var over: bool = await wait_until(watch, timeout)
	await wait_physics_frames(5)
	WorldState.flag_changed.disconnect(on_flag)
	WorldState.quest_changed.disconnect(on_quest)
	SaveSystem.saved.disconnect(on_saved)
	assert_true(over, "the act came to its end")
	run["locked_at_the_end"] = scene.player.is_locked()
	return run


# --- Before the stage -------------------------------------------------------------------------


func test_nothing_plays_before_the_stage_home() -> void:
	for stage: String in ["", "west", "list", "evening", "night"]:
		WorldState.new_game()
		_end_of_act_three()
		if not stage.is_empty():
			_walk_to(stage)
		var scene := await _house()
		assert_null(scene.get_node_or_null("CityHomecoming"), "stage '%s'" % stage)
		await wait_physics_frames(60)
		assert_false(scene.dialogue_box.is_open(), "stage '%s'" % stage)
		assert_eq(_guests(scene).size(), 0, "stage '%s'" % stage)
		assert_eq(_slots(scene).size(), 0, "no shelf, no peg, so no place yet")
		for flag: String in FLAGS:
			assert_false(WorldState.has_flag(flag), "stage '%s': %s" % [stage, flag])
		await _gone(scene)
	assert_push_error_count(0)


func test_the_house_before_the_homecoming_has_no_shelves_no_loaf_and_no_chair_of_hers() -> void:
	_end_of_act_three()
	_walk_to("night")
	var scene := await _house()
	assert_eq(_her_chairs(scene).size(), 0)
	assert_eq(_decor(scene, "haus/loaf").size(), 0)
	assert_eq(_slots(scene).size(), 0, "no shelf, no peg")
	assert_push_error_count(0)


# --- The homecoming -----------------------------------------------------------------------------


func test_tess_comes_hangs_the_shelves_brings_the_loaf_sits_and_goes_the_chair_stays() -> void:
	_end_of_act_three()
	WorldState.set_flag("city.tess_met")
	_walk_to("home")
	var scene := await _house()
	assert_true(WorldState.has_flag("house.workbench"), "the bench of Act III stands")
	assert_not_null(scene.get_node_or_null("CityHomecoming"))
	var before := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(before.ok, "the entry save is there")
	assert_eq(before.state.quests[QUEST].stage, "home", "at the door it said: home")
	assert_false(Chapter.in_flags(before.state.flags, "act4"))
	var run := await _play_out(scene)
	assert_eq(
		run["tape"],
		[
			"hk4_in_1",
			"hk4_in_2",
			"hk4_tess_1",
			"hk4_tess_3",
			"hk4_tess_4",
			"hk4_tess_5",
			"hk4_tess_6",
			"flag:house.shelves",
			"hk4_build_1",
			"hk4_build_2",
			"hk4_bench_1",
			"hk4_bench_2",
			"flag:house.bread",
			"hk4_bread_1",
			"hk4_bread_2",
			"flag:house.guest_tess",
			"hk4_close_1",
			"hk4_close_2",
			"hk4_close_3",
			"quest:done",
			"flag:chapter.act4",
			"flag:beat.act4_home",
			"saved",
		],
		"the order: the flag before the line that speaks of it, the end in one block"
	)
	assert_true(run["sat"], "she sits when the chair is set")
	assert_eq(run["chairs_after_sitting"], 1, "and the chair stands under her")
	assert_eq(run["guests"], 1, "one Tess, once")
	assert_false(run["locked_at_the_end"], "the room is hers again")
	await wait_physics_frames(60)
	assert_eq(_guests(scene).size(), 0, "she has gone")
	assert_eq(_her_chairs(scene).size(), 1, "and the chair stays")
	assert_eq(_decor(scene, "haus/loaf").size(), 1, "and the loaf lies on the table")
	assert_eq(_slots(scene).size(), 4, "four places for curiosities")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(WAY))
	assert_true(Chapter.reached("act4"))
	assert_true(Beat.reached("act4_home"))
	assert_eq(WorldState.relationship_state("tess"), "close")
	assert_true(WorldState.has_memory("tess", "guest"))
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")
	assert_push_error_count(0)


func test_the_end_is_on_the_disk_and_until_act_five_the_build_counts_it_as_finished() -> void:
	_end_of_act_three()
	_walk_to("home")
	var scene := await _house()
	var run := await _play_out(scene)
	assert_eq((run["tape"] as Array).count("saved"), 1, "one save for the end")
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(disk.ok, "readable")
	assert_eq(disk.state.quests[QUEST].stage, "done")
	assert_true(Chapter.in_flags(disk.state.flags, "act4"), "the mark of the chapter")
	for flag: String in ["beat.act4_home", "house.shelves", "house.bread", "house.guest_tess"]:
		assert_true(disk.state.flags.has(flag), "saved: " + flag)
	# Chapter.LAST is "act4": until Act V raises it, the newest end is the end of the build
	assert_true(SaveSystem.summary(SaveSystem.AUTOSAVE)["finished"], "the build ends here")
	assert_push_error_count(0)


func test_whoever_never_met_her_reads_her_name_and_the_act_ends_all_the_same() -> void:
	_end_of_act_three()
	_walk_to("home")
	var scene := await _house()
	var run := await _play_out(scene)
	assert_true("hk4_tess_2" in run["tape"], "the name on the folding rule")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act4"))
	assert_push_error_count(0)


func test_it_never_plays_a_second_time_not_with_the_scene_nor_after_a_restart() -> void:
	_end_of_act_three()
	_walk_to("home")
	var scene := await _house()
	await _play_out(scene)
	await _gone(scene)
	var marks: Array[String] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in FLAGS:
			marks.append(id)
	WorldState.flag_changed.connect(on_flag)
	var again := await _house()
	assert_null(again.get_node_or_null("CityHomecoming"), "over for good")
	assert_eq(_her_chairs(again).size(), 1, "but her chair stands")
	assert_eq(_slots(again).size(), 4)
	await wait_physics_frames(180)
	assert_eq(marks, [] as Array[String], "no mark again")
	assert_false(again.dialogue_box.is_open())
	assert_false(again.player.is_locked())
	await _gone(again)
	# the game is closed and opened again with "Weiter": the same
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	WorldState.new_game()
	WorldState.replace_state(disk.state)
	var restarted := await _house()
	assert_null(restarted.get_node_or_null("CityHomecoming"))
	await wait_physics_frames(180)
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(marks, [] as Array[String], "nothing after a restart either")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(restarted.player.is_locked())
	assert_push_error_count(0)


func test_a_homecoming_that_was_broken_off_plays_again_from_the_door() -> void:
	_end_of_act_three()
	_walk_to("home")
	var scene := await _house()
	# up to the shelves and no further: the game is closed (the cutscene saved nothing of it)
	var up: bool = await wait_until(
		func() -> bool:
			_move_on(scene)
			return WorldState.has_flag("house.shelves"),
		60.0
	)
	assert_true(up, "she has shown the shelves")
	assert_false(Chapter.reached("act4"))
	await _gone(scene)
	await wait_physics_frames(5)
	assert_eq(WorldState.quest_stage(QUEST), "home", "the stage is still home")
	var again := await _house()
	for flag: String in ["house.shelves", "house.bread", "house.guest_tess"]:
		assert_false(WorldState.has_flag(flag), "cleared at the door: " + flag)
	var run := await _play_out(again)
	assert_eq(run["tape"][0], "hk4_in_1", "from the door")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act4"))
	assert_eq(_her_chairs(again).size(), 1)
	assert_push_error_count(0)


func test_nothing_starts_while_a_line_is_up() -> void:
	_end_of_act_three()
	_walk_to("home")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(1)
	Talk.present(scene, CityHomecoming.DIALOGUE, "slot_nothing", scene.player)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	await wait_physics_frames(120)
	assert_eq(_guests(scene).size(), 0, "she waits at the door")
	assert_false(WorldState.has_flag("house.shelves"))
	assert_push_error_count(0)


# --- The road that ends the night -----------------------------------------------------------------


func test_the_road_ends_the_night_once_the_quarrel_has_sent_mira_ahead() -> void:
	for flag: String in PARTED:
		WorldState.new_game()
		_end_of_act_three()
		_walk_to("night")
		WorldState.set_flag(flag)
		var scene: GameScene = STRASSE.instantiate()
		add_child_autofree(scene)
		assert_eq(
			WorldState.quest_stage(QUEST), "home", "before the scene saves its entry: " + flag
		)
		var up: bool = await wait_until(
			func() -> bool:
				_move_on(scene)
				return Beat.reached("strasse_dawn"),
			60.0
		)
		assert_true(up, "the morning is told: " + flag)
		await wait_physics_frames(5)
		assert_false(scene.player.is_locked(), "and it lets go of the room: " + flag)
		scene.free()


func test_the_road_leaves_the_night_alone_until_mira_has_gone_ahead() -> void:
	_end_of_act_three()
	_walk_to("night")
	var scene: GameScene = STRASSE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(90)
	assert_eq(WorldState.quest_stage(QUEST), "night", "no quarrel, no morning")
	assert_false(Beat.reached("strasse_dawn"))
	assert_false(scene.dialogue_box.is_open())


func test_the_morning_is_told_only_once() -> void:
	_end_of_act_three()
	_walk_to("night")
	WorldState.set_flag("city.mira_parted_silent")
	var scene: GameScene = STRASSE.instantiate()
	add_child_autofree(scene)
	await wait_until(
		func() -> bool:
			_move_on(scene)
			return Beat.reached("strasse_dawn"),
		60.0
	)
	scene.free()
	await wait_physics_frames(2)
	var again: GameScene = STRASSE.instantiate()
	add_child_autofree(again)
	await wait_physics_frames(120)
	assert_false(again.dialogue_box.is_open(), "no second morning")
	assert_eq(WorldState.quest_stage(QUEST), "home")
