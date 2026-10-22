extends GutTest


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func test_labels_follow_the_last_device() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_eq(InputDevice.label_for(&"interact"), "E")
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	InputDevice.style = InputDevice.Style.XBOX
	assert_eq(InputDevice.label_for(&"interact"), "A")


func test_pad_styles_label_the_bottom_button() -> void:
	assert_eq(InputDevice.button_label(JOY_BUTTON_A, InputDevice.Style.PLAYSTATION), "×")
	assert_eq(InputDevice.button_label(JOY_BUTTON_A, InputDevice.Style.NINTENDO), "B")
	assert_eq(InputDevice.button_label(JOY_BUTTON_START, InputDevice.Style.XBOX), "Start")


func test_style_detection_from_names() -> void:
	assert_eq(
		InputDevice.style_from_name("DualSense Wireless Controller"), InputDevice.Style.PLAYSTATION
	)
	assert_eq(
		InputDevice.style_from_name("Nintendo Switch Pro Controller"), InputDevice.Style.NINTENDO
	)
	assert_eq(InputDevice.style_from_name("Xbox Series X Controller"), InputDevice.Style.XBOX)


func test_german_key_names() -> void:
	assert_eq(InputDevice.key_label(KEY_SPACE), "Leertaste")
	assert_eq(InputDevice.key_label(KEY_ESCAPE), "Esc")


func test_device_change_is_signalled_once() -> void:
	watch_signals(InputDevice)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_signal_emit_count(InputDevice, "device_changed", 1)


func test_the_controls_page_lists_keys_and_buttons() -> void:
	var menu := ControlsMenu.new()
	add_child_autofree(menu)
	menu.open()
	await wait_physics_frames(2)
	var rows: Array[String] = []
	for node in menu.list.get_children():
		if node is Label:
			rows.append((node as Label).text)
	assert_eq(rows.size(), ControlsMenu.ROWS.size() + 2, "the actions, skipping and scrolling")
	assert_true(rows[2].contains("E") and rows[2].contains("A"), rows[2])
	for row in rows:
		assert_false(row.contains("?"), "every action has a key and a button: " + row)
		assert_false(row.contains("Pad "), "no button without a name: " + row)
	menu.close()


func test_every_binding_is_listed_once() -> void:
	assert_eq(
		InputDevice.labels_for_kind(&"cancel", InputDevice.Kind.KEYBOARD),
		PackedStringArray(["Esc", "Backspace"])
	)
	assert_eq(
		InputDevice.labels_for_kind(&"interact", InputDevice.Kind.KEYBOARD),
		PackedStringArray(["E", "Leertaste", "Enter"]),
		"Enter and the keypad's Enter are one entry"
	)
	InputDevice.style = InputDevice.Style.XBOX
	assert_eq(
		InputDevice.labels_for_kind(&"sprint", InputDevice.Kind.GAMEPAD),
		PackedStringArray(["X", "Trigger"]),
		"buttons first, then triggers"
	)


func test_the_d_pad_has_a_name_and_the_shoulder_buttons_too() -> void:
	assert_eq(InputDevice.button_label(JOY_BUTTON_DPAD_UP, InputDevice.Style.XBOX), "Steuerkreuz")
	assert_eq(InputDevice.button_label(JOY_BUTTON_LEFT_SHOULDER, InputDevice.Style.XBOX), "LB")
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_LEFT_SHOULDER, InputDevice.Style.PLAYSTATION), "L1"
	)
	var move := InputDevice.labels_for_kind(&"move_up", InputDevice.Kind.GAMEPAD)
	assert_true(move.has("Steuerkreuz") and move.has("Stick"), str(move))


func test_playstation_buttons_are_words_on_the_controls_page() -> void:
	var cross := InputDevice.button_label(JOY_BUTTON_A, InputDevice.Style.PLAYSTATION, true)
	assert_eq(cross, "Kreuz")
	assert_eq(InputDevice.button_label(JOY_BUTTON_B, InputDevice.Style.PLAYSTATION, true), "Kreis")
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_X, InputDevice.Style.PLAYSTATION, true), "Quadrat"
	)
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_Y, InputDevice.Style.PLAYSTATION, true), "Dreieck"
	)
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_A, InputDevice.Style.PLAYSTATION),
		"×",
		"prompts keep the glyph"
	)
	InputDevice.style = InputDevice.Style.PLAYSTATION
	var row := ControlsMenu.row_text(&"interact", "CONTROLS_INTERACT")
	InputDevice.style = InputDevice.Style.XBOX
	assert_true(row.contains("Kreuz"), row)


func test_the_controls_page_names_esc_once() -> void:
	var back := ControlsMenu.row_text(&"cancel", "CONTROLS_BACK")
	var menu := ControlsMenu.row_text(&"menu", "CONTROLS_MENU")
	assert_false(back.contains("Esc"), back)
	assert_true(back.contains("Backspace") and back.contains("B"), back)
	assert_true(menu.contains("Esc") and menu.contains("Tab") and menu.contains("Start"), menu)
	var walk := ControlsMenu.row_text(&"move_up", "CONTROLS_MOVE")
	assert_true(walk.contains("WASD") and walk.contains("Pfeiltasten"), walk)
	assert_true(walk.contains("Stick") and walk.contains("Steuerkreuz"), walk)


func test_unplugging_the_last_pad_returns_to_the_keyboard_and_lets_go() -> void:
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	Input.action_press(&"move_up")
	Input.action_press(&"sprint")
	assert_true(Input.is_action_pressed(&"move_up"))
	Input.joy_connection_changed.emit(0, false)
	assert_eq(InputDevice.kind, InputDevice.Kind.KEYBOARD, "prompts show keys again")
	assert_false(Input.is_action_pressed(&"move_up"), "the walk does not run on by itself")
	assert_false(Input.is_action_pressed(&"sprint"))


func test_plugging_a_pad_in_changes_nothing_until_it_is_used() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	Input.joy_connection_changed.emit(0, true)
	assert_eq(InputDevice.kind, InputDevice.Kind.KEYBOARD)
