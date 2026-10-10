extends GutTest
## Phase 4, the house: the note at the cold fireplace sends the player for wood (and opens
## the west path), dry wood lights the fire, the room warms, Mira knocks; the spoon goes
## on the shelf and the shelf shows it.

const HAUS := preload("res://world/levels/slice/haus.tscn")


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)


func after_each() -> void:
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> HausScene:
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 0.2
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
	await wait_seconds(4.0)
	Settings.set_value("text.auto_advance", false, false)
	assert_true(WorldState.has_flag("house.mira_knocked"), "Mira comes in")
	assert_not_null(_prop(scene, "NpcWalker"), "Mira stands by the fire")
	assert_true(Beat.reached("mira_visit"))


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
				"Der Antreiber rückt ein Stück zur Seite. Mira setzt sich auf den freien Platz,"
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
