extends GutTest
## The layout model (ADR-048): defaults, the editable cells, compact lists, signals.
## Pure model (InputBindings.new(false)): the InputMap is not touched here.

const H := preload("res://tests/unit/binding_helpers.gd")
const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD

var model: InputBindings


func before_each() -> void:
	model = InputBindings.new(false)


func after_each() -> void:
	Settings.bindings.reset()
	Settings.apply_all()


## [fixed, slots, effective] per action and device, from the table in the design (0.3) with
## pad A pinned on interact.
func _expected() -> Dictionary:
	return {
		"move_up:0": [[], [KEY_W, KEY_UP], [KEY_W, KEY_UP]],
		"move_down:0": [[], [KEY_S, KEY_DOWN], [KEY_S, KEY_DOWN]],
		"move_left:0": [[], [KEY_A, KEY_LEFT], [KEY_A, KEY_LEFT]],
		"move_right:0": [[], [KEY_D, KEY_RIGHT], [KEY_D, KEY_RIGHT]],
		"sprint:0": [[], [KEY_SHIFT], [KEY_SHIFT]],
		"interact:0":
		[
			[KEY_ENTER, KEY_KP_ENTER],
			[KEY_E, KEY_SPACE],
			[KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
		],
		"cancel:0": [[KEY_ESCAPE], [KEY_BACKSPACE], [KEY_ESCAPE, KEY_BACKSPACE]],
		"menu:0": [[KEY_ESCAPE], [KEY_TAB], [KEY_ESCAPE, KEY_TAB]],
		"journal:0": [[], [KEY_J], [KEY_J]],
	}


func _expected_pad() -> Dictionary:
	var stick_up := ["a1-", "b11"]
	return {
		"move_up:1": [stick_up, [], stick_up],
		"move_down:1": [["a1+", "b12"], [], ["a1+", "b12"]],
		"move_left:1": [["a0-", "b13"], [], ["a0-", "b13"]],
		"move_right:1": [["a0+", "b14"], [], ["a0+", "b14"]],
		"sprint:1": [[], ["b2", "a5+"], ["b2", "a5+"]],
		"interact:1": [["b0"], [], ["b0"]],
		"cancel:1": [[], ["b1"], ["b1"]],
		"menu:1": [["b6"], [], ["b6"]],
		"journal:1": [[], ["b4"], ["b4"]],
	}


func test_defaults_match_the_documented_table() -> void:
	var table := _expected()
	for action in InputBindings.ACTIONS:
		var key: String = "%s:0" % action
		var row: Array = table[key]
		assert_eq(H.ids(model.fixed(action, KB)), H.key_ids(row[0]), key + " fixed")
		assert_eq(H.ids(model.default_slots(action, KB)), H.key_ids(row[1]), key + " slots")
		assert_eq(H.effective_ids(model, action, KB), H.key_ids(row[2]), key + " effective")
	var pad := _expected_pad()
	for action in InputBindings.ACTIONS:
		var key: String = "%s:1" % action
		var row: Array = pad[key]
		assert_eq(H.ids(model.fixed(action, PAD)), row[0], key + " fixed")
		assert_eq(H.ids(model.default_slots(action, PAD)), row[1], key + " slots")
		assert_eq(H.effective_ids(model, action, PAD), row[2], key + " effective")


func test_every_default_event_is_classified_and_the_slots_fit() -> void:
	for action in InputBindings.ACTIONS:
		var setting: Dictionary = ProjectSettings.get_setting("input/" + str(action))
		var events: Array = setting["events"]
		var counted := 0
		for device: int in InputBindings.Device.values():
			var kind := device as InputBindings.Device
			counted += model.fixed(action, kind).size() + model.default_slots(action, kind).size()
			assert_lte(model.default_slots(action, kind).size(), InputBindings.SLOTS, str(action))
		assert_eq(counted, events.size(), "%s: nothing lost, nothing invented" % action)
	assert_eq(H.violations(model), PackedStringArray(), "the defaults obey every rule")
	assert_false(model.is_overridden(), "a fresh model is the defaults")


func test_a_second_model_reads_the_project_defaults_not_the_input_map() -> void:
	# the live map may be changed by anyone; the defaults come from project.godot
	var live := InputBindings.new()
	live.bind(&"interact", KB, 0, H.key(KEY_F))
	var second := InputBindings.new(false)
	assert_eq(H.slot_ids(second, &"interact", KB), H.key_ids([KEY_E, KEY_SPACE]))
	live.reset()
	live.apply()


func test_bind_replaces_a_slot_and_keeps_fixed_and_pad() -> void:
	var result := model.bind(&"interact", KB, 0, H.key(KEY_F))
	assert_eq(result.code, InputBindings.Code.OK)
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_F, KEY_SPACE]))
	assert_eq(H.ids(model.fixed(&"interact", KB)), H.key_ids([KEY_ENTER, KEY_KP_ENTER]))
	assert_eq(H.effective_ids(model, &"interact", PAD), ["b0"], "the pad is untouched")
	assert_eq(
		H.effective_ids(model, &"interact", KB),
		H.key_ids([KEY_F, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]),
		"own keys first, the pinned ones behind"
	)
	assert_true(model.is_overridden(&"interact", KB))
	assert_false(model.is_overridden(&"interact", PAD), "only the keyboard side is an override")
	assert_eq(result.data, H.key(KEY_F), "the answer carries the normalised event")


func test_bind_appends_and_compacts() -> void:
	assert_eq(model.bind(&"journal", KB, 1, H.key(KEY_K)).code, InputBindings.Code.OK)
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_J, KEY_K]))
	assert_eq(model.bind(&"journal", KB, 2, H.key(KEY_L)).code, InputBindings.Code.BAD_SLOT)
	assert_eq(model.bind(&"journal", KB, -1, H.key(KEY_L)).code, InputBindings.Code.BAD_SLOT)
	assert_eq(model.bind(&"sprint", KB, 2, H.key(KEY_L)).code, InputBindings.Code.BAD_SLOT)
	assert_eq(model.bind(&"sprint", KB, 7, H.key(KEY_L)).code, InputBindings.Code.BAD_SLOT)
	assert_eq(model.clear(&"journal", KB, 0), InputBindings.Code.OK)
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_K]), "cell 2 moved up")
	assert_eq(model.clear(&"journal", KB, 1), InputBindings.Code.BAD_SLOT, "nothing in cell 2")


func test_clear_keeps_a_binding_per_device() -> void:
	assert_eq(model.clear(&"sprint", KB, 0), InputBindings.Code.LAST_BINDING)
	assert_eq(H.slot_ids(model, &"sprint", KB), H.key_ids([KEY_SHIFT]), "nothing changed")
	assert_eq(model.clear(&"cancel", KB, 0), InputBindings.Code.OK)
	assert_eq(H.effective_ids(model, &"cancel", KB), H.key_ids([KEY_ESCAPE]), "Esc stays")
	assert_eq(model.clear(&"menu", PAD, 0), InputBindings.Code.BAD_SLOT, "no cell, only Start")
	assert_eq(model.clear(&"cancel", PAD, 0), InputBindings.Code.LAST_BINDING, "B is all it has")
	assert_eq(model.clear(&"journal", PAD, 0), InputBindings.Code.LAST_BINDING)
	assert_eq(model.clear(&"move_up", PAD, 0), InputBindings.Code.NOT_EDITABLE)
	assert_eq(model.clear(&"no_such_action", KB, 0), InputBindings.Code.UNKNOWN_ACTION)
	assert_eq(model.clear(&"ui_accept", KB, 0), InputBindings.Code.UNKNOWN_ACTION)


func test_the_pad_can_only_be_changed_where_it_has_cells() -> void:
	assert_false(model.is_editable(&"move_up", PAD))
	assert_true(model.is_editable(&"move_up", KB))
	assert_false(model.is_editable(&"debug_panel", KB), "not one of the nine")
	var result := model.bind(&"move_up", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	assert_eq(result.code, InputBindings.Code.NOT_EDITABLE)
	assert_eq(model.check(&"move_left", PAD, 0, H.key(KEY_Q)).code, InputBindings.Code.NOT_EDITABLE)
	assert_eq(model.bind(&"ui_accept", KB, 0, H.key(KEY_F)).code, InputBindings.Code.UNKNOWN_ACTION)
	assert_true(model.slots(&"move_up", PAD).is_empty())
	assert_false(model.is_overridden())
	# menu has Start pinned and two free cells on the pad
	var extra := model.bind(&"menu", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	assert_eq(extra.code, InputBindings.Code.OK)
	assert_eq(H.effective_ids(model, &"menu", PAD), ["b6", "b9"] as Array[String], "Start first")


func test_unchanged_and_same_action_write_nothing() -> void:
	watch_signals(model)
	var same := model.bind(&"interact", KB, 1, H.key(KEY_E))
	assert_eq(same.code, InputBindings.Code.SAME_ACTION)
	assert_eq(same.other, &"interact")
	assert_eq(same.other_slot, 0)
	var unchanged := model.bind(&"interact", KB, 0, H.key(KEY_E))
	assert_eq(unchanged.code, InputBindings.Code.UNCHANGED)
	assert_true(unchanged.ok(), "UNCHANGED is not a refusal")
	assert_signal_not_emitted(model, "changed")
	assert_false(model.is_overridden())


func test_override_equal_to_default_is_not_stored() -> void:
	assert_eq(model.bind(&"journal", KB, 0, H.key(KEY_K)).code, InputBindings.Code.OK)
	assert_true(model.is_overridden(&"journal"))
	assert_eq(model.bind(&"journal", KB, 0, H.key(KEY_J)).code, InputBindings.Code.OK)
	assert_false(model.is_overridden(&"journal"), "back at the default: no override")
	assert_eq(model.to_data(), {}, "and nothing to write")


func test_the_order_of_the_cells_is_part_of_the_layout() -> void:
	# [Space, E] is not [E, Space]: cell 1 is what the prompts show
	model.bind(&"interact", KB, 0, H.key(KEY_F))
	model.bind(&"interact", KB, 1, H.key(KEY_E))
	model.bind(&"interact", KB, 0, H.key(KEY_SPACE))
	assert_eq(H.slot_ids(model, &"interact", KB), H.key_ids([KEY_SPACE, KEY_E]))
	assert_true(
		model.is_overridden(&"interact", KB), "the same keys in another order are an override"
	)
	assert_eq(H.effective_ids(model, &"interact", KB)[0], "k%d" % KEY_SPACE)
	model.bind(&"interact", KB, 1, H.key(KEY_F))
	model.bind(&"interact", KB, 0, H.key(KEY_E))
	model.bind(&"interact", KB, 1, H.key(KEY_SPACE))
	assert_false(model.is_overridden(&"interact"), "[E, Space] again is the default")


func test_changed_lists_every_affected_action_once() -> void:
	watch_signals(model)
	var refused := model.bind(&"journal", KB, 0, H.key(KEY_E))
	assert_eq(refused.code, InputBindings.Code.CONFLICT)
	assert_signal_emit_count(model, "changed", 0, "a conflict that is not settled changes nothing")
	var result := model.bind(&"journal", KB, 0, H.key(KEY_E), InputBindings.Resolve.SWAP)
	assert_eq(result.code, InputBindings.Code.OK)
	assert_signal_emit_count(model, "changed", 1, "one signal for the swap")
	var args: Array = get_signal_parameters(model, "changed")
	var names: PackedStringArray = args[0]
	assert_eq(_sorted(names), PackedStringArray(["interact", "journal"]))
	model.bind(&"journal", KB, 0, H.key(KEY_ENTER))
	model.bind(&"journal", PAD, 0, H.key(KEY_F))
	model.bind(&"journal", KB, 0, H.button(0))
	assert_signal_emit_count(model, "changed", 1, "refusals emit nothing")


func test_reset_variants() -> void:
	model.bind(&"journal", KB, 0, H.key(KEY_F))
	model.bind(&"interact", KB, 0, H.key(KEY_G))
	model.bind(&"sprint", KB, 0, H.key(KEY_H))
	model.bind(&"journal", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	model.bind(&"sprint", PAD, 0, H.button(JOY_BUTTON_RIGHT_SHOULDER))
	model.reset(&"journal", PAD)
	assert_false(model.is_overridden(&"journal", PAD), "one action on one device")
	assert_true(model.is_overridden(&"journal", KB))
	model.reset(&"journal")
	assert_false(model.is_overridden(&"journal"), "one action on both devices")
	model.reset(&"", PAD)
	assert_false(model.is_overridden(&"", PAD), "every action on one device")
	assert_true(model.is_overridden(&"sprint", KB))
	model.reset()
	assert_false(model.is_overridden(), "everything")
	assert_eq(H.layout(model), H.layout(InputBindings.new(false)))
	model.reset(&"no_such_action")
	assert_false(model.is_overridden(), "an unknown action is ignored")


func test_reset_emits_only_for_actions_that_changed() -> void:
	model.bind(&"journal", KB, 0, H.key(KEY_F))
	model.bind(&"sprint", KB, 0, H.key(KEY_G))
	model.bind(&"cancel", PAD, 0, H.button(JOY_BUTTON_LEFT_SHOULDER))
	watch_signals(model)
	model.reset(&"", KB)
	var names: PackedStringArray = get_signal_parameters(model, "changed")[0]
	assert_eq(_sorted(names), PackedStringArray(["journal", "sprint"]), "the pad side stayed")
	model.reset(&"", KB)
	assert_signal_emit_count(model, "changed", 1, "nothing left to reset: no signal")


func test_device_enum_matches_input_device_kind() -> void:
	assert_eq(int(InputBindings.Device.KEYBOARD), int(InputDevice.Kind.KEYBOARD))
	assert_eq(int(InputBindings.Device.GAMEPAD), int(InputDevice.Kind.GAMEPAD))


func test_reads_are_copies() -> void:
	var slots := model.slots(&"journal", KB)
	slots.clear()
	var event := model.effective(&"journal", KB)[0]
	event["physical_keycode"] = KEY_Q
	assert_eq(H.slot_ids(model, &"journal", KB), H.key_ids([KEY_J]))
	assert_eq(H.effective_ids(model, &"journal", KB), H.key_ids([KEY_J]))
	assert_eq(model.slots(&"nothing", KB), [] as Array[Dictionary])


func _sorted(names: PackedStringArray) -> PackedStringArray:
	var copy := names.duplicate()
	copy.sort()
	return copy
