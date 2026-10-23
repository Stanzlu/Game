extends GutTest
## The key layout page ("Tastenbelegung"): its rows, cells, sections and column, the second page
## and the way through it with keys only and with a pad only.

const Helpers := preload("res://tests/unit/controls_helpers.gd")
const SANDBOX := preload("res://world/levels/sandbox.tscn")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	get_tree().paused = false


func _open() -> ControlsMenu:
	var menu := ControlsMenu.new()
	add_child_autofree(menu)
	menu.open()
	await wait_physics_frames(3)
	return menu


func _send(event: InputEvent) -> void:
	Input.parse_input_event(event)


## A press and its release a little later, as a finger does it.
func _tap(down: InputEvent, up: InputEvent) -> void:
	_send(down)
	await wait_physics_frames(2)
	_send(up)
	await wait_physics_frames(2)


func _tap_action(name: StringName) -> void:
	await _tap(Helpers.action(name), Helpers.action(name, false))


func _tap_key(code: int) -> void:
	await _tap(Helpers.key(code), Helpers.key(code, false))


func _tap_pad(button: int) -> void:
	await _tap(Helpers.pad_button(button), Helpers.pad_button(button, false))


func _sandbox() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	for frame in 120:
		if MenuLayer.can_pause(get_tree()):
			break
		await wait_physics_frames(1)
	return scene


func test_page_has_nine_keyboard_and_five_pad_rows() -> void:
	var menu := await _open()
	var headers: Array[String] = []
	for node in menu.list.get_children():
		if node is Label and (node as Label).theme_type_variation == &"MutedLabel":
			headers.append((node as Label).text)
	assert_eq(headers, ["BIND_KEYBOARD", "BIND_PAD"], "two sections")
	for action in ControlsMenu.KEYBOARD_ROWS:
		assert_not_null(menu.row_for(action, KB), "keyboard row " + action)
	assert_eq(ControlsMenu.KEYBOARD_ROWS.size(), 9)
	assert_eq(ControlsMenu.GAMEPAD_ROWS.size(), 5)
	for action in ControlsMenu.GAMEPAD_ROWS:
		assert_not_null(menu.row_for(action, PAD), "pad row " + action)
	for walk: StringName in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		assert_false(ControlsMenu.GAMEPAD_ROWS.has(walk), "the pad walks with the stick")
		assert_null(menu.row_for(walk, PAD))
	var texts := Helpers.button_texts(menu)
	assert_eq(texts.size(), 9 + 5 + 3, "the rows, Weitere Tasten, Alles auf Standard, Zurück")
	assert_eq(texts.slice(-3), [tr("BIND_MORE_PAGE"), tr("BIND_RESET_ALL"), tr("MENU_BACK")])
	for action in ControlsMenu.KEYBOARD_ROWS:
		for cell in InputBindings.SLOTS:
			var text := menu.cell_text(action, KB, cell)
			assert_false(text.contains("?") or text.contains("Pad "), action + ": " + text)
	for action in ControlsMenu.GAMEPAD_ROWS:
		for cell in InputBindings.SLOTS:
			var text := menu.cell_text(action, PAD, cell)
			assert_false(text.contains("?") or text.contains("Pad "), action + ": " + text)


func test_rows_show_slots_and_fixed_keys() -> void:
	var menu := await _open()
	assert_eq(menu.cell_text(&"interact", KB, 0), "E")
	assert_eq(menu.cell_text(&"interact", KB, 1), "Leertaste")
	assert_eq(menu.fixed_text(&"interact", KB), "Enter", "Enter and the keypad's Enter are one")
	assert_eq(menu.fixed_text(&"cancel", KB), "Esc")
	assert_eq(menu.cell_text(&"cancel", KB, 0), "Backspace")
	assert_eq(menu.cell_text(&"cancel", KB, 1), BindingRow.EMPTY_TEXT)
	assert_eq(menu.fixed_text(&"menu", PAD), "Start")
	assert_eq(menu.cell_text(&"menu", PAD, 0), BindingRow.EMPTY_TEXT)
	assert_eq(menu.cell_text(&"menu", PAD, 1), BindingRow.EMPTY_TEXT)
	assert_eq(menu.fixed_text(&"interact", PAD), "A", "A confirms in every menu")
	assert_eq(menu.cell_text(&"sprint", PAD, 0), "X")
	assert_eq(menu.cell_text(&"sprint", PAD, 1), "RT")
	assert_eq(menu.fixed_text(&"move_up", KB), "", "walking has no pinned key on the keyboard")
	InputDevice.style = InputDevice.Style.PLAYSTATION
	menu.refresh_cells()
	assert_eq(
		menu.cell_text(&"sprint", PAD, 0), "Quadrat", "the body font has no PlayStation glyphs"
	)
	assert_eq(menu.fixed_text(&"interact", PAD), "Kreuz")
	InputDevice.style = InputDevice.Style.XBOX


func test_the_pad_section_comes_first_for_pad_players() -> void:
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	var menu := await _open()
	var pad_row := menu.row_for(&"sprint", PAD).button
	var key_row := menu.row_for(&"move_up", KB).button
	assert_lt(pad_row.get_index(), key_row.get_index(), "controller first")
	var first_header: Label = null
	for node in menu.list.get_children():
		if node is Label:
			first_header = node
			break
	assert_eq(first_header.text, "BIND_PAD")
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	await wait_physics_frames(2)
	assert_lt(pad_row.get_index(), key_row.get_index(), "the order is not changed while open")
	menu.close()
	menu.open()
	await wait_physics_frames(2)
	assert_lt(
		menu.row_for(&"move_up", KB).button.get_index(),
		menu.row_for(&"sprint", PAD).button.get_index(),
		"decided again when it opens"
	)


func test_left_right_move_between_cells_and_stop_at_the_free_one() -> void:
	var menu := await _open()
	# a row that cannot show cell 2 does not take the column along
	Helpers.focus(menu, &"menu", PAD)
	menu.row_for(&"menu", PAD).button.gui_input.emit(Helpers.action(&"ui_right"))
	Helpers.focus(menu, &"interact", KB)
	assert_eq(
		menu.selected_cell(&"interact", KB), 0, "Right on a row without a second cell: nothing"
	)
	Helpers.focus(menu, &"interact", KB)
	assert_eq(menu.selected_cell(&"interact", KB), 0)
	var button := menu.row_for(&"interact", KB).button
	button.gui_input.emit(Helpers.action(&"ui_right"))
	assert_eq(menu.selected_cell(&"interact", KB), 1)
	button.gui_input.emit(Helpers.action(&"ui_right"))
	assert_eq(menu.selected_cell(&"interact", KB), 1, "two cells, no third")
	button.gui_input.emit(Helpers.action(&"ui_left"))
	assert_eq(menu.selected_cell(&"interact", KB), 0)
	# Zurück has one key: the second cell is the free one, the first to be reached
	Helpers.focus(menu, &"cancel", KB)
	menu.row_for(&"cancel", KB).button.gui_input.emit(Helpers.action(&"ui_right"))
	assert_eq(menu.selected_cell(&"cancel", KB), 1)
	# Pause on the pad has no key of its own: only the first cell can be reached
	Helpers.focus(menu, &"menu", PAD)
	menu.row_for(&"menu", PAD).button.gui_input.emit(Helpers.action(&"ui_right"))
	assert_eq(menu.selected_cell(&"menu", PAD), 0, "the second cell follows the first")


func test_the_column_survives_row_changes_and_clamps_per_row() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"interact", KB)
	menu.row_for(&"interact", KB).button.gui_input.emit(Helpers.action(&"ui_right"))
	Helpers.focus(menu, &"move_up", KB)
	assert_eq(menu.selected_cell(&"move_up", KB), 1, "Up and Down keep the column")
	Helpers.focus(menu, &"menu", PAD)
	assert_eq(menu.selected_cell(&"menu", PAD), 0, "a row with nothing in cell 1 shows cell 0 ...")
	Helpers.focus(menu, &"interact", KB)
	assert_eq(menu.selected_cell(&"interact", KB), 1, "... without losing the column")
	var row := menu.row_for(&"interact", KB)
	assert_eq(row.cell_state(1), BindingRow.State.SELECTED)
	assert_eq(row.cell_state(0), BindingRow.State.FILLED)
	menu.close()
	menu.open()
	await wait_physics_frames(2)
	assert_eq(menu.selected_cell(&"interact", KB), 0, "a page that opens again starts at cell 1")


func test_the_selected_cell_is_clamped_when_the_list_shrinks() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"menu", PAD, 1)
	assert_eq(menu.cell_text(&"menu", PAD, 0), BindingRow.CAPTURE_TEXT, "cell 2 is not free yet")
	menu._input(Helpers.key(KEY_ESCAPE))
	assert_false(menu.is_capturing())
	# two keys on interact, capture on the second, then both are taken away from outside
	Helpers.capture(menu, &"interact", KB, 1)
	assert_eq(Settings.bindings.clear(&"interact", KB, 0), InputBindings.Code.OK)
	assert_eq(Settings.bindings.clear(&"interact", KB, 0), InputBindings.Code.OK)
	menu._input(Helpers.key(KEY_F))
	assert_eq(
		Helpers.slots(&"interact", KB), ["k%d" % KEY_F], "the key went to the first free cell"
	)
	assert_false(menu.is_capturing())


func test_a_hidden_page_does_not_react_and_a_new_one_starts_fresh() -> void:
	var menu := await _open()
	menu.close()
	assert_eq(Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_K)).code, 0)
	assert_eq(menu.cell_text(&"journal", KB, 0), "J", "nothing is shown or measured while hidden")
	menu.open()
	await wait_physics_frames(2)
	assert_eq(menu.cell_text(&"journal", KB, 0), "K", "opening builds it new")


func test_the_second_page_lists_what_the_rows_cannot_show() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"journal", KB)
	var more := menu.list.buttons()[menu.list.buttons().size() - 3]
	assert_eq(more.text, tr("BIND_MORE_PAGE"))
	more.pressed.emit()
	await wait_physics_frames(3)
	var notes := menu._notes
	assert_true(notes.is_open(), "the notes page is open")
	var lines: Array[String] = []
	for node in notes.list.get_children():
		if node is Label and not (node as Label).theme_type_variation == &"MutedLabel":
			lines.append((node as Label).text)
	assert_eq(lines.size(), 7, "one short sentence per fixed key and the three hints")
	assert_true(lines[0].begins_with("Enter") and lines[1].begins_with("Esc"), str(lines))
	assert_true(lines[4].contains("E") and lines[4].contains("A"), "the skip keys: " + lines[4])
	assert_eq(notes.list.buttons().size(), 1, "only Zurück takes the focus")
	await _tap_action(&"cancel")
	assert_false(notes.is_open(), "Esc closes the notes page ...")
	assert_true(menu.is_open(), "... and nothing more")
	menu.close()


func test_back_returns_to_the_pause_menu_and_its_hint_is_current() -> void:
	var scene := await _sandbox()
	await _tap_action(&"menu")
	assert_true(scene.pause_menu.is_open())
	var pages: ControlsMenu = scene.pause_menu.controls_menu
	pages.open()
	await wait_physics_frames(2)
	assert_eq(Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_K)).code, 0)
	await _tap_action(&"cancel")
	assert_false(pages.is_open())
	assert_true(scene.pause_menu.is_open(), "back in the pause menu")
	assert_true(scene.pause_menu.hint.text.contains("K Journal"), scene.pause_menu.hint.text)
	await _tap_action(&"menu")


func test_the_page_opens_from_settings_and_from_the_start_menu() -> void:
	var settings := SettingsMenu.new()
	settings.follow_mode = false
	settings.sound_set = AudioDirectorService.SoundSet.REAL
	add_child_autofree(settings)
	settings.open()
	await wait_physics_frames(2)
	var group: Array[String] = []
	var in_controls := false
	for node in settings.list.get_children():
		if node is Label and (node as Label).theme_type_variation == &"MutedLabel":
			in_controls = (node as Label).text == "SETTINGS_CONTROLS"
		elif node is Button and in_controls:
			group.append((node as Button).text)
	assert_eq(group, [tr("PAUSE_SPRINT"), tr("SETTINGS_SHOW_CONTROLS")], "under Steuerung")
	for button in settings.list.buttons():
		if button.text == tr("SETTINGS_SHOW_CONTROLS"):
			button.pressed.emit()
	await wait_physics_frames(2)
	var page: ControlsMenu = settings._controls
	assert_true(page.is_open())
	assert_false(page.follow_mode, "the start menu's page does not follow the world")
	assert_eq(page.list.sound_skin, AudioDirectorService.SoundSet.REAL)
	page.close()
	settings.close()


func test_keyboard_only_walkthrough() -> void:
	var menu := await _open()
	# down to Rennen, change it to F
	for i in 4:
		await _tap_action(&"ui_down")
	await _tap_action(&"ui_accept")
	assert_true(menu.is_capturing(), "Enter starts the capture")
	menu.capture.armed_in = 0.0
	await _tap_key(KEY_F)
	assert_eq(Helpers.slots(&"sprint", KB), ["k%d" % KEY_F])
	# the second key of Ansehen: Right picks the cell, K goes in, Delete takes it out again
	await _tap_action(&"ui_down")
	await _tap_action(&"ui_right")
	await _tap_action(&"ui_accept")
	menu.capture.armed_in = 0.0
	await _tap_key(KEY_K)
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_E, "k%d" % KEY_K])
	await _tap_key(KEY_DELETE)
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_E], "Delete empties the chosen cell")
	# the reset row is the second but last: ten rows down from Ansehen
	for i in 10:
		await _tap_action(&"ui_down")
	await _tap_action(&"ui_accept")
	var question := menu._confirm
	assert_true(question.is_open(), "the reset asks first")
	await _tap_action(&"ui_up")
	await _tap_action(&"ui_accept")
	assert_false(Settings.bindings.is_overridden(), "everything is back on Standard")
	await _tap_action(&"cancel")
	assert_false(menu.is_open(), "Esc leaves the page")


func test_gamepad_only_walkthrough() -> void:
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	var menu := await _open()
	# the pad section is first: Rennen, then Ansehen
	await _tap_pad(JOY_BUTTON_DPAD_DOWN)
	await _tap_pad(JOY_BUTTON_A)
	assert_true(menu.is_capturing(), "A starts the capture")
	menu.capture.armed_in = 0.0
	# X belongs to Rennen, and Ansehen has a free cell: the question offers to take it
	await _tap_pad(JOY_BUTTON_X)
	assert_false(menu.is_capturing())
	assert_true(menu._confirm.is_open(), "the key belongs to another action")
	await _tap_pad(JOY_BUTTON_DPAD_UP)
	await _tap_pad(JOY_BUTTON_A)
	assert_eq(Helpers.slots(&"interact", PAD), ["b%d" % JOY_BUTTON_X])
	assert_eq(Helpers.slots(&"sprint", PAD).size(), 1, "Rennen keeps the trigger")
	# Y empties the chosen cell again
	await _tap_pad(JOY_BUTTON_Y)
	assert_eq(Helpers.slots(&"interact", PAD), [])
	# Start leaves the page (the pause key)
	await _tap_pad(JOY_BUTTON_START)
	assert_false(menu.is_open(), "Start closes the page")


func test_toggling_large_text_in_settings_keeps_the_focus_with_two_pages_alive() -> void:
	var scene := await _sandbox()
	var pause: PauseMenu = scene.pause_menu
	pause.open()
	var settings: SettingsMenu = pause.settings_menu
	settings.open()
	settings._show_controls()
	settings._controls.close()
	await wait_physics_frames(2)
	var row: Button = null
	for button in settings.list.buttons():
		if button.text == tr("SETTINGS_TEXT_LARGE"):
			row = button
	row.grab_focus()
	Settings.set_value("text.large", true, false)
	await wait_physics_frames(4)
	var focus := get_viewport().gui_get_focus_owner()
	assert_true(settings.list.buttons().has(focus), "the settings menu keeps the focus")
	assert_true(pause.controls_menu.list.buttons().is_empty() or not pause.controls_menu.is_open())
	Settings.set_value("text.large", false, false)
	settings.close()
	pause.close()


func test_a_binding_change_leaves_the_focus_of_the_shown_page_alone() -> void:
	var scene := await _sandbox()
	var pause: PauseMenu = scene.pause_menu
	pause.open()
	pause.controls_menu.open()
	pause.controls_menu.close()
	var settings: SettingsMenu = pause.settings_menu
	settings.open()
	settings._show_controls()
	await wait_physics_frames(3)
	var page: ControlsMenu = settings._controls
	Helpers.focus(page, &"journal", KB)
	var focus := get_viewport().gui_get_focus_owner()
	assert_eq(Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_K)).code, 0)
	await wait_physics_frames(3)
	assert_eq(get_viewport().gui_get_focus_owner(), focus, "the hidden page took nothing")
	assert_eq(page.cell_text(&"journal", KB, 0), "K", "the shown page shows it")
	page.close()
	settings.close()
	pause.close()
