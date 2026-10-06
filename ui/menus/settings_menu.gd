class_name SettingsMenu
extends MenuLayer
## All player settings, grouped. Changes apply and save immediately (Settings autoload).

const VOLUMES := [
	["audio.master", "SETTINGS_VOLUME_MASTER"],
	["audio.music", "SETTINGS_VOLUME_MUSIC"],
	["audio.ambience", "SETTINGS_VOLUME_AMBIENCE"],
	["audio.sfx", "SETTINGS_VOLUME_SFX"],
	["audio.ui", "SETTINGS_VOLUME_UI"],
	["audio.voice", "SETTINGS_VOLUME_VOICE"],
]
const STEPS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


func _ready() -> void:
	title_key = "SETTINGS_TITLE"
	panel_width = 300
	layer = 50
	super()


func _build() -> void:
	list.add_header("SETTINGS_AUDIO")
	for entry: Array in VOLUMES:
		list.add_setting(entry[0], entry[1], STEPS)
	list.add_header("SETTINGS_TEXT")
	list.add_setting(
		"text.speed",
		"SETTINGS_TEXT_SPEED",
		["TEXT_SPEED_SLOW", "TEXT_SPEED_NORMAL", "TEXT_SPEED_FAST", "TEXT_SPEED_INSTANT"]
	)
	list.add_setting("text.auto_advance", "SETTINGS_AUTO_ADVANCE")
	list.add_setting("text.large", "SETTINGS_TEXT_LARGE")
	list.add_header("SETTINGS_CONTROLS")
	list.add_setting("controls.sprint_toggle", "PAUSE_SPRINT", ["SPRINT_HOLD", "SPRINT_TOGGLE"])
	list.add_setting(
		"controls.tuning", "PAUSE_TUNING", ["TUNING_DIREKT", "TUNING_WEICH", "TUNING_SCHWER"]
	)
	list.add_setting(
		"controls.eight_directions", "PAUSE_DIRECTIONS", ["DIRECTIONS_FREE", "DIRECTIONS_EIGHT"]
	)
	list.add_header("SETTINGS_DISPLAY")
	list.add_setting("display.fullscreen", "SETTINGS_FULLSCREEN")
	list.add_setting("display.vsync", "SETTINGS_VSYNC")
	list.add_setting("display.smooth_camera", "PAUSE_CAMERA", ["CAMERA_PIXEL", "CAMERA_SMOOTH"])
	list.add_setting("display.screen_shake", "SETTINGS_SCREEN_SHAKE")
	list.add_setting("display.reduce_flashing", "SETTINGS_REDUCE_FLASHING")
	list.add_header("SETTINGS_ACCESS")
	list.add_setting(
		"access.timing", "SETTINGS_TIMING", ["TIMING_NORMAL", "TIMING_LONGER", "TIMING_MUCH_LONGER"]
	)
	list.add_setting(
		"access.encounter_speed",
		"SETTINGS_ENCOUNTER_SPEED",
		["ENCOUNTER_NORMAL", "ENCOUNTER_CALMER", "ENCOUNTER_MUCH_CALMER"]
	)
	if OS.is_debug_build():
		list.add_header("SETTINGS_DEBUG")
		list.add_setting("debug.overlay", "PAUSE_OVERLAY")
	list.add_action("SETTINGS_RESET", _reset)
	list.add_action("MENU_BACK", close)
	hint.text = tr("SETTINGS_HINT")


func _reset() -> void:
	Settings.reset_to_defaults()
	rebuild()
