extends GutTest
## The event codec behind settings.json and the binding rules: strict, never clamps.


func _key(code: int) -> InputEventKey:
	var key := InputEventKey.new()
	key.physical_keycode = code as Key
	return key


func test_key_round_trip_drops_modifiers_and_device() -> void:
	var key := _key(KEY_W)
	key.shift_pressed = true
	key.ctrl_pressed = true
	key.echo = true
	key.pressed = true
	key.device = 16
	key.keycode = KEY_Z
	var data := BindingCodec.encode(key)
	assert_eq(data, {"type": "key", "physical_keycode": KEY_W})
	var back := BindingCodec.decode(data) as InputEventKey
	assert_eq(back.physical_keycode, KEY_W)
	assert_eq(back.device, -1, "a binding listens to every device")
	assert_false(back.shift_pressed or back.echo or back.pressed)


func test_button_and_axis_round_trip() -> void:
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_X
	button.device = 3
	var button_data := BindingCodec.encode(button)
	assert_eq(button_data, {"type": "joy_button", "button": JOY_BUTTON_X})
	assert_eq((BindingCodec.decode(button_data) as InputEventJoypadButton).device, -1)
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_X
	stick.axis_value = -0.3
	var stick_data := BindingCodec.encode(stick)
	assert_eq(stick_data["value"], -1.0, "the direction is kept, the strength is not")
	assert_eq((BindingCodec.decode(stick_data) as InputEventJoypadMotion).axis_value, -1.0)
	stick.axis_value = 0.0
	assert_eq(BindingCodec.encode(stick), {}, "no direction: nothing to bind")
	assert_null(BindingCodec.decode({"type": "joy_axis", "axis": 1, "value": 0}))
	var trigger := InputEventJoypadMotion.new()
	trigger.axis = JOY_AXIS_TRIGGER_RIGHT
	trigger.axis_value = 0.8
	assert_eq(BindingCodec.encode(trigger), {"type": "joy_axis", "axis": 5, "value": 1.0})
	trigger.axis_value = -1.0
	assert_eq(BindingCodec.encode(trigger), {}, "a trigger pulled backwards would be dead")
	assert_null(BindingCodec.decode({"type": "joy_axis", "axis": 5, "value": -1}))
	assert_null(BindingCodec.decode({"type": "joy_axis", "axis": 4, "value": -0.5}))


func test_decode_rejects_garbage() -> void:
	var nan := NAN
	var inf := INF
	var table: Array = [
		null,
		"key",
		[],
		{},
		{"type": "key"},
		{"type": "key", "physical_keycode": "up"},
		{"type": "key", "physical_keycode": null},
		{"type": "key", "physical_keycode": true},
		{"type": "mouse"},
		{"type": "script", "source": "res://evil.gd"},
		{"type": 5, "physical_keycode": 87},
		{"type": "key", "physical_keycode": nan},
		{"type": "key", "physical_keycode": inf},
		{"type": "key", "physical_keycode": 0},
		{"type": "key", "physical_keycode": -5},
		{"type": "key", "physical_keycode": 1e30},
		{"type": "key", "physical_keycode": 87.9},
		{"type": "key", "physical_keycode": KEY_UNKNOWN},
		{"type": "key", "physical_keycode": KEY_SPECIAL},
		{"type": "key", "physical_keycode": KEY_MASK_SHIFT | KEY_A},
		{"type": "key", "physical_keycode": 99999},
		{"type": "key", "physical_keycode": 0x7FFFFFFF},
		{"type": "joy_button"},
		{"type": "joy_button", "button": -1},
		{"type": "joy_button", "button": 26},
		{"type": "joy_button", "button": 500},
		{"type": "joy_button", "button": 0.5},
		{"type": "joy_button", "button": "a"},
		{"type": "joy_axis", "axis": 1},
		{"type": "joy_axis", "axis": 1, "value": "up"},
		{"type": "joy_axis", "axis": -3, "value": 1},
		{"type": "joy_axis", "axis": 6, "value": 1},
		{"type": "joy_axis", "axis": 10, "value": 1},
		{"type": "joy_axis", "axis": 1, "value": nan},
		{"type": "joy_axis", "axis": 1, "value": inf},
		{"type": "joy_axis", "axis": 1, "value": 0.0},
		{"type": "joy_axis", "axis": 5, "value": true},
		{"type": "joy_axis", "axis": 1, "value": false},
		{"type": "joy_axis", "axis": 1, "value": [1.0]},
		{"type": "joy_axis", "axis": true, "value": 1.0},
		{"type": "joy_button", "button": true},
		{"type": "key", "physical_keycode": KEY_EXCLAM},
		{"type": "key", "physical_keycode": KEY_BACKTAB},
	]
	for entry: Variant in table:
		assert_null(BindingCodec.decode(entry), "refused: " + str(entry))
		assert_eq(BindingCodec.normalize(entry), {}, "no normal form: " + str(entry))


func test_json_numbers_are_accepted_when_they_are_whole() -> void:
	# JSON has no integers: Godot hands back floats
	var parsed: Variant = JSON.parse_string('{"type": "key", "physical_keycode": 87}')
	var key := BindingCodec.decode(parsed) as InputEventKey
	assert_not_null(key)
	assert_eq(key.physical_keycode, KEY_W)
	assert_eq(BindingCodec.normalize(parsed), {"type": "key", "physical_keycode": KEY_W})
	var odd := BindingCodec.normalize({"type": "joy_axis", "axis": 1.0, "value": -0.25})
	assert_eq(odd, {"type": "joy_axis", "axis": 1, "value": -1.0})
	assert_not_null(BindingCodec.decode({"type": "joy_button", "button": 25.0}))


func test_key_is_valid() -> void:
	for code: int in [
		KEY_A,
		KEY_Z,
		KEY_5,
		KEY_SHIFT,
		KEY_CTRL,
		KEY_F13,
		KEY_KP_0,
		KEY_KP_ENTER,
		KEY_SPACE,
		KEY_ESCAPE,
		KEY_SEMICOLON,
		KEY_LESS,
		KEY_SECTION,
		KEY_YEN,
		KEY_HELP,
		KEY_VOLUMEUP,
		KEY_JIS_KANA,
	]:
		assert_true(BindingCodec.key_is_valid(code), "valid: %d" % code)
	for code: int in [
		0,
		-1,
		KEY_SPECIAL,
		KEY_UNKNOWN,
		KEY_MASK_SHIFT | KEY_A,
		KEY_MASK_CTRL | KEY_ESCAPE,
		99999,
		0x110000,
		0xD800,
		0x7FFFFFFF,
		97,
		0x400074,
		0x400200,
	]:
		assert_false(BindingCodec.key_is_valid(code), "invalid: %d" % code)


func test_characters_that_are_no_physical_key_are_refused() -> void:
	# these have a name in the engine but exist only as characters (Shift+1, Shift+;, ...)
	for code: int in [
		KEY_EXCLAM,
		KEY_QUOTEDBL,
		KEY_NUMBERSIGN,
		KEY_DOLLAR,
		KEY_PERCENT,
		KEY_AMPERSAND,
		KEY_PARENLEFT,
		KEY_PARENRIGHT,
		KEY_ASTERISK,
		KEY_PLUS,
		KEY_COLON,
		KEY_GREATER,
		KEY_QUESTION,
		KEY_AT,
		KEY_ASCIICIRCUM,
		KEY_UNDERSCORE,
		KEY_BRACELEFT,
		KEY_BRACERIGHT,
		KEY_BAR,
		KEY_ASCIITILDE,
		KEY_BACKTAB,
	]:
		assert_false(BindingCodec.key_is_valid(code), "no key: %d" % code)
		assert_eq(BindingCodec.encode(_key(code)), {}, "not encoded: %d" % code)
		assert_eq(BindingCodec.normalize({"type": "key", "physical_keycode": code}), {})


func test_the_gaps_between_the_named_special_keys_are_refused() -> void:
	# the engine has no name for these (asking prints a complaint): refused without asking
	var gaps: Array[int] = [0x40003f, 0x400040, 0x400041, 0x400044, 0x400046, 0x400047]
	gaps.append_array(range(0x40004f, 0x400054))
	gaps.append_array(range(KEY_JIS_KANA + 1, KEY_KP_MULTIPLY))
	for code in gaps:
		assert_false(BindingCodec.key_is_valid(code), "gap: %x" % code)


func test_the_key_filter_agrees_with_the_engine_names() -> void:
	# every code the codec lets through has a name the engine can turn back into the code
	var accepted := 0
	for code: int in range(1, 0x400100):
		if code > 0x3000 and code < KEY_SPECIAL:
			continue
		if BindingCodec.key_is_valid(code):
			accepted += 1
			assert_eq(OS.find_keycode_from_string(OS.get_keycode_string(code)), code)
	assert_gt(accepted, 150, "letters, digits, signs, F1..F35, keypad and the named keys")
	assert_lt(accepted, 200, "no characters that are no key")


func test_encode_refuses_other_event_types() -> void:
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	var action := InputEventAction.new()
	action.action = &"interact"
	var touch := InputEventScreenTouch.new()
	var midi := InputEventMIDI.new()
	var unknown_key := InputEventKey.new()
	for event: InputEvent in [click, InputEventMouseMotion.new(), action, touch, midi, unknown_key]:
		assert_eq(BindingCodec.encode(event), {}, event.get_class())


func test_event_id_and_device_of() -> void:
	var key := {"type": "key", "physical_keycode": 87}
	var button := {"type": "joy_button", "button": 9}
	var plus := {"type": "joy_axis", "axis": 5, "value": 1.0}
	var minus := {"type": "joy_axis", "axis": 1, "value": -1.0}
	assert_eq(BindingCodec.event_id(key), "k87")
	assert_eq(BindingCodec.event_id({"type": "joy_button", "button": 87}), "b87")
	assert_ne(
		BindingCodec.event_id(key), BindingCodec.event_id({"type": "joy_button", "button": 87})
	)
	assert_eq(BindingCodec.event_id(button), "b9")
	assert_eq(BindingCodec.event_id(plus), "a5+")
	assert_eq(BindingCodec.event_id(minus), "a1-")
	assert_eq(BindingCodec.event_id({}), "")
	assert_eq(BindingCodec.device_of(key), 0)
	assert_eq(BindingCodec.device_of(button), 1)
	assert_eq(BindingCodec.device_of(plus), 1)
	assert_eq(BindingCodec.device_of({"type": "mouse"}), -1)
	assert_eq(BindingCodec.device_of({}), -1)
	assert_true(BindingCodec.is_trigger(JOY_AXIS_TRIGGER_LEFT))
	assert_false(BindingCodec.is_trigger(JOY_AXIS_RIGHT_Y))
