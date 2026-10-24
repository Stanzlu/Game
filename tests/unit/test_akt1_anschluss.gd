extends GutTest
## Act I, segment A9: the join to the rift. The stone lies in the garden only once Elysia repeats
## itself (it is the third thing of the order: repetition, the missing reflection, the stone, the
## child, the rift; Game Bible §56), the seed is claimed by the Elysians in the first minute, and
## once the rift is open the people of the town say a shorter sentence of the same kind.

const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const GARDEN := "res://content/dialogue/slice/elysia.dialogue"
const MARKT_DIALOGUE := "res://content/dialogue/akt1/markt.dialogue"
const INN_DIALOGUE := "res://content/dialogue/akt1/gasthaus.dialogue"
const STONE_AT := Vector2i(41, 17)


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _garden() -> ElysiaScene:
	var scene: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The pebble in the garden (a pickup of the stone), or null.
func _stone(scene: GameScene) -> Node:
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node.get(&"item") == "item_stone":
			return node
	return null


func _stone_sight(scene: GameScene) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if (
			node.get(&"cue") == "stone"
			or (node.has_meta(&"cue") and node.get_meta(&"cue") == "stone")
		):
			return node
	return null


# --- The stone ----------------------------------------------------------------------------


func test_the_stone_is_not_there_before_the_repetition() -> void:
	var scene := await _garden()
	assert_null(_stone(scene), "nothing to take at the start")
	assert_null(_stone_sight(scene), "and nothing to say about it")
	assert_false(WorldState.has_item("item_stone"))


func test_the_stone_lies_where_the_child_stands_once_the_sentences_repeat() -> void:
	var scene := await _garden()
	WorldState.set_flag("elysia.loops")
	await wait_physics_frames(2)
	var stone := _stone(scene)
	assert_not_null(stone, "the stone lies there now")
	assert_not_null(_stone_sight(scene), "and the line about it is there")
	assert_eq(scene.map.world_to_cell(stone.global_position), STONE_AT)


func test_taking_the_stone_shortens_the_music_a_second_time() -> void:
	var scene := await _garden()
	WorldState.set_flag("elysia.loops")
	await wait_physics_frames(2)
	assert_false(WorldState.has_flag("elysia.loops_2"))
	_stone(scene).get_node("Interactable").interacted.emit(null)
	await wait_physics_frames(2)
	assert_true(WorldState.has_flag("elysia.stone_taken"))
	assert_true(WorldState.has_item("item_stone"))
	assert_true(WorldState.has_flag("elysia.loops_2"), "the quarter loop comes with the stone")
	assert_true(Beat.reached("stone"))
	assert_null(_stone_sight(scene), "the sight of it goes with it")


func test_a_stone_taken_before_stays_taken() -> void:
	# a save from before A9: the stone was taken early, and the repetition comes after
	WorldState.set_flag("elysia.stone_taken")
	var scene := await _garden()
	WorldState.set_flag("elysia.loops")
	await wait_physics_frames(2)
	assert_null(_stone(scene), "it is not laid out a second time")


# --- The seed -----------------------------------------------------------------------------


func test_the_elysians_claim_the_seed_in_the_first_minute() -> void:
	WorldState.add_item("item_seed", 1, false)
	var seen := await DialogueWalk.play(GARDEN, "wake", ["Hallo"])
	assert_true(LineText.of("el_wake_seed") in seen, "they know it, and call it theirs")
	var seed_at := seen.find(LineText.of("el_wake_seed"))
	assert_gt(seed_at, seen.find(LineText.of("el_wake_2")), "after the greeting")
	assert_lt(seed_at, seen.find(LineText.of("el_wake_7")), "before the gardener is mentioned")


func test_without_the_seed_they_say_nothing_about_it() -> void:
	var seen := await DialogueWalk.play(GARDEN, "wake", ["Hallo"])
	assert_false(LineText.of("el_wake_seed") in seen)
	assert_true(LineText.of("el_wake_7") in seen, "the rest of the greeting is unchanged")


func test_the_garden_gives_the_hero_the_seed_before_the_greeting() -> void:
	var scene: ElysiaScene = ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_true(WorldState.has_item("item_seed"), "it was there before the first memory")


# --- Loop 2 ------------------------------------------------------------------------------------


func test_once_the_rift_is_open_the_gatekeeper_has_a_shorter_sentence_of_his_own() -> void:
	WorldState.set_flag("elysia.loops")
	var first := await DialogueWalk.play(MARKT_DIALOGUE, "gatekeeper")
	assert_eq(first, PackedStringArray([LineText.of("mk_gate_10")]), "loop 1 until the rift")
	WorldState.set_flag("elysia.rift_open")
	for round in 3:
		var again := await DialogueWalk.play(MARKT_DIALOGUE, "gatekeeper")
		assert_eq(again, PackedStringArray([LineText.of("mk_gate_11")]), "loop 2, every time")
	assert_eq(LineText.of("mk_gate_11"), LineText.of("mk_gate_4"), "a sentence he said before")
	assert_lt(LineText.of("mk_gate_11").length(), LineText.of("mk_gate_10").length())


func test_once_the_rift_is_open_the_host_drops_the_first_of_his_two_sentences() -> void:
	WorldState.set_flag("elysia.inn_met")
	WorldState.set_flag("elysia.loops")
	var loop_1 := await DialogueWalk.play(INN_DIALOGUE, "host")
	assert_eq(
		loop_1,
		PackedStringArray([LineText.of("gh_host_loop_1"), LineText.of("gh_host_loop_2")]),
		"two sentences until the rift"
	)
	WorldState.set_flag("elysia.rift_open")
	var loop_2 := await DialogueWalk.play(INN_DIALOGUE, "host")
	assert_eq(loop_2, PackedStringArray([LineText.of("gh_host_loop_2")]), "one, the second")
	assert_eq(LineText.of("gh_host_loop_2"), LineText.of("gh_host_2"), "word for word")


func test_the_rift_alone_changes_nothing_before_the_repetition() -> void:
	WorldState.set_flag("elysia.rift_open")
	WorldState.set_flag("elysia.feast")
	var feast_lines := [
		LineText.of("mk_gate_7"), LineText.of("mk_gate_8"), LineText.of("mk_gate_9")
	]
	var seen := await DialogueWalk.play(MARKT_DIALOGUE, "gatekeeper")
	assert_true(seen[0] in feast_lines, "loop 2 needs loop 1: it is still the feast")


# --- The crossing ----------------------------------------------------------------------------


func test_the_crossing_keeps_stone_and_seed_and_nothing_of_the_curiosities() -> void:
	# Game Bible §11: stone and seed are what goes over; a leaf or a feather stays in Elysia
	assert_eq(RiftSequence.KEEP, PackedStringArray(["item_stone", "item_seed"]))
	for id: String in ["curiosity_dry_leaf", "curiosity_feather"]:
		assert_false(id in RiftSequence.KEEP, "%s stays behind" % id)
