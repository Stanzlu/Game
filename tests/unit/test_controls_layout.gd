extends GutTest
## The key layout page on screen: sizes, large text, skins, the footer that never jumps, and
## the autopilot that plays it.

const Helpers := preload("res://tests/unit/controls_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD
## The height of the game's own view: the menus are laid out for this, not for the test window.
const VIEW_HEIGHT := 360.0
const AUTOPILOT := preload("res://tools/autopilot/autopilot.gd")


class Recorder:
	extends Node
	var events: Array[InputEvent] = []

	func _input(event: InputEvent) -> void:
		events.append(event)


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()
	Settings.set_value("text.large", false, false)
	Settings.set_value("display.screen_shake", true, false)
	Settings.set_value("display.reduce_flashing", false, false)
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	get_tree().paused = false


func _open() -> ControlsMenu:
	var menu := ControlsMenu.new()
	add_child_autofree(menu)
	menu.open()
	await wait_physics_frames(4)
	return menu


func _name(action: StringName) -> String:
	return tr(str(ControlsMenu.LABEL_KEYS[action]))


func _le(value: float, limit: float, text := "") -> void:
	assert_true(value <= limit, "%s (%s should not be more than %s)" % [text, value, limit])


func _panel_of(menu: MenuLayer) -> Control:
	return menu.title.get_parent().get_parent() as Control


func test_a_right_click_on_a_cell_clears_it() -> void:
	var menu := await _open()
	var row := menu.row_for(&"interact", KB)
	var click := Helpers.click(MOUSE_BUTTON_RIGHT)
	var inside := row.cell_node(1).get_global_rect().get_center()
	click.position = row.button.get_global_transform().affine_inverse() * inside
	row.button.gui_input.emit(click)
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_E], "the cell under the pointer")
	var left := Helpers.click(MOUSE_BUTTON_LEFT)
	left.position = row.button.get_global_transform().affine_inverse() * inside
	row.button.gui_input.emit(left)
	assert_eq(menu.selected_cell(&"interact", KB), 1, "a left press picks the cell")


func test_the_clear_key_is_named_for_the_player_and_the_machine() -> void:
	var kb := InputDevice.Kind.KEYBOARD
	var xbox := InputDevice.Style.XBOX
	assert_eq(ControlsMenu.clear_label(kb, xbox, "Windows"), "Entf")
	assert_eq(ControlsMenu.clear_label(kb, xbox, "macOS"), "Fn+Löschen", "a Mac has no Entf")
	assert_eq(ControlsMenu.clear_label(InputDevice.Kind.GAMEPAD, xbox, "macOS"), "Y")
	var ps := InputDevice.Style.PLAYSTATION
	assert_eq(ControlsMenu.clear_label(InputDevice.Kind.GAMEPAD, ps, "Linux"), "Dreieck")


func test_a_question_that_was_never_answered_does_not_fire_later() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_E))
	assert_true(menu._confirm.is_open())
	menu.close()
	assert_false(menu._confirm.is_open(), "the page took its question with it")
	menu._confirm.answered.emit(true)
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_J], "an old question has no answer")
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_E, "k%d" % KEY_SPACE])


func test_a_new_binding_changes_the_cells_in_place() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"journal", KB)
	await wait_physics_frames(3)
	var scroll := menu.list.get_parent() as ScrollContainer
	var scrolled := scroll.scroll_vertical
	var first := menu.list.buttons()[0]
	var focused := get_viewport().gui_get_focus_owner()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_K))
	await wait_physics_frames(3)
	assert_eq(menu.list.buttons()[0], first, "no row was built anew")
	assert_eq(get_viewport().gui_get_focus_owner(), focused, "the cursor stays where it was")
	assert_eq(scroll.scroll_vertical, scrolled, "the list does not jump")
	assert_eq(menu.cell_text(&"journal", KB, 0), "K")
	assert_eq(menu.row_for(&"journal", KB).cell_state(0), BindingRow.State.SELECTED)


func test_a_refusal_shakes_the_cell_unless_shaking_is_off() -> void:
	var menu := await _open()
	var panel: Control = menu.row_for(&"journal", KB).cell_node(0).get_child(0)
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_ENTER))
	await wait_seconds(0.05)
	var moved := panel.position.x != 0.0
	await wait_seconds(0.3)
	assert_true(moved, "the cell moved a little")
	assert_eq(panel.position.x, 0.0, "and is back")
	Settings.set_value("display.screen_shake", false, false)
	menu._input(Helpers.key(KEY_ENTER))
	await wait_seconds(0.05)
	assert_eq(panel.position.x, 0.0, "not for players who turned shaking off")
	menu._input(Helpers.key(KEY_ESCAPE))


func test_cells_sit_inside_their_rows_and_line_up() -> void:
	var menu := await _open()
	var right_edges := {}
	var widths := {}
	for action in ControlsMenu.KEYBOARD_ROWS:
		var row := menu.row_for(action, KB)
		var rect := row.button.get_global_rect()
		for cell in InputBindings.SLOTS:
			var inside := row.cell_node(cell).get_global_rect()
			assert_true(rect.encloses(inside), "%s cell %d is inside its row" % [action, cell])
			widths[snappedf(inside.size.x, 0.01)] = true
			assert_eq(inside.size.y, rect.size.y, "a cell is as high as its row")
		right_edges[snappedf(row.cell_node(1).get_global_rect().end.x, 0.01)] = true
	assert_eq(widths.size(), 1, "every cell is as wide as every other")
	assert_eq(right_edges.size(), 1, "the cells stand in two straight columns")


func test_large_text_keeps_the_page_on_screen() -> void:
	Settings.set_value("text.large", true, false)
	var menu := await _open()
	_le(_panel_of(menu).size.x, ControlsMenu.MAX_PANEL_WIDTH, "never wider than 620 px")
	var rows: Array[BindingRow] = []
	for action in ControlsMenu.KEYBOARD_ROWS:
		rows.append(menu.row_for(action, KB))
	for action in ControlsMenu.GAMEPAD_ROWS:
		rows.append(menu.row_for(action, PAD))
	for row in rows:
		var font := row.button.get_theme_font(&"font")
		var size := row.button.get_theme_font_size(&"font_size")
		var name_end := row.button.get_global_rect().position.x + 14.0
		name_end += font.get_string_size(row.button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		_le(name_end, row.content_left(), "the name ends before the keys: " + row.button.text)
		var rect := row.button.get_global_rect()
		for cell in InputBindings.SLOTS:
			assert_true(
				rect.encloses(row.cell_node(cell).get_global_rect()), "inside: " + row.button.text
			)
	var small := Settings.get_bool("text.large")
	assert_true(small, "the page was built with large text")


func test_the_page_is_built_anew_when_the_text_size_changes() -> void:
	var menu := await _open()
	var before := menu.row_for(&"interact", KB).cell_node(0).size
	Settings.set_value("text.large", true, false)
	await wait_physics_frames(4)
	var after := menu.row_for(&"interact", KB).cell_node(0).size
	assert_gt(after.x, before.x, "wider cells for bigger letters")
	assert_gt(after.y, before.y, "and higher")
	Settings.set_value("text.large", false, false)
	await wait_physics_frames(4)
	assert_eq(menu.row_for(&"interact", KB).cell_node(0).size, before, "and back")


func test_no_key_changes_the_size_of_the_page() -> void:
	var menu := await _open()
	var panel := _panel_of(menu)
	var before := panel.size
	var cell_before := menu.row_for(&"journal", KB).cell_node(0).size
	# the widest name a key can have among those that can be bound at all
	var font := menu.row_for(&"journal", KB).button.get_theme_font(&"font")
	var size := menu.row_for(&"journal", KB).button.get_theme_font_size(&"font_size")
	var widest := 0.0
	var widest_code := KEY_F
	var codes: Array[int] = []
	for code in range(0x20, 0x7F):
		codes.append(code)
	for code in range(0x400000, 0x400200):
		codes.append(code)
	for code in codes:
		var data := Helpers.data(code)
		if Settings.bindings.check(&"journal", KB, 0, data).code != InputBindings.Code.OK:
			continue
		var wide := font.get_string_size(InputDevice.key_label(code as Key), 0, -1, size).x
		if wide > widest:
			widest = wide
			widest_code = code
	assert_eq(Settings.bindings.bind(&"journal", KB, 0, Helpers.data(widest_code)).code, 0)
	await wait_physics_frames(3)
	assert_eq(
		panel.size,
		before,
		"the widest key (%s) changed nothing" % menu.cell_text(&"journal", KB, 0)
	)
	assert_eq(menu.row_for(&"journal", KB).cell_node(0).size, cell_before)
	# a long name inside the cells' own width
	Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_F))
	assert_eq(
		(
			Settings
			. bindings
			. bind(&"move_up", KB, 0, Helpers.data(KEY_RIGHT), InputBindings.Resolve.SWAP)
			. code
		),
		InputBindings.Code.OK
	)
	await wait_physics_frames(3)
	assert_eq(menu.cell_text(&"move_up", KB, 0), "Pfeil rechts")
	assert_eq(panel.size, before, "E to Pfeil rechts changed nothing either")


## The names a cell must always have room for, spelled out here and not taken from the page.
func test_the_longest_names_fit_a_cell_untrimmed() -> void:
	var names: Array[String] = ["Pfeil rechts", "Leertaste", "Umschalt", "Backspace"]
	for button: JoyButton in [JOY_BUTTON_X, JOY_BUTTON_Y]:
		names.append(InputDevice.button_label(button, InputDevice.Style.PLAYSTATION, true))
	assert_has(names, "Quadrat")
	assert_has(names, "Dreieck")
	for large: bool in [false, true]:
		Settings.set_value("text.large", large, false)
		var menu := await _open()
		var row := menu.row_for(&"journal", KB)
		var label: Label = row._labels[0]
		var font := label.get_theme_font(&"font")
		var size := label.get_theme_font_size(&"font_size")
		var frame := (row._panels[0] as PanelContainer).get_theme_stylebox(&"panel")
		var inside := row.cell_node(0).size.x - frame.get_minimum_size().x
		for text in names:
			var wide := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			_le(wide, inside, "%s fits the cell (large text %s)" % [text, large])
		menu.close()


func test_the_waiting_cell_pulses_its_fill_and_not_its_dots() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"sprint", KB, 0)
	var panel := menu.row_for(&"sprint", KB).cell_node(0).get_child(0) as PanelContainer
	var label := panel.get_child(0) as Label
	var lowest := 1.0
	for i in 40:
		await wait_physics_frames(2)
		lowest = minf(lowest, panel.self_modulate.a)
		assert_eq(panel.modulate.a, 1.0, "the cell as a whole stays")
		assert_eq(label.modulate.a, 1.0, "the dots keep their strength")
	assert_lt(lowest, 0.8, "the fill pulses")
	assert_gte(lowest, BindingRow.PULSE_LOW - 0.01, "but not below its low point")
	assert_gte(BindingRow.PULSE_LOW, 0.5, "dark dots stay readable on the paler fill")
	menu._input(Helpers.key(KEY_ESCAPE))
	assert_eq(panel.self_modulate.a, 1.0, "back to normal")
	# players who turned flashing off get a steady cell
	Settings.set_value("display.reduce_flashing", true, false)
	Helpers.capture(menu, &"sprint", KB, 0)
	await wait_seconds(0.6)
	assert_eq(panel.self_modulate.a, 1.0)
	menu._input(Helpers.key(KEY_ESCAPE))


func test_the_footer_is_as_high_in_every_state() -> void:
	for large: bool in [false, true]:
		Settings.set_value("text.large", large, false)
		var menu := await _open()
		var panel := _panel_of(menu)
		Helpers.focus(menu, &"journal", KB)
		await wait_physics_frames(2)
		var idle := panel.size
		var footer := menu.hint.size.y
		assert_gt(footer, 0.0)
		menu.list.buttons()[menu.list.buttons().size() - 1].grab_focus()
		await wait_physics_frames(2)
		assert_eq(menu.hint.text, "", "no hint on Zurück")
		assert_eq(panel.size, idle, "an empty footer: same panel, large %s" % large)
		Helpers.capture(menu, &"cancel", KB, 0)
		await wait_physics_frames(2)
		assert_eq(panel.size, idle, "capture: same panel, large %s" % large)
		_le(menu.hint.get_line_count(), 2)
		menu._input(Helpers.key(KEY_ENTER))
		await wait_physics_frames(2)
		assert_eq(panel.size, idle, "message: same panel, large %s" % large)
		assert_eq(menu.hint.size.y, footer, "the footer keeps its height")
		menu._input(Helpers.key(KEY_ESCAPE))
		# one line of text or two: the footer is as high
		menu.hint.text = "a"
		await wait_physics_frames(2)
		var one_line := menu.hint.size.y
		menu.hint.text = "a\nb"
		await wait_physics_frames(2)
		assert_eq(menu.hint.size.y, one_line, "two lines fit where one stood, large %s" % large)
		assert_eq(panel.size, idle)
		# the longest message: both names of a swap
		Settings.bindings.bind(&"cancel", KB, 1, Helpers.data(KEY_F))
		Settings.bindings.bind(
			&"move_right", KB, 0, Helpers.data(KEY_G), InputBindings.Resolve.SWAP
		)
		menu._say(tr("BIND_DONE_SWAP") % [_name(&"cancel"), _name(&"move_right")])
		await wait_physics_frames(2)
		_le(menu.hint.get_line_count(), 2, "even the longest message needs two lines")
		assert_eq(panel.size, idle, "long message: same panel, large %s" % large)
		menu.close()
		Settings.bindings.reset()


func test_the_worst_questions_need_no_scrolling_at_large_text() -> void:
	Settings.set_value("text.large", true, false)
	var menu := await _open()
	var cap := VIEW_HEIGHT - MenuLayer.SCREEN_MARGIN
	# swap: E (Ansehen) with Backspace (Zurück)
	Helpers.capture(menu, &"cancel", KB, 0)
	menu._input(Helpers.key(KEY_E))
	await wait_physics_frames(3)
	var question := menu._confirm
	assert_true(question.is_open())
	assert_eq(
		_panel_of(question).custom_minimum_size.x,
		float(ControlsMenu.QUESTION_WIDTH),
		"the questions of the page are wider than the narrow default"
	)
	_le(question.list.get_combined_minimum_size().y, cap, "swap question")
	question.list.buttons()[1].pressed.emit()
	await wait_physics_frames(2)
	# take: Backspace into a free cell of Journal
	Helpers.capture(menu, &"journal", KB, 1)
	menu._input(Helpers.key(KEY_BACKSPACE))
	await wait_physics_frames(3)
	assert_true(question.is_open())
	_le(question.list.get_combined_minimum_size().y, cap, "take question")
	question.list.buttons()[1].pressed.emit()
	await wait_physics_frames(2)
	# reset
	Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_K))
	menu.list.buttons()[menu.list.buttons().size() - 2].pressed.emit()
	await wait_physics_frames(3)
	assert_true(question.is_open())
	_le(question.list.get_combined_minimum_size().y, cap, "reset question")
	question.list.buttons()[1].pressed.emit()
	await wait_physics_frames(2)


func test_both_skins_have_styles_for_the_cells() -> void:
	var colors := {}
	for mode: GameState.UiMode in [GameState.UiMode.ELYSIA, GameState.UiMode.REAL]:
		var theme := UiSkin.theme_for(mode)
		for panel_type: StringName in [&"BindCell", &"BindCellActive", &"BindCellEmpty"]:
			assert_true(theme.has_stylebox(&"panel", panel_type), "%d %s" % [mode, panel_type])
		for label_type: StringName in [&"BindCellLabel", &"BindCellActiveLabel", &"BindFixed"]:
			assert_true(theme.has_color(&"font_color", label_type), "%d %s" % [mode, label_type])
		var active := theme.get_stylebox(&"panel", &"BindCellActive") as StyleBoxFlat
		colors[mode] = active.bg_color
		var label_color := theme.get_color(&"font_color", &"BindCellActiveLabel")
		assert_lt(label_color.get_luminance(), 0.3, "dark text on the lit cell")
		assert_gt(active.bg_color.get_luminance(), 0.6, "the selected cell is a bright shape")
	assert_ne(colors[GameState.UiMode.ELYSIA], colors[GameState.UiMode.REAL], "each skin its own")
	var base := ThemeDB.get_project_theme()
	for panel_type: StringName in [&"BindCell", &"BindCellActive", &"BindCellEmpty"]:
		assert_true(base.has_stylebox(&"panel", panel_type), "the plain theme too: " + panel_type)


func test_the_autopilot_taps_real_keys_and_buttons_and_lets_go() -> void:
	var recorder := Recorder.new()
	add_child_autofree(recorder)
	var pilot: Node = AUTOPILOT.new()
	pilot.set(&"_events", [{"t": 0.0, "key": ["F"], "pad": [3], "tap": ["ui_down"]}])
	add_child_autofree(pilot)
	await wait_physics_frames(24)
	var key_down: InputEventKey = null
	var key_up: InputEventKey = null
	var pad_down: InputEventJoypadButton = null
	var pad_up: InputEventJoypadButton = null
	var action_up: InputEventAction = null
	for event in recorder.events:
		if event is InputEventKey:
			if (event as InputEventKey).pressed:
				key_down = event
			else:
				key_up = event
		elif event is InputEventJoypadButton:
			if (event as InputEventJoypadButton).pressed:
				pad_down = event
			else:
				pad_up = event
		elif event is InputEventAction and not (event as InputEventAction).pressed:
			action_up = event
	assert_not_null(key_down, "a real key press")
	assert_eq(key_down.physical_keycode, KEY_F)
	assert_not_null(key_up, "and its release, as a key and not as an action")
	assert_eq(key_up.physical_keycode, KEY_F)
	assert_eq((pad_down as InputEventJoypadButton).button_index, JOY_BUTTON_Y)
	assert_not_null(pad_up, "the button lets go as a button")
	assert_eq((pad_up as InputEventJoypadButton).button_index, JOY_BUTTON_Y)
	assert_not_null(action_up)
	assert_eq(action_up.action, &"ui_down", "an action still lets go as an action")


func test_a_key_the_autopilot_does_not_know_is_named_once() -> void:
	var pilot: Node = AUTOPILOT.new()
	pilot.set(&"_events", [{"t": 0.0, "key": ["NoSuchKey"]}])
	add_child_autofree(pilot)
	# long enough for the release that must not be tried a second time
	await wait_physics_frames(24)
	assert_push_error_count(1, "one script typo, one error")
	assert_true((pilot.get(&"_tapped") as Dictionary).is_empty(), "nothing waits for a release")


func test_the_autopilot_names_a_key_it_does_not_know_and_nothing_else() -> void:
	assert_null(AUTOPILOT.event_for("key:NoSuchKey", true))
	assert_push_error("autopilot key unknown")
	var key: InputEventKey = AUTOPILOT.event_for("key:Delete", true)
	assert_eq(key.physical_keycode, KEY_DELETE)
	assert_eq(key.keycode, KEY_DELETE)
	var pad: InputEventJoypadButton = AUTOPILOT.event_for("pad:6", false)
	assert_eq(pad.button_index, JOY_BUTTON_START)
	assert_false(pad.pressed)
	var action: InputEventAction = AUTOPILOT.event_for("cancel", true)
	assert_eq(action.action, &"cancel")


func test_the_scripts_of_the_page_only_use_what_exists() -> void:
	for path: String in [
		"res://tools/autopilot/controls_rebind.json", "res://tools/autopilot/controls_pad.json"
	]:
		var json := JSON.new()
		assert_eq(json.parse(FileAccess.get_file_as_string(path)), OK, path)
		for item: Dictionary in json.data:
			for name: String in item.get("tap", []):
				assert_true(InputMap.has_action(name), path + ": " + name)
			for name: String in item.get("key", []):
				assert_ne(OS.find_keycode_from_string(name), KEY_NONE, path + ": " + name)
			for button: Variant in item.get("pad", []):
				assert_true(int(button) >= 0 and int(button) < BindingCodec.BUTTON_COUNT, path)
