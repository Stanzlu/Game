extends GutTest
## Act VI, segment R6: standing up (docs/akt6/REGIONSBRIEFE.md, O6, O7). Whoever has the three
## offers behind her and gets up from the bench by her own step finds the host asking once, lightly,
## and letting her go with the soup; the walk moves on from the inn to the standing. Getting up
## earlier says nothing to anyone, and getting up again does not play it again. Afterwards the host
## is the same host without an offer, and the facet that nothing else read yet shows as an answer.
## What the cues say is tested in test_akt6_aufstehen.

const GASTHAUS := preload("res://world/levels/akt1/gasthaus.tscn")
const QUEST := "main_return_way"
const STAY_FLAGS: PackedStringArray = ["elysia.stay_1", "elysia.stay_2", "elysia.stay_3"]
const THREE_OFFERS: PackedStringArray = ["Bleiben.", "Noch bleiben.", "Noch bleiben."]
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("elysia.inn_met")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "pull")
	WorldState.advance_quest(QUEST, "elysia")
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


func _scene() -> GasthausScene:
	var scene: GasthausScene = GASTHAUS.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _props(scene: GameScene, file: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node.scene_file_path.ends_with(file):
			found.append(node)
	return found


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


func _sit(scene: GameScene) -> void:
	var bench := _props(scene, "bench.tscn")[0]
	(bench.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	await wait_physics_frames(3)


## Answers the box with these answers, in order, as they come up, until `done` holds.
func _answering(
	scene: GameScene, answers: PackedStringArray, done: Callable, timeout := 60.0
) -> void:
	var next := [0]
	var watch := func() -> bool:
		_polls += 1
		if scene.dialogue_box.is_open():
			var want := answers[next[0]] if next[0] < answers.size() else ""
			if next[0] < answers.size() and BoxAnswers.pick(scene.dialogue_box, want):
				next[0] += 1
			elif _polls % 6 == 0:
				_confirm()
		return done.call()
	assert_true(await wait_until(watch, timeout), "the box asked, and %s were taken" % [answers])
	assert_eq(next[0], answers.size(), "every answer was taken")


func _closed(scene: GameScene) -> Callable:
	return func() -> bool: return not scene.dialogue_box.is_open()


func _opened(scene: GameScene) -> Callable:
	return func() -> bool: return scene.dialogue_box.is_open()


## She sits down and takes the three offers; the game is then in the state of the third one.
func _three_offers(scene: GasthausScene) -> void:
	await _sit(scene)
	await _answering(scene, THREE_OFFERS, _closed(scene))
	assert_true(WorldState.has_flag("elysia.stay_3"))
	assert_eq(scene.player.state, Player.State.SIT, "she sits on")


## Her own step: she stands up and the box of the host comes up.
func _stand(scene: GasthausScene) -> void:
	scene.player.stand_up()
	await wait_physics_frames(2)


## Everything the game remembers, but for the play time that runs on by itself.
func _written_down() -> String:
	var state := WorldState.state.to_dict()
	state.erase("playtime_seconds")
	return JSON.stringify(state)


# --- Standing up -----------------------------------------------------------------------------


func test_getting_up_with_the_three_offers_behind_her_plays_the_host_once() -> void:
	var scene := await _scene()
	await _three_offers(scene)
	var xp := WorldState.state.elysia.xp
	var gold := WorldState.state.elysia.gold
	await _stand(scene)
	assert_eq(scene.view.zoom, scene.view_zoom, "the picture is given back at once")
	assert_true(await wait_until(_opened(scene), 5.0), "the host speaks as she gets up")
	assert_eq(scene.dialogue_box.cue, "stand_first", "his one question and his letting go")
	assert_true(WorldState.has_flag("elysia.stood_up"))
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_true(WorldState.has_item("item_soup"), "she carries the soup")
	assert_eq(WorldState.item_count("item_soup"), 1)
	assert_eq(WorldState.state.elysia.xp, xp, "the soup is no reward: no experience")
	assert_eq(WorldState.state.elysia.gold, gold, "and no gold")
	assert_eq(WorldState.quest_stage(QUEST), "stand", "the walk moves on from the inn")
	assert_true(Beat.reached(InnTable.STAND_BEAT), "and the game saves once")
	assert_ne(scene.player.state, Player.State.SIT, "she stands")
	assert_false(scene.player.is_locked(), "nothing holds her")


func test_it_is_not_played_again_when_she_sits_and_gets_up_again() -> void:
	var scene := await _scene()
	await _three_offers(scene)
	await _stand(scene)
	await _answering(scene, PackedStringArray(), _closed(scene))
	await wait_physics_frames(3)
	var opened := [0]
	scene.dialogue_box.opened.connect(func() -> void: opened[0] += 1)
	await _sit(scene)
	assert_true(await wait_until(_opened(scene), 5.0), "the table asks again")
	assert_eq(scene.dialogue_box.cue, "stay", "the same question: staying has no end")
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	await _stand(scene)
	await wait_physics_frames(30)
	assert_false(scene.dialogue_box.is_open(), "nobody asks the second time")
	assert_eq(opened[0], 1, "only the question of the sitting")
	assert_eq(WorldState.item_count("item_soup"), 1, "one soup")
	assert_eq(WorldState.quest_stage(QUEST), "stand")


func test_getting_up_before_the_third_offer_says_nothing_and_changes_nothing() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _answering(scene, PackedStringArray(["Bleiben.", "Nur sitzen."]), _closed(scene))
	assert_true(WorldState.has_flag("elysia.stay_1"))
	assert_false(WorldState.has_flag("elysia.stay_3"))
	var kept := _written_down()
	await _stand(scene)
	await wait_physics_frames(40)
	assert_false(scene.dialogue_box.is_open(), "the host has nothing to say yet")
	assert_false(WorldState.has_flag("elysia.stood_up"))
	assert_false(WorldState.has_item("item_soup"))
	assert_eq(WorldState.quest_stage(QUEST), "inn", "the walk waits")
	assert_eq(_written_down(), kept, "no mark, nothing written")


func test_getting_up_after_nothing_at_all_says_nothing() -> void:
	var scene := await _scene()
	await _sit(scene)
	await _answering(scene, PackedStringArray(["…"]), _closed(scene))
	await _stand(scene)
	await wait_physics_frames(40)
	assert_false(scene.dialogue_box.is_open())
	assert_false(WorldState.has_flag("elysia.stood_up"))


func test_a_game_that_waits_after_the_third_offer_plays_it_the_first_time_she_gets_up() -> void:
	# the sitting is not saved: loaded after the third offer she stands, and the step is still hers
	WorldState.set_flag("elysia.stay_1")
	WorldState.set_flag("elysia.stay_2")
	WorldState.set_flag("elysia.stay_3")
	var scene := await _scene()
	assert_ne(scene.player.state, Player.State.SIT)
	await _sit(scene)
	assert_true(await wait_until(_opened(scene), 5.0))
	assert_eq(scene.dialogue_box.cue, "stay", "the table first")
	await _answering(scene, PackedStringArray(["Nur sitzen."]), _closed(scene))
	await _stand(scene)
	assert_true(await wait_until(_opened(scene), 5.0))
	assert_eq(scene.dialogue_box.cue, "stand_first", "and when she gets up, the host")
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(WorldState.quest_stage(QUEST), "stand")


func test_the_flag_moves_the_walk_only_from_the_inn() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.loops")
	await _scene()
	WorldState.set_flag("elysia.stood_up")
	assert_eq(WorldState.quest_stage(QUEST), "", "no walk, no stage")
	assert_push_error_count(0)


func test_a_walk_in_an_earlier_stage_is_not_moved_by_the_flag() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.returned")
	WorldState.set_flag("elysia.loops")
	WorldState.start_quest(QUEST)
	WorldState.advance_quest(QUEST, "pull")
	await _scene()
	assert_eq(WorldState.quest_stage(QUEST), "pull", "the walk is where it was")
	WorldState.set_flag("elysia.stood_up")
	assert_eq(WorldState.quest_stage(QUEST), "pull", "a flag from elsewhere moves nothing")
	assert_push_error_count(0)


func test_a_game_that_never_spoke_to_the_host_keeps_his_first_words_after_standing_up() -> void:
	# a game that came back by the clock may never have met him: his first words, the guest book
	# and the meal are in Act I's cue, and the host afterwards does not displace them
	WorldState.clear_flag("elysia.inn_met")
	WorldState.set_flag("elysia.stood_up")
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host", "Act I's cue first")
	await _answering(scene, PackedStringArray(["Ich schau mich nur um."]), _closed(scene))
	assert_true(WorldState.has_flag("elysia.inn_met"), "now they have met")
	assert_eq(await _talk(scene, "host"), "host_after", "and from then on the host afterwards")
	await _answering(scene, PackedStringArray(["Danke für die Suppe."]), _closed(scene))


func test_the_soup_is_there_for_whoever_already_carries_one() -> void:
	WorldState.add_item("item_soup", 1, false)
	var scene := await _scene()
	await _three_offers(scene)
	await _stand(scene)
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(WorldState.item_count("item_soup"), 2, "a second one, as the host said")


# --- The host afterwards ----------------------------------------------------------------------


func test_whoever_has_stood_up_finds_the_host_without_an_offer() -> void:
	WorldState.set_flag("elysia.stood_up")
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host_after", "the host of afterwards")
	var kept := _written_down()
	await _answering(scene, PackedStringArray(["Danke für die Suppe."]), _closed(scene))
	assert_eq(_written_down(), kept, "nothing asked, nothing set")


func test_the_dance_is_an_answer_only_with_the_facet_and_the_host_is_glad_of_it() -> void:
	WorldState.set_flag("elysia.stood_up")
	WorldState.set_facet("aliveness")
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host_after")
	var kept := _written_down()
	await _answering(scene, PackedStringArray(["Tanzen?"]), _closed(scene))
	assert_eq(_written_down(), kept, "he is glad, and nothing is given for it")


func test_the_silence_is_taken_as_something_said() -> void:
	WorldState.set_flag("elysia.stood_up")
	WorldState.set_facet("aliveness")
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host_after")
	await _answering(scene, PackedStringArray(["…"]), _closed(scene))


func test_the_old_cues_stay_for_whoever_has_not_stood_up() -> void:
	var scene := await _scene()
	assert_eq(await _talk(scene, "host"), "host_back", "he waits, as in the first inn")
	await _answering(scene, PackedStringArray(), _closed(scene))
	assert_eq(await _talk(scene, "hearth"), "hearth_back")
	await _answering(scene, PackedStringArray(), _closed(scene))
