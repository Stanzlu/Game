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
	assert_eq(InputDevice.key_label(KEY_SHIFT), "Umschalt")
	assert_eq(InputDevice.key_label(KEY_UP), "Pfeil hoch")
	assert_eq(InputDevice.key_label(KEY_DELETE), "Entf")
	assert_eq(InputDevice.key_label(KEY_CTRL), "Strg")
	assert_eq(InputDevice.key_label(KEY_PAGEUP), "Bild auf")
	assert_eq(InputDevice.key_label(KEY_KP_5), "Num 5")


func test_device_change_is_signalled_once() -> void:
	watch_signals(InputDevice)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_signal_emit_count(InputDevice, "device_changed", 1)


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
		PackedStringArray(["X", "RT"]),
		"the button and the trigger, each by its name"
	)


func test_the_d_pad_has_a_name_and_the_shoulder_buttons_too() -> void:
	assert_eq(InputDevice.button_label(JOY_BUTTON_DPAD_UP, InputDevice.Style.XBOX), "Steuerkreuz")
	assert_eq(InputDevice.button_label(JOY_BUTTON_LEFT_SHOULDER, InputDevice.Style.XBOX), "LB")
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_LEFT_SHOULDER, InputDevice.Style.PLAYSTATION), "L1"
	)
	var move := InputDevice.labels_for_kind(&"move_up", InputDevice.Kind.GAMEPAD)
	assert_true(move.has("Steuerkreuz") and move.has("Stick"), str(move))


func test_playstation_buttons_are_words_where_the_font_has_no_glyphs() -> void:
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
	var words := InputDevice.labels_for_kind(&"interact", InputDevice.Kind.GAMEPAD, true)
	InputDevice.style = InputDevice.Style.XBOX
	assert_true(words.has("Kreuz"), str(words))


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


## Playtest 23.10.: Esc opened the pause menu and the mouse pointer was gone. Keys hide it, and
## only a mouse move shows it again; the pause menu pauses the tree, so the tracker has to go on
## listening then.
func test_it_keeps_listening_while_the_tree_is_paused() -> void:
	assert_eq(InputDevice.process_mode, Node.PROCESS_MODE_ALWAYS)
	get_tree().paused = true
	var press := InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_X
	press.pressed = true
	Input.parse_input_event(press)
	await wait_process_frames(2)
	var kind := InputDevice.kind
	get_tree().paused = false
	press = press.duplicate()
	press.pressed = false
	Input.parse_input_event(press)
	# the release is buffered: let it arrive now, not after after_each reset the device
	Input.flush_buffered_events()
	assert_eq(kind, InputDevice.Kind.GAMEPAD, "an event during the pause is still seen")
