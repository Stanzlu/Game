extends GutTest
## Act I, segment A8: the child's trail. Once Elysia repeats itself the child stands in three
## places of the town: in the lane before the gate (a corridor), at the door behind the bar
## (a closed door), before the great mirror (an empty room). Each shows one picture, unexplained,
## and goes; none of them is required (Game Bible §15, §31). The child's hum is the second melody
## of Act I.

const MARKT := preload("res://world/levels/akt1/markt.tscn")
const GASTHAUS := preload("res://world/levels/akt1/gasthaus.tscn")
const HALL := preload("res://world/levels/akt1/spiegelhalle.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const KIND := "res://content/dialogue/akt1/kind.dialogue"
const GARDEN := "res://content/dialogue/slice/elysia.dialogue"
## cue -> [fragment id, beat of the scene, the child's words, the picture]
const STATIONS := {
	"child_hallway": ["hallway", "trail_hallway", "kd_hall_2", "fragment_hallway"],
	"child_door": ["closed_door", "trail_door", "kd_door_2", "fragment_closed_door"],
	"child_room": ["empty_room", "trail_room", "kd_room_2", "fragment_empty_room"],
}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene(packed: PackedScene) -> GameScene:
	var scene: GameScene = packed.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _children_with_cue(scene: GameScene, cue: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if not node.is_queued_for_deletion() and node.get(&"cue") == cue:
			found.append(node)
	return found


# --- The three places ----------------------------------------------------------------------


func test_the_child_stands_in_the_town_only_while_elysia_repeats_itself() -> void:
	var scenes := {"child_hallway": MARKT, "child_door": GASTHAUS, "child_room": HALL}
	for cue: String in scenes:
		var scene := await _scene(scenes[cue])
		assert_eq(_children_with_cue(scene, cue).size(), 0, "%s: not before the repetition" % cue)
		WorldState.set_flag("elysia.loops")
		await wait_physics_frames(3)
		assert_eq(_children_with_cue(scene, cue).size(), 1, "%s: one child, no twin" % cue)
		scene.queue_free()
		await wait_physics_frames(2)
		WorldState.new_game()


func test_each_picture_comes_once_and_the_child_goes() -> void:
	var scenes := {"child_hallway": MARKT, "child_door": GASTHAUS, "child_room": HALL}
	for cue: String in scenes:
		var scene := await _scene(scenes[cue])
		WorldState.set_flag("elysia.loops")
		await wait_physics_frames(3)
		await DialogueWalk.play(KIND, cue)
		var data: Array = STATIONS[cue]
		assert_true(Collection.has_fragment(data[0]), "%s: the fragment is found" % cue)
		await wait_physics_frames(3)
		assert_true(Beat.reached(data[1]))
		# the child is leaving: gone after the fade
		await wait_seconds(2.0)
		assert_eq(_children_with_cue(scene, cue).size(), 0, "%s: gone" % cue)
		scene.queue_free()
		await wait_physics_frames(2)
		WorldState.new_game()


func test_three_fragments_three_pictures_and_nothing_counts() -> void:
	for cue: String in STATIONS:
		await DialogueWalk.play(KIND, cue)
	assert_eq(Collection.fragments(), 3)
	for cue: String in STATIONS:
		var picture: String = STATIONS[cue][3]
		assert_true(
			ResourceLoader.exists("res://assets/generated/fragments/%s.png" % picture),
			"the picture of %s" % cue
		)


# --- What the child says -------------------------------------------------------------------


func test_the_child_speaks_in_at_most_three_words_and_never_explains() -> void:
	for cue: String in STATIONS:
		var said := LineText.of(STATIONS[cue][2])
		assert_lte(said.split(" ", false).size(), 3, "the child says '%s'" % said)
	var lines := await DialogueWalk.play(KIND, "child_hallway")
	assert_eq(lines.size(), 4, "a look, one word, the picture, a step")


func test_the_child_has_no_hold_on_the_player_and_asks_nothing() -> void:
	for cue: String in STATIONS:
		var answers := await DialogueWalk.answers(KIND, cue)
		assert_eq(answers.size(), 0, "%s: a picture to see, no answers to give" % cue)


# --- The trail as a quest ------------------------------------------------------------------


func test_the_repetition_starts_the_trail_and_a_picture_moves_it_on() -> void:
	assert_false(WorldState.is_quest_started("main_elysia_trail"))
	var director := ElysiaDirector.attach(await _scene(MARKT))
	director.begin_loops()
	assert_eq(WorldState.quest_stage("main_elysia_trail"), "hum")
	await DialogueWalk.play(KIND, "child_door")
	assert_eq(WorldState.quest_stage("main_elysia_trail"), "trail")
	WorldState.set_flag("elysia.rift_open")
	assert_eq(WorldState.quest_stage("main_elysia_trail"), "rift")
	assert_true(WorldState.is_quest_done("main_elysia_trail"))


func test_the_rift_does_not_wait_for_a_single_picture() -> void:
	var director := ElysiaDirector.attach(await _scene(MARKT))
	director.begin_loops()
	WorldState.set_flag("elysia.rift_open")
	assert_true(WorldState.is_quest_done("main_elysia_trail"), "hum, then the rift")
	assert_eq(Collection.fragments(), 0, "every fragment is optional")


func test_a_save_from_the_repetition_before_the_trail_gets_its_quest() -> void:
	WorldState.set_flag("elysia.loops")
	ElysiaDirector.attach(await _scene(MARKT))
	assert_eq(WorldState.quest_stage("main_elysia_trail"), "hum")


func test_a_save_from_after_the_rift_has_nothing_left_to_follow() -> void:
	# the autosave of rift_found (A7) holds the repetition and the open rift, but no trail
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("elysia.rift_open")
	ElysiaDirector.attach(await _scene(MARKT))
	assert_eq(WorldState.quest_stage("main_elysia_trail"), "rift", "no hum that never ends")
	assert_true(WorldState.is_quest_done("main_elysia_trail"))


# --- The melody and the card ---------------------------------------------------------------


func test_the_last_word_of_the_child_gives_its_melody() -> void:
	var garden: ElysiaScene = ELYSIA.instantiate()
	WorldState.set_flag("elysia.woke")
	add_child_autofree(garden)
	await wait_physics_frames(3)
	assert_false(Collection.has_melody("child_hum"))
	WorldState.set_flag("elysia.child_met")
	var seen := await DialogueWalk.play(GARDEN, "child")
	assert_true(LineText.of("el_child_3") in seen, "the one question")
	assert_true(LineText.of("el_child_4") in seen)
	assert_true(Collection.has_melody("child_hum"))
	await wait_physics_frames(2)
	assert_true(Beat.reached("child_melody"))
	WorldState.set_flag("melody.elysia_perfect")
	assert_eq(Collection.melodies(), 2, "Act I has two melodies: the perfect one and the child's")


func test_a_found_fragment_shows_its_picture_quietly() -> void:
	var scene := await _scene(MARKT)
	var hud: Node = scene.hud
	var before: int = hud._popups.get_child_count()
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("fragment.hallway")
	await wait_process_frames(4)
	assert_eq(hud._popups.get_child_count(), before + 1, "one small card")
	var card: Node = hud._popups.get_child(hud._popups.get_child_count() - 1)
	var textures := card.find_children("*", "TextureRect", true, false)
	assert_eq(textures.size(), 1)
	assert_not_null((textures[0] as TextureRect).texture)
	assert_true(ContentValidator.has_translation("HUD_FRAGMENT"))
	WorldState.set_flag("melody.elysia_perfect")
	await wait_process_frames(4)
	assert_eq(hud._popups.get_child_count(), before + 1, "a melody has no card, only its narration")
