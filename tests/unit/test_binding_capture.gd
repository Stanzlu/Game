extends GutTest
## BindingCapture: what a capture makes of the raw events. Synthetic events only; the armed
## window is switched off unless a test is about it.

const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD
const KIND := BindingCapture.Kind


func _capture(device: InputBindings.Device, armed := false) -> BindingCapture:
	var capture := BindingCapture.new(device)
	if not armed:
		capture.armed_in = 0.0
	return capture


func _key(code: int, pressed := true, echo := false) -> InputEventKey:
	var key := InputEventKey.new()
	key.physical_keycode = code as Key
	key.pressed = pressed
	key.echo = echo
	return key


func _button(index: int, pressed := true) -> InputEventJoypadButton:
	var button := InputEventJoypadButton.new()
	button.button_index = index as JoyButton
	button.pressed = pressed
	return button


func _motion(axis: int, value: float, pad := 0) -> InputEventJoypadMotion:
	var motion := InputEventJoypadMotion.new()
	motion.axis = axis as JoyAxis
	motion.axis_value = value
	motion.device = pad
	return motion


func _kind(capture: BindingCapture, event: InputEvent) -> int:
	return capture.feed(event).kind


func test_a_key_press_is_the_new_binding() -> void:
	var capture := _capture(KB)
	var outcome := capture.feed(_key(KEY_F))
	assert_eq(outcome.kind, KIND.EVENT)
	assert_eq(outcome.data, {"type": "key", "physical_keycode": KEY_F})


func test_echo_release_and_the_empty_key_do_not_count() -> void:
	var capture := _capture(KB)
	assert_eq(_kind(capture, _key(KEY_F, true, true)), KIND.NONE, "a held key repeating")
	assert_eq(_kind(capture, _key(KEY_F, false)), KIND.NONE, "the release of the activating key")
	var empty := InputEventKey.new()
	empty.pressed = true
	assert_eq(_kind(capture, empty), KIND.INVALID, "no physical key code: say so, do not bind")
	var logical_only := InputEventKey.new()
	logical_only.keycode = KEY_F
	logical_only.pressed = true
	assert_eq(_kind(capture, logical_only), KIND.INVALID)
	assert_eq(_kind(capture, _key(KEY_UNKNOWN)), KIND.INVALID, "not a key the codec knows")
	assert_eq(_kind(capture, _key(KEY_F, false, true)), KIND.NONE)


func test_esc_cancels_in_both_modes_and_delete_clears() -> void:
	for device: InputBindings.Device in [KB, PAD]:
		var capture := _capture(device)
		assert_eq(_kind(capture, _key(KEY_ESCAPE)), KIND.CANCEL)
		assert_eq(_kind(capture, _key(KEY_DELETE)), KIND.CLEAR)
		assert_eq(_kind(capture, _button(JOY_BUTTON_Y)), KIND.CLEAR, "Y is the pad's Delete")
		assert_eq(_kind(capture, _button(JOY_BUTTON_Y, false)), KIND.NONE, "the release")
		assert_eq(_kind(capture, _button(JOY_BUTTON_START)), KIND.CANCEL, "Start is the pad's Esc")
		assert_eq(_kind(capture, _key(KEY_ESCAPE, false)), KIND.NONE, "the release")
	var by_name := InputEventKey.new()
	by_name.keycode = KEY_ESCAPE
	by_name.pressed = true
	assert_eq(_kind(_capture(KB), by_name), KIND.CANCEL, "Esc also without a physical code")


func test_shift_and_ctrl_bind_on_release() -> void:
	var capture := _capture(KB)
	assert_eq(_kind(capture, _key(KEY_SHIFT)), KIND.NONE, "could be the start of Shift+W")
	var released := capture.feed(_key(KEY_SHIFT, false))
	assert_eq(released.kind, KIND.EVENT)
	assert_eq(released.data, {"type": "key", "physical_keycode": KEY_SHIFT})
	assert_eq(_kind(capture, _key(KEY_CTRL)), KIND.NONE)
	assert_eq(_kind(capture, _key(KEY_CTRL, false)), KIND.EVENT)


func test_a_modifier_with_a_key_gives_the_key() -> void:
	var capture := _capture(KB)
	capture.feed(_key(KEY_SHIFT))
	var outcome := capture.feed(_key(KEY_W))
	assert_eq(outcome.kind, KIND.EVENT)
	assert_eq(outcome.data["physical_keycode"], KEY_W, "the modifier is dropped")
	assert_eq(_kind(capture, _key(KEY_SHIFT, false)), KIND.NONE, "and not bound afterwards")
	capture.feed(_key(KEY_CTRL))
	capture.feed(_key(KEY_TAB))
	assert_eq(_kind(capture, _key(KEY_CTRL, false)), KIND.NONE, "Ctrl+Tab never binds Ctrl")


func test_a_modifier_released_without_a_press_in_this_capture_is_ignored() -> void:
	# the player ran with Shift held, opened the page, confirmed, and lets go of Shift now
	var capture := _capture(KB)
	assert_eq(_kind(capture, _key(KEY_SHIFT, false)), KIND.NONE)
	assert_eq(_kind(capture, _key(KEY_CTRL, false)), KIND.NONE)


func test_a_second_modifier_replaces_the_first() -> void:
	var capture := _capture(KB)
	capture.feed(_key(KEY_SHIFT))
	capture.feed(_key(KEY_CTRL))
	assert_eq(_kind(capture, _key(KEY_SHIFT, false)), KIND.NONE)
	assert_eq(capture.feed(_key(KEY_CTRL, false)).data["physical_keycode"], KEY_CTRL)


func test_alt_and_meta_are_reported_at_once_for_the_model_to_refuse() -> void:
	# they are never bindable, so no waiting for a release: the model says "not this key"
	var capture := _capture(KB)
	assert_eq(_kind(capture, _key(KEY_ALT)), KIND.EVENT)
	assert_eq(_kind(capture, _key(KEY_META)), KIND.EVENT)
	assert_eq(_kind(capture, _key(KEY_ALT, false)), KIND.NONE)


func test_reset_forgets_a_pending_modifier() -> void:
	var capture := _capture(KB)
	capture.feed(_key(KEY_SHIFT))
	capture.reset()
	assert_eq(_kind(capture, _key(KEY_SHIFT, false)), KIND.NONE)


func test_the_other_device_is_named_not_bound() -> void:
	var pad_capture := _capture(PAD)
	var pressed := pad_capture.feed(_button(JOY_BUTTON_X))
	assert_eq(pressed.kind, KIND.EVENT)
	assert_eq(pressed.data, {"type": "joy_button", "button": JOY_BUTTON_X})
	assert_eq(_kind(pad_capture, _button(JOY_BUTTON_X, false)), KIND.NONE, "the release")
	var key := pad_capture.feed(_key(KEY_F))
	assert_eq(key.kind, KIND.OTHER_DEVICE)
	assert_eq(key.data["physical_keycode"], KEY_F, "what was meant is handed back")
	assert_eq(_kind(pad_capture, _key(KEY_SHIFT)), KIND.OTHER_DEVICE, "a modifier is a key too")
	assert_eq(_kind(pad_capture, _key(KEY_SHIFT, false)), KIND.NONE)
	var key_capture := _capture(KB)
	var button := key_capture.feed(_button(JOY_BUTTON_X))
	assert_eq(button.kind, KIND.OTHER_DEVICE)
	assert_eq(button.data["button"], JOY_BUTTON_X)
	assert_eq(_kind(pad_capture, _button(30)), KIND.INVALID, "a button that does not exist")


func test_a_trigger_binds_once_per_pull() -> void:
	var capture := _capture(PAD)
	var trigger := JOY_AXIS_TRIGGER_RIGHT
	assert_eq(_kind(capture, _motion(trigger, 0.2)), KIND.NONE)
	assert_eq(_kind(capture, _motion(trigger, 0.5)), KIND.NONE, "not pulled far enough")
	var pulled := capture.feed(_motion(trigger, 0.7))
	assert_eq(pulled.kind, KIND.EVENT)
	assert_eq(pulled.data, {"type": "joy_axis", "axis": trigger, "value": 1.0})
	assert_eq(_kind(capture, _motion(trigger, 0.9)), KIND.NONE, "the same pull is not a second one")
	assert_eq(_kind(capture, _motion(trigger, 0.1)), KIND.NONE)
	assert_eq(_kind(capture, _motion(trigger, 0.8)), KIND.EVENT, "released and pulled again")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_LEFT, 0.9)), KIND.EVENT, "the other trigger")


func test_a_first_fast_pull_binds() -> void:
	# an axis never seen before counts as at rest: the first event may already be far out
	assert_eq(_kind(_capture(PAD), _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.EVENT)
	assert_eq(_kind(_capture(PAD), _motion(JOY_AXIS_TRIGGER_RIGHT, -0.9)), KIND.NONE, "backwards")


func test_a_stick_is_reported_once_per_push() -> void:
	var capture := _capture(PAD)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.5)), KIND.NONE)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.8)), KIND.STICK)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9)), KIND.NONE)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.5)), KIND.NONE, "not at rest yet")
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.1)), KIND.NONE)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, -0.8)), KIND.STICK, "pushed the other way")
	assert_eq(_kind(capture, _motion(JOY_AXIS_RIGHT_Y, 0.9)), KIND.STICK, "each stick on its own")


func test_a_keyboard_capture_does_not_listen_to_the_sticks() -> void:
	var capture := _capture(KB)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9)), KIND.NONE)
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.NONE)
	assert_eq(_kind(_capture(PAD), _motion(JOY_AXIS_MAX - 1, 0.9)), KIND.NONE, "no such axis")


func test_mouse_actions_and_touch_are_not_for_the_capture() -> void:
	var capture := _capture(KB)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var action := InputEventAction.new()
	action.action = &"interact"
	action.pressed = true
	for event: InputEvent in [
		click, InputEventMouseMotion.new(), action, InputEventScreenTouch.new()
	]:
		assert_eq(_kind(capture, event), KIND.NONE, event.get_class())
		assert_eq(_kind(_capture(PAD), event), KIND.NONE, event.get_class())


func test_presses_are_ignored_while_the_capture_is_arming() -> void:
	var capture := _capture(KB, true)
	assert_eq(capture.armed_in, BindingCapture.ARM_SECONDS)
	assert_eq(_kind(capture, _key(KEY_F)), KIND.NONE, "the second tap of a double tap")
	assert_eq(_kind(capture, _key(KEY_DELETE)), KIND.NONE)
	assert_eq(_kind(capture, _key(KEY_SHIFT)), KIND.NONE)
	assert_eq(_kind(capture, _key(KEY_SHIFT, false)), KIND.NONE, "no press was seen")
	assert_eq(_kind(capture, _key(KEY_ESCAPE)), KIND.CANCEL, "leaving works at once")
	capture.tick(0.2)
	assert_eq(_kind(capture, _key(KEY_F)), KIND.NONE, "still arming")
	capture.tick(0.2)
	assert_eq(capture.armed_in, 0.0)
	assert_eq(_kind(capture, _key(KEY_F)), KIND.EVENT)
	capture.tick(5.0)
	assert_eq(capture.armed_in, 0.0, "it does not go negative")


func test_pad_presses_are_ignored_while_arming_but_start_leaves() -> void:
	var capture := _capture(PAD, true)
	assert_eq(_kind(capture, _button(JOY_BUTTON_A)), KIND.NONE, "A started the capture")
	assert_eq(_kind(capture, _button(JOY_BUTTON_Y)), KIND.NONE, "Y waits like Delete does")
	assert_eq(_kind(capture, _button(JOY_BUTTON_START)), KIND.CANCEL)
	capture.tick(BindingCapture.ARM_SECONDS)
	assert_eq(_kind(capture, _button(JOY_BUTTON_A)), KIND.EVENT)


func test_a_trigger_held_through_the_arming_waits_for_a_release() -> void:
	var capture := _capture(PAD, true)
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.NONE)
	capture.tick(1.0)
	assert_eq(
		_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.95)), KIND.NONE, "still the same pull"
	)
	capture.feed(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.0))
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.EVENT)
	var stick := _capture(PAD, true)
	assert_eq(_kind(stick, _motion(JOY_AXIS_LEFT_Y, -0.9)), KIND.NONE)
	stick.tick(1.0)
	assert_eq(_kind(stick, _motion(JOY_AXIS_LEFT_Y, -0.95)), KIND.NONE, "held, not pushed")


func test_an_axis_deflected_at_the_start_has_to_come_to_rest_first() -> void:
	# the stick that moved the cursor to the row is still pushed when the capture starts
	var capture := _capture(PAD)
	capture.hold_axis(0, JOY_AXIS_LEFT_X)
	capture.hold_axis(0, JOY_AXIS_TRIGGER_RIGHT)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9)), KIND.NONE, "no false message")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.NONE)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_Y, 0.9)), KIND.STICK, "another axis is free")
	capture.feed(_motion(JOY_AXIS_LEFT_X, 0.0))
	capture.feed(_motion(JOY_AXIS_TRIGGER_RIGHT, 0.1))
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9)), KIND.STICK, "after it was at rest")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9)), KIND.EVENT)
	var other_pad := _capture(PAD)
	other_pad.hold_axis(1, JOY_AXIS_LEFT_X)
	assert_eq(_kind(other_pad, _motion(JOY_AXIS_LEFT_X, 0.9, 0)), KIND.STICK, "pad 0 is not pad 1")
	assert_eq(_kind(other_pad, _motion(JOY_AXIS_LEFT_X, 0.9, 1)), KIND.NONE)


func test_the_snapshot_holds_every_deflected_axis_of_every_pad() -> void:
	var positions := {"0:0": 0.9, "0:5": 0.31, "1:2": -0.5, "1:4": 0.29, "1:5": 0.0}
	var reader := func(pad: int, axis: int) -> float:
		return float(positions.get("%d:%d" % [pad, axis], 0.0))
	var capture := _capture(PAD)
	capture.snapshot([0, 1] as Array[int], reader)
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9, 0)), KIND.NONE, "stick of pad 0")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9, 0)), KIND.NONE, "0.31 is held")
	assert_eq(_kind(capture, _motion(JOY_AXIS_RIGHT_X, 0.9, 1)), KIND.NONE, "pulled backwards")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_LEFT, 0.9, 1)), KIND.EVENT, "0.29 is rest")
	assert_eq(_kind(capture, _motion(JOY_AXIS_TRIGGER_RIGHT, 0.9, 1)), KIND.EVENT, "0.0 is rest")
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_Y, 0.9, 0)), KIND.STICK, "a free axis")
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9, 1)), KIND.STICK, "pad 1 is not pad 0")
	# the first event of a held axis that is back at rest frees it
	capture.feed(_motion(JOY_AXIS_LEFT_X, 0.0, 0))
	assert_eq(_kind(capture, _motion(JOY_AXIS_LEFT_X, 0.9, 0)), KIND.STICK)
	var none := _capture(PAD)
	none.snapshot([] as Array[int], reader)
	assert_eq(_kind(none, _motion(JOY_AXIS_LEFT_X, 0.9, 0)), KIND.STICK, "no pads: nothing held")
	# headless has no pad: the constructor's own snapshot finds nothing and must not fail
	assert_not_null(BindingCapture.new(PAD))
	var real: Callable = Input.get_joy_axis
	assert_eq(float(real.call(0, JOY_AXIS_LEFT_X)), 0.0, "the reader the constructor hands over")
	assert_eq(BindingCapture.new(KB).armed_in, BindingCapture.ARM_SECONDS)
