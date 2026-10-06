extends GutTest
## Settings: schema validation, persistence (test profile), session overrides, side effects
## on audio buses and the input map.

const FILE := "user://profiles/test/settings_unit.json"

var settings: SettingsService


func before_each() -> void:
	if FileAccess.file_exists(FILE):
		DirAccess.remove_absolute(FILE)
	settings = SettingsService.new()
	settings.file_path = FILE
	add_child_autofree(settings)


func after_each() -> void:
	# The instance under test changes global audio and input; restore the autoload's view.
	Settings.apply_all()


func _read_file() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FILE))
	return parsed if parsed is Dictionary else {}


func test_defaults_without_file() -> void:
	assert_eq(settings.get_int("text.speed"), 1)
	assert_false(settings.get_bool("controls.sprint_toggle"))
	assert_true(settings.get_bool("display.smooth_camera"))
	assert_true(settings.get_bool("display.vsync"), "VSync on unless the player turns it off")
	assert_false(FileAccess.file_exists(FILE), "nothing written until something changes")


func test_valid_values_are_saved_and_loaded_again() -> void:
	assert_true(settings.set_value("controls.sprint_toggle", true))
	assert_true(settings.set_value("text.speed", 3))
	var values: Dictionary = _read_file().get("values", {})
	assert_eq(values.get("controls.sprint_toggle"), true)
	var other := SettingsService.new()
	other.file_path = FILE
	add_child_autofree(other)
	assert_true(other.get_bool("controls.sprint_toggle"))
	assert_eq(other.get_int("text.speed"), 3)
	assert_eq(other.text_seconds_per_char(), 0.0)


func test_invalid_values_are_refused() -> void:
	assert_false(settings.set_value("text.speed", 9))
	assert_push_error("invalid setting")
	assert_false(settings.set_value("controls.sprint_toggle", "yes"))
	assert_push_error("invalid setting")
	assert_false(settings.set_value("no.such.key", 1))
	assert_push_error("invalid setting")
	assert_eq(settings.get_int("text.speed"), 1)


func test_broken_or_hostile_file_falls_back_to_defaults() -> void:
	DirAccess.make_dir_recursive_absolute(FILE.get_base_dir())
	var file := FileAccess.open(FILE, FileAccess.WRITE)
	(
		file
		. store_string(
			(
				JSON
				. stringify(
					{
						"version": 1,
						"values":
						{"text.speed": 2, "audio.music": 99, "display.fullscreen": "on", "x": 1},
						"input":
						{
							"interact": [{"type": "key", "physical_keycode": 70}],
							"no_action": [{"type": "key", "physical_keycode": 70}],
							"cancel": [{"type": "script", "source": "res://evil.gd"}],
						},
					}
				)
			)
		)
	)
	file.close()
	var loaded := SettingsService.new()
	loaded.file_path = FILE
	add_child_autofree(loaded)
	assert_eq(loaded.get_int("text.speed"), 2)
	assert_eq(loaded.get_int("audio.music"), 10, "out of range: default")
	assert_false(loaded.get_bool("display.fullscreen"))
	assert_eq(loaded.input_overrides().keys(), ["interact"])
	assert_push_warning("setting reset")
	assert_push_warning("setting reset")
	assert_push_warning("setting reset")
	assert_push_warning("binding dropped")


func test_unreadable_file_is_reported_not_fatal() -> void:
	DirAccess.make_dir_recursive_absolute(FILE.get_base_dir())
	var file := FileAccess.open(FILE, FileAccess.WRITE)
	file.store_string('Object(Node, "script": Resource("user://evil.gd"))')
	file.close()
	var loaded := SettingsService.new()
	loaded.file_path = FILE
	add_child_autofree(loaded)
	assert_push_warning("settings unreadable")
	assert_eq(loaded.get_int("text.speed"), 1)


func test_session_overrides_are_never_written() -> void:
	settings.apply_args(["--camera=pixel", "--sprint=toggle", "--tuning=schwer"])
	assert_false(settings.get_bool("display.smooth_camera"))
	assert_true(settings.get_bool("controls.sprint_toggle"))
	assert_eq(settings.get_int("controls.tuning"), 2)
	settings.set_value("text.speed", 2)
	var values: Dictionary = _read_file().get("values", {})
	assert_eq(values.get("display.smooth_camera"), true, "file keeps the real value")
	assert_eq(values.get("controls.sprint_toggle"), false)


func test_volume_steps_drive_audio_buses() -> void:
	var bus := AudioServer.get_bus_index(&"Music")
	settings.set_value("audio.music", 5)
	assert_almost_eq(AudioServer.get_bus_volume_db(bus), linear_to_db(0.5), 0.01)
	settings.set_value("audio.music", 0)
	assert_true(AudioServer.is_bus_mute(bus))
	settings.set_value("audio.music", 10)
	assert_false(AudioServer.is_bus_mute(bus))


func test_input_overrides_replace_and_restore_bindings() -> void:
	var f_key := InputEventKey.new()
	f_key.physical_keycode = KEY_F
	assert_true(settings.set_input_override("interact", [f_key]))
	var events := InputMap.action_get_events(&"interact")
	assert_eq(events.size(), 1)
	assert_eq((events[0] as InputEventKey).physical_keycode, KEY_F)
	assert_eq(events[0].device, -1)
	settings.clear_input_overrides()
	assert_gt(InputMap.action_get_events(&"interact").size(), 1, "defaults are back")


func test_event_codec_rejects_garbage() -> void:
	assert_null(SettingsService.decode_event({"type": "key"}))
	assert_null(SettingsService.decode_event({"type": "joy_axis", "axis": 1, "value": "up"}))
	assert_null(SettingsService.decode_event({"type": "mouse"}))
	var axis := SettingsService.decode_event({"type": "joy_axis", "axis": 1, "value": -0.3})
	assert_eq((axis as InputEventJoypadMotion).axis_value, -1.0)


func test_large_text_scales_every_theme_together() -> void:
	var theme := ThemeDB.get_project_theme()
	TextSize.apply(true)
	assert_eq(theme.default_font_size, 27)
	assert_eq(theme.default_font, TextSize.LARGE_BODY)
	assert_eq(theme.get_font_size(&"font_size", &"SmallLabel"), 16, "small text doubles")
	# read through load(): a property of a constant would be folded at compile time
	var compact := load("res://ui/theme/compact_theme.tres") as Theme
	assert_eq(compact.default_font_size, 16, "developer panels too")
	TextSize.apply(false)
	assert_eq(theme.default_font_size, 19)
	assert_eq(theme.get_font_size(&"font_size", &"PromptLabel"), 8)


func test_choice_rows_make_room_for_their_value() -> void:
	var list := OptionList.new()
	add_child_autofree(list)
	var row := list.add_choice(
		"SETTINGS_TEXT_SPEED",
		["TEXT_SPEED_NORMAL"],
		func() -> int: return 0,
		func(_i: int) -> void: pass
	)
	var font := row.get_theme_font(&"font")
	var size := row.get_theme_font_size(&"font_size")
	var label_w := font.get_string_size(row.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	assert_gt(row.custom_minimum_size.x, label_w + 30.0, "label plus value plus gap")
