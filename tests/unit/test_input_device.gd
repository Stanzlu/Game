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
	assert_eq(rows.size(), ControlsMenu.ROWS.size())
	assert_true(rows[2].contains("E") and rows[2].contains("A"), rows[2])
	for row in rows:
		assert_false(row.contains("?"), "every action has a key and a button: " + row)
	menu.close()
