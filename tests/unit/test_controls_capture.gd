extends GutTest
## What the key layout page does while a capture waits and what it answers to the rules:
## starting, binding, cancelling, clearing, refusals, conflicts and the reset.

const Helpers := preload("res://tests/unit/controls_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()
	Settings.set_value("display.screen_shake", true, false)
	Settings.set_value("display.reduce_flashing", false, false)
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


func test_activating_a_cell_starts_the_capture() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"sprint", KB)
	menu.row_for(&"sprint", KB).button.pressed.emit()
	assert_true(menu.is_capturing())
	assert_eq(menu.title.text, "BIND_PRESS_KEY", "the title asks for a key")
	assert_eq(menu.hint.text, tr("BIND_CAPTURE_KEYS") % [_name(&"sprint"), "Esc", "Entf"])
	assert_eq(menu.cell_text(&"sprint", KB, 0), BindingRow.CAPTURE_TEXT)
	assert_eq(menu.row_for(&"sprint", KB).cell_state(0), BindingRow.State.CAPTURING)
	var dimmed := 0
	for node in menu.list.get_children():
		if node is Control and not node is MenuCursor:
			var shown := node != menu.row_for(&"sprint", KB).button
			assert_eq((node as Control).modulate.a, 0.5 if shown else 1.0, str(node))
			dimmed += int(shown)
	assert_gt(dimmed, 10, "the rest of the list steps back")
	menu._input(Helpers.key(KEY_ESCAPE))
	for node in menu.list.get_children():
		if node is Control:
			assert_eq((node as Control).modulate.a, 1.0, "nothing stays dimmed: " + str(node))
	assert_eq(menu.title.text, "CONTROLS_TITLE")


func test_a_pad_cell_asks_for_a_button() -> void:
	var menu := await _open()
	assert_true(Input.get_connected_joypads().is_empty(), "the test machine has no pad")
	Helpers.capture(menu, &"sprint", PAD, 0)
	assert_eq(menu.title.text, "BIND_PRESS_PAD")
	assert_eq(menu.hint.text, tr("BIND_NO_PAD") % "Esc", "no pad found: say so")
	menu._input(Helpers.key(KEY_ESCAPE))
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	Helpers.capture(menu, &"sprint", PAD, 0)
	assert_eq(menu.hint.text, tr("BIND_CAPTURE_PAD") % [_name(&"sprint"), "Start", "Y"])
	menu._input(Helpers.pad_button(JOY_BUTTON_START))


func test_a_pressed_key_is_bound() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_F))
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_F])
	assert_eq(menu.cell_text(&"journal", KB, 0), "F")
	assert_false(menu.is_capturing())
	assert_eq(menu.title.text, "CONTROLS_TITLE", "the title is back")
	assert_eq(menu.hint.text, tr("BIND_DONE") % [_name(&"journal"), "F"])
	menu._input(Helpers.key(KEY_F, false))
	assert_false(menu.is_capturing(), "the release does not start it again")
	assert_eq(InputDevice.label_for(&"journal"), "F", "the rest of the game knows at once")


func test_the_arming_window_passes_with_the_frames() -> void:
	var menu := await _open()
	menu.begin_capture(&"journal", KB, 0)
	menu._input(Helpers.key(KEY_F))
	assert_true(menu.is_capturing(), "the press that started it must not count")
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_J])
	await wait_seconds(BindingCapture.ARM_SECONDS + 0.2)
	menu._input(Helpers.key(KEY_F))
	assert_false(menu.is_capturing(), "a little later it counts")
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_F])


func test_esc_and_start_cancel_without_closing_the_page() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB)
	menu._input(Helpers.key(KEY_ESCAPE))
	assert_false(menu.is_capturing())
	assert_true(menu.is_open(), "Esc cancels the capture, not the page")
	Helpers.capture(menu, &"journal", PAD)
	menu._input(Helpers.pad_button(JOY_BUTTON_START))
	assert_false(menu.is_capturing())
	assert_true(menu.is_open())
	assert_false(Settings.bindings.is_overridden(), "nothing was bound")


func test_the_cancel_action_cancels_a_capture_and_the_window_losing_focus_too() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB)
	# an action event (autopilot, tests) does not pass the capture: the page's own handler
	menu._unhandled_input(Helpers.action(&"cancel"))
	assert_false(menu.is_capturing())
	assert_true(menu.is_open())
	Helpers.capture(menu, &"journal", KB)
	menu._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_false(menu.is_capturing(), "Alt+Tab ends it quietly")
	assert_true(menu.is_open())
	# closing the page from outside ends it too
	Helpers.capture(menu, &"journal", KB)
	menu.close()
	assert_false(menu.is_capturing())


func test_a_click_cancels_and_the_wheel_does_not() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB)
	menu._input(Helpers.click(MOUSE_BUTTON_WHEEL_DOWN))
	assert_true(menu.is_capturing(), "scrolling the list is not a click")
	menu._input(Helpers.click(MOUSE_BUTTON_LEFT, false))
	assert_true(menu.is_capturing(), "a release changes nothing")
	menu._input(Helpers.click(MOUSE_BUTTON_LEFT))
	assert_false(menu.is_capturing(), "a click elsewhere cancels")
	for button: int in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		Helpers.capture(menu, &"journal", KB)
		menu._input(Helpers.click(button))
		assert_false(menu.is_capturing(), "every button counts")


func test_the_mouse_cannot_move_the_focus_during_a_capture() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"journal", KB)
	Helpers.capture(menu, &"journal", KB)
	var other := menu.row_for(&"sprint", KB).button
	assert_eq(other.mouse_filter, Control.MOUSE_FILTER_IGNORE, "hover cannot reach another row")
	assert_eq(
		menu.row_for(&"journal", KB).button.mouse_filter,
		Control.MOUSE_FILTER_STOP,
		"the row that waits keeps its own"
	)
	menu._input(Helpers.key(KEY_ESCAPE))
	assert_eq(other.mouse_filter, Control.MOUSE_FILTER_STOP, "and gets it back")


func test_delete_clears_in_a_capture_and_when_idle() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"interact", KB, 1)
	menu._input(Helpers.key(KEY_DELETE))
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_E], "the cell is emptied")
	assert_false(menu.is_capturing())
	assert_eq(menu.hint.text, tr("BIND_CLEARED") % ["Leertaste", _name(&"interact")])
	# the only key of Rennen stays
	Helpers.capture(menu, &"sprint", KB, 0)
	menu._input(Helpers.key(KEY_DELETE))
	assert_eq(menu.hint.text, tr("BIND_LAST") % _name(&"sprint"))
	assert_true(menu.is_capturing(), "a refusal keeps the capture")
	menu._input(Helpers.key(KEY_ESCAPE))
	# an empty cell
	Helpers.capture(menu, &"cancel", KB, 1)
	menu._input(Helpers.key(KEY_DELETE))
	assert_eq(menu.hint.text, tr("BIND_NOTHING"))
	menu._input(Helpers.key(KEY_ESCAPE))
	# on the pad the last button says so in its own word
	Helpers.capture(menu, &"sprint", PAD, 0)
	menu._input(Helpers.key(KEY_DELETE))
	assert_eq(Helpers.slots(&"sprint", PAD).size(), 1)
	Helpers.capture(menu, &"sprint", PAD, 0)
	menu._input(Helpers.key(KEY_DELETE))
	assert_eq(menu.hint.text, tr("BIND_LAST_PAD") % _name(&"sprint"))


func test_idle_delete_ignores_a_repeat_and_pad_y_clears_once() -> void:
	var menu := await _open()
	Helpers.focus(menu, &"interact", KB)
	var button := menu.row_for(&"interact", KB).button
	button.gui_input.emit(Helpers.key(KEY_DELETE, true, true))
	assert_eq(Helpers.slots(&"interact", KB).size(), 2, "a held key repeats: only the first counts")
	button.gui_input.emit(Helpers.key(KEY_DELETE))
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_SPACE])
	button.gui_input.emit(Helpers.key(KEY_DELETE, false))
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_SPACE], "a release does nothing")
	Helpers.focus(menu, &"sprint", PAD)
	var pad_row := menu.row_for(&"sprint", PAD).button
	pad_row.gui_input.emit(Helpers.pad_button(JOY_BUTTON_Y, false))
	assert_eq(Helpers.slots(&"sprint", PAD).size(), 2)
	pad_row.gui_input.emit(Helpers.pad_button(JOY_BUTTON_Y))
	assert_eq(Helpers.slots(&"sprint", PAD).size(), 1, "Y empties the chosen cell")
	assert_eq(menu.hint.text, tr("BIND_CLEARED") % ["X", _name(&"sprint")])


func test_a_refused_key_shows_a_message_and_keeps_capturing() -> void:
	var menu := await _open()
	var sprint := _name(&"sprint")
	var cases: Array[Array] = [
		[&"journal", KB, Helpers.key(KEY_ENTER), tr("BIND_FIXED_KEY") % "Enter"],
		[&"journal", KB, Helpers.key(KEY_PAGEUP), tr("BIND_FIXED_KEY") % "Bild auf"],
		[&"journal", KB, Helpers.key(KEY_W), tr("BIND_RESERVED_FOR") % ["W", tr("CONTROLS_MOVE")]],
		# Space and Tab are kept for two actions each: reserved, not fixed (Rennen may have them)
		[
			&"journal",
			KB,
			Helpers.key(KEY_SPACE),
			tr("BIND_RESERVED_TWO") % ["Leertaste", _name(&"interact"), sprint]
		],
		[
			&"journal",
			KB,
			Helpers.key(KEY_TAB),
			tr("BIND_RESERVED_TWO") % ["Tab", _name(&"menu"), sprint]
		],
		[&"journal", KB, Helpers.key(KEY_CAPSLOCK), tr("BIND_INVALID")],
		[&"journal", KB, Helpers.pad_button(JOY_BUTTON_B), tr("BIND_ONLY_KEY")],
		[&"journal", KB, Helpers.key(KEY_UNKNOWN), tr("BIND_INVALID")],
		[&"interact", KB, Helpers.key(KEY_E), tr("BIND_SAME_ACTION") % [_name(&"interact"), "E"]],
		[&"journal", PAD, Helpers.pad_axis(JOY_AXIS_LEFT_X, 1.0), tr("BIND_STICK")],
		[&"journal", PAD, Helpers.key(KEY_F), tr("BIND_ONLY_PAD")],
		[
			&"journal",
			PAD,
			Helpers.pad_button(JOY_BUTTON_DPAD_UP),
			tr("BIND_FIXED_KEY") % "Steuerkreuz"
		],
		[&"journal", PAD, Helpers.pad_button(JOY_BUTTON_GUIDE), tr("BIND_INVALID")],
		[
			&"interact",
			PAD,
			Helpers.pad_axis(JOY_AXIS_TRIGGER_RIGHT, 1.0),
			tr("BIND_TRIGGER") % sprint
		],
	]
	for item in cases:
		var action: StringName = item[0]
		var device: InputBindings.Device = item[1]
		var cell := 1 if action == &"interact" and device == KB else 0
		InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
		Helpers.capture(menu, action, device, cell)
		menu._input(item[2])
		var label := "%s %d %s" % [action, device, item[3]]
		assert_eq(menu.hint.text, item[3], label)
		assert_true(menu.is_capturing(), "still capturing: " + label)
		menu._input(Helpers.key(KEY_ESCAPE))
	assert_false(Settings.bindings.is_overridden(), "nothing was bound by a refusal")


func test_the_capture_hint_comes_back_at_the_next_key_and_after_a_while() -> void:
	var menu := await _open()
	menu.message_seconds = 0.2
	Helpers.capture(menu, &"journal", KB)
	var capture_hint := menu.hint.text
	menu._input(Helpers.key(KEY_ENTER))
	assert_ne(menu.hint.text, capture_hint, "the refusal is shown")
	await wait_seconds(0.5)
	assert_eq(menu.hint.text, capture_hint, "after the message the capture hint is back")
	menu._input(Helpers.key(KEY_ENTER))
	assert_ne(menu.hint.text, capture_hint)
	menu._input(Helpers.key(KEY_ENTER, false))
	menu._input(Helpers.key(KEY_PAGEUP))
	assert_eq(
		menu.hint.text, tr("BIND_FIXED_KEY") % "Bild auf", "the next key replaces the message"
	)
	menu._input(Helpers.key(KEY_ESCAPE))


func test_a_conflict_asks_and_swaps() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_E))
	var question := menu._confirm
	assert_true(question.is_open(), "E belongs to Ansehen")
	assert_false(menu.is_capturing(), "the capture is over, the question has the floor")
	assert_eq(question.list.buttons().find(get_viewport().gui_get_focus_owner()), 1, "safe answer")
	var asked := tr("BIND_ASK_SWAP") % ["E", _name(&"interact"), "J"]
	var shown: Array[String] = []
	for node in question.list.get_children():
		if node is Label:
			shown.append((node as Label).text)
	assert_eq(shown, [asked], "the names of the keys and actions are in the question")
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_J], "nothing changes before the answer")
	question.list.buttons()[0].pressed.emit()
	assert_eq(Helpers.slots(&"journal", KB), ["k%d" % KEY_E])
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_J, "k%d" % KEY_SPACE])
	assert_eq(menu.cell_text(&"interact", KB, 0), "J", "both rows show it")
	assert_eq(menu.hint.text, tr("BIND_DONE_SWAP") % [_name(&"journal"), _name(&"interact")])
	assert_false(question.is_open())


func test_a_conflict_can_be_declined_with_the_answer_or_with_back() -> void:
	var menu := await _open()
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_E))
	menu._confirm.list.buttons()[1].pressed.emit()
	assert_false(Settings.bindings.is_overridden(), "Abbrechen changes nothing")
	Helpers.capture(menu, &"journal", KB, 0)
	menu._input(Helpers.key(KEY_E))
	menu._confirm._unhandled_input(Helpers.action(&"cancel"))
	assert_false(menu._confirm.is_open())
	assert_false(Settings.bindings.is_overridden(), "back answers no")
	assert_true(menu.is_open(), "the page stays")


func test_a_conflict_without_swap_offers_to_take_the_key() -> void:
	var menu := await _open()
	# W cannot move to Ansehen (walking keys belong to walking): no swap, but Ansehen has more
	Helpers.capture(menu, &"move_up", KB, 0)
	menu._input(Helpers.key(KEY_E))
	var question := menu._confirm
	assert_true(question.is_open())
	var shown: Array[String] = []
	for node in question.list.get_children():
		if node is Label:
			shown.append((node as Label).text)
	assert_eq(shown, [tr("BIND_ASK_TAKE") % ["E", _name(&"interact")]])
	assert_eq(question.list.buttons()[0].text, tr("BIND_TAKE"))
	question.list.buttons()[0].pressed.emit()
	assert_eq(Helpers.slots(&"move_up", KB), ["k%d" % KEY_E, "k%d" % KEY_UP])
	assert_eq(Helpers.slots(&"interact", KB), ["k%d" % KEY_SPACE], "Ansehen keeps Leertaste")
	assert_eq(menu.hint.text, tr("BIND_DONE") % [_name(&"move_up"), "E"])


func test_a_conflict_with_a_sole_binding_is_explained() -> void:
	var menu := await _open()
	# Umschalt is the only key of Rennen and a free cell has nothing to swap
	Helpers.capture(menu, &"journal", KB, 1)
	menu._input(Helpers.key(KEY_SHIFT))
	menu._input(Helpers.key(KEY_SHIFT, false))
	assert_eq(menu.hint.text, tr("BIND_SOLE") % ["Umschalt", _name(&"sprint")])
	assert_true(menu.is_capturing(), "the next key can be tried at once")
	assert_true(menu._confirm == null or not menu._confirm.is_open(), "no question")
	menu._input(Helpers.key(KEY_ESCAPE))
	# and the pad says button
	Helpers.capture(menu, &"journal", PAD, 1)
	menu._input(Helpers.pad_button(JOY_BUTTON_B))
	assert_eq(menu.hint.text, tr("BIND_SOLE_PAD") % ["B", _name(&"cancel")])


func test_the_reset_asks_first_and_is_always_there() -> void:
	var menu := await _open()
	var reset := menu.list.buttons()[menu.list.buttons().size() - 2]
	assert_eq(reset.text, tr("BIND_RESET_ALL"))
	assert_false(reset.disabled, "the row is never greyed out")
	reset.pressed.emit()
	assert_eq(menu.hint.text, tr("BIND_ALREADY_DEFAULT"), "nothing to reset: say so")
	assert_true(menu._confirm == null or not menu._confirm.is_open(), "no pointless question")
	Settings.bindings.bind(&"journal", KB, 0, Helpers.data(KEY_K))
	reset.pressed.emit()
	var question := menu._confirm
	assert_true(question.is_open())
	assert_eq(question.list.buttons().find(get_viewport().gui_get_focus_owner()), 1, "safe answer")
	question.list.buttons()[1].pressed.emit()
	assert_true(Settings.bindings.is_overridden(), "Abbrechen keeps everything")
	reset.grab_focus()
	reset.pressed.emit()
	question.list.buttons()[0].pressed.emit()
	await wait_physics_frames(2)
	assert_false(Settings.bindings.is_overridden())
	assert_eq(menu.hint.text, tr("BIND_RESET_DONE"))
	assert_eq(menu.list.buttons().find(get_viewport().gui_get_focus_owner()), 0, "first row again")
	assert_eq(menu.cell_text(&"journal", KB, 0), "J")
