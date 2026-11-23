extends GutTest
## Act VI, segment R8: the way home from Elysia ends in the house (docs/akt6/REGIONSBRIEFE.md, O13
## to O15, O18). The first entry in the stage "home" of `main_return_way` plays the homecoming
## (`ReturnHomecoming`): the house as she left it; for whoever stood up from the table in the inn
## the host knocks, comes in without a bowl, sits down at the fire and stays; the drover reads the
## visit off the sheet; Elysia's song comes home; and the act ends quietly (stage `done`, the mark
## of the chapter and the beat, no black, no title). Nothing hangs on the host. What the cues say is
## tested in test_akt6_heimkehr.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const QUEST := "main_return_way"
const FIRE_SEAT := Vector2i(16, 10)
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)
	# the workbench of Act III stands in the house (the drover sits at it)
	WorldState.set_flag("house.workbench")
	Beat.mark("act6_morning")


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


## The walk of the way back advanced to this stage through the real calls.
func _walk_on(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for next: String in ["pull", "elysia", "home", "done"]:
		if WorldState.quest_stage(QUEST) == stage:
			break
		WorldState.advance_quest(QUEST, next)


func _house() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _alive(scene: GameScene) -> Array[Node]:
	var list: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			list.append(node)
	return list


## A prop with this cue (a Decor keeps it as meta, a walker as a property), or null.
func _first(scene: GameScene, cue: String) -> Node:
	for node in _alive(scene):
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
		if str(node.get(&"cue")) == cue:
			return node
	return null


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Moves the text on as a player does until `until` holds; `seen` collects the cues, in order.
func _told(scene: GameScene, until: Callable, seen := [], seconds := 120.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if scene.dialogue_box.is_open():
				var cue: String = scene.dialogue_box.cue
				if seen.is_empty() or seen[seen.size() - 1] != cue:
					seen.append(cue)
				if _polls % 8 == 0:
					_confirm()
			return until.call(),
		seconds
	)


## Talks to the prop as the player does and returns the cue that the box shows.
func _talk(scene: GameScene, cue: String) -> String:
	var prop := _first(scene, cue)
	assert_not_null(prop, "the prop with the cue %s is on the map" % cue)
	if prop == null:
		return ""
	(prop.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0), "it says something")
	return scene.dialogue_box.cue


func _ended() -> Callable:
	return func() -> bool: return Beat.reached(ReturnHomecoming.BEAT)


# --- Without the host ---------------------------------------------------------------------------


func test_whoever_did_not_stand_up_has_a_quiet_house_the_song_and_the_end_of_the_act() -> void:
	_walk_on("home")
	var scene := await _house()
	assert_eq(WorldState.quest_stage(QUEST), "home", "the stage waits for the end")
	assert_false(Chapter.reached("act6"))
	var seen := []
	assert_true(await _told(scene, _ended(), seen), "the homecoming runs to its end")
	await wait_physics_frames(2)
	assert_eq(seen, ["home_in", "home_song", "home_close"], "no knock, no visit")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act6"), "the mark of the chapter, quietly")
	assert_true(WorldState.has_flag("melody.elysia_home"), "the song was heard")
	assert_false(WorldState.has_flag("house.guest_host"), "nobody at the fire")
	assert_null(_first(scene, "host_home"))
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked(), "she stays where she is, free")
	assert_false(ScreenFade.is_covered(), "no black, no title")


# --- With the host ------------------------------------------------------------------------------


func test_whoever_stood_up_is_knocked_on_the_host_sits_at_the_fire_and_stays() -> void:
	WorldState.set_flag("elysia.stood_up")
	_walk_on("home")
	var scene := await _house()
	assert_null(_first(scene, "host_home"), "not before he has come")
	var seen := []
	assert_true(await _told(scene, _ended(), seen), "the homecoming runs to its end")
	await wait_physics_frames(3)
	assert_eq(
		seen,
		["home_in", "host_in", "antreiber_visit", "home_song", "home_close"],
		"the visit, the drover reads it off the sheet, then the song and the end"
	)
	assert_true(WorldState.has_flag("house.guest_host"))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act6"))
	var host := _first(scene, "host_home")
	assert_not_null(host, "the fire has its guest")
	if host != null:
		assert_eq(scene.map.world_to_cell(host.global_position), FIRE_SEAT)
	var guests := _alive(scene).filter(func(node: Node) -> bool: return node is GuestWalker)
	assert_eq(guests.size(), 0, "the one who walked in is the one who sits there")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_eq(await _talk(scene, "host_home"), "host_home", "and he has nothing to offer")
	var closed := func() -> bool: return not scene.dialogue_box.is_open()
	assert_true(await _told(scene, closed))


func test_the_host_brings_nothing_in_and_the_act_asks_for_nothing_of_him() -> void:
	WorldState.set_flag("elysia.stood_up")
	WorldState.add_item("item_soup", 1, false)
	_walk_on("home")
	var xp := WorldState.state.elysia.xp
	var scene := await _house()
	assert_true(await _told(scene, _ended()))
	assert_eq(WorldState.item_count("item_soup"), 1, "the soup is where it was: nobody takes it")
	assert_eq(WorldState.state.elysia.xp, xp)
	assert_eq(WorldState.state.inventory.size(), 1, "and he gave her nothing")


func test_a_homecoming_broken_off_plays_again_from_the_door_with_an_empty_fire() -> void:
	WorldState.set_flag("elysia.stood_up")
	_walk_on("home")
	WorldState.set_flag("house.guest_host")
	var scene := await _house()
	assert_false(WorldState.has_flag("house.guest_host"), "he comes with the homecoming")
	assert_null(_first(scene, "host_home"), "so the fire is empty until he has come")
	assert_true(await _told(scene, _ended()))
	assert_true(WorldState.has_flag("house.guest_host"))
	assert_not_null(_first(scene, "host_home"))


func test_a_game_after_the_end_finds_the_fire_as_it_stood_and_plays_nothing_again() -> void:
	WorldState.set_flag("elysia.stood_up")
	WorldState.set_flag("elysia.left")
	_walk_on("done")
	WorldState.set_flag("house.guest_host")
	WorldState.set_flag("chapter.act6")
	Beat.mark(ReturnHomecoming.BEAT)
	var scene := await _house()
	await wait_physics_frames(120)
	assert_not_null(_first(scene, "host_home"), "he sits at the fire")
	assert_null(scene.get_node_or_null("ReturnHomecoming"), "nothing is played twice")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_eq(WorldState.quest_stage(QUEST), "done")
	# the sheet on the wall: the empty afternoon and the host's name
	assert_eq(await _talk(scene, "plan_board"), "plan_board_back", "the sheet after the way out")
	var closed := func() -> bool: return not scene.dialogue_box.is_open()
	assert_true(await _told(scene, closed))


func test_the_host_and_the_keeper_of_the_mountains_have_each_his_own_place_at_the_fire() -> void:
	WorldState.set_flag("elysia.stood_up")
	WorldState.set_flag("elysia.left")
	_walk_on("done")
	for flag: String in ["house.guest_host", "house.guest_waechter", "chapter.act6"]:
		WorldState.set_flag(flag)
	Beat.mark(ReturnHomecoming.BEAT)
	var scene := await _house()
	var host := _first(scene, "host_home")
	var keeper := _first(scene, "waechter_home")
	assert_not_null(host)
	assert_not_null(keeper)
	if host != null and keeper != null:
		var a := scene.map.world_to_cell(host.global_position)
		var b := scene.map.world_to_cell(keeper.global_position)
		assert_eq(a, FIRE_SEAT)
		assert_eq(b, Vector2i(17, 10))
		assert_ne(a, b, "each guest has his own place")


func test_the_sheet_on_the_wall_is_the_old_one_for_whoever_has_not_left_elysia() -> void:
	_walk_on("elysia")
	var scene := await _house()
	assert_null(scene.get_node_or_null("ReturnHomecoming"), "the stage is not home")
	assert_eq(await _talk(scene, "plan_board"), "plan_board", "Act III's sheet")


# --- The other acts, the valley and the build ---------------------------------------------------


func test_the_house_of_the_other_acts_gets_no_homecoming_of_this_one() -> void:
	var scene := await _house()
	await wait_physics_frames(60)
	assert_false(WorldState.is_quest_started(QUEST))
	assert_null(scene.get_node_or_null("ReturnHomecoming"))
	assert_false(Chapter.reached("act6"))


func test_the_valleys_arrival_is_not_told_after_the_act_has_ended() -> void:
	WorldState.set_flag("elysia.left")
	assert_true(ReturnBeat.exit_due(), "before: the valley tells it")
	Beat.mark(ReturnHomecoming.BEAT)
	assert_false(ReturnBeat.exit_due(), "after: the act is over and the arrival is not")


func test_the_walk_ends_on_done_with_its_journal_and_the_song_has_its_caption_and_its_file(
) -> void:
	var quest := ContentDB.quest(QUEST)
	assert_eq(quest.stage("home").next, PackedStringArray(["done"]))
	assert_true(quest.stage("done").is_final())
	var line := tr("QUEST_MAIN_RETURN_WAY_DONE")
	assert_ne(line, "QUEST_MAIN_RETURN_WAY_DONE")
	for word: String in ["Leere", "Gefühl", "heilen", "Elysia", "Wirt"]:
		assert_false(line.contains(word), "no %s" % word)
	for digit: String in "0123456789":
		assert_false(line.contains(digit), "numbers are written out")
	assert_eq(Chapter.LAST, "act6", "the last chapter of the build")
	assert_true(FileAccess.file_exists("res://assets/generated/sfx/elysia_home_0.wav"))
	assert_eq(AudioDirector.CAPTIONS.get("elysia_home"), "CAPTION_ELYSIA_HOME")
	assert_ne(tr("CAPTION_ELYSIA_HOME"), "CAPTION_ELYSIA_HOME")
