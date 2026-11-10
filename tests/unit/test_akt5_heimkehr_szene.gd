extends GutTest
## Act V, segment G9: the way down and the homecoming (docs/akt5/REGIONSBRIEFE.md, O12, O18). In
## the valley the walk of the hero is on `home`; in the house the first entry in that stage plays
## the homecoming (`MountainHomecoming`): a few quiet lines. Whoever let the keeper go at the
## console (the facet `trust`) is knocked on: he checks the hearth, not quite, and stays standing
## there. Whoever did not has an empty hearth. The act ends quietly (stage `done`, the mark of the
## chapter and the beat, no title). What the cues say is tested in test_akt5_heimkehr.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const PASS := preload("res://world/levels/akt5/pass.tscn")
const QUEST := "main_mountain_way"
const HEARTH := Vector2i(17, 10)
const DESCENT := Vector2i(66, 6)
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


## The walk of the hero advanced to this stage through the real calls.
func _walk_on(stage: String) -> void:
	WorldState.start_quest(QUEST)
	for next: String in [
		"valley", "plant", "load", "letgo", "high", "child", "house", "home", "done"
	]:
		if WorldState.quest_stage(QUEST) == stage:
			break
		if next == "house" and stage == "home":
			continue  # the house of the plateau is never a condition
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


# --- The way down -------------------------------------------------------------------------------


func test_in_the_valley_the_walk_is_on_home_after_the_child_with_or_without_the_house() -> void:
	for stage: String in ["child", "house"]:
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.REAL)
		_walk_on(stage)
		assert_eq(WorldState.quest_stage(QUEST), stage)
		var scene: TalScene = TAL.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(3)
		assert_eq(WorldState.quest_stage(QUEST), "home", "walked down from %s" % stage)
		scene.queue_free()
		await wait_physics_frames(2)


func test_the_valley_leaves_every_other_walk_alone() -> void:
	var scene: TalScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_false(WorldState.is_quest_started(QUEST), "no walk, no stage")
	scene.queue_free()
	await wait_physics_frames(2)
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	_walk_on("high")
	var higher: TalScene = TAL.instantiate()
	add_child_autofree(higher)
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage(QUEST), "high", "she did not come down from the child yet")


func test_the_way_down_has_its_look_only_once_the_child_is_gone() -> void:
	var scene: PassScene = PASS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_null(_first(scene, "descent_pass"), "the way up is as it was")
	WorldState.set_flag("grat.child_gone")
	await wait_physics_frames(3)
	var spot := _first(scene, "descent_pass")
	assert_not_null(spot, "and now the way down")
	if spot != null:
		assert_eq(scene.map.world_to_cell(spot.global_position), DESCENT)
	scene.queue_free()
	await wait_physics_frames(2)
	# a scene built with the flag already set is what a loaded game is
	var loaded: PassScene = PASS.instantiate()
	add_child_autofree(loaded)
	await wait_physics_frames(3)
	assert_not_null(_first(loaded, "descent_pass"), "built with the flag already set")


# --- The homecoming -----------------------------------------------------------------------------


func test_without_the_facet_the_house_is_quiet_the_hearth_stays_empty_and_the_act_ends() -> void:
	_walk_on("home")
	var scene := await _house()
	assert_eq(WorldState.quest_stage(QUEST), "home", "the stage waits for the end")
	assert_false(Chapter.reached("act5"))
	var done := func() -> bool: return Beat.reached("act5_home")
	assert_true(await _told(scene, done), "the homecoming runs to its end")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act5"), "the mark of the chapter, quietly")
	assert_false(WorldState.has_flag("house.guest_waechter"), "nobody at the hearth")
	assert_null(_first(scene, "waechter_home"))
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(scene.player.is_locked(), "she stays where she is, free")


func test_with_the_facet_the_keeper_comes_checks_the_hearth_and_stays_standing_there() -> void:
	WorldState.set_facet("trust")
	_walk_on("home")
	var scene := await _house()
	assert_null(_first(scene, "waechter_home"), "not before he has come")
	var done := func() -> bool: return Beat.reached("act5_home")
	assert_true(await _told(scene, done), "the homecoming runs to its end")
	await wait_physics_frames(3)
	assert_true(WorldState.has_flag("house.guest_waechter"))
	assert_eq(WorldState.quest_stage(QUEST), "done")
	assert_true(Chapter.reached("act5"))
	var keeper := _first(scene, "waechter_home")
	assert_not_null(keeper, "the hearth has its keeper")
	if keeper != null:
		assert_eq(scene.map.world_to_cell(keeper.global_position), HEARTH)
	var guests := _alive(scene).filter(func(node: Node) -> bool: return node is GuestWalker)
	assert_eq(guests.size(), 0, "the one who walked in is the one who stands there")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())


func test_a_homecoming_broken_off_plays_again_from_the_door_with_an_empty_hearth() -> void:
	WorldState.set_facet("trust")
	_walk_on("home")
	WorldState.set_flag("house.guest_waechter")
	var scene := await _house()
	assert_false(WorldState.has_flag("house.guest_waechter"), "he comes with the homecoming")
	assert_null(_first(scene, "waechter_home"), "so the hearth is empty until he has come")
	var done := func() -> bool: return Beat.reached("act5_home")
	assert_true(await _told(scene, done))
	assert_true(WorldState.has_flag("house.guest_waechter"))


func test_a_game_after_the_end_finds_the_hearth_as_it_stood_and_plays_nothing_again() -> void:
	WorldState.set_facet("trust")
	_walk_on("done")
	WorldState.set_flag("house.guest_waechter")
	WorldState.set_flag("chapter.act5")
	Beat.mark("act5_home")
	Beat.mark("act6_morning")  # the day after the end is Act VI's (R1): told already
	var scene := await _house()
	await wait_physics_frames(120)
	assert_not_null(_first(scene, "waechter_home"), "he stands at the hearth")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty(), "nothing is played twice")
	assert_eq(WorldState.quest_stage(QUEST), "done")
	scene.queue_free()
	await wait_physics_frames(2)
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	_walk_on("done")
	Beat.mark("act5_home")
	var empty := await _house()
	assert_null(_first(empty, "waechter_home"), "and without the facet the hearth is empty")


func test_the_house_of_the_slice_and_the_other_acts_is_untouched() -> void:
	var scene := await _house()
	await wait_physics_frames(60)
	assert_false(WorldState.is_quest_started(QUEST), "no walk of the mountains")
	assert_false(Chapter.reached("act5"))
	assert_null(scene.get_node_or_null("MountainHomecoming"), "no homecoming of Act V")
	assert_null(_first(scene, "waechter_home"))
	scene.queue_free()
	await wait_physics_frames(2)
	# the homecomings of Act III and IV are theirs: the keeper does not come to them
	for quest: String in ["main_forest_way", "main_city_way"]:
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.REAL)
		WorldState.set_facet("trust")
		WorldState.start_quest(quest)
		var steps := 0
		while WorldState.quest_stage(quest) != "home" and steps < 20:
			var here := ContentDB.quest(quest).stage(WorldState.quest_stage(quest))
			WorldState.advance_quest(quest, here.next[0])
			steps += 1
		assert_eq(WorldState.quest_stage(quest), "home", "%s is on its way home" % quest)
		var other := await _house()
		assert_null(other.get_node_or_null("MountainHomecoming"), "not in the way home of " + quest)
		assert_false(WorldState.is_quest_started(QUEST), "and no walk of the mountains")
		other.queue_free()
		await wait_physics_frames(2)


func test_the_end_of_the_act_is_no_longer_the_end_of_the_build_and_the_journal_follows_it() -> void:
	# the day after goes on (Act VI, R1, ADR-074): the last chapter of the build moved on
	assert_ne(Chapter.LAST, "act5")
	assert_true(ContentDB.quest(QUEST).stage("done").is_final())
	for key: String in ["QUEST_MAIN_MOUNTAIN_WAY_HOME", "QUEST_MAIN_MOUNTAIN_WAY_DONE"]:
		var line := tr(key)
		assert_ne(line, key, key)
		for word: String in ["Kind", "Kreide", "Mut", "Vertrauen", "loslassen"]:
			assert_false(line.contains(word), "%s: no %s" % [key, word])
		for digit: String in "0123456789":
			assert_false(line.contains(digit), "%s: numbers are written out" % key)
