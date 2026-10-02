extends GutTest
## Guards the Phase-0 project configuration against accidental changes.

const EXPECTED_BUSES: PackedStringArray = ["Master", "Music", "Ambience", "SFX", "UI", "Voice"]
const GAMEPLAY_ACTIONS: PackedStringArray = [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"interact",
	"cancel",
	"sprint",
	"menu",
	"journal"
]
const UI_CSV := "res://content/locale/ui.csv"


func test_pixel_art_display_settings() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer")
	assert_eq(
		ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"), 0
	)
	assert_true(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel"))


func test_main_scene_loads() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_true(ResourceLoader.exists(path), "main scene missing: " + path)
	assert_not_null(load(path) as PackedScene)


func test_audio_buses_exist_and_route_to_master() -> void:
	for bus_name: String in EXPECTED_BUSES:
		var idx := AudioServer.get_bus_index(bus_name)
		assert_ne(idx, -1, "missing audio bus " + bus_name)
		if bus_name != "Master" and idx != -1:
			assert_eq(AudioServer.get_bus_send(idx), &"Master", bus_name + " must send to Master")


func test_gameplay_actions_have_keyboard_and_controller() -> void:
	for action: String in GAMEPLAY_ACTIONS:
		assert_true(InputMap.has_action(action), "missing action " + action)
		var has_key := false
		var has_pad := false
		for event: InputEvent in InputMap.action_get_events(action):
			has_key = has_key or event is InputEventKey
			has_pad = has_pad or event is InputEventJoypadButton or event is InputEventJoypadMotion
		assert_true(has_key, action + " needs a keyboard binding")
		assert_true(has_pad, action + " needs a controller binding")


func test_all_input_events_listen_to_all_devices() -> void:
	for action: StringName in InputMap.get_actions():
		if String(action).begins_with("ui_"):
			continue
		for event: InputEvent in InputMap.action_get_events(action):
			assert_eq(event.device, -1, "%s: event must use device -1 (all devices)" % action)


func test_every_ui_string_has_a_german_translation() -> void:
	var file := FileAccess.open(UI_CSV, FileAccess.READ)
	assert_not_null(file, "cannot open " + UI_CSV)
	if file == null:
		return
	var header := file.get_csv_line()
	assert_eq(header, PackedStringArray(["keys", "de"]))
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 2 or row[0].is_empty():
			continue
		assert_false(row[1].strip_edges().is_empty(), "empty German text for " + row[0])
		assert_eq(TranslationServer.translate(row[0]), StringName(row[1]), "not loaded: " + row[0])


func test_autoloads_are_present() -> void:
	assert_true(get_tree().root.has_node("Log"), "Log autoload missing")
	assert_true(get_tree().root.has_node("DialogueManager"), "DialogueManager autoload missing")


func test_translation_templates_never_include_test_files() -> void:
	var pot_files: PackedStringArray = ProjectSettings.get_setting(
		"internationalization/locale/translations_pot_files", PackedStringArray()
	)
	for path: String in pot_files:
		assert_false(path.begins_with("res://tests/"), "test file in POT list: " + path)
	assert_false(
		ProjectSettings.get_setting(
			"dialogue_manager/editor/translations/UPDATE_TRANSLATION_TEMPLATES_AUTOMATICALLY", true
		),
		"Dialogue Manager must not edit the POT list automatically (see CONTENT_GUIDE)"
	)
