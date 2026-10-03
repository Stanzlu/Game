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
	assert_eq(InputDevice.button_label(JOY_BUTTON_A, InputDevice.Style.PLAYSTATION), "✕")
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
