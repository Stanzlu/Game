extends GutTest
## The names of keys and buttons (ADR-048): German key names, pad names by style, the walk
## keys together, and labels that follow a rebinding.

const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	InputDevice.style = InputDevice.Style.XBOX
	Settings.bindings.reset()
	Settings.apply_all()


func _key(code: int) -> Dictionary:
	return {"type": "key", "physical_keycode": code}


func test_labels_follow_a_rebinding() -> void:
	assert_eq(InputDevice.label_for(&"interact"), "E")
	Settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	assert_eq(InputDevice.label_for(&"interact"), "F")
	assert_eq(InputDevice.labels_for_kind(&"interact", InputDevice.Kind.KEYBOARD)[1], "Leertaste")
	Settings.bindings.reset()
	assert_eq(InputDevice.label_for(&"interact"), "E", "and back")


func test_labels_changed_is_signalled_by_a_binding_change() -> void:
	watch_signals(InputDevice)
	Settings.bindings.bind(&"journal", KB, 0, _key(KEY_K))
	assert_signal_emit_count(InputDevice, "labels_changed", 1)
	Settings.bindings.bind(&"journal", KB, 0, _key(KEY_K))
	Settings.bindings.bind(&"journal", KB, 0, _key(KEY_ENTER))
	assert_signal_emit_count(
		InputDevice, "labels_changed", 1, "an edit that changed nothing is quiet"
	)
	Settings.bindings.reset()
	assert_signal_emit_count(InputDevice, "labels_changed", 2)


func test_german_key_names() -> void:
	var names := {
		KEY_UP: "Pfeil hoch",
		KEY_DOWN: "Pfeil runter",
		KEY_LEFT: "Pfeil links",
		KEY_RIGHT: "Pfeil rechts",
		KEY_PAGEUP: "Bild auf",
		KEY_PAGEDOWN: "Bild ab",
		KEY_DELETE: "Entf",
		KEY_INSERT: "Einfg",
		KEY_HOME: "Pos1",
		KEY_END: "Ende",
		KEY_CTRL: "Strg",
		KEY_SHIFT: "Umschalt",
		KEY_SPACE: "Leertaste",
		KEY_ESCAPE: "Esc",
		KEY_ENTER: "Enter",
		KEY_KP_ENTER: "Enter",
		KEY_BACKSPACE: "Backspace",
		KEY_KP_5: "Num 5",
		KEY_KP_ADD: "Num +",
		KEY_KP_PERIOD: "Num ,",
		KEY_A: "A",
		KEY_5: "5",
		KEY_SEMICOLON: ";",
		KEY_MINUS: "-",
		KEY_BRACKETLEFT: "[",
		KEY_F5: "F5",
		KEY_TAB: "Tab",
	}
	for code: int in names:
		assert_eq(InputDevice.key_label(code as Key), names[code], "key %d" % code)
	assert_false(InputDevice.key_label(KEY_META).is_empty())


func test_trigger_labels_by_style() -> void:
	assert_eq(InputDevice.trigger_label(true, InputDevice.Style.XBOX), "LT")
	assert_eq(InputDevice.trigger_label(false, InputDevice.Style.XBOX), "RT")
	assert_eq(InputDevice.trigger_label(true, InputDevice.Style.PLAYSTATION), "L2")
	assert_eq(InputDevice.trigger_label(false, InputDevice.Style.PLAYSTATION), "R2")
	assert_eq(InputDevice.trigger_label(true, InputDevice.Style.NINTENDO), "ZL")
	assert_eq(InputDevice.trigger_label(false, InputDevice.Style.NINTENDO), "ZR")
	InputDevice.style = InputDevice.Style.PLAYSTATION
	assert_eq(
		InputDevice.labels_for_kind(&"sprint", InputDevice.Kind.GAMEPAD),
		PackedStringArray(["□", "R2"]),
		"the sprint trigger is the right one"
	)


func test_pad_buttons_have_names() -> void:
	var xbox := InputDevice.Style.XBOX
	assert_eq(InputDevice.button_label(JOY_BUTTON_LEFT_STICK, xbox), "L3")
	assert_eq(InputDevice.button_label(JOY_BUTTON_RIGHT_STICK, xbox), "R3")
	assert_eq(InputDevice.button_label(JOY_BUTTON_BACK, xbox), "Select")
	assert_eq(InputDevice.button_label(JOY_BUTTON_START, xbox), "Start")
	assert_eq(InputDevice.button_label(JOY_BUTTON_Y, InputDevice.Style.NINTENDO), "X")
	assert_eq(
		InputDevice.button_label(JOY_BUTTON_MISC1, xbox), "Pad 15", "unknown ones keep a number"
	)


func test_labels_keep_the_order_of_the_input_map() -> void:
	var keyboard := InputDevice.Kind.KEYBOARD
	var pad := InputDevice.Kind.GAMEPAD
	assert_eq(
		InputDevice.labels_for_kind(&"interact", keyboard),
		PackedStringArray(["E", "Leertaste", "Enter"]),
		"own keys first, the pinned ones behind"
	)
	assert_eq(
		InputDevice.labels_for_kind(&"cancel", keyboard), PackedStringArray(["Esc", "Backspace"])
	)
	assert_eq(InputDevice.labels_for_kind(&"menu", keyboard), PackedStringArray(["Esc", "Tab"]))
	assert_eq(InputDevice.labels_for_kind(&"menu", pad), PackedStringArray(["Start"]))
	assert_eq(
		InputDevice.labels_for_kind(&"move_up", pad), PackedStringArray(["Stick", "Steuerkreuz"])
	)
	assert_eq(InputDevice.labels_for_kind(&"interact", pad), PackedStringArray(["A"]))


func test_move_label() -> void:
	var keyboard := InputDevice.Kind.KEYBOARD
	assert_eq(InputDevice.move_label(keyboard), "WASD")
	assert_eq(InputDevice.move_label(InputDevice.Kind.GAMEPAD), "Stick")
	for action: StringName in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		Settings.bindings.clear(action, KB, 0)
		if action == &"move_up":
			assert_eq(InputDevice.move_label(keyboard), "Pfeil hoch A S D", "mixed: the four names")
	assert_eq(InputDevice.move_label(keyboard), "Pfeiltasten", "all four on the arrows")
	Settings.bindings.reset()
	Settings.bindings.bind(&"move_up", KB, 0, _key(KEY_I))
	Settings.bindings.bind(&"move_left", KB, 0, _key(KEY_G))
	Settings.bindings.bind(&"move_down", KB, 0, _key(KEY_K))
	Settings.bindings.bind(&"move_right", KB, 0, _key(KEY_L))
	assert_eq(
		InputDevice.move_label(keyboard),
		"IGKL",
		"letters together, in the order up, left, down, right"
	)


func test_data_label_matches_the_map_label() -> void:
	var seen := 0
	for style: InputDevice.Style in [InputDevice.Style.XBOX, InputDevice.Style.PLAYSTATION]:
		InputDevice.style = style
		for action in InputBindings.ACTIONS:
			for device: int in InputBindings.Device.values():
				var from_data := PackedStringArray()
				for data in Settings.bindings.effective(action, device as InputBindings.Device):
					var label := InputDevice.data_label(data)
					if not from_data.has(label):
						from_data.append(label)
				var kind := device as InputDevice.Kind
				assert_eq(
					from_data, InputDevice.labels_for_kind(action, kind), "%s/%d" % [action, device]
				)
				seen += from_data.size()
	assert_gt(seen, 40)
	assert_eq(InputDevice.data_label({}), "")
	assert_eq(InputDevice.data_label({"type": "mouse"}), "")
	InputDevice.style = InputDevice.Style.PLAYSTATION
	assert_eq(InputDevice.data_label({"type": "joy_button", "button": 0}), "×")
	assert_eq(InputDevice.data_label({"type": "joy_button", "button": 0}, true), "Kreuz")


func test_other_events_have_no_label() -> void:
	var click := InputEventMouseButton.new()
	assert_eq(InputDevice.event_label(click), "")
	assert_eq(InputDevice.event_label(InputEventAction.new()), "")


func test_observe_follows_a_consumed_pad_press() -> void:
	# the key capture consumes its events; it hands them to observe() so the prompts follow
	InputDevice.style = InputDevice.Style.PLAYSTATION
	var press := InputEventJoypadButton.new()
	press.button_index = JOY_BUTTON_X
	press.pressed = true
	InputDevice.observe(press)
	assert_eq(InputDevice.kind, InputDevice.Kind.GAMEPAD)
	assert_eq(InputDevice.style, InputDevice.Style.XBOX, "the style comes from the pad's name")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F
	key.pressed = true
	InputDevice.observe(key)
	assert_eq(InputDevice.kind, InputDevice.Kind.KEYBOARD)
	var drift := InputEventJoypadMotion.new()
	drift.axis = JOY_AXIS_LEFT_X
	drift.axis_value = 0.3
	InputDevice.observe(drift)
	assert_eq(InputDevice.kind, InputDevice.Kind.KEYBOARD, "a resting stick is no press")


func test_an_action_without_events_shows_a_question_mark() -> void:
	InputMap.action_erase_events(&"interact")
	assert_eq(InputDevice.label_for(&"interact"), "?")
	assert_eq(InputDevice.labels_for_kind(&"interact", InputDevice.Kind.KEYBOARD).size(), 0)
	# the old page must survive it too
	var menu := ControlsMenu.new()
	add_child_autofree(menu)
	menu.open()
	await wait_physics_frames(2)
	assert_true(menu.is_open())
	menu.close()
	Settings.apply_all()
	assert_eq(InputDevice.label_for(&"interact"), "E", "apply_all heals the map")
