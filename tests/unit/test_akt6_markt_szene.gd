extends GutTest
## Act VI, segment R4: the market and the hall of mirrors as they were (docs/akt6/REGIONSBRIEFE.md,
## O5). Whoever came back through the gap (`elysia.returned`) hears new cues from the people of the
## market and the keeper and the mirror of the hall (`talk_when` in the maps); the lines of Act I
## are untouched for everyone else. What the cues say is tested in test_akt6_markt.

const MARKT := preload("res://world/levels/akt1/markt.tscn")
const HALL := preload("res://world/levels/akt1/spiegelhalle.tscn")
## The cue of Act I -> the cue of Act VI, per place.
const MARKET_PAIRS := {
	"poet": "poet_back",
	"musician": "musician_back",
	"gatekeeper": "gatekeeper_back",
	"feast_guest": "guest_back",
	"festmaster": "festmaster_back",
}
## These two keep Act I's cue until the errand of the board is done (the loaf and the errand are
## in that cue); the merchant keeps his shop and has no new cue at all.
const ERRAND_PAIRS := {"baker": "baker_back", "board": "board_back"}
const OLD_ONLY: PackedStringArray = ["merchant"]
## What is picked where Act I's cues loop: the keeper offers hints for ever, the mirror asks.
const LEAVE := {"keeper": "Ich schaue selbst.", "mirror": "Wegsehen.", "festmaster": "Später."}
const HALL_PAIRS := {"keeper": "keeper_back", "mirror": "mirror_back"}
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.feast")
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


func _place(packed: PackedScene) -> GameScene:
	var scene: GameScene = packed.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The prop (walker or decor) with this cue on the map, or null; the first one found.
func _prop(scene: GameScene, cue: String) -> Node:
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
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


## Talks to the prop as the player does and returns the cue that the box shows.
func _talk(scene: GameScene, cue: String) -> String:
	var prop := _prop(scene, cue)
	assert_not_null(prop, "the prop with the cue %s is on the map" % cue)
	if prop == null:
		return ""
	(prop.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0), "it says something")
	return scene.dialogue_box.cue


## Moves the text on, picks `answers` in order at the choices, until the box is closed.
func _through(scene: GameScene, answers: PackedStringArray = []) -> void:
	var next := [0]
	var closed := func() -> bool:
		_polls += 1
		if scene.dialogue_box.is_open():
			if BoxAnswers.pick(
				scene.dialogue_box, answers[next[0]] if next[0] < answers.size() else ""
			):
				next[0] += 1
			elif _polls % 6 == 0:
				_confirm()
		return not scene.dialogue_box.is_open()
	assert_true(await wait_until(closed, 30.0), "the conversation ends")
	await wait_physics_frames(2)


func test_the_people_of_the_market_say_what_they_always_said_to_whoever_did_not_come_back() -> void:
	var scene := await _place(MARKT)
	var cues: Array = MARKET_PAIRS.keys() + ERRAND_PAIRS.keys() + Array(OLD_ONLY)
	for cue: String in cues:
		assert_eq(await _talk(scene, cue), cue, "%s keeps the cue of Act I" % cue)
		await _through(scene, PackedStringArray([LEAVE.get(cue, "")]))
	assert_false(WorldState.has_flag("elysia.returned"))


func test_whoever_came_back_hears_the_new_cues_in_the_same_places() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("melody.elysia_perfect")
	WorldState.set_flag("elysia.feast_toast")
	var scene := await _place(MARKT)
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	for cue: String in MARKET_PAIRS:
		assert_eq(await _talk(scene, cue), MARKET_PAIRS[cue], "%s says its new cue" % cue)
		await _through(scene, PackedStringArray([LEAVE.get(cue, "")]))
	assert_eq(await _talk(scene, "merchant"), "merchant", "the merchant keeps his shop")
	await _through(scene, PackedStringArray(["Ich schaue nur."]))
	assert_eq(WorldState.state.elysia.xp, xp, "the feast gives nothing a second time")
	assert_eq(WorldState.state.elysia.gold, gold)


func test_what_the_old_cues_still_give_is_not_taken_from_whoever_has_not_had_it() -> void:
	# a game that came back by the clock (the rift opens by itself) may never have heard the
	# melody, raised the glass or looked into the mirror: the cues of Act I still hold those
	WorldState.set_flag("elysia.returned")
	var scene := await _place(MARKT)
	assert_eq(await _talk(scene, "musician"), "musician", "the melody is still to be heard")
	await _through(scene, PackedStringArray(["Zuhören."]))
	assert_true(WorldState.has_flag("melody.elysia_perfect"), "and now it is")
	assert_eq(await _talk(scene, "musician"), "musician_back", "from then on the new cue")
	await _through(scene, PackedStringArray(["Weitergehen."]))
	assert_eq(await _talk(scene, "festmaster"), "festmaster", "the toast is still to be raised")
	await _through(scene, PackedStringArray(["Später."]))
	assert_false(WorldState.has_flag("elysia.feast_toast"))
	# one scene at a time: the dialogue of a prop opens in the first scene of the group
	scene.queue_free()
	await wait_physics_frames(2)
	var hall := await _place(HALL)
	assert_eq(await _talk(hall, "mirror"), "mirror", "the mirror has not been looked into yet")
	await _through(hall, PackedStringArray(["Weiter hinsehen."]))
	assert_true(WorldState.has_flag("elysia.hall_mirror_seen"))
	assert_true(WorldState.has_facet("perception"), "Act I's mirror gives what it gave")
	assert_eq(await _talk(hall, "mirror"), "mirror_back", "and then the new one")
	await _through(hall, PackedStringArray(["Wegsehen."]))


func test_the_baker_and_the_board_keep_the_errand_until_it_is_done() -> void:
	WorldState.set_flag("elysia.returned")
	var scene := await _place(MARKT)
	for cue: String in ERRAND_PAIRS:
		assert_eq(
			await _talk(scene, cue), cue, "%s: the loaf and the errand are in Act I's cue" % cue
		)
		await _through(scene, PackedStringArray(["Später."]))
	assert_false(WorldState.is_quest_started("side_elysia_board"), "nothing was taken on the way")


func test_once_the_errand_is_done_the_baker_and_the_board_say_their_new_cues() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("beat.market_board_done")
	var scene := await _place(MARKT)
	for cue: String in ERRAND_PAIRS:
		assert_eq(await _talk(scene, cue), ERRAND_PAIRS[cue], "%s says its new cue" % cue)
		await _through(scene)


func test_the_errand_is_handed_in_for_someone_who_came_back_with_the_loaf() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.start_quest("side_elysia_board")
	WorldState.advance_quest("side_elysia_board", "bread")
	var scene := await _place(MARKT)
	assert_eq(await _talk(scene, "baker"), "baker", "she still has the loaf for the errand")
	await _through(scene)
	assert_true(WorldState.has_item("item_loaf"), "the loaf, from Act I's cue")
	assert_eq(WorldState.quest_stage("side_elysia_board"), "deliver")


func test_the_hall_keeps_its_old_cues_for_whoever_did_not_come_back() -> void:
	var scene := await _place(HALL)
	for cue: String in HALL_PAIRS:
		assert_eq(await _talk(scene, cue), cue, "%s keeps the cue of Act I" % cue)
		await _through(scene, PackedStringArray([LEAVE.get(cue, "")]))


func test_whoever_came_back_hears_the_keeper_and_the_mirror_say_something_new() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.hall_mirror_seen")
	var scene := await _place(HALL)
	for cue: String in HALL_PAIRS:
		assert_eq(await _talk(scene, cue), HALL_PAIRS[cue], "%s says its new cue" % cue)
		await _through(scene, PackedStringArray(["Wegsehen."]))
	assert_false(WorldState.has_facet("perception"), "looking at the mirror again gives nothing")


func test_the_feast_stands_as_it_stood_and_the_old_toast_is_not_asked_for_again() -> void:
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.feast_toast")
	var xp := WorldState.state.elysia.xp
	var scene := await _place(MARKT)
	assert_eq(await _talk(scene, "festmaster"), "festmaster_back")
	await _through(scene, PackedStringArray(["Später."]))
	assert_eq(WorldState.state.elysia.xp, xp, "no toast is paid for a second time")
	assert_true(WorldState.has_flag("elysia.feast_toast"), "what was set stays set")
