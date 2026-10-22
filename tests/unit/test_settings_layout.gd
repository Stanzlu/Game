extends GutTest
## The key and button layout in settings.json (ADR-048): written as version 2 with both devices
## of an overridden action, read back after a restart, announced when it changes, and left
## alone by "reset all settings".

const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD

var file_path := RuntimeEnv.user_dir() + "settings_layout_unit.json"

var settings: SettingsService


func before_each() -> void:
	for path: String in [file_path, file_path + ".other"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	settings = SettingsService.new()
	settings.file_path = file_path
	add_child_autofree(settings)


func after_each() -> void:
	# the instances under test change the global input map; restore the autoload's view
	Settings.bindings.reset()
	Settings.apply_all()


func _read_file() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	return parsed if parsed is Dictionary else {}


func _write_file(content: String) -> void:
	DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(content)
	file.close()


## A second service on the same file, as after a restart (it writes the global input map).
func _restarted() -> SettingsService:
	var other := SettingsService.new()
	other.file_path = file_path
	add_child_autofree(other)
	return other


func _key(code: int) -> Dictionary:
	return {"type": "key", "physical_keycode": code}


func test_a_binding_survives_a_restart() -> void:
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	settings.flush()
	var other := _restarted()
	assert_eq(other.bindings.slots(&"interact", KB)[0], _key(KEY_F))
	var events := InputMap.action_get_events(&"interact")
	assert_eq((events[0] as InputEventKey).physical_keycode, KEY_F, "the map follows the file")
	assert_eq(events[0].device, -1)
	assert_eq(other.bindings.effective(&"interact", PAD), [{"type": "joy_button", "button": 0}])
	assert_true(events.any(func(e: InputEvent) -> bool: return e is InputEventJoypadButton))


func test_the_file_never_stores_defaults() -> void:
	settings.bindings.bind(&"journal", KB, 0, _key(KEY_K))
	settings.flush()
	assert_true(_read_file()["input"].has("journal"))
	settings.bindings.reset()
	settings.flush()
	assert_eq(_read_file()["input"], {}, "nothing overridden, nothing written")
	settings.bindings.bind(&"journal", KB, 0, _key(KEY_J))
	assert_eq(settings.writes, 2, "the default again is no edit worth a write")


func test_both_devices_are_written_for_an_overridden_action() -> void:
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	settings.flush()
	var ids: Array[String] = []
	for entry: Dictionary in _read_file()["input"]["interact"]:
		ids.append(BindingCodec.event_id(entry))
	assert_eq(
		ids,
		["k%d" % KEY_F, "k%d" % KEY_SPACE, "k%d" % KEY_ENTER, "k%d" % KEY_KP_ENTER, "b0"],
		"the keys with the pinned ones, then the pad's A"
	)
	assert_eq(_read_file()["input"].keys(), ["interact"], "and only the action that was changed")


func test_saved_file_is_version_2() -> void:
	settings.set_value("text.speed", 2)
	settings.flush()
	assert_eq(int(_read_file()["version"]), 2)
	assert_eq(SettingsService.FILE_VERSION, 2)


func test_v1_file_still_loads() -> void:
	_write_file(
		(
			JSON
			. stringify(
				{
					"version": 1,
					"values": {"text.speed": 2},
					"input":
					{"interact": [_key(KEY_F)], "sprint": [{"type": "joy_button", "button": 9}]},
				}
			)
		)
	)
	var loaded := _restarted()
	assert_eq(loaded.get_int("text.speed"), 2)
	assert_eq(loaded.bindings.slots(&"interact", KB), [_key(KEY_F)])
	assert_eq(loaded.bindings.effective(&"interact", PAD).size(), 1, "pad A stays")
	assert_eq(loaded.bindings.effective(&"sprint", KB), [_key(KEY_SHIFT)], "the keys stay")
	assert_push_warning_count(0, "a version 1 file is fine as it is")


func test_a_file_without_a_version_loads_without_complaint() -> void:
	_write_file(JSON.stringify({"values": {"text.speed": 3}}))
	assert_eq(_restarted().get_int("text.speed"), 3)
	_write_file(JSON.stringify({"version": "abc", "values": {"text.speed": 0}}))
	assert_eq(_restarted().get_int("text.speed"), 0)
	assert_push_warning_count(0)


func test_newer_file_version_warns_but_loads() -> void:
	_write_file(
		JSON.stringify(
			{"version": 99, "values": {"text.speed": 2}, "input": {"journal": [_key(KEY_K)]}}
		)
	)
	var loaded := _restarted()
	assert_push_warning("newer version")
	assert_eq(loaded.get_int("text.speed"), 2, "read as far as it is understood")
	assert_eq(loaded.bindings.slots(&"journal", KB), [_key(KEY_K)])


func test_reset_to_defaults_leaves_the_bindings() -> void:
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	settings.set_value("text.speed", 3)
	settings.reset_to_defaults()
	assert_eq(settings.get_int("text.speed"), 1)
	assert_true(
		settings.bindings.is_overridden(&"interact"), "the layout is not a setting to reset"
	)
	assert_eq((InputMap.action_get_events(&"interact")[0] as InputEventKey).physical_keycode, KEY_F)


func test_bindings_changed_signal_and_one_write() -> void:
	watch_signals(settings)
	watch_signals(InputDevice)
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	assert_signal_emitted_with_parameters(
		settings, "bindings_changed", [PackedStringArray(["interact"])]
	)
	assert_signal_emit_count(InputDevice, "labels_changed", 1)
	assert_signal_not_emitted(settings, "changed")
	settings.bindings.bind(&"journal", KB, 0, _key(KEY_K))
	assert_eq(settings.writes, 0, "the write waits for the end of the frame")
	await wait_physics_frames(1)
	assert_eq(settings.writes, 1, "two edits in a frame, one write")
	settings.bindings.bind(&"journal", KB, 0, _key(KEY_ENTER))
	settings.bindings.bind(&"journal", KB, 0, _key(KEY_K))
	await wait_physics_frames(1)
	assert_eq(settings.writes, 1, "a refusal and a repeat write nothing")
	assert_signal_emit_count(settings, "bindings_changed", 2)


func test_a_second_service_does_not_poison_the_defaults() -> void:
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	var other := SettingsService.new()
	other.file_path = file_path + ".other"
	add_child_autofree(other)
	assert_eq(
		other.bindings.default_slots(&"interact", KB),
		[_key(KEY_E), _key(KEY_SPACE)],
		"from the project"
	)
	assert_false(other.bindings.is_overridden())


func test_apply_all_heals_the_map_after_a_foreign_service() -> void:
	settings.bindings.bind(&"interact", KB, 0, _key(KEY_F))
	assert_eq((InputMap.action_get_events(&"interact")[0] as InputEventKey).physical_keycode, KEY_F)
	Settings.apply_all()
	var first := InputMap.action_get_events(&"interact")[0] as InputEventKey
	assert_eq(first.physical_keycode, KEY_E, "the autoload's layout is the truth")


func test_input_block_of_the_wrong_type_is_reported() -> void:
	_write_file(JSON.stringify({"version": 2, "values": {}, "input": [1, 2]}))
	var loaded := _restarted()
	assert_push_warning("binding dropped")
	assert_false(loaded.bindings.is_overridden())
	assert_push_warning_count(1)
