extends GutTest
## Pause menu, sprint toggle and NPC attention in real scenes.

const SANDBOX := preload("res://world/levels/sandbox.tscn")
const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const NPC_SCENE := preload("res://entities/npc/npc_walker.tscn")


func _send(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(action: StringName) -> void:
	_send(action, true)
	await wait_physics_frames(2)
	_send(action, false)
	await wait_physics_frames(2)


class FakeCutscene:
	extends Node
	var in_dialogue := false

	func is_open() -> bool:
		return true


func after_each() -> void:
	for action: StringName in [&"move_right", &"sprint"]:
		Input.action_release(action)
	get_tree().paused = false
	Settings.set_value("controls.tuning", 0, false)
	Settings.set_value("controls.sprint_toggle", false, false)
	Settings.set_value("text.large", false, false)
	Settings.set_value("audio.master", 10, false)
	ScreenFade.fade_in(0.0)
	WorldState.new_game()


func _sandbox() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


func test_menu_action_pauses_and_options_apply() -> void:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	await _tap(&"menu")
	assert_true(scene.pause_menu.is_open(), "menu opened")
	assert_true(get_tree().paused, "game paused")
	Settings.set_value("controls.tuning", 2, false)
	assert_eq(scene.player.tuning.display_key, "TUNING_SCHWER", "setting applied to player")
	await _tap(&"menu")
	assert_false(scene.pause_menu.is_open(), "menu closed")
	assert_false(get_tree().paused, "game resumed")


func test_sprint_toggle_latches_until_stopping() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	map.build_from_text("##########\n#@.......#\n##########", "toggle")
	var player: Player = PLAYER_SCENE.instantiate()
	map.entities.add_child(player)
	player.teleport(map.cell_to_world(Vector2i(1, 1)))
	player.sprint_toggle = true
	await wait_physics_frames(2)
	Input.action_press(&"move_right")
	await _tap(&"sprint")
	await wait_seconds(0.4)
	assert_eq(player.state, Player.State.RUN, "toggle keeps running without holding")
	Input.action_release(&"move_right")
	await wait_seconds(0.3)
	Input.action_press(&"move_right")
	await wait_seconds(0.3)
	assert_eq(player.state, Player.State.WALK, "latch released after stopping")


func test_npc_stops_and_looks_at_a_nearby_player() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	map.build_from_text("##########\n#........#\n#........#\n##########", "npc")
	var npc: NpcWalker = NPC_SCENE.instantiate()
	map.entities.add_child(npc)
	npc.position = map.cell_to_world(Vector2i(2, 1))
	npc.apply_params({"route": [[0, 0], [5, 0]]})
	var player: Player = PLAYER_SCENE.instantiate()
	map.entities.add_child(player)
	player.teleport(map.cell_to_world(Vector2i(8, 2)))
	await wait_seconds(0.5)
	assert_false(npc.attending, "walks while the player is far")
	player.teleport(npc.global_position + Vector2(18, 4))
	await wait_physics_frames(3)
	assert_true(npc.attending, "notices the player")
	assert_eq(npc.facing, Facing.from_vector(player.global_position - npc.global_position))
	assert_eq(npc.velocity, Vector2.ZERO)


# --- Menus (Polish round 2) -------------------------------------------------------------


func _scroll_of(menu: MenuLayer) -> ScrollContainer:
	return menu.list.get_parent() as ScrollContainer


func test_large_text_pause_menu_shows_every_row_without_a_scroll_bar() -> void:
	var scene := await _sandbox()
	Settings.set_value("text.large", true, false)
	await _tap(&"menu")
	await wait_physics_frames(4)
	var menu := scene.pause_menu
	var scroll := _scroll_of(menu)
	assert_false(scroll.get_v_scroll_bar().visible, "no scroll bar for eight rows")
	var buttons := menu.list.buttons()
	assert_eq(buttons.size(), 8, "resume, journal, save, load, settings, controls, menu, quit")
	for button in buttons:
		assert_true(scroll.get_global_rect().encloses(button.get_global_rect()), button.text)
	# the same menu stays whole when the text size changes while it is open
	Settings.set_value("text.large", false, false)
	await wait_physics_frames(6)
	Settings.set_value("text.large", true, false)
	await wait_physics_frames(6)
	assert_false(scroll.get_v_scroll_bar().visible, "back in large text: still no bar")
	await _tap(&"menu")


func test_panel_height_follows_the_text_size_after_a_submenu() -> void:
	var scene := await _sandbox()
	await _tap(&"menu")
	var menu := scene.pause_menu
	var normal_height := _scroll_of(menu).custom_minimum_size.y
	menu.settings_menu.open()
	Settings.set_value("text.large", true, false)
	await wait_physics_frames(6)
	menu.settings_menu.close()
	await wait_physics_frames(6)
	assert_gt(
		_scroll_of(menu).custom_minimum_size.y,
		normal_height,
		"the pause panel measured itself again for the larger font"
	)
	await _tap(&"menu")


func test_a_volume_stops_at_its_ends() -> void:
	var scene := await _sandbox()
	var menu := scene.pause_menu.settings_menu
	Settings.set_value("audio.master", 10, false)
	menu.open()
	await wait_physics_frames(2)
	await _tap(&"ui_right")
	assert_eq(Settings.get_int("audio.master"), 10, "10 plus right stays at 10, not mute")
	Settings.set_value("audio.master", 0, false)
	menu.rebuild()
	await wait_physics_frames(2)
	menu.list.focus_first()
	await _tap(&"ui_left")
	assert_eq(Settings.get_int("audio.master"), 0, "0 minus left stays at 0")
	menu.close()


func test_other_choices_still_wrap() -> void:
	var scene := await _sandbox()
	var menu := scene.pause_menu.settings_menu
	menu.open()
	await wait_physics_frames(2)
	var speed_row: Button = null
	for button in menu.list.buttons():
		if button.text == tr("SETTINGS_TEXT_SPEED"):
			speed_row = button
	speed_row.grab_focus()
	Settings.set_value("text.speed", 3, false)
	await _tap(&"ui_right")
	assert_eq(Settings.get_int("text.speed"), 0, "text speed goes round")
	Settings.set_value("text.speed", 1, false)
	menu.close()


func test_pause_menu_has_a_controls_entry_after_settings() -> void:
	var scene := await _sandbox()
	await _tap(&"menu")
	var texts: Array[String] = []
	for button in scene.pause_menu.list.buttons():
		texts.append(button.text)
	var at := texts.find(tr("PAUSE_SETTINGS"))
	assert_eq(texts[at + 1], tr("SETTINGS_SHOW_CONTROLS"))
	assert_eq(texts[at + 2], tr("PAUSE_TO_MENU"))
	scene.pause_menu.controls_menu.open()
	assert_true(scene.pause_menu.controls_menu.is_open())
	await _tap(&"cancel")
	assert_true(scene.pause_menu.is_open(), "back in the pause menu")
	assert_eq(
		scene.pause_menu.hint.text,
		tr("PAUSE_HINT") % [InputDevice.label_for(&"menu"), InputDevice.label_for(&"journal")]
	)
	await _tap(&"menu")


func test_prototype_tuning_is_not_among_the_player_options() -> void:
	var scene := await _sandbox()
	var menu := scene.pause_menu.settings_menu
	menu.open()
	await wait_physics_frames(2)
	var headers: Array[String] = []
	var group := ""
	var in_group: Dictionary = {}
	for row in menu.list.get_children():
		if row is Label and (row as Label).theme_type_variation == &"MutedLabel":
			group = (row as Label).text
			headers.append(group)
		elif row is Button:
			in_group[group] = int(in_group.get(group, 0)) + 1
	assert_eq(in_group["SETTINGS_CONTROLS"], 1, "only the sprint mode under Steuerung")
	assert_eq(headers.count("SETTINGS_DEBUG") > 0, OS.is_debug_build(), "tuning is developer-only")
	menu.close()


func test_the_first_row_of_a_group_brings_its_header_into_view() -> void:
	var scene := await _sandbox()
	Settings.set_value("text.large", true, false)
	var menu := scene.pause_menu.settings_menu
	menu.open()
	await wait_physics_frames(4)
	var scroll := _scroll_of(menu)
	var checked := 0
	# walk the whole list down: whenever a group's first row is focused, its header is on screen
	var buttons := menu.list.buttons()
	for i in buttons.size():
		await _tap(&"ui_down")
		await wait_physics_frames(3)
		var focused := get_viewport().gui_get_focus_owner()
		var at := focused.get_index()
		var above := menu.list.get_child(at - 1) as Label if at > 0 else null
		if above != null and above.theme_type_variation == &"MutedLabel":
			checked += 1
			var inside := above.get_global_rect()
			var window := scroll.get_global_rect()
			assert_true(
				inside.position.y >= window.position.y and inside.end.y <= window.end.y,
				"%s is visible with its first row" % above.text
			)
	assert_gt(checked, 4, "the walk met the groups")
	menu.close()


func test_menu_scroll_bars_are_pixel_thin_in_every_skin() -> void:
	var scene := await _sandbox()
	var scroll := _scroll_of(scene.pause_menu)
	assert_eq(scroll.get_v_scroll_bar().custom_minimum_size.x, 3.0)
	for skin: Theme in [UiSkin.ELYSIA_SKIN, UiSkin.REAL_SKIN]:
		assert_true(skin.has_stylebox(&"grabber", &"VScrollBar"), "the skin draws its own grabber")
		var box := skin.get_stylebox(&"grabber", &"VScrollBar")
		assert_true(box is StyleBoxFlat and not (box as StyleBoxFlat).anti_aliasing)
		assert_true(skin.has_stylebox(&"normal", &"LineEdit"), "and its own text field")


func test_menus_open_while_the_screen_fades_in() -> void:
	var scene := await _sandbox()
	ScreenFade.fade_out(0.0)
	assert_false(MenuLayer.can_pause(get_tree()), "a black screen keeps the menu closed")
	ScreenFade.fade_in(2.0)
	assert_true(ScreenFade.is_fading_in())
	assert_true(MenuLayer.can_pause(get_tree()), "Esc works while the picture comes back")
	assert_true(MenuLayer.can_open(get_tree()))
	ScreenFade.fade_in(0.0)
	ScreenFade.fade_out(2.0)
	assert_false(ScreenFade.is_fading_in())
	assert_false(MenuLayer.can_pause(get_tree()), "fading out still blocks")
	assert_not_null(scene)


func test_pause_opens_while_a_cutscene_only_talks() -> void:
	await _sandbox()
	var cutscene := FakeCutscene.new()
	cutscene.add_to_group(&"cutscene")
	add_child_autofree(cutscene)
	assert_false(MenuLayer.can_pause(get_tree()), "a running cutscene blocks the pause menu")
	cutscene.in_dialogue = true
	assert_true(MenuLayer.can_pause(get_tree()), "while it talks, Esc opens the menu")
	assert_false(MenuLayer.can_open(get_tree()), "the journal stays closed")


func test_a_resting_pointer_does_not_steal_the_focus() -> void:
	var scene := await _sandbox()
	await _tap(&"menu")
	var buttons := scene.pause_menu.list.buttons()
	assert_true(buttons[0].has_focus())
	buttons[2].mouse_entered.emit()
	assert_true(buttons[0].has_focus(), "a menu that opens under a still mouse keeps its focus")
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(4, 0)
	motion.position = Vector2(10, 10)
	Input.parse_input_event(motion)
	await wait_physics_frames(2)
	buttons[2].mouse_entered.emit()
	assert_true(buttons[2].has_focus(), "after the mouse moved, hovering selects")
	await _tap(&"menu")


func test_the_elysia_journal_has_no_ascii_boxes_and_lists_things() -> void:
	var scene := await _sandbox()
	WorldState.set_ui_mode(GameState.UiMode.ELYSIA)
	WorldState.start_quest("side_valley_goat")
	WorldState.add_item("item_stone")
	WorldState.add_item("item_seed")
	await _tap(&"journal")
	await wait_physics_frames(6)
	var journal := scene.journal
	var texts: Array[String] = []
	for button in journal.list.buttons():
		texts.append(button.text)
	assert_true(tr("ITEM_STONE_NAME") in texts, "the stone is listed under Dinge")
	assert_true(tr("ITEM_SEED_NAME") in texts)
	# the quest page: objectives are paragraphs with a gem, never "[ ]" text
	journal.list.focus_first()
	await wait_physics_frames(6)
	var shown := ""
	for label in journal._detail_box.find_children("*", "Label", true, false):
		shown += (label as Label).text + "\n"
	assert_false("[ ]" in shown or "[x]" in shown, "no ASCII check boxes in the gold UI")
	var gems := 0
	for node in journal._detail_box.find_children("*", "Control", true, false):
		gems += int(node is JournalMark)
	assert_gt(gems, 0, "open objectives carry the gem")
	# a thing shows its own line and, in Elysia, its rarity
	var stone := journal.list.buttons()[texts.find(tr("ITEM_STONE_NAME"))]
	stone.grab_focus()
	await wait_physics_frames(6)
	shown = ""
	for label in journal._detail_box.find_children("*", "Label", true, false):
		shown += (label as Label).text + "\n"
	assert_string_contains(shown, tr("ITEM_STONE_DESC"))
	assert_string_contains(shown, tr("HUD_RARITY") % tr("RARITY_NONE"))
	await _tap(&"journal")


func test_the_real_journal_lists_things_without_rarity_and_hides_an_empty_column() -> void:
	var scene := await _sandbox()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	await _tap(&"journal")
	await wait_physics_frames(4)
	assert_eq(scene.journal.list.buttons().size(), 0)
	assert_false(scene.journal._detail_scroll.visible, "an empty journal has no detail column")
	await _tap(&"journal")
	WorldState.add_item("curiosity_tiny_spoon")
	await _tap(&"journal")
	await wait_physics_frames(6)
	assert_true(scene.journal._detail_scroll.visible)
	var shown := ""
	for label in scene.journal._detail_box.find_children("*", "Label", true, false):
		shown += (label as Label).text
	assert_eq(shown, tr("CURIOSITY_TINY_SPOON_DESC"), "the line of the thing, no rarity")
	await _tap(&"journal")


func test_save_slots_show_name_place_and_time() -> void:
	var scene := await _sandbox()
	WorldState.state.player.name = "Kai"
	WorldState.state.player.map = "tal"
	WorldState.state.playtime_seconds = 12 * 60.0 + 5.0
	assert_eq(SaveSystem.write_slot("slot_3", SaveCodec.encode(WorldState.state)), OK)
	var menu := scene.pause_menu.save_menu
	menu.open_mode(SaveMenu.Mode.LOAD)
	await wait_physics_frames(3)
	var card: Button = null
	for button in menu.list.buttons():
		if button.text.begins_with("Kai"):
			card = button
	assert_not_null(card, "the filled slot is a card")
	assert_eq(card.text, "Kai · Das Tal")
	var labels := card.find_children("*", "Label", true, false)
	var lines: Array[String] = []
	for label in labels:
		lines.append((label as Label).text)
	assert_true(tr("SLOT_N") % "3" in lines, "the slot name stands on the right")
	var sub := ""
	for line in lines:
		if " min · " in line:
			sub = line
	assert_true(sub.begins_with("12 min · "), sub)
	assert_true(card.custom_minimum_size.y > 0.0 or card.size.y > 0.0)
	menu.close()
	DirAccess.remove_absolute(SaveSystem.path_for("slot_3"))
	assert_false(FileAccess.file_exists(SaveSystem.path_for("slot_3")))
