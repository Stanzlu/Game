# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W6, the scene of the house on the way home (ADR-070): the first time she
## enters it in the stage "home" the bench stands in the corner and the Antreiber sits at it,
## wherever he was before (the cat on his lap, once she is fed), the hermit comes as a guest if she
## asked him in the hut and goes again (the chair stays), and then the act is over, quietly, in one
## block: "done", the mark of the chapter, the beat and one save. The valley and the old places
## are tested in test_akt3_heimkehr_weg, the lines in test_akt3_heimkehr, the pictures in
## test_akt3_heimkehr_bild.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const FIXTURE := "res://tests/fixtures/saves/v2_akt2_end.json"
const HEIMKEHR := "res://content/dialogue/akt3/heimkehr.dialogue"
const ANTREIBER_SHEET := "res://entities/character/sheet_antreiber_look.tres"
const QUEST := "main_forest_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night", "home", "done"]
## Where the Antreiber sits at the bench.
const SEAT := Vector2i(22, 14)
## The lines the homecoming can show, by ID: the tape of a run is made of them.
const HOME_LINES: Array[String] = [
	"hk_in_1",
	"hk_in_2",
	"hk_in_3",
	"hk_guest_1",
	"hk_guest_2",
	"hk_guest_3",
	"hk_guest_4",
	"hk_guest_5",
	"hk_guest_6",
	"hk_close_1",
	"hk_close_2",
]
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
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "heimkehr_test_saves"
	_clear_saves()


func after_each() -> void:
	Input.action_release(&"move_down")
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


## The state "Weiter" loads at the end of Act II, with the morning after told (the valley is as the
## morning left it).
func _end_of_act_two() -> void:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)
	WorldState.set_flag("beat.act3_morning")
	WorldState.set_flag("valley.mira_gone")
	WorldState.set_day_preset("morgen")


## Starts the hero's walk and takes it up to `stage` (the stage "leave" is the start).
func _walk_to(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for step in WAY.size():
		if WAY[step] == stage:
			return
		assert_true(WorldState.advance_quest(QUEST, WAY[step + 1]), "to " + WAY[step + 1])


## The house with Mira long behind her (the fire burns and she has been): only the homecoming plays.
func _house() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
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


## Every cat the room shows (the one at the window, the one asleep).
func _cats(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool: return node is Decor and node.sprite_id.begins_with("haus/cat")
	)


## Every man with the Antreiber's sheet.
func _antreibers(scene: GameScene) -> Array[Node]:
	return _alive(scene).filter(
		func(node: Node) -> bool:
			return node is NpcWalker and node.sheet.resource_path == ANTREIBER_SHEET
	)


## The Decor or the walker with this cue (a Decor keeps it as meta), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in _alive(scene):
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if node is NpcWalker and (node as NpcWalker).cue == cue:
			return node
	return null


## What looking at, or talking to, a thing does: the same signal the player's key sends.
func _look(prop: Node) -> void:
	(prop.get_node("Interactable") as Interactable).interacted.emit(null)


## The key a player presses to move the text on, as the real input path takes it.
func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


func _asked(scene: GameScene) -> bool:
	var box := scene.dialogue_box
	return box.is_open() and box.line != null and box._responses.visible


## The answers that can be picked in the group that is up.
func _offered(scene: GameScene) -> PackedStringArray:
	var texts: PackedStringArray = []
	for response: DialogueResponse in scene.dialogue_box.line.responses:
		if response.is_allowed:
			texts.append(response.text)
	return texts


## Looks at `prop` and takes `answers` in the real box, in order, as the groups come up, until the
## box is shut again; the lines in between are moved on. Returns what each group offered. Every
## answer has to be taken.
func _talk_through(
	scene: GameScene, prop: Node, answers: PackedStringArray
) -> Array[PackedStringArray]:
	var offered: Array[PackedStringArray] = []
	var next := [0]
	var opened := [false]
	var watch := func() -> bool:
		if scene.dialogue_box.is_open():
			opened[0] = true
			if _asked(scene):
				if next[0] < answers.size():
					var shown := _offered(scene)
					if BoxAnswers.pick(scene.dialogue_box, answers[next[0]]):
						offered.append(shown)
						next[0] += 1
			else:
				_confirm()
		return opened[0] and not scene.dialogue_box.is_open() and next[0] == answers.size()
	_look(prop)
	var done: bool = await wait_until(watch, 60.0)
	assert_true(done, "the box opened, the answers %s were taken and it closed" % [answers])
	assert_eq(next[0], answers.size(), "every answer was taken")
	await wait_physics_frames(3)
	return offered


## Moves the text on as a player does, every few ticks (the first press types the line out, the next
## moves on; a group of answers waits for its answer). The lines of the homecoming are told and not
## waited for: a test that waited for the automatic advance would take a minute of play time.
func _move_on(scene: GameScene) -> void:
	_polls += 1
	if _polls % 8 == 0 and scene.dialogue_box.is_open() and not _asked(scene):
		_confirm()


## Waits until `done` holds, moving the lines on meanwhile.
func _until(scene: GameScene, done: Callable, timeout := 120.0) -> bool:
	var watch := func() -> bool:
		_move_on(scene)
		return done.call()
	return await wait_until(watch, timeout)


## The ID of the line that is on show ("" if none of the lines of the homecoming is).
func _line_on_show(scene: GameScene) -> String:
	if _line_ids.is_empty():
		for id in HOME_LINES:
			_line_ids[LineText.of(id)] = id
	var box := scene.dialogue_box
	if box.is_open() and box.line != null:
		return str(_line_ids.get(box.line.text, ""))
	return ""


## Plays the homecoming to the end of the act and writes a tape of what a player sees and what the
## game sets, in the order it happens: every line of the homecoming as its ID, the chair ("flag:
## house.guest_hermit"), the stage "done", the mark of the chapter, the beat and the save. Also what
## the room looked like three ticks after he sat.
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
		if value and id in ["house.guest_hermit", "chapter.act3", "beat.act3_home"]:
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
		if WorldState.has_flag("house.guest_hermit"):
			run["ticks"] += 1
			if run["ticks"] == 1:
				run["sat"] = (
					not guests.is_empty() and str(guests[0].sprite.animation).begins_with("sit")
				)
			if run["ticks"] == 3:
				run["chairs_after_sitting"] = _decor(scene, "haus/guest_chair").size()
		return Chapter.reached("act3")
	var over: bool = await wait_until(watch, timeout)
	await wait_physics_frames(5)
	WorldState.flag_changed.disconnect(on_flag)
	WorldState.quest_changed.disconnect(on_quest)
	SaveSystem.saved.disconnect(on_saved)
	assert_true(over, "the act came to its end")
	run["locked_at_the_end"] = scene.player.is_locked()
	return run


# --- The house: the bench ------------------------------------------------------------------


func test_the_bench_stands_in_the_corner_when_the_picture_comes_up() -> void:
	_end_of_act_two()
	_walk_to("home")
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	assert_true(WorldState.has_flag("house.workbench"), "set before the map is built")
	for sprite: String in ["haus/workbench", "haus/plan_board"]:
		assert_eq(_decor(scene, sprite).size(), 1, "%s stands from the first frame" % sprite)
	assert_eq(_decor(scene, "haus/guest_chair").size(), 0, "the chair comes with the hermit")
	assert_not_null(_first(scene, "antreiber_bench"))
	assert_not_null(_first(scene, "cat_bench"))
	assert_true(scene.is_homecoming())
	assert_push_error_count(0)


func test_nothing_of_the_bench_stands_before_the_homecoming() -> void:
	for stage: String in ["", "leave", "brook", "wood"]:
		WorldState.new_game()
		_end_of_act_two()
		if not stage.is_empty():
			_walk_to(stage)
		var scene := await _house()
		assert_false(WorldState.has_flag("house.workbench"), "stage '%s'" % stage)
		assert_false(scene.is_homecoming(), "stage '%s'" % stage)
		for sprite: String in ["haus/workbench", "haus/plan_board", "haus/guest_chair"]:
			assert_eq(_decor(scene, sprite).size(), 0, "stage '%s': no %s" % [stage, sprite])
		assert_null(_first(scene, "antreiber_bench"))
		assert_null(_first(scene, "cat_bench"))
		# the room is what it was: he sits at the fire with the cat on his lap
		assert_not_null(_first(scene, "antreiber_rest"), "stage '%s': at the fire" % stage)
		await wait_physics_frames(30)
		assert_false(Chapter.reached("act3"), "stage '%s'" % stage)
		await _gone(scene)
	assert_push_error_count(0)


func test_the_night_is_home_when_the_house_is_entered_without_the_valley() -> void:
	# a save from the night wood that comes back to the house with no valley behind it
	_end_of_act_two()
	_walk_to("night")
	var scene := await _house()
	assert_eq(WorldState.quest_stage(QUEST), "home", "the step is made before the map is built")
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(WAY.slice(0, 5)))
	assert_true(scene.is_homecoming())
	assert_true(WorldState.has_flag("house.workbench"))
	assert_eq(_decor(scene, "haus/workbench").size(), 1)
	assert_push_error_count(0)


func test_one_antreiber_and_one_cat_in_the_house_in_every_state() -> void:
	var states: Array[Array] = [
		["house.antreiber_by_fire"],
		["house.antreiber_by_fire", "house.antreiber_refused"],
		["forest.antreiber_ahead"],
		["house.antreiber_left"],
		["forest.antreiber_met", "forest.antreiber_sat", "forest.antreiber_ahead"],
		[],
	]
	for state: Array in states:
		for fed: bool in [true, false]:
			WorldState.new_game()
			_end_of_act_two()
			WorldState.clear_flag("house.antreiber_by_fire")
			WorldState.clear_flag("house.antreiber_refused")
			for flag: String in state:
				WorldState.set_flag(flag)
			if not fed:
				WorldState.clear_flag("house.cat_fed")
			_walk_to("home")
			var scene := await _house()
			var label := "%s, fed %s" % [state, fed]
			var men := _antreibers(scene)
			assert_eq(men.size(), 1, "one man: " + label)
			assert_eq(
				(men[0] as NpcWalker).cue, "antreiber_bench", "and he is at the bench: " + label
			)
			assert_true((men[0] as NpcWalker).seated, "sitting: " + label)
			assert_eq(scene.map.world_to_cell(men[0].global_position), SEAT, label)
			var cats := _cats(scene)
			assert_eq(cats.size(), 1, "one cat: " + label)
			if fed:
				var lap := cats[0] as Decor
				assert_eq(lap.sprite_id, "haus/cat_sleep", "asleep on him: " + label)
				assert_eq(
					scene.map.world_to_cell(lap.global_position), SEAT + Vector2i(0, 1), label
				)
				assert_eq(lap.get_meta(&"cue"), "cat_bench", "and she can be spoken to: " + label)
			else:
				assert_eq(
					(cats[0] as Decor).sprite_id, "haus/cat_window", "at the window: " + label
				)
			await _gone(scene)
	assert_push_error_count(0)


# --- The house: the homecoming ---------------------------------------------------------------


## South from where she stands is the door: the bench and the chair stand off the way, and nothing
## holds her in the room.
func _walk_out(scene: HausScene) -> bool:
	SceneTravel.last_target = ""
	scene.player.global_position = scene.map.cell_to_world(Vector2i(19, 13))
	scene.player.velocity = Vector2.ZERO
	Input.action_press(&"move_down")
	var left := 240
	while left > 0 and SceneTravel.last_target != "tal":
		await wait_physics_frames(1)
		left -= 1
	Input.action_release(&"move_down")
	return SceneTravel.last_target == "tal"


## What the autosave on the disk says of the end: the stage, the mark of the chapter, the beat, the
## bench; and the build counts the game as finished.
func _assert_the_end_on_the_disk(label: String) -> void:
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(disk.ok, "readable: " + label)
	assert_eq(disk.state.quests[QUEST].stage, "done", "the stage: " + label)
	assert_true(Chapter.in_flags(disk.state.flags, "act3"), "the mark of the chapter: " + label)
	assert_true(disk.state.flags.has("beat.act3_home"), "the beat: " + label)
	assert_true(disk.state.flags.has("house.workbench"), "the bench: " + label)
	assert_true(SaveSystem.summary(SaveSystem.AUTOSAVE)["finished"], "finished: " + label)


func test_without_the_hermit_the_act_ends_quietly_and_nothing_plays_again() -> void:
	SceneTravel.stay = true
	_end_of_act_two()
	_walk_to("home")
	var scene := await _house()
	assert_true(scene.is_homecoming())
	var before := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(before.ok, "the entry save is there")
	assert_eq(before.state.quests[QUEST].stage, "home", "at the door it said: home")
	assert_false(Chapter.in_flags(before.state.flags, "act3"))
	assert_false(SaveSystem.summary(SaveSystem.AUTOSAVE)["finished"], "not finished before")
	var run := await _play_out(scene)
	assert_eq(
		run["tape"],
		[
			"hk_in_1",
			"hk_in_2",
			"hk_in_3",
			"hk_close_2",
			"quest:done",
			"flag:chapter.act3",
			"flag:beat.act3_home",
			"saved",
		],
		"the order, and nothing before the end: no mark, no beat, no save"
	)
	assert_eq(run["guests"], 0, "nobody came in")
	assert_false(WorldState.has_flag("house.guest_hermit"))
	assert_eq(_decor(scene, "haus/guest_chair").size(), 0, "and no chair")
	assert_false(run["locked_at_the_end"], "the room is hers again")
	assert_false(scene.is_homecoming())
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(WAY))
	assert_true(SaveSystem.blockers().is_empty(), "nothing holds the game from saving")
	_assert_the_end_on_the_disk("without the hermit")
	# the door was never locked, and the room has no blocker in it
	for node in _alive(scene):
		var script: Script = node.get_script()
		assert_false(script != null and "blocker" in script.resource_path, "no blocker anywhere")
	assert_true(await _walk_out(scene), "she can go out")
	await _gone(scene)
	# a second visit: the bench stands and nothing plays, nothing is marked, nothing is saved twice
	var marks: Array[String] = []
	var on_flag := func(id: String, value: bool) -> void:
		if value and id in ["chapter.act3", "beat.act3_home", "house.guest_hermit"]:
			marks.append(id)
	WorldState.flag_changed.connect(on_flag)
	var again := await _house()
	assert_false(again.is_homecoming(), "the scene is over for good")
	assert_true(WorldState.has_flag("house.workbench"), "but the bench stands")
	await wait_physics_frames(180)
	assert_eq(marks, [] as Array[String], "no mark again")
	assert_eq(WorldState.quest_history(QUEST), PackedStringArray(WAY), "and no second step")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(again.dialogue_box.is_open())
	assert_false(again.player.is_locked())
	await _gone(again)
	# the game is closed and opened again with "Weiter": the same
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	WorldState.new_game()
	WorldState.replace_state(disk.state)
	var restarted := await _house()
	assert_false(restarted.is_homecoming())
	await wait_physics_frames(180)
	WorldState.flag_changed.disconnect(on_flag)
	assert_eq(marks, [] as Array[String], "nothing after a restart either")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_false(restarted.player.is_locked())
	assert_push_error_count(0)


func test_with_the_hermit_he_comes_sits_speaks_and_goes_and_the_chair_stays() -> void:
	_end_of_act_two()
	WorldState.set_flag("forest.hermit_invited")
	_walk_to("home")
	var scene := await _house()
	assert_eq(_decor(scene, "haus/guest_chair").size(), 0, "no chair yet")
	var run := await _play_out(scene)
	assert_eq(
		run["tape"],
		[
			"hk_in_1",
			"hk_in_2",
			"hk_in_3",
			"flag:house.guest_hermit",
			"hk_guest_1",
			"hk_guest_2",
			"hk_guest_3",
			"hk_guest_4",
			"hk_guest_5",
			"hk_close_1",
			"hk_close_2",
			"quest:done",
			"flag:chapter.act3",
			"flag:beat.act3_home",
			"saved",
		],
		"he sits after the first lines, speaks, and the last lines come before the end"
	)
	assert_true(run["sat"], "the flag is set when he sits")
	assert_eq(run["chairs_after_sitting"], 1, "and the chair stands under him")
	assert_eq(run["guests"], 1, "one hermit, once")
	await wait_physics_frames(60)
	assert_eq(_guests(scene).size(), 0, "he has gone")
	assert_eq(_decor(scene, "haus/guest_chair").size(), 1, "and the chair stays")
	assert_true(WorldState.has_flag("house.guest_hermit"))
	var chair := _decor(scene, "haus/guest_chair")[0] as Decor
	assert_eq(scene.map.world_to_cell(chair.global_position), HausScene.CHAIR_CELL)
	assert_eq(_antreibers(scene).size(), 1, "the Antreiber stays at the bench")
	assert_false(scene.player.is_locked())
	_assert_the_end_on_the_disk("with the hermit")
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(disk.state.flags.has("house.guest_hermit"), "the chair he left is saved")
	assert_push_error_count(0)


func test_the_act_ends_for_every_walk_and_the_lines_follow_the_cat() -> void:
	var variants: Array[Dictionary] = [
		{"care": true, "invited": false, "by_fire": false, "fed": true},
		{"care": true, "invited": true, "by_fire": false, "fed": false},
		{"care": false, "invited": false, "by_fire": true, "fed": false},
	]
	for variant: Dictionary in variants:
		WorldState.new_game()
		_end_of_act_two()
		if not variant["by_fire"]:
			WorldState.clear_flag("house.antreiber_by_fire")
			WorldState.set_flag("forest.antreiber_ahead")
		if not variant["fed"]:
			WorldState.clear_flag("house.cat_fed")
		if variant["care"]:
			WorldState.set_facet("care")
		if variant["invited"]:
			WorldState.set_flag("forest.hermit_invited")
		_walk_to("home")
		var scene := await _house()
		var run := await _play_out(scene)
		var label := str(variant)
		var tape: Array = run["tape"]
		assert_eq(WorldState.quest_stage(QUEST), "done", label)
		assert_true(Chapter.reached("act3"), label)
		assert_eq(WorldState.has_flag("house.guest_hermit"), variant["invited"], label)
		assert_eq(run["guests"], 1 if variant["invited"] else 0, label)
		assert_eq(tape.count("saved"), 1, "one save: " + label)
		assert_eq("hk_in_2" in tape, variant["fed"], "the cat on his lap is told: " + label)
		assert_eq("hk_guest_5" in tape, variant["invited"] and variant["fed"], label)
		assert_eq("hk_guest_6" in tape, variant["invited"] and not variant["fed"], label)
		var cats := _cats(scene)
		assert_eq(cats.size(), 1, "one cat: " + label)
		assert_eq(
			(cats[0] as Decor).sprite_id, "haus/cat_sleep" if variant["fed"] else "haus/cat_window"
		)
		_assert_the_end_on_the_disk(label)
		await _gone(scene)
	assert_push_error_count(0)


func test_a_game_closed_in_the_middle_plays_it_again_from_the_door() -> void:
	_end_of_act_two()
	WorldState.set_flag("forest.hermit_invited")
	_walk_to("home")
	var scene := await _house()
	var sat := func() -> bool: return WorldState.has_flag("house.guest_hermit")
	assert_true(await _until(scene, sat), "he sat down")
	assert_false(Chapter.reached("act3"), "the act is not over")
	# what the disk holds is what the game saved at the door: the scene blocks the save
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	assert_true(disk.ok)
	assert_eq(disk.state.quests[QUEST].stage, "home")
	assert_false(disk.state.flags.has("house.guest_hermit"), "no chair on the disk")
	assert_false(Chapter.in_flags(disk.state.flags, "act3"))
	scene.free()
	await wait_physics_frames(3)
	assert_true(SaveSystem.blockers().is_empty(), "the freed scene let go of the save")
	# the state is still in memory with the chair in it: the room built again takes it away
	var again := await _house()
	assert_true(again.is_homecoming(), "it plays from the beginning")
	assert_false(WorldState.has_flag("house.guest_hermit"), "the chair is not there yet")
	assert_eq(_decor(again, "haus/guest_chair").size(), 0)
	again.free()
	await wait_physics_frames(3)
	# the game was closed: the disk is what it plays from
	WorldState.new_game()
	WorldState.replace_state(disk.state)
	var restarted := await _house()
	assert_true(restarted.is_homecoming())
	assert_eq(_decor(restarted, "haus/guest_chair").size(), 0)
	var run := await _play_out(restarted)
	assert_eq(run["tape"][0], "hk_in_1", "from its first line")
	assert_eq(run["tape"].count("flag:house.guest_hermit"), 1, "he sits once more")
	assert_eq(_decor(restarted, "haus/guest_chair").size(), 1)
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_push_error_count(0)


func test_a_scene_freed_in_every_phase_leaves_nothing_behind() -> void:
	for phase: int in [
		HausScene.HomePhase.CALM,
		HausScene.HomePhase.KNOCK,
		HausScene.HomePhase.CHAIR,
		HausScene.HomePhase.SETTLE,
		HausScene.HomePhase.CLOSE,
		HausScene.HomePhase.STAND,
		HausScene.HomePhase.END,
	]:
		WorldState.new_game()
		_end_of_act_two()
		WorldState.set_flag("forest.hermit_invited")
		_walk_to("home")
		var scene := await _house()
		var at := func() -> bool: return scene._home == phase
		assert_true(await _until(scene, at), "phase %d reached" % phase)
		# one more frame, so the step of the phase before is under way
		await wait_physics_frames(2)
		scene.free()
		await wait_physics_frames(30)
		assert_eq(WorldState.quest_stage(QUEST), "home", "phase %d: still home" % phase)
		assert_false(Chapter.reached("act3"), "phase %d: no mark" % phase)
		assert_true(SaveSystem.blockers().is_empty(), "phase %d: the save is free" % phase)
		assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0, "phase %d" % phase)
	assert_push_error_count(0)


func test_a_scene_freed_before_it_began_leaves_nothing_behind() -> void:
	_end_of_act_two()
	_walk_to("home")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	assert_eq(scene._home, HausScene.HomePhase.WAIT, "it waits for a quiet room")
	scene.free()
	await wait_physics_frames(30)
	assert_eq(WorldState.quest_stage(QUEST), "home")
	assert_true(SaveSystem.blockers().is_empty())
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0)
	assert_push_error_count(0)


func test_a_scene_freed_while_a_line_or_a_walk_runs_leaves_nothing_behind() -> void:
	for nth: int in [1, 2, 3, 4, 5]:
		WorldState.new_game()
		_end_of_act_two()
		WorldState.set_flag("forest.hermit_invited")
		_walk_to("home")
		var scene := await _house()
		var edges := [0, false]
		var busy_start := func() -> bool:
			var busy: bool = scene._home_busy
			if busy and not edges[1]:
				edges[0] += 1
			edges[1] = busy
			return edges[0] >= nth
		assert_true(await _until(scene, busy_start), "busy period %d" % nth)
		await wait_physics_frames(20)
		scene.free()
		await wait_physics_frames(120)
		assert_eq(WorldState.quest_stage(QUEST), "home", "busy %d: still home" % nth)
		assert_true(SaveSystem.blockers().is_empty(), "busy %d: the save is free" % nth)
	assert_push_error_count(0)


# --- The talk at the bench ---------------------------------------------------------------


func test_the_tea_answer_is_offered_only_with_care_and_changes_nothing_else() -> void:
	for care: bool in [false, true]:
		WorldState.new_game()
		_end_of_act_two()
		if care:
			WorldState.set_facet("care")
		_walk_to("home")
		var scene := await _house()
		var man := _first(scene, "antreiber_bench")
		assert_not_null(man)
		# the scene has not begun yet: speak to him first (the line is the player's)
		var flags_before: Dictionary = WorldState.state.flags.duplicate()
		var asked := await _talk_through(
			scene, man, PackedStringArray([LineText.of("hk_antr_r2") if care else "…"])
		)
		assert_eq(asked.size(), 1)
		assert_eq("Tee machen." in asked[0], care, "tea only with care (care %s)" % care)
		assert_true("Helfen." in asked[0] and "…" in asked[0], "the other answers are always there")
		var flags_after: Dictionary = WorldState.state.flags.duplicate()
		for flag: String in flags_after:
			if not flags_before.has(flag):
				assert_true(flag.begins_with("beat."), "no state but a beat: %s" % flag)
		await _gone(scene)
	assert_push_error_count(0)


func test_the_cat_on_his_lap_can_be_named_where_the_fire_has_no_cat_to_speak_to() -> void:
	_end_of_act_two()
	_walk_to("home")
	var scene := await _house()
	# the way of the frozen state: at the fire and fed. The cat of the fire (cue "cat") is gone from
	# the room, the only cat to speak to lies on his lap
	assert_null(_first(scene, "cat"), "the old cat is not in the room")
	var cat := _first(scene, "cat_bench")
	assert_not_null(cat)
	assert_eq(WorldState.cat_name(), "")
	var offered := await _talk_through(scene, cat, PackedStringArray(["Ihr einen Namen geben."]))
	assert_eq(offered.size(), 1)
	assert_true("Ihr einen Namen geben." in offered[0] and "…" in offered[0])
	await wait_physics_frames(2)
	var entry := scene.get_node_or_null("CatName") as NameEntry
	assert_not_null(entry, "the name entry opens")
	entry.field.text = "Ofenkatze"
	entry.call(&"_confirm")
	await wait_physics_frames(3)
	assert_eq(WorldState.cat_name(), "Ofenkatze")
	assert_false(WorldState.has_flag("house.cat_naming"))
	assert_false(get_tree().paused)
	await wait_until(func() -> bool: return not scene.dialogue_box.is_open(), 30.0)
	# once she has a name the cue offers nothing to name
	var again := await _talk_through(scene, cat, PackedStringArray())
	assert_eq(again.size(), 0, "no answer group")
	assert_push_error_count(0)


func test_naming_is_offered_only_to_a_cat_without_a_name() -> void:
	WorldState.set_flag("house.cat_fed")
	var silent := await DialogueWalk.groups(HEIMKEHR, "cat_bench", PackedStringArray(["…"]))
	assert_eq(silent.size(), 1)
	assert_true("Ihr einen Namen geben." in silent[0] and "…" in silent[0], "both answers")
	assert_eq(silent[0][silent[0].size() - 1], "…", "the silence is the last")
	assert_false(WorldState.has_flag("house.cat_naming"), "looking and saying nothing sets nothing")
	await DialogueWalk.groups(HEIMKEHR, "cat_bench", PackedStringArray(["Namen"]))
	assert_true(WorldState.has_flag("house.cat_naming"), "the answer asks the scene for the entry")
	WorldState.clear_flag("house.cat_naming")
	WorldState.set_cat_name("Asche")
	var named := await DialogueWalk.groups(HEIMKEHR, "cat_bench")
	assert_eq(named.size(), 0, "nothing to ask a cat that has a name")
	assert_false(WorldState.has_flag("house.cat_naming"), "and nothing is set")
	assert_push_error_count(0)


func test_the_tea_line_depends_on_the_tea_in_the_wood_and_nothing_else() -> void:
	var tea := LineText.of("hk_antr_1")
	var waiting := LineText.of("hk_antr_2")
	for flag: String in ["", "forest.antreiber_sat", "forest.flood_sat"]:
		WorldState.new_game()
		if not flag.is_empty():
			WorldState.set_flag(flag)
		var lines := await DialogueWalk.play(HEIMKEHR, "antreiber_bench")
		assert_eq(tea in lines, not flag.is_empty(), "tea made in the wood: '%s'" % flag)
		assert_eq(waiting in lines, flag.is_empty())
	assert_push_error_count(0)
