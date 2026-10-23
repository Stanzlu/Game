# gdlint: ignore=max-public-methods
extends GutTest
## Phase 4, the house: the note at the cold fireplace sends the player for wood (and opens
## the west path), dry wood lights the fire, the room warms, Mira knocks; the spoon goes
## on the shelf and the shelf shows it.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const PICKUP := preload("res://world/props/pickup.tscn")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	Settings.set_value("display.reduce_flashing", false, false)


func _scene(mira_after := 0.2) -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = mira_after
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _prop(scene: GameScene, prefix: String) -> Node:
	for node in scene.map.entities.get_children():
		if str(node.name).begins_with(prefix):
			return node
	return null


func test_entering_without_mira_still_starts_the_shelter_quest() -> void:
	await _scene()
	assert_eq(WorldState.quest_stage("main_valley_shelter"), "house")
	assert_true(Beat.reached("house_entered"))


func test_the_cold_house_has_no_cat_and_no_mira() -> void:
	var scene := await _scene()
	assert_false((_prop(scene, "Fireplace") as Node).get(&"lit"))
	assert_null(_prop(scene, "NpcWalker"), "Mira comes later")
	var cats := scene.map.entities.get_children().filter(
		func(n: Node) -> bool: return n is Decor and (n as Decor).sprite_id.begins_with("haus/cat")
	)
	assert_eq(cats.size(), 0)


func test_fire_warms_the_room_and_mira_knocks() -> void:
	# lines advance on their own, as with the "auto advance" setting
	Settings.set_value("text.auto_advance", true, false)
	var scene := await _scene()
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	assert_true(WorldState.has_flag("house.fire_lit"))
	assert_true(Beat.reached("fire"))
	assert_true((_prop(scene, "Fireplace") as Node).get(&"lit"), "the flames are there")
	await wait_seconds(1.6)
	assert_true(scene.dialogue_box.is_open(), "it knocks")
	await wait_until(func() -> bool: return WorldState.has_flag("house.mira_seated"), 20.0)
	Settings.set_value("text.auto_advance", false, false)
	assert_true(WorldState.has_flag("house.mira_knocked"), "Mira comes in")
	assert_not_null(_mira(scene), "Mira sits by the fire")
	assert_true(Beat.reached("mira_visit"))


## Mira's seat on the map (an NpcWalker with the cue "mira"), or null.
func _mira(scene: GameScene) -> NpcWalker:
	for node in scene.map.entities.get_children():
		if node is NpcWalker and (node as NpcWalker).cue == "mira" and node.visible:
			return node as NpcWalker
	return null


func _guests(scene: GameScene) -> Array[Node]:
	return scene.map.entities.find_children("*", "GuestWalker", true, false)


## Picks the first allowed answer whenever one is asked, until `done` holds.
func _answer_until(scene: GameScene, done: Callable, timeout: float) -> void:
	var box := scene.dialogue_box
	var picker := func() -> bool:
		if box.is_open() and box.line != null and not box.line.responses.is_empty():
			if box._responses.visible:
				for response: DialogueResponse in box.line.responses:
					if response.is_allowed:
						box._responses.response_selected.emit(response)
						break
		return done.call()
	await wait_until(picker, timeout)


func test_mira_comes_in_sits_down_and_goes_in_the_room() -> void:
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)
	var scene := await _scene()
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	var order: Array[String] = []
	var at_seated := {}
	var at_left := {}
	WorldState.flag_changed.connect(
		func(id: String, value: bool) -> void:
			if (
				not value
				or not id in ["house.mira_knocked", "house.mira_seated", "house.mira_left"]
			):
				return
			order.append(id)
			var state := {
				"beat": Beat.reached("mira_visit"),
				"visited": WorldState.has_flag("house.mira_visited")
			}
			if id == "house.mira_seated":
				at_seated.merge(state)
			elif id == "house.mira_left":
				at_left.merge(state)
	)
	# a lambda copies plain variables: what it notes goes into a dictionary
	var seen := {"dark": false, "walked_in": false, "glare": 0.0}
	var done := func() -> bool:
		# nobody blacks the picture out for her: she is seen coming and going
		seen["dark"] = seen["dark"] or ScreenFade.is_covered() or ScreenFade.is_fading()
		seen["walked_in"] = seen["walked_in"] or not _guests(scene).is_empty()
		seen["glare"] = maxf(seen["glare"], scene._window_light.energy)
		return WorldState.has_flag("house.mira_left")
	await _answer_until(scene, done, 90.0)
	assert_eq(order, ["house.mira_knocked", "house.mira_seated", "house.mira_left"])
	assert_true(seen["walked_in"], "a visitor walks through the room")
	assert_false(seen["dark"], "no black screen at any time")
	assert_gt(seen["glare"], HausScene.WINDOW_ENERGY + 0.2, "the window light swells at the door")
	assert_false(at_seated["beat"], "she has sat down before the talk begins")
	assert_true(at_left["beat"], "the talk is over when she is gone")
	assert_true(at_left["visited"])
	await wait_physics_frames(3)
	assert_eq(_guests(scene).size(), 0, "the guest is gone")
	assert_null(_mira(scene), "and so is her seat")
	await wait_until(func() -> bool: return not scene.player.is_locked(), 5.0)
	assert_false(scene.player.is_locked(), "the player is free again")


func test_the_visit_cannot_be_saved_while_the_antreiber_comes() -> void:
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)
	WorldState.set_flag("valley.wood_taken")
	var scene := await _scene(120.0)
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	scene.player.sit_on(scene.map.cell_to_world(Vector2i(17, 11)), Facing.Dir.N)
	var coming := func() -> bool:
		return not scene.map.entities.find_children("*", "AntreiberActor", true, false).is_empty()
	await wait_until(coming, 20.0)
	assert_true("antreiber_visit" in SaveSystem.blockers(), "he walks in: no saving now")
	await _answer_until(
		scene, func() -> bool: return WorldState.has_flag("house.antreiber_by_fire"), 40.0
	)
	await wait_physics_frames(3)
	assert_false("antreiber_visit" in SaveSystem.blockers(), "free again once he sits")


func test_after_loading_the_rest_by_the_fire_is_not_told_again() -> void:
	# the state of a save made during the Antreiber's visit: the rest was told, he is pending
	Settings.set_value("text.auto_advance", true, false)
	Settings.set_value("text.speed", 3, false)
	WorldState.set_flag("valley.wood_taken")
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	WorldState.set_flag("house.fire_lit")
	WorldState.set_flag("house.rested")
	var scene := await _scene(120.0)
	scene.player.sit_on(scene.map.cell_to_world(Vector2i(17, 11)), Facing.Dir.N)
	var spoken: Array[String] = []
	var watch := func() -> bool:
		var box := scene.dialogue_box
		if box.is_open() and box.line != null:
			if spoken.is_empty() or spoken.back() != box.line.text:
				spoken.append(box.line.text)
		return WorldState.has_flag("house.antreiber_by_fire")
	await wait_until(watch, 40.0)
	assert_false(spoken.is_empty())
	assert_true(
		spoken[0].begins_with("Wir könnten noch Holz"),
		"he comes at once, the rest by the fire is not told again: " + spoken[0]
	)
	for text in spoken:
		assert_false(text.begins_with("Du sitzt"), "no second fire_rest: " + text)


func test_mira_does_not_knock_into_the_black_after_loading() -> void:
	Settings.set_value("text.speed", 3, false)
	WorldState.set_fire_lit(true)
	WorldState.set_flag("house.fire_lit")
	WorldState.set_flag("house.rested")
	await ScreenFade.fade_out(0.0)
	var scene := HAUS.instantiate()
	add_child_autofree(scene)
	# the picture comes back over two seconds; the knock must wait for it, and then a moment
	# counted in game time (the predicate runs once per physics tick), never by the wall clock
	var marks := {"faded": -1.0, "knocked": -1.0, "now": 0.0}
	var watch := func() -> bool:
		marks["now"] += get_physics_process_delta_time()
		var now: float = marks["now"]
		if marks["faded"] < 0.0 and not ScreenFade.is_covered() and not ScreenFade.is_fading():
			marks["faded"] = now
		if scene.dialogue_box.is_open():
			marks["knocked"] = now
		return marks["knocked"] >= 0.0
	await wait_until(watch, 12.0)
	assert_gt(marks["knocked"], 0.0, "it knocks")
	assert_gt(marks["faded"], 0.0, "after the picture was back")
	assert_gt(
		marks["knocked"] - marks["faded"], HausScene.AFTER_LOAD_CALM, "and after a moment of quiet"
	)


func test_the_evening_house_has_no_rain_on_the_roof_and_a_warm_window() -> void:
	WorldState.set_fire_lit(true)
	var scene := await _scene()
	assert_eq(scene.ambience, HausScene.WARM_AMBIENCE, "rain on the roof by day")
	assert_eq(scene._window_light.color, HausScene.WINDOW_LIGHT)
	WorldState.set_day_preset("abend")
	var evening := await _scene()
	assert_eq(evening.ambience, HausScene.EVENING_AMBIENCE, "fire and crickets at night fall")
	assert_eq(evening._window_light.color, HausScene.WINDOW_LIGHT_EVENING)
	assert_lt(evening._window_light.energy, HausScene.WINDOW_ENERGY)
	var beds: Array = []
	for bed: Dictionary in (HausScene.EVENING_AMBIENCE as SoundscapeDef).beds:
		beds.append(bed["sound"])
	assert_false("roof" in beds)
	assert_eq((HausScene.EVENING_AMBIENCE as SoundscapeDef).problems().size(), 0)


func test_the_fire_flares_up_when_it_catches() -> void:
	var scene := await _scene()
	var fireplace := _prop(scene, "Fireplace") as Fireplace
	assert_eq(fireplace._decor.sprite_id, "haus/fireplace_cold")
	WorldState.add_item("item_dry_wood", 1, false)
	WorldState.set_fire_lit(true)
	await wait_physics_frames(2)
	assert_true(fireplace.lit)
	assert_eq(fireplace._decor.sprite_id, "haus/fireplace_cold", "the wood lands first")
	assert_null(fireplace.get_node_or_null("Embers"))
	await wait_seconds(Fireplace.IGNITE_DELAY + 0.3)
	assert_eq(fireplace._decor.sprite_id, "haus/fireplace_lit")
	assert_not_null(fireplace.get_node_or_null("FlareLight"), "the light flares")
	assert_not_null(fireplace.get_node_or_null("Embers"), "embers fly up")
	await wait_seconds(Fireplace.FLARE_SECONDS + 0.3)
	assert_null(fireplace.get_node_or_null("FlareLight"), "and settles")


func test_reduced_flashing_leaves_out_the_flare() -> void:
	Settings.set_value("display.reduce_flashing", true, false)
	var scene := await _scene()
	var fireplace := _prop(scene, "Fireplace") as Fireplace
	WorldState.set_fire_lit(true)
	await wait_seconds(Fireplace.IGNITE_DELAY + 0.3)
	assert_eq(fireplace._decor.sprite_id, "haus/fireplace_lit")
	assert_null(fireplace.get_node_or_null("FlareLight"))


func _sounds(scene: GameScene) -> Array[String]:
	var found: Array[String] = []
	for player in scene.map.entities.find_children("*", "AudioStreamPlayer2D", true, false):
		# the one-shots of SoundBank, not the loops of the props (the fire's crackle)
		var randomizer := (player as AudioStreamPlayer2D).stream as AudioStreamRandomizer
		if randomizer != null:
			found.append(randomizer.get_stream(0).resource_path.get_file().get_basename())
	return found


func _looked_at(scene: GameScene, cue: String) -> void:
	for node in scene.map.entities.get_children():
		if node is Decor and node.get_meta(&"cue", "") == cue and not node.is_queued_for_deletion():
			(
				((node as Decor).find_children("*", "Interactable", true, false)[0] as Interactable)
				. interacted
				. emit(scene.player)
			)
			return


func test_the_cat_is_heard() -> void:
	WorldState.set_fire_lit(true)
	WorldState.set_flag("house.fire_lit")
	var scene := await _scene()
	_looked_at(scene, "cat")
	await wait_physics_frames(2)
	assert_true("cat_meow_muffled" in _sounds(scene), "muffled through the window pane")
	WorldState.add_item("item_fish", 1, false)
	WorldState.set_flag("house.cat_fed")
	await wait_physics_frames(2)
	assert_true("cat_meow_0" in _sounds(scene) or "cat_meow_1" in _sounds(scene), "inside")
	_looked_at(scene, "cat")
	await wait_physics_frames(2)
	assert_true("purr" in _sounds(scene), "asleep by the fire she purrs")


func test_a_name_makes_her_purr() -> void:
	WorldState.set_flag("house.cat_fed")
	var scene := await _scene()
	assert_false("purr" in _sounds(scene))
	WorldState.set_cat_name("Pfote")
	await wait_physics_frames(2)
	assert_true("purr" in _sounds(scene))


func test_picking_up_wood_is_heard() -> void:
	var holder := Node2D.new()
	add_child_autofree(holder)
	var pickup: Node2D = PICKUP.instantiate()
	holder.add_child(pickup)
	pickup.global_position = Vector2(30, 40)
	pickup.call(
		&"apply_params",
		{"item": "item_dry_wood", "flag": "valley.wood_taken", "sound": "wood_drop"}
	)
	(pickup.get_node("Interactable") as Interactable).interacted.emit(null)
	await wait_physics_frames(2)
	var heard := holder.find_children("*", "AudioStreamPlayer2D", true, false)
	assert_eq(heard.size(), 1, "the sound stays when the wood is gone")
	var randomizer := (heard[0] as AudioStreamPlayer2D).stream as AudioStreamRandomizer
	assert_true(randomizer.get_stream(0).resource_path.ends_with("wood_drop.wav"))
	assert_true(WorldState.has_item("item_dry_wood"))


func test_the_guest_walks_sits_and_stands() -> void:
	var holder := Node2D.new()
	add_child_autofree(holder)
	var guest := GuestWalker.create(load("res://entities/character/sheet_mira_look.tres"))
	holder.add_child(guest)
	await wait_physics_frames(1)
	var way: Array[Vector2] = [Vector2(20, 0), Vector2(20, 20)]
	await guest.walk_to(way, 200.0)
	assert_eq(guest.global_position, Vector2(20, 20))
	assert_eq(guest.facing, Facing.Dir.S, "she looks the way she last went")
	guest.sit_down(Facing.Dir.E)
	assert_eq(guest.sprite.animation, CharacterSheet.animation_name("sit", Facing.Dir.E))
	guest.stand_up()
	assert_eq(guest.sprite.animation, CharacterSheet.animation_name("idle", Facing.Dir.E))


func test_the_house_is_seen_closer_than_everywhere_else() -> void:
	var scene := await _scene()
	assert_eq(scene.view.zoom, 1.5)
	var room := Vector2(HausScene.ROOM.size * scene.map.data.tile_size)
	# the room fits the view on a 640x360 window and on any larger one (same picture, scaled)
	assert_lt(room.x * scene.view.zoom, 640.0)
	assert_lt(room.y * scene.view.zoom, 360.0)
	var centre := Vector2(HausScene.ROOM.get_center() * scene.map.data.tile_size)
	assert_lt(scene.view.camera_position.distance_to(centre), 1.5, "the room stays centred")
	var tal: Node = (load("res://world/levels/slice/tal.tscn") as PackedScene).instantiate()
	assert_eq(tal.get("view_zoom"), 1.25, "ADR-045 stays for everything but the interior")
	tal.free()


func _shelves(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool:
			return (
				node is Decor
				and (node as Decor).sprite_id.begins_with("haus/shelf")
				and not node.is_queued_for_deletion()
			)
	)


func test_the_spoon_goes_on_the_shelf() -> void:
	var scene := await _scene()
	assert_eq((_shelves(scene)[0] as Decor).sprite_id, "haus/shelf")
	WorldState.add_item("curiosity_tiny_spoon", 1, false)
	assert_true(WorldState.place_curiosity("shelf_1", "curiosity_tiny_spoon"))
	WorldState.set_flag("house.shelf_filled")
	var shelves := _shelves(scene)
	assert_eq(shelves.size(), 1, "rebuilt with the new look, not doubled")
	assert_eq(
		(shelves[0] as Decor).sprite_id, "haus/shelf_spoon", "the shelf shows the spoon at once"
	)
	assert_not_null(shelves[0].get_node_or_null("Interactable"), "can still be looked at")


func _count(scene: GameScene, prefix: String) -> int:
	var count := 0
	for node in scene.map.entities.get_children():
		if str(node.name).begins_with(prefix) and not node.is_queued_for_deletion():
			count += 1
	return count


func test_the_door_waits_for_mira_after_the_fire() -> void:
	var scene := await _scene()
	assert_eq(_count(scene, "Blocker"), 0, "free to go before the fire")
	WorldState.set_flag("house.fire_lit")
	assert_eq(_count(scene, "Blocker"), 1, "nobody misses Mira's visit by walking out")
	WorldState.set_flag("house.mira_visited")
	assert_eq(_count(scene, "Blocker"), 0, "open again after her visit")


# --- Texts (text and puzzle pass, 10.10.) ----------------------------------------------


## Plays `cue` to its end, picking the first allowed answer that contains `pick`.
func _play(cue: String, pick := "") -> PackedStringArray:
	var resource := load(HausScene.DIALOGUE) as DialogueResource
	var seen: PackedStringArray = []
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null:
		seen.append(line.text)
		var next_id := line.next_id
		if not line.responses.is_empty():
			var chosen: DialogueResponse = null
			for r: DialogueResponse in line.responses:
				if r.is_allowed and (chosen == null or (not pick.is_empty() and pick in r.text)):
					chosen = r
			seen.append(chosen.text)
			next_id = chosen.next_id
		line = await DialogueManager.get_next_dialogue_line(resource, next_id)
	return seen


func test_the_shelf_counts_its_free_spaces() -> void:
	WorldState.add_item("item_stone", 1, false)
	var seen := await _play("shelf", "Nichts")
	assert_true("Zwei Fächer sind ganz leer" in seen[0])
	assert_true("Beide gerade groß genug für etwas Kleines." in seen, "both are free")
	assert_true("Du behältst den Stein. Das Fach kann warten." in seen, "no spoon joke")
	seen = await _play("shelf", "Stein")
	assert_eq(WorldState.curiosity_in("shelf_2"), "item_stone")
	seen = await _play("shelf")
	assert_eq(
		seen[0], "Im Regal liegt der Stein. Er glänzt nicht. Er liegt einfach gut da.", "alone"
	)
	WorldState.add_item("curiosity_tiny_spoon", 1, false)
	seen = await _play("shelf", "Nichts")
	assert_true("Ein Fach ist noch frei, gerade groß genug für etwas Kleines." in seen)
	assert_true("Du behältst den Löffel. Für sehr kleine Suppen, vielleicht." in seen)


func test_mira_disagrees_about_her_fish() -> void:
	var seen := await _play("mira_visit", "beste Fisch")
	assert_true("Nein. Der war zu lang im Feuer." in seen, "Game Bible §56: Mira widerspricht")
	assert_true(WorldState.has_memory("mira", "praised_fish"))
	assert_ne(tr("MEMORY_MIRA_PRAISED_FISH"), "MEMORY_MIRA_PRAISED_FISH", "in the journal")
	WorldState.new_game()
	seen = await _play("mira_visit", "…")
	assert_true("Ihr esst. Der Regen trommelt aufs Dach." in seen)
	assert_true(WorldState.has_memory("mira", "ate_quietly"))


func test_mira_finds_a_free_place_next_to_the_antreiber() -> void:
	WorldState.set_flag("house.antreiber_by_fire")
	var seen := await _play("mira_visit")
	assert_true(
		(
			(
				"Der Antreiber ist ein Stück zur Seite gerückt. Mira sitzt auf dem freien Platz,"
				+ " als wäre er immer frei gewesen."
			)
			in seen
		)
	)


func test_the_bucket_by_the_fire() -> void:
	assert_eq((await _play("bucket")).size(), 1)
	WorldState.set_fire_lit(true)
	assert_eq(
		await _play("bucket"),
		PackedStringArray(["Es tropft in den Eimer. Plink. Lange nichts. Plink."])
	)
