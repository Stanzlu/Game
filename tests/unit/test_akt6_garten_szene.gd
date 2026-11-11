extends GutTest
## Act VI, segment R3: Elysia as it was (docs/akt6/REGIONSBRIEFE.md, O5, O7, O8). Whoever came
## back through the gap (`elysia.returned`) hears new cues from the people of the garden and the
## basin (`talk_when` in the map); the lines of Act I are untouched for everyone else. The gardener
## gives a compliment for nothing, which can be taken (the old systems come back, loud) or left
## lying; the basin is the first thing that gives nothing, and whoever plays there has the facet
## that the gardener reads. What the cues say is tested in test_akt6_garten.

const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const GARTEN := "res://content/dialogue/akt6/garten.dialogue"
const OWN := "res://content/dialogue/slice/elysia.dialogue"
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
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


## Back in Elysia as the gap leaves her: the flag, the beat and the walk's stage are all there.
func _returned() -> void:
	WorldState.set_flag("elysia.returned")
	Beat.mark("act6_return")


func _elysia() -> ElysiaScene:
	var scene: ElysiaScene = ELYSIA.instantiate()
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


## Everything the game remembers, but for the play time that runs on by itself.
func _written_down() -> String:
	var state := WorldState.state.to_dict()
	state.erase("playtime_seconds")
	return JSON.stringify(state)


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


# --- talk_when -----------------------------------------------------------------------------------


func test_talk_when_picks_the_first_flag_that_is_set_and_keeps_the_own_pair_otherwise() -> void:
	var when := {
		"story.a": {"dialogue": GARTEN, "cue": "x"},
		"story.b": {"cue": "y"},
	}
	assert_eq(Talk.pick(when, OWN, "own"), PackedStringArray([OWN, "own"]), "no flag: its own")
	WorldState.set_flag("story.b")
	assert_eq(
		Talk.pick(when, OWN, "own"), PackedStringArray([OWN, "y"]), "a missing path is its own"
	)
	WorldState.set_flag("story.a")
	assert_eq(
		Talk.pick(when, OWN, "own"), PackedStringArray([GARTEN, "x"]), "the first one that holds"
	)
	assert_eq(Talk.pick({}, OWN, "own"), PackedStringArray([OWN, "own"]))
	assert_eq(Talk.pick(null, OWN, "own"), PackedStringArray([OWN, "own"]), "no param at all")


func test_the_people_of_the_garden_say_what_they_always_said_to_whoever_did_not_come_back() -> void:
	var scene := await _elysia()
	assert_eq(await _talk(scene, "gardener"), "gardener")
	await _through(scene)
	assert_eq(await _talk(scene, "favor"), "favor")
	await _through(scene)
	assert_eq(await _talk(scene, "elysian"), "elysian")
	await _through(scene)
	assert_eq(await _talk(scene, "basin"), "basin")
	await _through(scene)


func test_whoever_came_back_hears_the_new_cues_in_the_same_places() -> void:
	_returned()
	var scene := await _elysia()
	var pairs := {
		"gardener": "gardener_back",
		"favor": "favor_back",
		"elysian": "elysian_back",
		"basin": "basin_back",
	}
	var picks := {"gardener": "Lass nur.", "basin": "Zusehen."}
	for cue: String in pairs:
		assert_eq(await _talk(scene, cue), pairs[cue], "%s says its new cue" % cue)
		await _through(scene, PackedStringArray([picks.get(cue, "")]))
	assert_false(WorldState.has_flag("elysia.back_gift"), "nothing was taken on the way")


func test_the_flag_is_read_when_she_is_spoken_to_not_when_the_scene_is_built() -> void:
	var scene := await _elysia()
	assert_eq(await _talk(scene, "gardener"), "gardener", "not back yet: as in Act I")
	await _through(scene)
	WorldState.set_flag("elysia.returned")
	assert_eq(await _talk(scene, "gardener"), "gardener_back", "in the picture that stands")
	await _through(scene, PackedStringArray(["Lass nur."]))


# --- The gift -------------------------------------------------------------------------------------


func test_taking_the_compliment_is_loud_and_the_gardener_has_nothing_more_to_give() -> void:
	_returned()
	var scene := await _elysia()
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	assert_eq(await _talk(scene, "gardener"), "gardener_back")
	await _through(scene, PackedStringArray(["Annehmen."]))
	assert_true(WorldState.has_item("item_compliment"), "the compliment, a real one")
	assert_eq(WorldState.state.elysia.xp, xp + 2000, "and the number in the corner goes up")
	assert_eq(WorldState.state.elysia.gold, gold + 500)
	assert_true(WorldState.has_flag("elysia.back_gift"))
	assert_eq(
		await _talk(scene, "gardener"), "gardener_back", "the cue is the same, its word is not"
	)
	await _through(scene)
	assert_eq(WorldState.state.elysia.xp, xp + 2000, "she gives it once")


func test_leaving_the_compliment_lying_changes_nothing_and_the_offer_stands() -> void:
	_returned()
	var scene := await _elysia()
	var xp := WorldState.state.elysia.xp
	var kept := _written_down()
	assert_eq(await _talk(scene, "gardener"), "gardener_back")
	await _through(scene, PackedStringArray(["Lass nur."]))
	assert_false(WorldState.has_item("item_compliment"))
	assert_eq(WorldState.state.elysia.xp, xp, "no experience")
	assert_false(WorldState.has_flag("elysia.back_gift"))
	assert_eq(_written_down(), kept, "nothing was written down at all")
	var again := await _talk(scene, "gardener")
	assert_eq(again, "gardener_back", "it is offered again, as kindly as before")
	await _through(scene, PackedStringArray(["Lass nur."]))


# --- The basin ------------------------------------------------------------------------------------


func test_the_basin_gives_nothing_and_whoever_plays_in_it_has_the_facet_the_gardener_reads(
) -> void:
	_returned()
	var scene := await _elysia()
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	var inventory := WorldState.state.inventory.duplicate()
	assert_false(WorldState.has_facet("aliveness"))
	assert_eq(await _talk(scene, "basin"), "basin_back")
	await _through(scene, PackedStringArray(["Wasser spritzen."]))
	assert_true(WorldState.has_facet("aliveness"), "the first thing in Elysia that gives nothing")
	assert_eq(WorldState.state.elysia.xp, xp, "no experience")
	assert_eq(WorldState.state.elysia.gold, gold, "no gold")
	assert_eq(WorldState.state.inventory, inventory, "no loot")
	# the gardener reads it: after the gift her cue has the answer that she answers
	WorldState.set_flag("elysia.back_gift")
	var answers := await DialogueWalk.answers(GARTEN, "gardener_again")
	assert_eq(answers.size(), 3, "the one for the basin, the plain one and the silence")
	assert_true(answers[answers.size() - 1].begins_with("…"), "the silence is the last")


func test_watching_the_basin_is_an_answer_of_its_own_and_sets_nothing() -> void:
	_returned()
	var scene := await _elysia()
	assert_eq(await _talk(scene, "basin"), "basin_back")
	await _through(scene, PackedStringArray(["Zusehen."]))
	assert_false(WorldState.has_facet("aliveness"), "to watch is not to play")
	WorldState.set_flag("elysia.back_gift")
	var answers := await DialogueWalk.answers(GARTEN, "gardener_again")
	assert_eq(answers.size(), 2, "without the facet there is no answer for the basin")


func test_the_old_systems_stay_as_they_were_for_whoever_has_not_come_back() -> void:
	var scene := await _elysia()
	var xp := WorldState.state.elysia.xp
	assert_eq(await _talk(scene, "gardener"), "gardener")
	await _through(scene)
	assert_eq(WorldState.state.elysia.xp, xp, "nothing is given for nothing before the return")
	assert_false(WorldState.has_item("item_compliment"))
	assert_true(WorldState.is_quest_active("side_elysia_butterflies"), "Act I's own: the quest")
	assert_true(WorldState.has_flag("elysia.butterflies_asked"), "and the butterflies appear")
	assert_false(WorldState.has_flag("elysia.back_gift"))
