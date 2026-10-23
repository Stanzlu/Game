extends GutTest
## How a capture of the key layout page ends and what the footer says then: cancelled, the same
## key, a text size change, pad Y (the pad's Delete).

const Helpers := preload("res://tests/unit/controls_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()
	Settings.set_value("text.large", false, false)
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	get_tree().paused = false


func _open() -> ControlsMenu:
	var menu := ControlsMenu.new()
	add_child_autofree(menu)
	menu.open()
	await wait_physics_frames(3)
	return menu


func _name(action: StringName) -> String:
	return tr(str(ControlsMenu.LABEL_KEYS[action]))


func test_a_cancelled_capture_leaves_no_refusal_behind() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"journal", KB)
	Helpers.capture(menu, &"journal", KB)
	menu._input(Helpers.key(KEY_ENTER))
	assert_eq(menu.hint.text, tr("BIND_FIXED_KEY") % "Enter", "the refusal is shown")
	# the cancel action (autopilot, tests) is no key press: it must clear the message itself
	menu._unhandled_input(Helpers.action(&"cancel"))
	assert_false(menu.is_capturing())
	assert_eq(menu.hint.text, tr("BIND_HINT") % ["E", "Entf", "Esc"], "the idle hint is back")
	# and the same for a click, the window losing focus and a text size change
	for end: Callable in [
		func() -> void: menu._input(Helpers.click(MOUSE_BUTTON_LEFT)),
		func() -> void: menu._notification(NOTIFICATION_APPLICATION_FOCUS_OUT),
	]:
		Helpers.capture(menu, &"journal", KB)
		menu._input(Helpers.key(KEY_ENTER))
		end.call()
		assert_eq(menu.hint.text, tr("BIND_HINT") % ["E", "Entf", "Esc"])


func test_the_next_press_brings_back_the_capture_hint() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB)
	var capture_hint := menu.hint.text
	menu._input(Helpers.key(KEY_ENTER))
	assert_ne(menu.hint.text, capture_hint, "the refusal is shown")
	# Shift alone binds nothing (it waits for its release): the capture hint is back at once
	menu._input(Helpers.key(KEY_SHIFT))
	assert_eq(menu.hint.text, capture_hint, "a press that is no refusal ends the message")
	menu._input(Helpers.key(KEY_ESCAPE))


func test_the_same_key_ends_the_capture_and_changes_nothing() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_J))
	assert_false(menu.is_capturing(), "J is on Journal already")
	assert_false(Settings.bindings.is_overridden())
	assert_ne(menu.hint.text, tr("BIND_DONE") % [_name(&"journal"), "J"], "nothing is announced")


func test_a_text_size_change_ends_a_capture() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB)
	Settings.set_value("text.large", true, false)
	await wait_physics_frames(4)
	assert_false(menu.is_capturing(), "the page is built anew, nothing may wait on the old rows")
	assert_true(menu.is_open())


func test_pad_y_clears_in_a_pad_capture_like_delete_on_the_keyboard() -> void:
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	var menu := await _open()
	assert_eq(Helpers.slots(&"sprint", PAD), ["b%d" % JOY_BUTTON_X, "a5+"])
	Helpers.capture(menu, &"sprint", PAD, 1)
	menu._input(Helpers.pad_button(JOY_BUTTON_Y))
	assert_eq(Helpers.slots(&"sprint", PAD), ["b%d" % JOY_BUTTON_X], "the trigger is gone")
	assert_false(menu.is_capturing())
	assert_eq(menu.hint.text, tr("BIND_CLEARED") % ["RT", _name(&"sprint")])
	# the only button of an action stays, and the capture goes on like after any refusal
	Helpers.capture(menu, &"sprint", PAD, 0)
	menu._input(Helpers.pad_button(JOY_BUTTON_Y))
	assert_true(menu.is_capturing())
	assert_eq(menu.hint.text, tr("BIND_LAST_PAD") % _name(&"sprint"))
	menu._input(Helpers.pad_button(JOY_BUTTON_START))
