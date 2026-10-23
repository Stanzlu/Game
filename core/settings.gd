class_name SettingsService
extends Node
## Autoload "Settings": player settings, saved as JSON in settings.json (ADR-018).
## Every value has a schema entry with default and range; anything invalid in the file is
## replaced by the default and logged. Start arguments (--camera=pixel, --tuning=schwer, ...)
## override values for the running session only and are never written.
##
## Key and button layout: `bindings` (InputBindings, ADR-048) holds the overrides, the file
## stores them as {"<action>": [{"type": "key", "physical_keycode": 87}, ...]} (version 2: a
## device is overridden if the list holds events of that device; the fixed events and the
## other device's events are written along). `bindings_changed` is the signal for it:
## `changed(key)` is for values only (every scene re-applies its settings on it).

signal changed(key: String)
## The InputMap holds new events for these actions (the player rebound something).
signal bindings_changed(actions: PackedStringArray)

const FILE_VERSION := 2
const TUNING_PRESETS: PackedStringArray = ["direkt", "weich", "schwer"]
const AUDIO_BUSES := {
	"audio.master": &"Master",
	"audio.music": &"Music",
	"audio.ambience": &"Ambience",
	"audio.sfx": &"SFX",
	"audio.ui": &"UI",
	"audio.voice": &"Voice",
}
## Seconds per typed character for text.speed 0..3 (slow, normal, fast, instant).
const TEXT_SPEEDS: Array[float] = [0.045, 0.025, 0.012, 0.0]
## Multipliers for access.timing (normal, longer, much longer).
const TIMING_FACTORS: Array[float] = [1.0, 1.5, 2.0]
## Multipliers for access.encounter_speed (normal, calmer, much calmer).
const ENCOUNTER_SPEEDS: Array[float] = [1.0, 0.75, 0.5]
## key -> [default, max] for integers (min is 0), [default] for booleans.
const SCHEMA := {
	"audio.master": [10, 10],
	"audio.music": [10, 10],
	"audio.ambience": [10, 10],
	"audio.sfx": [10, 10],
	"audio.ui": [10, 10],
	"audio.voice": [10, 10],
	"text.speed": [1, 3],
	"text.auto_advance": [false],
	"text.large": [false],
	"controls.sprint_toggle": [false],
	"controls.tuning": [0, 2],
	"controls.eight_directions": [true],
	"display.fullscreen": [false],
	"display.vsync": [true],
	"display.smooth_camera": [true],
	"display.screen_shake": [true],
	"display.reduce_flashing": [false],
	"display.parallax": [true],
	"access.timing": [0, 2],
	"access.encounter_speed": [0, 2],
	"access.captions": [false],
	"debug.overlay": [false],
}

var file_path := ""
## How often the file was written (a slider drag changes a value every frame: one write).
var writes := 0
## The key and button layout. Edits go through here; the InputMap follows by itself.
var bindings := InputBindings.new()
var _save_queued := false
var _values: Dictionary[String, Variant] = {}
var _session: Dictionary[String, Variant] = {}


func _ready() -> void:
	if file_path.is_empty():
		file_path = RuntimeEnv.user_dir() + "settings.json"
	bindings.changed.connect(_on_bindings_changed)
	reset_to_defaults(false)
	load_file()
	apply_args(OS.get_cmdline_user_args())
	apply_all()


func _exit_tree() -> void:
	flush()


# --- Values ----------------------------------------------------------------------------


func get_value(key: String) -> Variant:
	if _session.has(key):
		return _session[key]
	return _values.get(key, default_value(key))


func get_bool(key: String) -> bool:
	return bool(get_value(key))


func get_int(key: String) -> int:
	return int(get_value(key))


static func default_value(key: String) -> Variant:
	var entry: Array = SCHEMA.get(key, [null])
	return entry[0]


## Returns the value if it fits the schema, otherwise null.
static func validate(key: String, value: Variant) -> Variant:
	if not SCHEMA.has(key):
		return null
	var entry: Array = SCHEMA[key]
	if entry[0] is bool:
		return value if value is bool else null
	if not (value is int or value is float):
		return null
	var f := float(value)
	if not is_finite(f) or f != floorf(f) or f < 0.0 or f > float(entry[1]):
		return null
	return int(f)


func set_value(key: String, value: Variant, persist := true) -> bool:
	var checked: Variant = validate(key, value)
	if checked == null:
		Log.error(Log.Category.UI, "invalid setting", {"key": key, "value": str(value)})
		return false
	_session.erase(key)
	if _values.get(key) == checked:
		return true
	_values[key] = checked
	Log.info(Log.Category.UI, "setting", {"key": key, "value": checked})
	_apply(key)
	changed.emit(key)
	if persist:
		request_save()
	return true


## Session-only value (start arguments, captures); never written to the file.
func override(key: String, value: Variant) -> void:
	var checked: Variant = validate(key, value)
	if checked == null:
		Log.warn(Log.Category.UI, "invalid override", {"key": key, "value": str(value)})
		return
	_session[key] = checked
	_apply(key)
	changed.emit(key)


func reset_to_defaults(persist := true) -> void:
	_values.clear()
	_session.clear()
	for key: String in SCHEMA:
		_values[key] = default_value(key)
	if persist:
		apply_all()
		for key: String in SCHEMA:
			changed.emit(key)
		request_save()


# --- Convenience for consumers ---------------------------------------------------------


func text_seconds_per_char() -> float:
	return TEXT_SPEEDS[get_int("text.speed")]


func timing_factor() -> float:
	return TIMING_FACTORS[get_int("access.timing")]


func encounter_speed() -> float:
	return ENCOUNTER_SPEEDS[get_int("access.encounter_speed")]


func tuning() -> MovementTuning:
	return load("res://entities/player/tuning/%s.tres" % TUNING_PRESETS[get_int("controls.tuning")])


## --camera=pixel|smooth, --tuning=direkt|weich|schwer, --directions=eight|free,
## --sprint=hold|toggle, --overlay, --text=instant (session only).
func apply_args(args: PackedStringArray) -> void:
	for arg in args:
		var parts := arg.trim_prefix("--").split("=", true, 1)
		var value := parts[1] if parts.size() > 1 else ""
		match parts[0]:
			"camera":
				override("display.smooth_camera", value != "pixel")
			"tuning":
				override("controls.tuning", maxi(TUNING_PRESETS.find(value), 0))
			"directions":
				override("controls.eight_directions", value != "free")
			"sprint":
				override("controls.sprint_toggle", value == "toggle")
			"overlay":
				override("debug.overlay", true)
			"text":
				override("text.speed", 3 if value == "instant" else 1)
			"large-text":
				override("text.large", true)


# --- Side effects ----------------------------------------------------------------------


func apply_all() -> void:
	for key: String in SCHEMA:
		_apply(key)
	bindings.apply()


func _apply(key: String) -> void:
	if AUDIO_BUSES.has(key):
		var bus := AudioServer.get_bus_index(AUDIO_BUSES[key])
		if bus >= 0:
			var step := get_int(key)
			AudioServer.set_bus_mute(bus, step == 0)
			# squared taper: half the slider is -12 dB, which sounds about half as loud
			AudioServer.set_bus_volume_db(
				bus, linear_to_db(pow(step / 10.0, 2.0)) if step > 0 else -80.0
			)
	elif key == "text.large":
		TextSize.apply(get_bool(key))
	elif key == "display.vsync":
		apply_vsync(get_bool(key))
	elif key == "display.fullscreen" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			(
				DisplayServer.WINDOW_MODE_FULLSCREEN
				if get_bool(key)
				else DisplayServer.WINDOW_MODE_WINDOWED
			)
		)


## VSync on: the display paces the frames. Off: the engine caps them at the display's
## refresh rate instead. That gets around macOS 26 holding fullscreen games with VSync at
## 30 fps in Low Power Mode (playtest 05.10.), at the price of possible tearing.
static func apply_vsync(on: bool) -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED
	)
	var hz := DisplayServer.screen_get_refresh_rate()
	Engine.max_fps = 0 if on else (roundi(hz) if hz >= 30.0 else 60)


## Switches VSync off for a moment and on again, once, at the start. Playtest v0.8.0 on a Mac with
## a 145 Hz screen: the first scene of the performance test (Elysia) ran at 37 fps, a quarter
## of the refresh rate, and everything after the test had switched VSync off and on again at
## 145 (KNOWN_ISSUES #78). The same cycle before the first scene is the cheap guess that
## this was the cause; the next test says. Only on macOS and with VSync on, else it does nothing.
## The timer belongs to the tree, not to a node: VSync must come back even if `owner` is freed.
static func restart_vsync(owner: Node, seconds := 0.3) -> void:
	if OS.get_name() != "macOS" or DisplayServer.get_name() == "headless":
		return
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		return
	var tree := owner.get_tree()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await tree.create_timer(seconds, true, false, true).timeout
	apply_vsync(Settings.get_bool("display.vsync"))


# --- Key layout -------------------------------------------------------------------------


## A rebinding was made: save it and let every prompt that names a key look again.
func _on_bindings_changed(actions: PackedStringArray) -> void:
	request_save()
	bindings_changed.emit(actions)
	InputDevice.labels_changed.emit()


# --- File ------------------------------------------------------------------------------


## Writes the file at the end of the frame, once however many values changed (dragging a
## slider changes one every frame).
func request_save() -> void:
	if _save_queued:
		return
	_save_queued = true
	flush.call_deferred()


## Writes a queued save now (before the game closes).
func flush() -> void:
	if _save_queued:
		save_file()


func save_file() -> Error:
	_save_queued = false
	writes += 1
	var data := {
		"version": FILE_VERSION, "values": _values.duplicate(), "input": bindings.to_data()
	}
	var err := DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	if err != OK:
		Log.error(Log.Category.UI, "settings folder", {"error": error_string(err)})
		return err
	var tmp := file_path + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		err = FileAccess.get_open_error()
		Log.error(Log.Category.UI, "settings not saved", {"error": error_string(err)})
		return err
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	# the rename replaces the old file in one step: there is no moment without a settings file
	err = DirAccess.rename_absolute(tmp, file_path)
	if err != OK and FileAccess.file_exists(file_path):
		# a platform whose rename will not overwrite: remove first, only now
		DirAccess.remove_absolute(file_path)
		err = DirAccess.rename_absolute(tmp, file_path)
	if err != OK:
		Log.error(Log.Category.UI, "settings not saved", {"error": error_string(err)})
	return err


## Reads the file if it exists. Invalid entries fall back to defaults and are reported. A file
## that cannot be read at all is kept as settings.json.bad before the next save replaces it, and
## a file from a newer build as settings.json.newer (the key layout is the one thing in it that
## costs the player time to redo).
func load_file() -> void:
	if not FileAccess.file_exists(file_path):
		return
	var text := FileAccess.get_file_as_string(file_path)
	var json := JSON.new()
	if text.length() > 65536 or json.parse(text) != OK or not json.data is Dictionary:
		var info := {"path": file_path, "kept_as": _keep_file_as(".bad")}
		Log.warn(Log.Category.UI, "settings unreadable, using defaults", info)
		return
	var data: Dictionary = json.data
	_check_version(data.get("version"))
	var values: Variant = data.get("values")
	if values is Dictionary:
		for key: Variant in values:
			var checked: Variant = validate(str(key), (values as Dictionary)[key])
			if checked == null:
				Log.warn(Log.Category.UI, "setting reset", {"key": str(key)})
			else:
				_values[str(key)] = checked
	bindings.load_data(data.get("input"))


## A newer build may have written the file: read it as far as it is understood, never refuse.
## The next save writes it as FILE_VERSION and loses what this build does not know, so the
## newer file is copied aside first. No version (or no whole number) counts as 1.
func _check_version(version: Variant) -> void:
	if (version is int or version is float) and float(version) > float(FILE_VERSION):
		var info := {"version": version, "kept_as": _keep_file_as(".newer")}
		Log.warn(Log.Category.UI, "settings from a newer version", info)


## Copies the settings file next to itself with `suffix`; returns where it went ("" if that
## failed).
func _keep_file_as(suffix: String) -> String:
	var kept := file_path + suffix
	return kept if DirAccess.copy_absolute(file_path, kept) == OK else ""
