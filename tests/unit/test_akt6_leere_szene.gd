extends GutTest
## Act VI, segment R1: the day after the mountains (docs/akt6/REGIONSBRIEFE.md, O1, O10, O13).
## "Weiter" after the end of Act V begins in the house with a few lines of things and the walk
## "Der Weg zurück" (`ReturnBeat`); Mira stands at her old camp in the valley and goes her own
## way once the player comes close (`MiraLeaves`); the first time she comes into the house after
## that, a light that is not from here shows for a breath and the walk moves on to `pull`. What
## the cues say is tested in test_akt6_leere.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const QUEST := "main_return_way"
const MIRA_CELL := Vector2i(50, 19)
const EMPTY_CELL := Vector2i(51, 20)
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


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


## The end of Act V as the frozen save has it: the chapter is marked, the mountains are done.
func _after_the_mountains() -> void:
	WorldState.set_flag("chapter.act5")
	WorldState.set_flag("valley.mira_gone")
	WorldState.set_flag("valley.mira_met")
	WorldState.set_flag("valley.bridge_fixed")
	WorldState.set_day_preset("morgen")


func _house() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _valley() -> TalScene:
	var scene: TalScene = TAL.instantiate()
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


## Moves the text on as a player does until `until` holds.
func _told(scene: GameScene, until: Callable, seconds := 90.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				_confirm()
			return until.call(),
		seconds
	)


func _near_mira(scene: GameScene) -> void:
	var mira := _first(scene, "mira_leaves")
	assert_not_null(mira, "Mira stands at her old camp")
	if mira != null:
		scene.player.global_position = mira.global_position + Vector2(-32.0, 0.0)


# --- The morning ----------------------------------------------------------------------------------


func test_the_morning_is_due_after_the_end_of_act_five_and_until_it_is_told() -> void:
	assert_false(ReturnBeat.morning_due(), "not before the end of Act V")
	_after_the_mountains()
	assert_true(ReturnBeat.morning_due())
	Beat.mark("act6_morning")
	assert_false(ReturnBeat.morning_due(), "told once, never twice")


func test_weiter_in_the_house_tells_the_morning_starts_the_walk_and_sets_mira_at_her_camp() -> void:
	_after_the_mountains()
	var scene := await _house()
	assert_true(WorldState.has_flag("valley.mira_leaving"), "set before the valley is ever built")
	assert_false(WorldState.is_quest_started(QUEST), "the walk begins with the lines, not before")
	assert_not_null(scene.get_node_or_null("ReturnBeatMorning"))
	var done := func() -> bool: return Beat.reached("act6_morning")
	assert_true(await _told(scene, done), "the morning runs to its end")
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage(QUEST), "empty", "the walk of the day after: nothing asked")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked(), "she is free")
	assert_false(WorldState.has_flag("valley.mira_left"), "Mira has not gone yet")
	assert_false(WorldState.has_flag("valley.rift_light"), "and no light yet")


func test_a_game_saved_in_the_valley_tells_the_morning_there() -> void:
	_after_the_mountains()
	var scene := await _valley()
	assert_not_null(scene.get_node_or_null("ReturnBeatMorning"))
	assert_not_null(_first(scene, "mira_leaves"), "Mira is at her camp from the first picture")
	var done := func() -> bool: return Beat.reached("act6_morning")
	assert_true(await _told(scene, done))
	assert_eq(WorldState.quest_stage(QUEST), "empty")


func test_the_morning_that_was_told_is_not_told_again() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.start_quest(QUEST)
	var scene := await _house()
	await wait_physics_frames(60)
	assert_null(scene.get_node_or_null("ReturnBeatMorning"))
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_eq(WorldState.quest_stage(QUEST), "empty", "the walk stays where it was")


func test_the_house_of_the_other_acts_is_untouched() -> void:
	var scene := await _house()
	await wait_physics_frames(60)
	assert_null(scene.get_node_or_null("ReturnBeatMorning"), "no day after without the mountains")
	assert_null(scene.get_node_or_null("ReturnBeatQuiet"))
	assert_false(WorldState.is_quest_started(QUEST))
	assert_false(WorldState.has_flag("valley.mira_leaving"))


# --- Mira goes her own way -----------------------------------------------------------------------


func test_mira_stands_at_her_old_camp_only_on_the_day_after_and_only_until_she_has_gone() -> void:
	var plain := await _valley()
	assert_null(_first(plain, "mira_leaves"), "no Mira at the camp in the other acts")
	assert_null(_first(plain, "camp_empty"))
	plain.queue_free()
	await wait_physics_frames(2)
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.start_quest(QUEST)
	var scene := await _valley()
	var mira := _first(scene, "mira_leaves")
	assert_not_null(mira, "she is there")
	if mira != null:
		assert_eq(scene.map.world_to_cell(mira.global_position), MIRA_CELL)
	assert_null(_first(scene, "camp_empty"), "the place is not empty yet")
	assert_not_null(scene.get_node_or_null("MiraLeaves"))


func test_she_says_that_she_goes_and_goes_over_the_bridge_and_the_place_stays_empty() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.set_flag("city.mira_parted_boundary")
	WorldState.start_quest(QUEST)
	var kept := JSON.stringify(WorldState.state.to_dict()["relationships"])
	var scene := await _valley()
	_near_mira(scene)
	# what the walk shows: the guest at her camp, over the bridge (its planks lie at x 40 to 45 on the
	# row of the stones), and out of the picture in the west
	var seen := {"guest": false, "start": Vector2i(-1, -1), "bridge": false, "west": 99}
	var watch := func() -> bool:
		for node in _alive(scene):
			if node is GuestWalker:
				var cell := scene.map.world_to_cell((node as Node2D).global_position)
				if not seen["guest"]:
					seen["guest"] = true
					seen["start"] = cell
				if cell.x >= 40 and cell.x <= 45 and cell.y == 22:
					seen["bridge"] = true
				seen["west"] = mini(seen["west"], cell.x)
		return Beat.reached("act6_mira")
	assert_true(await _told(scene, watch, 120.0), "she has said it and gone")
	await wait_physics_frames(3)
	assert_true(seen["guest"], "the one who walks is there")
	assert_eq(seen["start"], MIRA_CELL, "from her place at the camp")
	assert_true(seen["bridge"], "over the bridge")
	assert_lte(seen["west"], 32, "and on to the west, out of the picture")
	assert_true(WorldState.has_flag("valley.mira_left"))
	assert_null(_first(scene, "mira_leaves"), "the camp's Mira is gone")
	assert_not_null(_first(scene, "camp_empty"), "and the empty place is there to look at")
	var guests := _alive(scene).filter(func(node: Node) -> bool: return node is GuestWalker)
	assert_eq(guests.size(), 0, "the one who walked off has left the picture")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked(), "she is free")
	assert_eq(WorldState.quest_stage(QUEST), "gone", "the walk says where to look: the house")
	assert_false(WorldState.has_flag("valley.rift_light"), "the light is the house's")
	assert_eq(JSON.stringify(WorldState.state.to_dict()["relationships"]), kept, "no new memory")


func test_mira_waits_until_the_player_is_close_and_nothing_hangs_on_her_before() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.start_quest(QUEST)
	var scene := await _valley()
	scene.player.global_position = Vector2(8.0 * 16.0, 24.0 * 16.0)
	await wait_physics_frames(60)
	assert_false(WorldState.has_flag("valley.mira_left"), "far away she stands")
	assert_not_null(_first(scene, "mira_leaves"))
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())


func test_a_game_closed_while_she_goes_has_saved_nothing_of_it_and_finds_her_at_the_camp() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.start_quest(QUEST)
	var scene := await _valley()
	_near_mira(scene)
	# in the middle of the walk: the flag stands in memory, the cutscene holds the save back
	var mid := func() -> bool:
		return WorldState.has_flag("valley.mira_left") and not Beat.reached("act6_mira")
	assert_true(await _told(scene, mid, 120.0), "she is on her way")
	assert_false(SaveSystem.can_save(), "nothing is written while she goes")
	var disk := SaveSystem.read_slot(SaveSystem.AUTOSAVE)
	if disk.ok:
		assert_false(disk.state.flags.has("valley.mira_left"), "and nothing of it is on the disk")
	# a load now is a load before it: the room is built from the saved flags
	var saved := WorldState.state.flags.duplicate()
	saved.erase("valley.mira_left")
	scene.queue_free()
	await wait_physics_frames(3)
	get_tree().call_group(&"cutscene", "queue_free")
	await wait_physics_frames(2)
	WorldState.state.flags = saved
	var again := await _valley()
	assert_true(MiraLeaves.due())
	assert_not_null(_first(again, "mira_leaves"), "she stands at the camp again")
	assert_false(Beat.reached("act6_mira"))


func test_the_day_after_is_told_before_mira_when_the_player_starts_next_to_her() -> void:
	_after_the_mountains()
	var scene := await _valley()
	_near_mira(scene)
	var told_first := [false]
	var morning := func() -> bool:
		if Beat.reached("act6_morning") and not told_first[0]:
			told_first[0] = not WorldState.has_flag("valley.mira_left")
		return Beat.reached("act6_morning")
	assert_true(await _told(scene, morning, 120.0), "the morning is told")
	assert_true(told_first[0], "and Mira had not begun when it ended")
	var gone := func() -> bool: return Beat.reached("act6_mira")
	assert_true(await _told(scene, gone, 120.0), "then she goes")
	assert_eq(WorldState.quest_stage(QUEST), "gone")


# --- The quiet house ----------------------------------------------------------------------


func test_the_house_is_quiet_after_mira_the_light_shows_once_and_the_walk_moves_to_pull() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.set_flag("valley.mira_left")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "gone")
	var scene := await _house()
	assert_not_null(scene.get_node_or_null("ReturnBeatQuiet"))
	var done := func() -> bool: return Beat.reached("act6_quiet")
	assert_true(await _told(scene, done), "the quiet runs to its end")
	await wait_physics_frames(3)
	assert_true(WorldState.has_flag("valley.rift_light"))
	assert_eq(WorldState.quest_stage(QUEST), "pull")
	assert_true(ContentDB.quest(QUEST).stage("pull").is_final(), "nothing after it yet (R2)")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked())
	scene.queue_free()
	await wait_physics_frames(2)
	var again := await _house()
	await wait_physics_frames(60)
	assert_null(again.get_node_or_null("ReturnBeatQuiet"), "once")


func test_the_house_is_not_quiet_before_mira_has_gone() -> void:
	_after_the_mountains()
	Beat.mark("act6_morning")
	WorldState.set_flag("valley.mira_leaving")
	WorldState.start_quest(QUEST)
	var scene := await _house()
	await wait_physics_frames(60)
	assert_null(scene.get_node_or_null("ReturnBeatQuiet"))
	assert_false(WorldState.has_flag("valley.rift_light"))
	assert_eq(WorldState.quest_stage(QUEST), "empty")


# --- The build ------------------------------------------------------------------------------------


func test_the_last_chapter_is_act_six_and_the_walk_has_its_stages_with_their_journal() -> void:
	assert_eq(Chapter.LAST, "act6")
	var quest := ContentDB.quest(QUEST)
	assert_not_null(quest)
	assert_eq(quest.stages[0].id, "empty")
	assert_eq(quest.stages[0].next, PackedStringArray(["gone", "pull"]))
	assert_eq(quest.stage("gone").next, PackedStringArray(["pull"]))
	assert_true(quest.stage("pull").is_final(), "nothing after it yet (R2)")
	var keys: PackedStringArray = [
		"QUEST_MAIN_RETURN_WAY_TITLE",
		"QUEST_MAIN_RETURN_WAY_EMPTY",
		"QUEST_MAIN_RETURN_WAY_GONE",
		"QUEST_MAIN_RETURN_WAY_PULL",
	]
	for key in keys:
		var line := tr(key)
		assert_ne(line, key, key)
		for word: String in ["Elysia", "Leere", "Gefühl", "heilen", "loslassen"]:
			assert_false(line.contains(word), "%s: no %s" % [key, word])
		for digit: String in "0123456789":
			assert_false(line.contains(digit), "%s: numbers are written out" % key)
	assert_true(tr("QUEST_MAIN_RETURN_WAY_GONE").contains("Haus"), "it says where to look next")
