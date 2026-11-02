extends GutTest
## Act IV, segment S4: "Nichts" (Bible §44). Once the board is sawn, Tess sits on her crate before
## the workshop, and whoever sits down on the bench beside her sits with her. The quest starts with
## the sitting and ends when she stands up: no beat, no praise, no counter. The words are tested in
## test_akt4_werkstatt_nach, the placement in test_akt4_stadt_szene.

const STADT := preload("res://world/levels/akt4/stadt.tscn")
const BENCH_SCRIPT := preload("res://world/props/bench.gd")
const BENCH_CELL := Vector2i(25, 41)
const QUEST := "side_city_nothing"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Input.action_release(&"move_left")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> StadtScene:
	var scene: StadtScene = STADT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _bench(scene: GameScene) -> Node2D:
	for node in scene.map.entities.get_children():
		if (
			node.get_script() == BENCH_SCRIPT
			and scene.map.world_to_cell((node as Node2D).global_position) == BENCH_CELL
		):
			return node as Node2D
	return null


## She sits down on the workshop's bench, where the bench itself would put her.
func _sit(scene: GameScene) -> void:
	scene.player.sit_on(_bench(scene).global_position + BENCH_SCRIPT.SEAT, Facing.Dir.S)
	await wait_physics_frames(3)


func _closed(scene: GameScene) -> Callable:
	return func() -> bool: return not scene.dialogue_box.is_open()


func test_before_the_board_the_bench_is_only_a_bench() -> void:
	var scene := await _scene()
	await _sit(scene)
	await wait_physics_frames(10)
	assert_eq(scene.player.state, Player.State.SIT)
	assert_false(scene.dialogue_box.is_open(), "nobody sits beside her, so nothing is said")
	assert_false(WorldState.is_quest_started(QUEST))
	scene.player.stand_up()
	await wait_physics_frames(3)
	assert_false(WorldState.has_flag("city.sat_with_tess"))
	assert_false(WorldState.is_quest_started(QUEST))


func test_sitting_beside_tess_starts_the_quest_and_standing_up_ends_it() -> void:
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	await _sit(scene)
	var opened: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(opened, "the lines of things are told")
	assert_eq(WorldState.quest_stage(QUEST), "sit", "the quest began with the sitting")
	assert_false(WorldState.has_flag("city.sat_with_tess"), "and is not over while she sits")
	var closed: bool = await wait_until(_closed(scene), 30.0)
	assert_true(closed)
	assert_eq(scene.player.state, Player.State.SIT, "she sits on as long as she likes")
	assert_false(scene.player.is_locked())
	assert_eq(WorldState.quest_stage(QUEST), "sit", "no end by time")
	Input.action_press(&"move_left")
	await wait_until(func() -> bool: return scene.player.state != Player.State.SIT, 5.0)
	Input.action_release(&"move_left")
	await wait_physics_frames(3)
	assert_eq(WorldState.quest_stage(QUEST), "done", "the quest ends when she gets up")
	assert_true(WorldState.has_flag("city.sat_with_tess"))


func _beats() -> PackedStringArray:
	var found: PackedStringArray = []
	for id: String in WorldState.state.flags:
		if id.begins_with("beat."):
			found.append(id)
	return found


func test_nothing_follows_it_no_beat_no_item_no_other_quest() -> void:
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	var beats := _beats()
	var items := WorldState.state.inventory.duplicate()
	var quests := WorldState.state.quests.keys()
	await _sit(scene)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	await wait_until(_closed(scene), 30.0)
	scene.player.stand_up()
	await wait_physics_frames(5)
	assert_eq(WorldState.state.inventory, items, "nothing is given for it")
	assert_eq(_beats(), beats, "and no beat is marked")
	var now := WorldState.state.quests.keys()
	now.erase(QUEST)
	assert_eq(now, quests, "no quest but this one began")


func test_the_second_sitting_is_the_shorter_version_and_ends_again_without_ado() -> void:
	WorldState.set_flag("city.board_done")
	var scene := await _scene()
	await _sit(scene)
	await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	await wait_until(_closed(scene), 30.0)
	scene.player.stand_up()
	await wait_physics_frames(5)
	assert_eq(WorldState.quest_stage(QUEST), "done")
	await _sit(scene)
	var again: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(again, "a second sitting is told again, shorter")
	await wait_until(_closed(scene), 30.0)
	scene.player.stand_up()
	await wait_physics_frames(5)
	assert_eq(WorldState.quest_stage(QUEST), "done", "still done, nothing is counted")
