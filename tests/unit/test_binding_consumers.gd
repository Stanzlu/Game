extends GutTest
## Everything that names a key follows a rebinding at once, and the keys that must never fail
## (Esc, Start, Enter, the answers of a conversation) keep working after any rebinding.

const BootScript := preload("res://core/boot/boot.gd")
const SANDBOX := preload("res://world/levels/sandbox.tscn")
const BOOT_SCENE := preload("res://core/boot/boot.tscn")
const BOX := preload("res://ui/dialogue/dialogue_box.tscn")
const ASK := (
	"~ ask\n"
	+ "Mira: Bleibst du noch?\n"
	+ "- Ja\n"
	+ "\tdo WorldState.add_gold(100)\n"
	+ "\tMira: Gut.\n"
	+ "- Nein\n"
	+ "\tMira: Schade.\n"
	+ "=> END\n"
)
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD

var _saved_dir := ""


func before_each() -> void:
	# a start menu of its own: the saves of the other tests must not show up in it
	_saved_dir = SaveSystem.save_dir
	SaveSystem.save_dir = RuntimeEnv.user_dir() + "consumer_test_saves"


func after_each() -> void:
	SaveSystem.save_dir = _saved_dir
	Settings.bindings.reset()
	Settings.apply_all()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	get_tree().paused = false
	ScreenFade.fade_in(0.0)
	WorldState.new_game()


func _key(code: int) -> Dictionary:
	return {"type": "key", "physical_keycode": code}


func _bind(action: StringName, slot: int, code: int) -> void:
	assert_eq(Settings.bindings.bind(action, KB, slot, _key(code)).code, InputBindings.Code.OK)


func _sandbox() -> GameScene:
	var scene: GameScene = SANDBOX.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	# the pause menu opens only when no fade covers the screen
	for frame in 120:
		if MenuLayer.can_pause(get_tree()):
			break
		await wait_physics_frames(1)
	return scene


## A real key press and release as the operating system would send them.
func _press_key(code: int, hold_frames := 2) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.physical_keycode = code as Key
		key.keycode = code as Key
		key.pressed = pressed
		Input.parse_input_event(key)
		await wait_physics_frames(hold_frames)


func _press_button(index: int) -> void:
	for pressed: bool in [true, false]:
		var button := InputEventJoypadButton.new()
		button.button_index = index as JoyButton
		button.pressed = pressed
		Input.parse_input_event(button)
		await wait_physics_frames(2)


## The action pressed and released, two frames each so that every handler has seen it.
func _send(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		await wait_physics_frames(2)


func test_interaction_prompt_follows_a_rebinding() -> void:
	var scene := await _sandbox()
	var target := Interactable.new()
	scene.player.add_child(target)
	target.global_position = scene.player.global_position + Vector2(13, -3)
	scene.player.sensor.target_changed.emit(target)
	await wait_seconds(0.3)
	assert_true(scene.prompt.visible)
	assert_eq(scene.prompt._key.text, "E")
	_bind(&"interact", 0, KEY_F)
	assert_eq(scene.prompt._key.text, "F", "the cap shows the new key at once")
	assert_eq(scene.prompt._panel.modulate.a, 1.0, "and does not pop in a second time")
	assert_true(scene.prompt.visible)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_eq(scene.prompt._key.text, "A")
	Settings.bindings.reset()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_eq(scene.prompt._key.text, "E")


func test_a_rebinding_with_no_prompt_shown_is_harmless() -> void:
	var scene := await _sandbox()
	assert_false(scene.prompt.visible)
	_bind(&"interact", 0, KEY_F)
	assert_false(scene.prompt.visible, "nothing to show, nothing appears")


func test_start_menu_footer_follows_a_rebinding() -> void:
	var boot: Control = BOOT_SCENE.instantiate()
	add_child_autofree(boot)
	await wait_physics_frames(4)
	assert_true(boot._hint.text.contains("WASD") and boot._hint.text.contains("E"), boot._hint.text)
	_bind(&"sprint", 0, KEY_F)
	assert_true(boot._hint.text.contains("Rennen: F"), boot._hint.text)
	_bind(&"move_up", 0, KEY_I)
	assert_true(boot._hint.text.contains("IASD"), boot._hint.text)
	Settings.bindings.clear(&"move_up", KB, 0)
	Settings.bindings.clear(&"move_down", KB, 0)
	Settings.bindings.clear(&"move_left", KB, 0)
	Settings.bindings.clear(&"move_right", KB, 0)
	assert_true(boot._hint.text.contains("Pfeiltasten"), boot._hint.text)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_true(boot._hint.text.contains("Stick"), boot._hint.text)


func test_pause_hint_follows_a_rebinding() -> void:
	var scene := await _sandbox()
	scene.pause_menu.open()
	assert_true(scene.pause_menu.hint.text.contains("J"), scene.pause_menu.hint.text)
	_bind(&"journal", 0, KEY_K)
	assert_true(scene.pause_menu.hint.text.contains("K Journal"), scene.pause_menu.hint.text)
	scene.pause_menu.controls_menu.open()
	_bind(&"journal", 0, KEY_L)
	assert_true(scene.pause_menu.hint.text.contains("L Journal"), "also behind a stacked page")
	scene.pause_menu.controls_menu.close()
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_true(scene.pause_menu.hint.text.contains("Select"), scene.pause_menu.hint.text)
	scene.pause_menu.close()


func test_a_closed_pause_menu_does_not_build_its_hint() -> void:
	var scene := await _sandbox()
	var before: String = scene.pause_menu.hint.text
	_bind(&"journal", 0, KEY_K)
	assert_eq(scene.pause_menu.hint.text, before, "nothing to refresh while it is closed")
	scene.pause_menu.open()
	assert_true(scene.pause_menu.hint.text.contains("K Journal"), "but opening builds it new")
	scene.pause_menu.close()


func test_esc_and_start_still_open_the_pause_menu_after_any_rebinding() -> void:
	var scene := await _sandbox()
	_bind(&"menu", 0, KEY_F)
	assert_false(Settings.bindings.effective(&"menu", KB).has(_key(KEY_TAB)), "Tab is free now")
	await _press_key(KEY_TAB)
	assert_false(scene.pause_menu.is_open(), "Tab no longer opens it")
	await _press_key(KEY_ESCAPE)
	assert_true(scene.pause_menu.is_open(), "Esc is pinned on menu")
	await _press_key(KEY_ESCAPE)
	assert_false(scene.pause_menu.is_open(), "and closes it again")
	await _press_key(KEY_F)
	assert_true(scene.pause_menu.is_open(), "the new key works")
	await _press_key(KEY_F)
	await _press_button(JOY_BUTTON_START)
	assert_true(scene.pause_menu.is_open(), "Start opens it")
	await _press_button(JOY_BUTTON_START)
	assert_false(scene.pause_menu.is_open(), "and closes it")
	# the pad's extra buttons come on top of Start, they never replace it
	Settings.bindings.bind(
		&"menu", PAD, 0, {"type": "joy_button", "button": JOY_BUTTON_LEFT_SHOULDER}
	)
	await _press_button(JOY_BUTTON_START)
	assert_true(scene.pause_menu.is_open())
	await _press_button(JOY_BUTTON_START)


func test_enter_still_confirms_after_rebinding_interact() -> void:
	var scene := await _sandbox()
	_bind(&"interact", 0, KEY_F)
	_bind(&"interact", 1, KEY_G)
	assert_eq(Settings.bindings.slots(&"interact", KB).size(), 2)
	await _send(&"menu")
	assert_true(scene.pause_menu.is_open())
	assert_true(scene.pause_menu.list.buttons()[0].has_focus(), "Weiter has the focus")
	await _press_key(KEY_ENTER)
	assert_false(scene.pause_menu.is_open(), "Enter pressed Weiter")
	await _send(&"menu")
	await _press_key(KEY_KP_ENTER)
	assert_false(scene.pause_menu.is_open(), "so does the keypad's Enter")
	await _send(&"menu")
	await _press_key(KEY_F)
	assert_false(scene.pause_menu.is_open(), "and the new interact key")


func _box_with_answers(cue_text := ASK) -> DialogueBox:
	WorldState.new_game()
	Settings.set_value("text.speed", 1, false)
	var box: DialogueBox = BOX.instantiate()
	add_child_autofree(box)
	box.present(DialogueManager.create_resource_from_text(cue_text), "ask")
	await wait_seconds(0.1)
	await _send(&"interact")  # finishes typing, the answers appear
	await wait_physics_frames(3)
	return box


func _gold() -> int:
	return WorldState.state.elysia.gold


func test_dialogue_answers_accept_ui_accept() -> void:
	# interact has left Space and Enter is the only confirm key of ui_accept it still shares
	_bind(&"interact", 1, KEY_G)
	var box := await _box_with_answers()
	assert_true(box._responses.visible)
	var gold_before := _gold()
	await _press_key(KEY_SPACE)
	assert_eq(_gold(), gold_before, "the guard window still swallows an early press")
	await wait_seconds(0.4)
	await _press_key(KEY_SPACE)
	await wait_seconds(0.2)
	assert_eq(_gold(), gold_before + 100, "Space (ui_accept only) picks the focused answer")


func test_a_second_ui_accept_does_not_run_the_answer_twice() -> void:
	_bind(&"interact", 1, KEY_G)
	var box := await _box_with_answers()
	var gold_before := _gold()
	await wait_seconds(0.4)
	for i in 3:
		await _send(&"ui_accept")
	await wait_seconds(0.3)
	assert_eq(_gold(), gold_before + 100, "once")
	assert_not_null(box)


func test_a_press_that_is_both_interact_and_ui_accept_picks_once() -> void:
	# Enter is pinned on interact and is ui_accept too: the addon's own path, not picked twice
	var box := await _box_with_answers()
	var gold_before := _gold()
	await wait_seconds(0.4)
	await _press_key(KEY_ENTER)
	await wait_seconds(0.3)
	assert_eq(_gold(), gold_before + 100)
	assert_not_null(box)


func test_ui_accept_follows_the_focused_answer() -> void:
	_bind(&"interact", 1, KEY_G)
	var box := await _box_with_answers()
	await wait_seconds(0.4)
	var items := box._responses.get_menu_items()
	assert_eq(items.size(), 2)
	(items[1] as Control).grab_focus()
	var gold_before := _gold()
	await _send(&"ui_accept")
	await wait_seconds(0.3)
	assert_eq(_gold(), gold_before, "the second answer is picked, not the first (+100)")
	assert_eq(box.line.text, "Schade.", "the conversation went on with the second answer")


func test_a_hidden_second_page_keeps_its_hands_off_the_focus() -> void:
	var scene := await _sandbox()
	var pause: PauseMenu = scene.pause_menu
	pause.open()
	var settings: SettingsMenu = pause.settings_menu
	settings.open()
	settings._show_controls()
	var visible_page: ControlsMenu = settings._controls
	assert_ne(visible_page, pause.controls_menu, "two pages exist, the Settings one is shown")
	await wait_physics_frames(3)
	var focus := get_viewport().gui_get_focus_owner()
	assert_not_null(focus)
	assert_true(visible_page.is_ancestor_of(focus), "the shown page owns the focus")
	pause.controls_menu.rebuild()
	await wait_physics_frames(3)
	assert_eq(get_viewport().gui_get_focus_owner(), focus, "a hidden page does not take it")
	visible_page.close()
	settings.close()
	await wait_physics_frames(2)
	var back_in_pause := get_viewport().gui_get_focus_owner()
	assert_true(pause.list.buttons().has(back_in_pause), "the pause menu has it again")
	settings.rebuild()
	await wait_physics_frames(3)
	assert_eq(get_viewport().gui_get_focus_owner(), back_in_pause, "a closed menu keeps out of it")
	pause.close()


func test_a_shown_menu_still_keeps_its_row_when_it_rebuilds() -> void:
	var scene := await _sandbox()
	var settings: SettingsMenu = scene.pause_menu.settings_menu
	settings.open()
	await wait_physics_frames(2)
	var row := settings.list.buttons()[3]
	row.grab_focus()
	settings.rebuild()
	await wait_physics_frames(3)
	var focused := get_viewport().gui_get_focus_owner()
	assert_eq(settings.list.buttons().find(focused), 3, "the third row again")
	settings.close()


func test_the_controls_hint_of_the_start_menu_uses_the_walk_label() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	assert_true(
		BootScript.controls_hint().contains(InputDevice.move_label(InputDevice.Kind.KEYBOARD))
	)
	InputDevice.set_kind(InputDevice.Kind.GAMEPAD)
	assert_true(
		BootScript.controls_hint().contains(InputDevice.move_label(InputDevice.Kind.GAMEPAD))
	)
