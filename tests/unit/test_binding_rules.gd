extends GutTest
## The rules of the key layout (ADR-048): what may be bound where, conflicts and how they are
## settled. Pure model, nothing here touches the InputMap.

const H := preload("res://tests/unit/binding_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD
const CODE := InputBindings.Code
const RESOLVE := InputBindings.Resolve

const MOVES: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right"]

var model: InputBindings


func before_each() -> void:
	model = InputBindings.new(false)


func _check(action: StringName, device: InputBindings.Device, slot: int, data: Dictionary) -> int:
	return model.check(action, device, slot, data).code


func test_reserved_keys_are_refused() -> void:
	var nobody: Array[int] = [
		KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_PAGEUP, KEY_PAGEDOWN, KEY_F3, KEY_F4, KEY_DELETE
	]
	for code in nobody:
		var result := model.check(&"journal", KB, 0, H.key(code))
		assert_eq(result.code, CODE.RESERVED, "key %d" % code)
		assert_eq(result.owners, [] as Array[StringName], "nobody may hold %d" % code)
		assert_eq(result.other, &"")
	var walking: Array[int] = [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
	for code in walking:
		var result := model.check(&"journal", KB, 0, H.key(code))
		assert_eq(result.code, CODE.RESERVED, "key %d" % code)
		assert_eq(result.owners, MOVES, "walking only")
		assert_eq(result.other, &"move_up")
	var space := model.check(&"journal", KB, 0, H.key(KEY_SPACE))
	assert_eq(space.code, CODE.RESERVED)
	assert_eq(space.owners, [&"interact", &"sprint"] as Array[StringName])
	var tab := model.check(&"cancel", KB, 0, H.key(KEY_TAB))
	assert_eq(tab.code, CODE.RESERVED)
	assert_eq(tab.owners, [&"menu", &"sprint"] as Array[StringName])
	assert_eq(_check(&"interact", KB, 1, H.key(KEY_SPACE)), CODE.UNCHANGED, "its own key")
	assert_eq(_check(&"menu", KB, 0, H.key(KEY_TAB)), CODE.UNCHANGED, "its own key")
	assert_eq(_check(&"move_up", KB, 1, H.key(KEY_UP)), CODE.UNCHANGED, "its own key")


func test_the_pinned_events_cannot_be_given_to_their_own_action_either() -> void:
	# Enter and Esc and Start and A are part of the action already: not a cell's business
	assert_eq(_check(&"interact", KB, 0, H.key(KEY_ENTER)), CODE.RESERVED)
	assert_eq(_check(&"interact", KB, 1, H.key(KEY_KP_ENTER)), CODE.RESERVED)
	assert_eq(_check(&"cancel", KB, 0, H.key(KEY_ESCAPE)), CODE.RESERVED)
	assert_eq(_check(&"menu", KB, 1, H.key(KEY_ESCAPE)), CODE.RESERVED)
	assert_eq(_check(&"menu", PAD, 0, H.button(JOY_BUTTON_START)), CODE.RESERVED)
	assert_eq(_check(&"interact", PAD, 0, H.button(JOY_BUTTON_A)), CODE.RESERVED)
	assert_eq(_check(&"cancel", PAD, 0, H.button(JOY_BUTTON_A)), CODE.RESERVED)


func test_space_and_tab_may_also_go_to_sprint() -> void:
	# sprint is only polled, no menu or dialogue ever sees its key
	var space := model.check(&"sprint", KB, 0, H.key(KEY_SPACE))
	assert_eq(space.code, CODE.CONFLICT, "free for sprint, but interact has it")
	assert_eq(space.other, &"interact")
	assert_true(space.can_swap and space.can_take)
	var tab := model.check(&"sprint", KB, 1, H.key(KEY_TAB))
	assert_eq(tab.code, CODE.CONFLICT)
	assert_eq(tab.other, &"menu")
	assert_true(tab.can_take, "menu keeps Esc")
	assert_false(tab.can_swap, "cell 2 of sprint is empty: nothing to give back")
	var taken := model.bind(&"sprint", KB, 1, H.key(KEY_SPACE), RESOLVE.TAKE)
	assert_eq(taken.code, CODE.OK)
	assert_eq(H.slot_ids(model, &"sprint", KB), H.key_ids([KEY_SHIFT, KEY_SPACE]))
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_E]), "Enter stays pinned")
	assert_eq(H.violations(model), PackedStringArray())


func test_keys_that_can_never_be_bound() -> void:
	var blocked: Array[int] = [
		KEY_CAPSLOCK,
		KEY_NUMLOCK,
		KEY_SCROLLLOCK,
		KEY_ALT,
		KEY_META,
		KEY_BACK,
		KEY_FORWARD,
		KEY_STOP,
		KEY_REFRESH,
		KEY_VOLUMEDOWN,
		KEY_VOLUMEMUTE,
		KEY_VOLUMEUP,
		KEY_MEDIAPLAY,
		KEY_MEDIASTOP,
		KEY_MEDIAPREVIOUS,
		KEY_MEDIANEXT,
		KEY_MEDIARECORD,
		KEY_HOMEPAGE,
		KEY_FAVORITES,
		KEY_SEARCH,
		KEY_STANDBY,
		KEY_OPENURL,
		KEY_LAUNCHMAIL,
		KEY_LAUNCHMEDIA,
		KEY_LAUNCH0,
		KEY_LAUNCHF,
		KEY_GLOBE,
	]
	for code in blocked:
		var result := model.check(&"journal", KB, 0, H.key(code))
		assert_eq(result.code, CODE.INVALID_EVENT, "key %d" % code)
		assert_true(InputBindings.reservation(H.key(code)).has("blocked"))
	assert_eq(_check(&"journal", KB, 0, H.key(KEY_UNKNOWN)), CODE.INVALID_EVENT)
	assert_eq(_check(&"journal", KB, 0, H.key(0)), CODE.INVALID_EVENT)
	assert_eq(_check(&"journal", KB, 0, {}), CODE.INVALID_EVENT)
	assert_eq(_check(&"journal", KB, 0, {"type": "mouse"}), CODE.INVALID_EVENT)
	assert_eq(_check(&"journal", KB, 0, H.key(KEY_SHIFT)), CODE.CONFLICT, "bindable, sprint has it")
	for code: int in [KEY_CTRL, KEY_F13, KEY_MENU, KEY_KP_5, KEY_SEMICOLON, KEY_INSERT]:
		assert_eq(_check(&"journal", KB, 0, H.key(code)), CODE.OK, "may be bound: %d" % code)


func test_pad_rules() -> void:
	for index: int in [JOY_BUTTON_START, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_RIGHT]:
		var result := model.check(&"journal", PAD, 0, H.button(index))
		assert_eq(result.code, CODE.RESERVED, "button %d" % index)
		assert_true(result.owners.is_empty())
	assert_eq(_check(&"journal", PAD, 0, H.button(JOY_BUTTON_GUIDE)), CODE.INVALID_EVENT)
	assert_eq(_check(&"journal", PAD, 0, H.axis(JOY_AXIS_LEFT_X, -1.0)), CODE.STICK)
	assert_eq(_check(&"journal", PAD, 0, H.axis(JOY_AXIS_RIGHT_Y, 1.0)), CODE.STICK)
	assert_eq(
		_check(&"sprint", PAD, 0, H.axis(JOY_AXIS_LEFT_Y, 1.0)), CODE.STICK, "not even sprint"
	)
	assert_eq(_check(&"interact", PAD, 0, H.axis(JOY_AXIS_TRIGGER_LEFT, 1.0)), CODE.TRIGGER)
	assert_eq(_check(&"journal", PAD, 0, H.axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)), CODE.TRIGGER)
	assert_eq(_check(&"sprint", PAD, 0, H.axis(JOY_AXIS_TRIGGER_LEFT, 1.0)), CODE.OK)
	assert_eq(_check(&"sprint", PAD, 1, H.axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)), CODE.UNCHANGED)
	assert_eq(_check(&"sprint", PAD, 0, H.axis(JOY_AXIS_TRIGGER_LEFT, -1.0)), CODE.INVALID_EVENT)
	assert_eq(_check(&"sprint", PAD, 0, H.button(26)), CODE.INVALID_EVENT, "no such button")
	assert_eq(_check(&"journal", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER)), CODE.OK)
	assert_eq(
		_check(&"journal", PAD, 0, H.button(JOY_BUTTON_MISC1)), CODE.OK, "extra buttons count"
	)


func test_pad_a_is_pinned_on_interact_and_y_belongs_to_nobody() -> void:
	assert_eq(H.ids(model.fixed(&"interact", PAD)), ["b0"] as Array[String])
	assert_true(model.slots(&"interact", PAD).is_empty(), "two free cells next to the pinned A")
	assert_eq(model.clear(&"interact", PAD, 0), CODE.BAD_SLOT)
	for action: StringName in [&"journal", &"cancel", &"interact", &"sprint", &"menu"]:
		var y := model.check(action, PAD, 0, H.button(JOY_BUTTON_Y))
		assert_eq(y.code, CODE.RESERVED, "Y clears a cell on the page: %s" % action)
		assert_true(y.owners.is_empty())
	# an extra button next to A, shown first because own buttons come before pinned ones
	var taken := model.bind(&"interact", PAD, 0, H.button(JOY_BUTTON_X), RESOLVE.TAKE)
	assert_eq(taken.code, CODE.OK)
	assert_eq(H.effective_ids(model, &"interact", PAD), ["b2", "b0"] as Array[String])
	assert_eq(H.effective_ids(model, &"sprint", PAD), ["a5+"] as Array[String])


func test_device_mismatch() -> void:
	assert_eq(_check(&"journal", PAD, 0, H.key(KEY_K)), CODE.WRONG_DEVICE)
	assert_eq(_check(&"journal", KB, 0, H.button(JOY_BUTTON_LEFT_SHOULDER)), CODE.WRONG_DEVICE)
	assert_eq(_check(&"sprint", KB, 0, H.axis(JOY_AXIS_TRIGGER_LEFT, 1.0)), CODE.WRONG_DEVICE)
	assert_eq(H.layout(model), H.layout(InputBindings.new(false)), "nothing changed")


func test_the_order_of_the_checks() -> void:
	assert_eq(_check(&"nothing", PAD, 9, {}), CODE.UNKNOWN_ACTION, "the action first")
	assert_eq(_check(&"move_up", PAD, 9, {}), CODE.NOT_EDITABLE, "then the device")
	assert_eq(_check(&"journal", KB, 9, {}), CODE.BAD_SLOT, "then the cell")
	assert_eq(_check(&"journal", KB, 0, {}), CODE.INVALID_EVENT, "then the event")
	assert_eq(_check(&"journal", PAD, 0, H.key(0)), CODE.INVALID_EVENT, "before the device")
	assert_eq(_check(&"journal", PAD, 0, H.key(KEY_ENTER)), CODE.WRONG_DEVICE, "before the rules")
	assert_eq(_check(&"journal", KB, 0, H.key(KEY_ENTER)), CODE.RESERVED, "before conflicts")


func test_conflict_reports_holder_and_options() -> void:
	var result := model.check(&"journal", KB, 0, H.key(KEY_E))
	assert_eq(result.code, CODE.CONFLICT)
	assert_eq(result.other, &"interact")
	assert_eq(result.other_slot, 0)
	assert_true(result.can_swap)
	assert_true(result.can_take)
	assert_false(result.ok())
	assert_eq(result.data, H.key(KEY_E))
	var second := model.check(&"sprint", KB, 0, H.key(KEY_SPACE))
	assert_eq(second.other, &"interact")
	assert_eq(second.other_slot, 1, "the cell of the holder")
	var pad := model.check(&"journal", PAD, 0, H.button(JOY_BUTTON_B))
	assert_eq(pad.other, &"cancel")
	assert_eq(model.check(&"journal", KB, 0, H.key(KEY_K)).code, CODE.OK)
	assert_eq(H.layout(model), H.layout(InputBindings.new(false)), "check changes nothing")


func test_swap_exchanges_both_slots() -> void:
	var result := model.bind(&"journal", KB, 0, H.key(KEY_E), RESOLVE.SWAP)
	assert_eq(result.code, CODE.OK)
	assert_eq(result.other, &"interact", "the other action that was touched")
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_E]))
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_J, KEY_SPACE]))
	assert_eq(H.violations(model), PackedStringArray())
	var back := model.bind(&"journal", KB, 0, H.key(KEY_J), RESOLVE.SWAP)
	assert_eq(back.code, CODE.OK)
	assert_false(model.is_overridden(), "swapped back: the defaults again")


func test_take_removes_it_from_the_other() -> void:
	var result := model.bind(&"journal", KB, 0, H.key(KEY_E), RESOLVE.TAKE)
	assert_eq(result.code, CODE.OK)
	assert_eq(result.other, &"interact")
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_E]))
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_SPACE]), "compact: Space moved up")
	assert_eq(H.effective_ids(model, &"interact", KB)[0], "k%d" % KEY_SPACE)
	assert_eq(H.violations(model), PackedStringArray())


func test_swap_is_not_offered_when_the_other_cannot_hold_the_key() -> void:
	# ESDF: W belongs to walking, interact may not have it, so only taking E is possible
	var result := model.check(&"move_up", KB, 0, H.key(KEY_E))
	assert_eq(result.code, CODE.CONFLICT)
	assert_false(result.can_swap)
	assert_true(result.can_take)
	var refused := model.bind(&"move_up", KB, 0, H.key(KEY_E), RESOLVE.SWAP)
	assert_eq(refused.code, CODE.CONFLICT, "a swap that is not possible changes nothing")
	assert_eq(H.slot_ids(model, &"move_up", KB), H.key_ids([KEY_W, KEY_UP]))
	var taken := model.bind(&"move_up", KB, 0, H.key(KEY_E), RESOLVE.TAKE)
	assert_eq(taken.code, CODE.OK)
	assert_eq(H.slot_ids(model, &"move_up", KB), H.key_ids([KEY_E, KEY_UP]))
	assert_eq(H.effective_ids(model, &"interact", KB)[0], "k%d" % KEY_SPACE)
	assert_eq(H.violations(model), PackedStringArray())


func test_take_is_refused_for_the_last_binding() -> void:
	# B is the only pad button of cancel; Shift the only key of sprint
	var pad := model.check(&"journal", PAD, 1, H.button(JOY_BUTTON_B))
	assert_eq(pad.code, CODE.CONFLICT)
	assert_false(pad.can_swap or pad.can_take)
	assert_eq(
		model.bind(&"journal", PAD, 1, H.button(JOY_BUTTON_B), RESOLVE.TAKE).code,
		CODE.LAST_BINDING,
		"taking it would leave cancel without a button"
	)
	assert_eq(
		model.bind(&"journal", PAD, 1, H.button(JOY_BUTTON_B), RESOLVE.SWAP).code, CODE.CONFLICT
	)
	var keys := model.check(&"journal", KB, 1, H.key(KEY_SHIFT))
	assert_eq(keys.code, CODE.CONFLICT)
	assert_false(keys.can_take)
	assert_eq(model.bind(&"journal", KB, 1, H.key(KEY_SHIFT), RESOLVE.TAKE).code, CODE.LAST_BINDING)
	assert_false(model.is_overridden(), "nothing changed")
	# with the cell filled the two keys can swap instead
	var swap := model.check(&"journal", KB, 0, H.key(KEY_SHIFT))
	assert_true(swap.can_swap and not swap.can_take)
	assert_eq(model.bind(&"journal", KB, 0, H.key(KEY_SHIFT), RESOLVE.SWAP).code, CODE.OK)
	assert_eq(H.slot_ids(model, &"sprint", KB), H.key_ids([KEY_J]))
	assert_eq(H.violations(model), PackedStringArray())


func test_a_key_on_the_other_device_is_no_conflict() -> void:
	# Shift on the keyboard and a pad button with the same number are different events
	assert_eq(_check(&"journal", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER)), CODE.OK)
	assert_eq(model.bind(&"journal", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER)).code, CODE.OK)
	assert_eq(model.bind(&"cancel", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER)).code, CODE.CONFLICT)


func test_esc_is_shared_by_cancel_and_menu_without_a_conflict() -> void:
	var esc := "k%d" % KEY_ESCAPE
	assert_true(H.effective_ids(model, &"cancel", KB).has(esc))
	assert_true(H.effective_ids(model, &"menu", KB).has(esc))
	assert_eq(H.violations(model), PackedStringArray(), "the checker accepts exactly that overlap")
	# any other shared key is a violation (the checker is not blind)
	assert_false(H.violations(_with_shared_key()).is_empty(), "the same key twice is found")


## A model where two actions share a key, made by reaching into the storage on purpose.
func _with_shared_key() -> InputBindings:
	var shared := InputBindings.new(false)
	var list: Array[Dictionary] = [H.key(KEY_E)]
	shared._override["journal:0"] = list
	return shared


func test_reserved_covers_every_menu_and_system_event() -> void:
	# a later project.godot edit must not silently create a free-for-all key
	var actions: Array[StringName] = [
		&"ui_up",
		&"ui_down",
		&"ui_left",
		&"ui_right",
		&"ui_accept",
		&"ui_cancel",
		&"ui_select",
		&"ui_focus_next",
		&"ui_focus_prev",
		&"ui_page_up",
		&"ui_page_down",
		&"scroll_up",
		&"scroll_down",
		&"debug_overlay",
		&"debug_panel",
	]
	var checked := 0
	for action in actions:
		for event in InputMap.action_get_events(action):
			var data := _encode_like_the_page(event)
			if data.is_empty():
				continue
			checked += 1
			var rule := InputBindings.reservation(data)
			assert_false(rule.is_empty(), "%s: %s is free" % [action, BindingCodec.event_id(data)])
			if rule.has("owners") and not (rule["owners"] as Array).is_empty():
				assert_true(_owned_by_a_default(rule["owners"], data), "%s: %s" % [action, data])
	assert_gt(checked, 30)
	# the keys and buttons the controls page handles itself
	for data: Dictionary in [
		H.key(KEY_DELETE),
		H.key(KEY_ESCAPE),
		H.button(JOY_BUTTON_Y),
		H.button(JOY_BUTTON_START),
		H.button(JOY_BUTTON_A),
		H.key(KEY_ENTER),
	]:
		assert_eq(InputBindings.reservation(data), {"owners": [] as Array[StringName]})


## Engine defaults carry the key in `keycode`, the project's own in `physical_keycode`.
func _encode_like_the_page(event: InputEvent) -> Dictionary:
	var key := event as InputEventKey
	if key != null:
		var code := key.physical_keycode if key.physical_keycode != 0 else key.keycode
		return H.key(code)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return BindingCodec.encode(event)
	return {}


func _owned_by_a_default(owners: Array, data: Dictionary) -> bool:
	for action: StringName in owners:
		for device: int in InputBindings.Device.values():
			var kind := device as InputBindings.Device
			if H.ids(model.effective(action, kind)).has(BindingCodec.event_id(data)):
				return true
	return false
