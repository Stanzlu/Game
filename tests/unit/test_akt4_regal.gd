extends GutTest
## Act IV, segment S8: the places for curiosities in the house (docs/akt4/REGIONSBRIEFE.md, O9,
## O14).
## Four slots (two shelves and two pegs on the north wall) that stand once Tess has hung them
## (`house.shelves`): looking at one opens the menu of what the player carries, a pick puts it
## there, a row takes it back; carrying nothing, a line says that nothing stands there. Nothing
## counts and nothing is praised. The homecoming that hangs them is tested in
## test_akt4_heimkehr_szene.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const SLOTS: PackedStringArray = ["shelf_3", "shelf_4", "wall_1", "wall_2"]
const FEATHER := "curiosity_duck_feather"
const STRING := "curiosity_snapped_string"
const POSTER := "curiosity_concert_poster"


func before_each() -> void:
	# the menu pauses the tree, as every menu does: the test goes on while it is open
	process_mode = Node.PROCESS_MODE_ALWAYS
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
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


## The house with the shelves up (the act is over: the homecoming is not played).
func _house() -> HausScene:
	WorldState.set_flag("house.shelves")
	WorldState.set_flag("house.mira_visited")
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func _slots(scene: GameScene) -> Dictionary:
	var found := {}
	for node in scene.map.entities.get_children():
		if node is CuriositySlot and not node.is_queued_for_deletion():
			found[(node as CuriositySlot).slot_id] = node
	return found


func _carry(item: String) -> void:
	assert_gt(WorldState.add_item(item), 0, "carried: " + item)


# --- WorldState --------------------------------------------------------------------------------


func test_a_curiosity_can_be_placed_and_taken_back_and_comes_back_to_the_bag() -> void:
	_carry(FEATHER)
	assert_true(WorldState.place_curiosity("shelf_3", FEATHER))
	assert_eq(WorldState.curiosity_in("shelf_3"), FEATHER)
	assert_false(WorldState.has_item(FEATHER), "it stands there now")
	assert_eq(Collection.curiosities(), 1, "a curiosity on a shelf still counts as one, once")
	assert_true(WorldState.take_curiosity("shelf_3"))
	assert_true(WorldState.has_item(FEATHER))
	assert_eq(WorldState.curiosity_in("shelf_3"), "")
	assert_false(WorldState.take_curiosity("shelf_3"), "nothing there to take")


func test_placing_on_an_occupied_slot_gives_the_old_one_back() -> void:
	_carry(FEATHER)
	_carry(STRING)
	WorldState.place_curiosity("wall_1", FEATHER)
	assert_true(WorldState.place_curiosity("wall_1", STRING))
	assert_eq(WorldState.curiosity_in("wall_1"), STRING)
	assert_true(WorldState.has_item(FEATHER), "the feather is in the bag again")


func test_the_menu_lists_what_may_stand_on_a_shelf_and_is_carried_in_a_fixed_order() -> void:
	assert_eq(ShelfMenu.carried().size(), 0)
	_carry(STRING)
	_carry(FEATHER)
	_carry("item_loaf")
	assert_eq(
		ShelfMenu.carried(),
		PackedStringArray([FEATHER, STRING]),
		"curiosities only, sorted: the loaf is bread"
	)


# --- The slots in the house ---------------------------------------------------------------------


func test_the_four_slots_stand_in_the_house_only_once_the_shelves_are_hung() -> void:
	var scene: HausScene = HAUS.instantiate()
	WorldState.set_flag("house.mira_visited")
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(_slots(scene).size(), 0, "not before Tess has been here")
	WorldState.set_flag("house.shelves")
	await wait_physics_frames(3)
	var slots := _slots(scene)
	for id: String in SLOTS:
		assert_true(slots.has(id), id)
	assert_eq(slots.size(), 4)


func test_with_nothing_to_put_there_a_line_says_that_nothing_stands_there() -> void:
	var scene := await _house()
	var slot: CuriositySlot = _slots(scene)["shelf_3"]
	await wait_until(func() -> bool: return scene.is_quiet(), 10.0)
	(slot.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up: bool = await wait_until(func() -> bool: return scene.dialogue_box.is_open(), 10.0)
	assert_true(up, "the line of an empty place")
	assert_false(MenuLayer.any_open(get_tree()) and scene.get_node_or_null("ShelfMenu") != null)
	assert_eq(slot.item_id(), "")


func test_with_something_carried_the_menu_opens_and_a_pick_puts_it_on_the_slot() -> void:
	_carry(FEATHER)
	var scene := await _house()
	var slot: CuriositySlot = _slots(scene)["shelf_4"]
	await wait_until(func() -> bool: return scene.is_quiet(), 10.0)
	(slot.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	var up: bool = await wait_until(
		func() -> bool: return scene.get_node_or_null("ShelfMenu") != null, 10.0
	)
	assert_true(up, "the menu of what she carries")
	var menu := scene.get_node("ShelfMenu") as ShelfMenu
	assert_eq(menu.slot_id, "shelf_4")
	menu._place(FEATHER)
	await wait_physics_frames(3)
	assert_eq(WorldState.curiosity_in("shelf_4"), FEATHER)
	assert_true(slot.get_node("Icon").visible, "its little picture stands above the board")
	assert_not_null((slot.get_node("Icon") as Sprite2D).texture)
	assert_false(WorldState.has_item(FEATHER))


func test_a_slot_that_holds_something_shows_it_and_the_menu_offers_to_take_it_back() -> void:
	_carry(FEATHER)
	WorldState.place_curiosity("wall_2", FEATHER)
	var scene := await _house()
	var slot: CuriositySlot = _slots(scene)["wall_2"]
	assert_true(slot.get_node("Icon").visible, "shown at once when the house is loaded")
	await wait_until(func() -> bool: return scene.is_quiet(), 10.0)
	(slot.get_node("Interactable") as Interactable).interacted.emit(scene.player)
	await wait_until(func() -> bool: return scene.get_node_or_null("ShelfMenu") != null, 10.0)
	var menu := scene.get_node("ShelfMenu") as ShelfMenu
	menu._take_back()
	await wait_physics_frames(3)
	assert_eq(WorldState.curiosity_in("wall_2"), "")
	assert_true(WorldState.has_item(FEATHER))
	assert_false(slot.get_node("Icon").visible, "the place is bare again")


func test_the_places_are_saved_with_the_house_and_nothing_is_counted_in_the_picture() -> void:
	_carry(POSTER)
	WorldState.place_curiosity("shelf_3", POSTER)
	var encoded := SaveCodec.encode(WorldState.state)
	var back := SaveCodec.decode(encoded)
	assert_true(back.ok, back.error)
	assert_eq(back.state.house.curiosity_slots.get("shelf_3"), POSTER)
	for text: String in ["SHELF_TITLE", "SHELF_TAKE"]:
		assert_ne(tr(text), text, text)
		for digit: String in "0123456789":
			assert_false(tr(text).contains(digit), "no number: " + text)
