extends GutTest
## Act V, segment G7: the central scene (docs/akt5/REGIONSBRIEFE.md, O8, O9, O10; Bible 15). On the
## Grat, at the edge of the plateau, a child sits on a flat stone and waits. Nothing happens until
## the player sits down beside it, in her own time. Then the child hums, six frames hang in the
## air (only the pictures she holds show a picture, the others stay empty), the answer is given or
## not, the child is gone, the frames fade and in the valley a shoot grows in the bed. What the
## lines say is tested in test_akt5_kind.

const GRAT := preload("res://world/levels/akt5/grat.tscn")
const TAL := preload("res://world/levels/slice/tal.tscn")
const QUEST := "main_mountain_way"
const SEAT := Vector2i(79, 10)
const CHILD := Vector2i(80, 10)
const SPOT := Vector2i(78, 10)
const BED := Vector2i(12, 11)
const PICTURES: Array[String] = [
	"fragment.hallway",
	"fragment.closed_door",
	"fragment.empty_room",
	"fragment.hand",
	"fragment.hiding",
]
var _polls := 0


func before_each() -> void:
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


## The Grat after the letting go, with the walk of the hero on `high`.
func _grat(flags: Array[String] = []) -> GratScene:
	WorldState.set_flag("plant.letgo")
	for flag in flags:
		WorldState.set_flag(flag)
	WorldState.start_quest(QUEST)
	for next: String in ["valley", "plant", "load", "letgo", "high"]:
		WorldState.advance_quest(QUEST, next)
	var scene: GratScene = GRAT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _put(scene: GameScene, cell: Vector2i) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	await wait_physics_frames(2)


func _alive(scene: GameScene) -> Array[Node]:
	var list: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion():
			list.append(node)
	return list


## A prop with this cue (a Decor or a walker keeps it), or null.
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


## Moves the text on as a player does until `until` holds; at a choice it takes the answer with
## this text (the first allowed one without text).
func _told(scene: GameScene, until: Callable, pick := "", seconds := 90.0) -> bool:
	return await wait_until(
		func() -> bool:
			_polls += 1
			if _polls % 8 == 0 and scene.dialogue_box.is_open():
				if scene.dialogue_box._responses.visible:
					BoxAnswers.pick(scene.dialogue_box, pick)
				else:
					_confirm()
			return until.call(),
		seconds
	)


func _sit(scene: GameScene, cell := SEAT) -> void:
	var at := scene.map.cell_to_world(cell)
	scene.player.global_position = at
	scene.player.sit_on(at, Facing.Dir.S)
	await wait_physics_frames(2)


func _meeting(scene: GameScene) -> ChildMeeting:
	return scene.get_node("ChildMeeting") as ChildMeeting


# --- The child and the stone ------------------------------------------------------------------


func test_the_child_sits_on_the_stone_at_the_edge_and_the_stone_is_free_beside_it() -> void:
	var scene := await _grat()
	var child := _first(scene, "child_look")
	assert_not_null(child, "the child waits")
	if child != null:
		assert_eq(scene.map.world_to_cell(child.global_position), CHILD)
	var stone := _first(scene, "seat_empty")
	assert_null(stone, "the spot beside the stone is there only once the child is gone")
	var rock := false
	for node in _alive(scene):
		if node is Decor and (node as Decor).sprite_id == "tal/gb_sit_rock":
			rock = true
			assert_eq(scene.map.world_to_cell(node.global_position), SEAT)
	assert_true(rock, "the flat stone")


func test_nothing_happens_until_she_sits_down_beside_the_child() -> void:
	var scene := await _grat()
	await _put(scene, SEAT)
	await wait_physics_frames(300)
	assert_false(WorldState.has_flag("grat.child_gone"))
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty(), "no cutscene runs")
	assert_eq(_meeting(scene).frames.size(), 0)
	assert_false(scene.player.is_locked(), "and nothing locks her")
	# sitting somewhere else does not count either
	await _sit(scene, Vector2i(70, 9))
	await wait_physics_frames(60)
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())
	assert_false(WorldState.has_flag("grat.child_gone"))


# --- The scene ----------------------------------------------------------------------------------


func test_sitting_down_plays_the_scene_and_leaves_the_seat_empty() -> void:
	var scene := await _grat()
	await _sit(scene)
	var gone := func() -> bool: return Beat.reached("grat_child")
	assert_true(await _told(scene, gone, "Ich bin da."), "the scene runs to its end")
	assert_true(WorldState.has_flag("grat.child_gone"))
	assert_true(WorldState.has_flag("house.garden_sprout"), "in the valley a shoot grows")
	assert_eq(WorldState.quest_stage(QUEST), "child", "the walk goes on")
	assert_null(_first(scene, "child_look"), "the child is gone")
	assert_not_null(_first(scene, "seat_empty"), "and its place can be looked at")
	assert_eq(scene.player.state, Player.State.SIT, "she may stay seated as long as she likes")
	assert_false(scene.player.is_locked(), "nothing holds her")
	assert_eq(_meeting(scene).frames.size(), 0, "the frames are gone")
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty())


func test_six_frames_hang_in_the_air_and_only_the_pictures_she_holds_show_a_picture() -> void:
	var scene := await _grat(["fragment.hallway", "fragment.hand"])
	await _sit(scene)
	var seen := {"frames": 0, "pictures": 0}
	var up := func() -> bool:
		var meeting := _meeting(scene)
		if meeting.frames.size() == 6 and seen["frames"] == 0:
			seen["frames"] = meeting.frames.size()
			for frame in meeting.frames:
				if frame.has_node("Picture"):
					seen["pictures"] += 1
		return Beat.reached("grat_child")
	assert_true(await _told(scene, up, "Ich bin da."))
	assert_eq(seen["frames"], 6, "six frames, always")
	assert_eq(seen["pictures"], 2, "two pictures: the others stay empty")


func test_every_picture_she_holds_is_one_of_the_five_and_the_sixth_is_not_there_yet() -> void:
	assert_eq(ChildMeeting.NAMES.size(), 6)
	assert_eq(ChildMeeting.held_names(), [] as Array[String], "none held")
	for flag in PICTURES:
		WorldState.set_flag(flag)
	assert_eq(ChildMeeting.held_names().size(), 5)
	assert_false(ChildMeeting.held(5), "the picture of the first house is G8's")
	WorldState.set_flag("fragment.first_house")
	assert_eq(ChildMeeting.held_names().size(), 6)
	assert_eq(ChildMeeting.held_names()[5], "first_house", "in the order of the child's story")


func test_the_answers_lead_to_the_same_end_and_no_way_is_wrong() -> void:
	for pick: String in ["Ich bin da.", "…"]:
		WorldState.new_game()
		WorldState.set_ui_mode(GameState.UiMode.REAL)
		var scene := await _grat()
		await _sit(scene)
		var gone := func() -> bool: return Beat.reached("grat_child")
		assert_true(await _told(scene, gone, pick), "ends with %s" % pick)
		assert_true(WorldState.has_flag("house.garden_sprout"), "the same shoot after %s" % pick)
		assert_eq(WorldState.quest_stage(QUEST), "child")
		scene.queue_free()
		await wait_physics_frames(2)


func test_with_trust_there_is_an_answer_that_asks_for_nothing_and_it_ends_the_same() -> void:
	WorldState.set_facet("trust")
	var scene := await _grat()
	await _sit(scene)
	var gone := func() -> bool: return Beat.reached("grat_child")
	assert_true(await _told(scene, gone, "Ich warte mit dir."))
	assert_true(WorldState.has_flag("house.garden_sprout"))
	assert_eq(WorldState.quest_stage(QUEST), "child")


func test_the_scene_is_played_once_and_a_loaded_game_after_it_finds_the_seat_empty() -> void:
	var scene := await _grat(["grat.child_gone", "house.garden_sprout"])
	assert_null(_first(scene, "child_look"), "no child")
	assert_not_null(_first(scene, "seat_empty"))
	await _sit(scene)
	await wait_physics_frames(120)
	assert_true(get_tree().get_nodes_in_group(&"cutscene").is_empty(), "nothing is played twice")
	assert_eq(_meeting(scene).frames.size(), 0, "and no frames")


# --- The valley ---------------------------------------------------------------------------------


func test_in_the_valley_the_bed_shows_a_shoot_only_after_the_scene() -> void:
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	var sprouts := tal.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return node is Decor and (node as Decor).sprite_id == "tal/gb_sprout"
	)
	assert_eq(sprouts.size(), 0, "a bed gone wild, before")
	WorldState.set_flag("house.garden_sprout")
	await wait_physics_frames(3)
	sprouts = tal.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id == "tal/gb_sprout"
				and not node.is_queued_for_deletion()
			)
	)
	assert_eq(sprouts.size(), 1, "one shoot")
	assert_eq(tal.map.world_to_cell(sprouts[0].global_position), BED)


func test_the_hero_stage_child_ends_the_walk_for_now() -> void:
	var quest := ContentDB.quest(QUEST)
	assert_true(quest.can_advance("high", "child"))
	assert_false(quest.stage("high").is_final(), "the first house (G8) hangs on the child")
	assert_true(quest.stage("child").is_final())
	assert_ne(tr("QUEST_MAIN_MOUNTAIN_WAY_CHILD"), "QUEST_MAIN_MOUNTAIN_WAY_CHILD")
