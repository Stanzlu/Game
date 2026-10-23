extends GutTest
## InputBindings.apply against the real InputMap: display order, deadzones, held keys, and
## healing a map somebody else changed. Every test puts the autoload's layout back.

const H := preload("res://tests/unit/binding_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD

var live: InputBindings


func before_each() -> void:
	live = InputBindings.new()


func after_each() -> void:
	_hold_shift(false)
	Settings.bindings.reset()
	Settings.apply_all()


## The ids of the events the InputMap holds for an action, in its order.
func _map(action: StringName) -> Array[String]:
	var out: Array[String] = []
	for event in InputMap.action_get_events(action):
		out.append(BindingCodec.event_id(BindingCodec.encode(event)))
	return out


func _hold_shift(pressed: bool) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SHIFT
	key.pressed = pressed
	Input.parse_input_event(key)
	Input.flush_buffered_events()


func test_apply_writes_display_order_and_keeps_the_deadzone() -> void:
	live.bind(&"interact", KB, 0, H.key(KEY_F))
	assert_eq(
		_map(&"interact"),
		["k%d" % KEY_F, "k%d" % KEY_SPACE, "k%d" % KEY_ENTER, "k%d" % KEY_KP_ENTER, "b0"],
		"own keys first, the pinned ones behind, the pad after the keyboard"
	)
	assert_eq(InputMap.action_get_deadzone(&"interact"), 0.5)
	live.bind(&"cancel", KB, 1, H.key(KEY_G))
	assert_eq(
		_map(&"cancel"),
		["k%d" % KEY_ESCAPE, "k%d" % KEY_BACKSPACE, "k%d" % KEY_G, "b1"],
		"Esc stays first"
	)
	live.bind(&"move_up", KB, 0, H.key(KEY_Q))
	assert_eq(_map(&"move_up"), ["k%d" % KEY_Q, "k%d" % KEY_UP, "a1-", "b11"])
	var walk_zone := InputMap.action_get_deadzone(&"move_up")
	assert_almost_eq(walk_zone, 0.2, 0.0001, "walking keeps its small deadzone")
	live.bind(&"menu", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	assert_eq(_map(&"menu"), ["k%d" % KEY_ESCAPE, "k%d" % KEY_TAB, "b6", "b9"])
	for action in InputBindings.ACTIONS:
		for event in InputMap.action_get_events(action):
			assert_eq(event.device, -1, "every event listens to all devices")


func test_apply_releases_only_changed_actions() -> void:
	_hold_shift(true)
	assert_true(Input.is_action_pressed(&"sprint"), "the held key is the sprint key")
	live.bind(&"journal", KB, 0, H.key(KEY_K))
	assert_true(Input.is_action_pressed(&"sprint"), "rebinding something else lets it be")
	live.bind(&"sprint", KB, 0, H.key(KEY_F))
	assert_false(Input.is_action_pressed(&"sprint"), "its meaning changed: it is let go")
	assert_false(Input.is_action_pressed(&"journal"))


func test_a_full_apply_leaves_a_held_key_alone_when_nothing_differs() -> void:
	# the start-up path and "Einstellungen zurücksetzen" rewrite all nine actions
	_hold_shift(true)
	assert_true(Input.is_action_pressed(&"sprint"))
	live.apply()
	assert_true(Input.is_action_pressed(&"sprint"), "InputBindings.apply() with nothing to do")
	Settings.apply_all()
	assert_true(Input.is_action_pressed(&"sprint"), "Settings.apply_all() with nothing to do")
	Settings.bindings.bind(&"sprint", KB, 0, H.key(KEY_F))
	assert_false(Input.is_action_pressed(&"sprint"), "its keys changed: let go")


func test_apply_heals_a_foreign_change() -> void:
	var wanted := _map(&"interact")
	InputMap.action_erase_events(&"interact")
	assert_true(_map(&"interact").is_empty())
	live.apply()
	assert_eq(_map(&"interact"), wanted)
	InputMap.action_erase_events(&"journal")
	live.apply(PackedStringArray(["interact"]))
	assert_true(_map(&"journal").is_empty(), "only the named actions are looked at")
	live.apply(PackedStringArray(["journal"]))
	assert_eq(_map(&"journal"), ["k%d" % KEY_J, "b4"])


func test_a_model_without_a_live_map_leaves_the_input_map_alone() -> void:
	var pure := InputBindings.new(false)
	pure.bind(&"journal", KB, 0, H.key(KEY_K))
	pure.apply()
	assert_eq(_map(&"journal"), ["k%d" % KEY_J, "b4"])


func test_the_map_is_new_when_the_signal_arrives() -> void:
	var seen: Array = []
	live.changed.connect(
		func(names: PackedStringArray) -> void: seen.append([names, _map(&"interact")])
	)
	live.bind(&"interact", KB, 0, H.key(KEY_F))
	assert_eq(seen.size(), 1)
	assert_eq((seen[0] as Array)[0], PackedStringArray(["interact"]))
	assert_eq(((seen[0] as Array)[1] as Array)[0], "k%d" % KEY_F, "the map already follows")


func test_a_swap_reaches_both_actions_in_the_map() -> void:
	live.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.SWAP)
	assert_eq(_map(&"journal"), ["k%d" % KEY_E, "b4"])
	assert_eq(_map(&"interact")[0], "k%d" % KEY_J)
	live.reset()
	assert_eq(_map(&"journal"), ["k%d" % KEY_J, "b4"])
	assert_eq(_map(&"interact")[0], "k%d" % KEY_E, "reset puts every action back")


func test_apply_does_not_touch_actions_that_are_not_rebindable() -> void:
	var before := _map(&"ui_accept")
	var scroll := _map(&"scroll_up")
	live.bind(&"interact", KB, 0, H.key(KEY_F))
	live.apply()
	assert_eq(_map(&"ui_accept"), before, "Enter and Space still confirm in every menu")
	assert_eq(_map(&"scroll_up"), scroll)
