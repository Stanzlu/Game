extends GutTest
## Act I, segment A6: the feast. Once the hall was noticed, the market stands in its feast state;
## the host invites, the mistress of the feast has a toast, and raising a glass is worth about
## eleven thousand experience: the reward grows while the deed shrinks (Game Bible §10), and
## with it level 48 is certain whatever else was skipped.

const MARKT := preload("res://world/levels/akt1/markt.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const DIALOGUE := "res://content/dialogue/akt1/markt.dialogue"
## What the slice guarantees (docs/PRODUKTIONSPLAN.md 4.4): chest, three butterflies, fountain.
const SLICE_XP := 22600
const FEAST_XP := 11000
const FEAST_CUES: PackedStringArray = ["festmaster", "host_feast"]


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _market() -> MarktScene:
	var scene: MarktScene = MARKT.instantiate()
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


# --- The state of the market ------------------------------------------------------------


func test_the_market_is_plain_until_the_hall_was_noticed() -> void:
	var scene := await _market()
	assert_false(WorldState.has_flag("elysia.feast"))
	for cue: String in ["festmaster", "host_feast", "feast_guest"]:
		assert_eq(_props_with_cue(scene, cue).size(), 0, "%s is not there yet" % cue)
	assert_false(Beat.reached("feast_enter"))


func test_the_market_enters_its_feast_state_with_everyone_twice() -> void:
	WorldState.set_flag("elysia.hall_mirror_seen")
	var scene := await _market()
	assert_true(WorldState.has_flag("elysia.feast"))
	assert_true(Beat.reached("feast_enter"))
	assert_eq(_props_with_cue(scene, "festmaster").size(), 1, "she stands at the fountain, once")
	assert_eq(_props_with_cue(scene, "host_feast").size(), 1, "the host, once, on the middle axis")
	var guests := _props_with_cue(scene, "feast_guest")
	assert_eq(guests.size(), 4, "two pairs of guests")
	var axis := 30.0 * 16.0 + 8.0
	var sum: float = 0.0
	for guest in guests:
		sum += (guest as Node2D).global_position.x
	assert_almost_eq(sum, 4.0 * axis, 1.0, "the guests mirror each other")


func test_the_state_follows_the_flag_while_the_market_is_open() -> void:
	var scene := await _market()
	WorldState.set_flag("elysia.feast")
	await wait_physics_frames(3)
	assert_eq(_props_with_cue(scene, "festmaster").size(), 1)
	WorldState.clear_flag("elysia.feast")
	await wait_physics_frames(3)
	assert_eq(_props_with_cue(scene, "festmaster").size(), 0)


# --- The invitation and the toast ---------------------------------------------------------


func test_the_host_invites_and_the_invitation_is_free_to_refuse() -> void:
	var answers := await DialogueWalk.answers(DIALOGUE, "host_feast")
	assert_eq(answers.size(), 3, "accept, look around, silence")
	await DialogueWalk.play(DIALOGUE, "host_feast", ["schau mich nur um"])
	assert_false(WorldState.has_flag("elysia.feast_invited"))
	var seen := await DialogueWalk.play(DIALOGUE, "host_feast", ["Ich komme"])
	assert_true(LineText.of("mk_host_3") in seen)
	assert_true(WorldState.has_flag("elysia.feast_invited"))
	assert_false(WorldState.has_flag("elysia.feast_toast"), "he asks, he does not hold")


func test_the_toast_pays_eleven_thousand_for_lifting_a_glass() -> void:
	WorldState.start_quest("main_elysia_hero")
	var xp: int = WorldState.state.elysia.xp
	var gold: int = WorldState.state.elysia.gold
	var seen := await DialogueWalk.play(DIALOGUE, "festmaster", ["Glas heben"])
	assert_true(
		LineText.of("mk_fest_2") in seen, "without the invitation she introduces the feast herself"
	)
	assert_true(LineText.of("mk_fest_7") in seen)
	assert_true(WorldState.has_flag("elysia.feast_toast"))
	assert_eq(WorldState.state.elysia.xp, xp + FEAST_XP)
	assert_eq(WorldState.state.elysia.gold, gold + 3000)
	var later := await DialogueWalk.play(DIALOGUE, "festmaster")
	assert_eq(later.size(), 1, "one line of the feast that goes on")
	assert_eq(WorldState.state.elysia.xp, xp + FEAST_XP, "and pays nothing again")


func test_with_the_invitation_the_host_has_announced_her() -> void:
	WorldState.set_flag("elysia.feast_invited")
	var seen := await DialogueWalk.play(DIALOGUE, "festmaster", ["Später"])
	assert_true(LineText.of("mk_fest_1") in seen)
	assert_false(LineText.of("mk_fest_2") in seen)
	assert_false(WorldState.has_flag("elysia.feast_toast"), "later is an answer")


func test_level_forty_eight_is_certain_after_the_feast() -> void:
	WorldState.add_xp(SLICE_XP)
	assert_lt(WorldState.elysia_level(), 48, "the slice alone is not enough")
	await DialogueWalk.play(DIALOGUE, "festmaster", ["Glas heben"])
	assert_gte(WorldState.elysia_level(), 48, "with the toast it is")


func test_the_perceptive_may_say_it_is_the_same_feast_and_he_notes_it() -> void:
	var plain := await DialogueWalk.answers(DIALOGUE, "festmaster")
	assert_eq(plain.size(), 2)
	WorldState.set_facet("perception")
	var answers := await DialogueWalk.answers(DIALOGUE, "festmaster")
	assert_eq(answers.size(), 3)
	var seen := await DialogueWalk.play(DIALOGUE, "festmaster", ["dasselbe Fest"])
	assert_true(LineText.of("mk_fest_4") in seen)
	assert_true(LineText.of("mk_fest_7") in seen, "the toast comes all the same")
	assert_true(WorldState.has_flag("elysia.feast_noticed"))
	var host := await DialogueWalk.play(DIALOGUE, "host_feast")
	assert_true(LineText.of("mk_host_5") in host, "he lets the hero notice")
	assert_true(LineText.of("mk_host_6") in host, "and still: no need to go back")


# --- The people of the feast -----------------------------------------------------------------


func test_everybody_has_a_feast_variant_and_the_guests_say_the_same() -> void:
	WorldState.set_flag("elysia.feast")
	var gate := await DialogueWalk.play(DIALOGUE, "gatekeeper")
	assert_true(
		gate[0] in [LineText.of("mk_gate_7"), LineText.of("mk_gate_8"), LineText.of("mk_gate_9")]
	)
	var baker := await DialogueWalk.play(DIALOGUE, "baker")
	assert_true(baker[0] in [LineText.of("mk_baker_6"), LineText.of("mk_baker_7")])
	var tailor := await DialogueWalk.play(DIALOGUE, "tailor")
	assert_true(tailor[0] in [LineText.of("mk_tailor_7"), LineText.of("mk_tailor_8")])
	var florist := await DialogueWalk.play(DIALOGUE, "florist")
	assert_true(florist[0] in [LineText.of("mk_flower_4"), LineText.of("mk_flower_5")])
	var merchant := await DialogueWalk.play(DIALOGUE, "merchant", ["schaue nur"])
	assert_true(LineText.of("mk_shop_7") in merchant)
	var guest := await DialogueWalk.play(DIALOGUE, "feast_guest")
	assert_eq(guest, PackedStringArray([LineText.of("mk_guest_1")]))


func test_the_plain_market_keeps_its_old_lines() -> void:
	var gate := await DialogueWalk.play(DIALOGUE, "gatekeeper")
	assert_true(LineText.of("mk_gate_1") in gate, "no feast, the first welcome")


# --- The hero's quest ---------------------------------------------------------------------------


func test_the_toast_is_the_stage_feast_and_the_last_stage_for_now() -> void:
	WorldState.start_quest("main_elysia_hero")
	for stage: String in ["celebrated", "market", "hall"]:
		WorldState.advance_quest("main_elysia_hero", stage)
	assert_false(WorldState.is_quest_done("main_elysia_hero"))
	WorldState.set_flag("elysia.hall_mirror_seen")
	await _market()
	await DialogueWalk.play(DIALOGUE, "festmaster", ["Glas heben"])
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "feast")
	assert_true(WorldState.is_quest_done("main_elysia_hero"), "for now, until the repetition")
	assert_true(Beat.reached("feast"))


func test_the_chest_catches_up_a_feast_that_came_before_it() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	WorldState.start_quest("main_elysia_hero")
	for flag: String in ["market_seen", "hall_seen", "feast_toast"]:
		WorldState.set_flag("elysia." + flag)
	WorldState.advance_quest("main_elysia_hero", "celebrated")
	await wait_physics_frames(2)
	assert_eq(WorldState.quest_stage("main_elysia_hero"), "feast", "the town, the hall, the feast")
