extends GutTest
## Act VI, the collectibles on the maps (docs/akt6/REGIONSBRIEFE.md, section R10): the things that
## carry them are the old things of Elysia, and the map picks the new cue with `talk_when` and
## `elysia.returned`. A new cue never takes a function of Act I away: the guest book speaks the new
## cue only once it is signed (the signing stays where it was), the fountain keeps its coin for ten
## gold, the pillar had only a description, and the table in the inn is new for everyone who is
## back. Whoever has not come back finds every old cue as it was. What the cues say is tested in
## test_akt6_sammlung.

const ELYSIA := preload("res://world/levels/slice/elysia.tscn")
const MARKT := preload("res://world/levels/akt1/markt.tscn")
const GASTHAUS := preload("res://world/levels/akt1/gasthaus.tscn")
var _polls := 0


func before_each() -> void:
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.set_flag("elysia.woke")
	WorldState.set_flag("elysia.loops")
	WorldState.set_flag("elysia.inn_met")
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


func _back() -> void:
	# back in Elysia as the gap leaves her: the arrival has been told, nothing plays on its own
	WorldState.set_flag("elysia.returned")
	Beat.mark("act6_return")


func _scene(packed: PackedScene) -> GameScene:
	var scene: GameScene = packed.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## Every prop of the map with this cue (a Decor keeps it as meta, a walker as a property).
func _props(scene: GameScene, cue: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			found.append(node)
		elif str(node.get(&"cue")) == cue:
			found.append(node)
	return found


func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## Talks to the prop as the player does and returns the cue that the box shows.
func _talk(scene: GameScene, cue: String, index := 0) -> String:
	var props := _props(scene, cue)
	assert_gt(props.size(), index, "the prop with the cue %s is on the map" % cue)
	if props.size() <= index:
		return ""
	(props[index].get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up := func() -> bool: return scene.dialogue_box.is_open()
	assert_true(await wait_until(up, 5.0), "it says something")
	return scene.dialogue_box.cue


## Moves the text on, picks `answers` in order at the choices, until the box is closed.
func _through(scene: GameScene, answers: PackedStringArray = []) -> void:
	var next := [0]
	var closed := func() -> bool:
		_polls += 1
		if scene.dialogue_box.is_open():
			var want := answers[next[0]] if next[0] < answers.size() else ""
			if next[0] < answers.size() and BoxAnswers.pick(scene.dialogue_box, want):
				next[0] += 1
			elif _polls % 6 == 0:
				_confirm()
		return not scene.dialogue_box.is_open()
	assert_true(await wait_until(closed, 30.0), "the conversation ends")
	await wait_physics_frames(2)


# --- The pillar and its shadow ------------------------------------------------------------------


func test_every_pillar_of_the_garden_shows_the_shadow_to_whoever_is_back() -> void:
	_back()
	var scene := await _scene(ELYSIA)
	var count := _props(scene, "pillar").size()
	assert_gte(count, 2, "the pillar stands at least twice, mirrored")
	assert_eq(count % 2, 0, "and every one has its twin")
	for index in count:
		assert_eq(await _talk(scene, "pillar", index), "pillar_back", "pillar %d" % index)
		await _through(scene)
		assert_true(Collection.has_fragment("still_shadow"))
		WorldState.clear_flag("fragment.still_shadow")


func test_whoever_has_not_come_back_finds_the_pillar_as_it_was() -> void:
	var scene := await _scene(ELYSIA)
	assert_eq(await _talk(scene, "pillar"), "pillar", "Act I's description")
	await _through(scene)
	assert_false(Collection.has_fragment("still_shadow"), "no trace without the way back")


# --- The basin and the pebble -------------------------------------------------------------------


func test_the_basin_gives_a_pebble_once_and_playing_in_it_is_still_playing() -> void:
	_back()
	var scene := await _scene(ELYSIA)
	assert_eq(await _talk(scene, "basin"), "basin_back")
	await _through(scene, PackedStringArray(["Einen Kiesel vom Grund holen."]))
	assert_eq(WorldState.item_count("curiosity_basin_pebble"), 1, "she holds the pebble")
	assert_false(WorldState.has_facet("aliveness"), "taking is not playing")
	# the answer is gone, the others stay: the water still asks to be played in
	assert_eq(await _talk(scene, "basin"), "basin_back")
	await _through(scene, PackedStringArray(["Wasser spritzen."]))
	assert_true(WorldState.has_facet("aliveness"), "playing still sets what it set")
	assert_eq(WorldState.item_count("curiosity_basin_pebble"), 1, "and takes no second pebble")


# --- The fountain and the coin ------------------------------------------------------------------


func test_the_fountain_gives_a_coin_to_whoever_is_back_and_keeps_its_old_cue_for_the_rest() -> void:
	_back()
	var scene := await _scene(MARKT)
	assert_eq(await _talk(scene, "fountain"), "fountain_back")
	await _through(scene, PackedStringArray(["Eine Münze vom Grund fischen."]))
	assert_eq(WorldState.item_count("curiosity_fountain_coin"), 1)
	assert_true(WorldState.has_flag("elysia.coin_taken"))


func test_the_fountain_of_act_one_is_unchanged_for_whoever_has_not_come_back() -> void:
	var scene := await _scene(MARKT)
	assert_eq(await _talk(scene, "fountain"), "fountain", "the old cue")
	await _through(scene)
	assert_eq(WorldState.item_count("curiosity_fountain_coin"), 0)


# --- The inn: the guest book and the table ------------------------------------------------------


func test_the_guest_book_gives_the_stub_only_after_it_is_signed() -> void:
	_back()
	WorldState.set_flag("elysia.inn_book_signed")
	var scene := await _scene(GASTHAUS)
	assert_eq(await _talk(scene, "guestbook"), "guestbook_back")
	await _through(scene, PackedStringArray(["Den Stummel abbinden."]))
	assert_eq(WorldState.item_count("curiosity_guest_pencil"), 1)


func test_the_guest_book_that_is_not_signed_keeps_the_signing_of_act_one() -> void:
	_back()
	var scene := await _scene(GASTHAUS)
	assert_eq(await _talk(scene, "guestbook"), "guestbook", "the signing is not taken away")
	await _through(scene)
	assert_eq(WorldState.item_count("curiosity_guest_pencil"), 0)


func test_the_table_in_the_inn_shows_its_rings_to_whoever_is_back_and_stands_for_nobody_else(
) -> void:
	_back()
	var scene := await _scene(GASTHAUS)
	assert_eq(await _talk(scene, "table_look"), "table_look")
	await _through(scene)
	assert_true(Collection.has_fragment("table_rings"))
	WorldState.clear_flag("elysia.returned")
	var other := await _scene(GASTHAUS)
	assert_eq(_props(other, "table_look").size(), 0, "no table without the way back")
