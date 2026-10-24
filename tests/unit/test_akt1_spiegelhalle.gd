extends GutTest
## Act I, segment A5: the hall of mirrors. Three rooms in which everything stands twice, almost;
## the gate of a room opens when the hero has noticed what lies on one side only (Perception, Game
## Bible §16), the keeper helps as often as he is asked, the last room has a mirror that does not
## show the hero, and nothing here can be failed.

const HALL := preload("res://world/levels/akt1/spiegelhalle.tscn")
const MARKT := preload("res://world/levels/akt1/markt.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const DIALOGUE := "res://content/dialogue/akt1/spiegelhalle.dialogue"


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _hall() -> SpiegelhalleScene:
	var scene: SpiegelhalleScene = HALL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _props_with_cue(scene: GameScene, cue: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.get(&"cue") == cue or (node.has_meta(&"cue") and node.get_meta(&"cue") == cue):
			found.append(node)
	return found


# --- The place -------------------------------------------------------------------------


func test_the_hall_has_its_two_gates_the_mirror_and_the_keeper() -> void:
	var scene := await _hall()
	assert_eq(_props_with_cue(scene, "gate_shut").size(), 2, "one gate per room")
	assert_eq(_props_with_cue(scene, "mirror").size(), 1)
	assert_eq(_props_with_cue(scene, "keeper").size(), 1, "he stands in the middle, once")
	assert_eq(_props_with_cue(scene, "leaf").size(), 1, "the leaf lies on one side only")
	assert_eq(_props_with_cue(scene, "feather").size(), 1, "the feather on the other")
	assert_true(Beat.reached("hall_enter"))
	assert_true(WorldState.has_flag("elysia.hall_seen"))


func test_the_leaf_is_on_the_left_and_the_feather_on_the_right() -> void:
	var scene := await _hall()
	var axis := 16.0 * 16.0 + 8.0
	var leaf := _props_with_cue(scene, "leaf")[0] as Node2D
	var feather := _props_with_cue(scene, "feather")[0] as Node2D
	assert_lt(leaf.global_position.x, axis, "the leaf lies left of the middle")
	assert_gt(feather.global_position.x, axis, "the feather right of it")


func test_the_camera_stays_inside_the_hall() -> void:
	var scene := await _hall()
	var bounds: Rect2 = scene.view.bounds
	assert_eq(bounds.position, Vector2(48, 48))
	assert_eq(bounds.size, Vector2(432, 624))


func test_the_ways_in_and_out_belong_together() -> void:
	var market: MarktScene = MARKT.instantiate()
	add_child_autofree(market)
	await wait_physics_frames(3)
	assert_false(
		market.map.data.find_marker("spawn_hall").is_empty(), "out of the hall onto the steps"
	)
	var hall := await _hall()
	assert_false(
		hall.map.data.find_marker("spawn_markt").is_empty(), "into the hall from the steps"
	)


# --- Noticing: the gates --------------------------------------------------------------------


func test_noticing_the_leaf_opens_the_first_gate_and_the_leaf_may_stay() -> void:
	var scene := await _hall()
	var xp: int = WorldState.state.elysia.xp
	assert_eq(_props_with_cue(scene, "gate_shut").size(), 2)
	var seen := await DialogueWalk.play(DIALOGUE, "leaf", ["Liegen lassen"])
	assert_true(LineText.of("sh_leaf_2") in seen, "the other side has none")
	assert_true(WorldState.has_flag("elysia.hall_room_1"))
	assert_eq(WorldState.state.elysia.xp, xp + 1500)
	assert_false(WorldState.has_item("curiosity_dry_leaf"), "it was left where it lay")
	await wait_physics_frames(3)
	assert_eq(
		_props_with_cue(scene, "gate_shut").size(), 1, "the gate of the vestibule stands open"
	)
	assert_true(Beat.reached("hall_room_1"))
	var again := await DialogueWalk.play(DIALOGUE, "leaf", ["Liegen lassen"])
	assert_true(LineText.of("sh_leaf_5") in again, "a second look finds nothing new")
	assert_eq(WorldState.state.elysia.xp, xp + 1500, "and pays nothing")


func test_picking_up_the_leaf_makes_it_a_curiosity_and_takes_it_off_the_floor() -> void:
	var scene := await _hall()
	await DialogueWalk.play(DIALOGUE, "leaf", ["aufheben"])
	assert_true(WorldState.has_item("curiosity_dry_leaf"))
	assert_eq(Collection.curiosities(), 1)
	await wait_physics_frames(3)
	assert_eq(_props_with_cue(scene, "leaf").size(), 0, "nothing lies there any more")


func test_noticing_the_feather_opens_the_second_gate() -> void:
	var scene := await _hall()
	WorldState.set_flag("elysia.hall_room_1")
	await wait_physics_frames(3)
	var xp: int = WorldState.state.elysia.xp
	await DialogueWalk.play(DIALOGUE, "feather", ["einstecken"])
	assert_true(WorldState.has_flag("elysia.hall_room_2"))
	assert_true(WorldState.has_item("curiosity_feather"))
	assert_eq(WorldState.state.elysia.xp, xp + 2000)
	await wait_physics_frames(3)
	assert_eq(_props_with_cue(scene, "gate_shut").size(), 0, "both gates stand open")
	assert_true(Beat.reached("hall_room_2"))


func test_the_gate_opening_is_written_out_too() -> void:
	assert_true(ContentValidator.has_translation("CAPTION_GATE"))
	var scene := await _hall()
	WorldState.set_flag("elysia.hall_room_1")
	await wait_physics_frames(2)
	assert_eq(scene.hud._caption.text, tr("CAPTION_GATE"), "whatever the captions setting says")


func test_a_shut_gate_says_what_it_waits_for() -> void:
	var seen := await DialogueWalk.play(DIALOGUE, "gate_shut")
	assert_true(LineText.of("sh_gate_2") in seen)


# --- The keeper: help as often as asked ---------------------------------------------------


func test_the_keeper_helps_in_three_steps_for_the_room_the_hero_is_in() -> void:
	var first := await DialogueWalk.play(
		DIALOGUE, "keeper", ["Hinweis", "genauer", "Sag es mir", "selbst"]
	)
	assert_true(LineText.of("sh_keeper_3") in first, "the only exception he knows")
	assert_true(LineText.of("sh_hint_1") in first, "that something has no twin")
	assert_true(LineText.of("sh_hint_4") in first, "where")
	assert_true(LineText.of("sh_hint_7") in first, "what")
	assert_true(LineText.of("sh_keeper_6") in first, "and he lets the hero look alone")
	WorldState.set_flag("elysia.hall_room_1")
	var second := await DialogueWalk.play(
		DIALOGUE, "keeper", ["Hinweis", "genauer", "Sag es mir", "selbst"]
	)
	assert_false(LineText.of("sh_keeper_3") in second, "he introduces himself once")
	assert_true(LineText.of("sh_hint_2") in second)
	assert_true(LineText.of("sh_hint_5") in second)
	assert_true(LineText.of("sh_hint_8") in second)
	WorldState.set_flag("elysia.hall_room_2")
	var third := await DialogueWalk.play(
		DIALOGUE, "keeper", ["Hinweis", "genauer", "Sag es mir", "selbst"]
	)
	assert_true(LineText.of("sh_hint_3") in third)
	assert_true(LineText.of("sh_hint_9") in third)


func test_the_keeper_never_withholds_and_never_decides() -> void:
	var answers := await DialogueWalk.answers(DIALOGUE, "keeper")
	assert_eq(answers.size(), 4, "a hint, a closer one, the answer, or looking alone")
	assert_false(WorldState.has_flag("elysia.hall_room_1"), "asking for help opens nothing")


# --- The mirror and the new possibility --------------------------------------------------------


func test_the_mirror_shows_the_hall_and_not_the_hero_and_gives_perception() -> void:
	await _hall()
	var xp: int = WorldState.state.elysia.xp
	assert_false(WorldState.has_facet("perception"))
	var away := await DialogueWalk.play(DIALOGUE, "mirror", ["Wegsehen"])
	assert_true(LineText.of("sh_mirror_3") in away)
	assert_false(WorldState.has_facet("perception"), "looking away takes nothing")
	var seen := await DialogueWalk.play(DIALOGUE, "mirror", ["hinsehen"])
	assert_true(LineText.of("sh_mirror_5") in seen, "the basin in the garden showed nothing either")
	assert_true(WorldState.has_facet("perception"))
	assert_eq(WorldState.state.elysia.xp, xp + 5000)
	await wait_physics_frames(2)
	assert_true(Beat.reached("hall_mirror"))
	assert_true(Beat.reached("perception"))
	var later := await DialogueWalk.play(DIALOGUE, "mirror")
	assert_eq(later, PackedStringArray([LineText.of("sh_mirror_6")]))
	var keeper := await DialogueWalk.play(DIALOGUE, "keeper")
	assert_eq(keeper, PackedStringArray([LineText.of("sh_keeper_4")]), "he knows")


# --- The hero's quest ----------------------------------------------------------------------


func test_the_hall_is_the_stage_after_the_market() -> void:
	WorldState.start_quest("main_elysia_hero")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	WorldState.advance_quest("main_elysia_hero", "market")
	assert_false(WorldState.is_quest_done("main_elysia_hero"), "the hall is still to come")
	await _hall()
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "hall")
	assert_false(WorldState.is_quest_done("main_elysia_hero"), "the feast is the next stage")


func test_a_visit_before_the_chest_is_caught_up_by_the_chest() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	WorldState.start_quest("main_elysia_hero")
	WorldState.set_flag("elysia.market_seen")
	WorldState.set_flag("elysia.hall_seen")
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "hall", "the town, then the hall")
	assert_false(WorldState.is_quest_done("main_elysia_hero"))
