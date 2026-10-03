class_name SettingsService
extends Node
## Autoload "Settings": player settings, saved as JSON in settings.json (ADR-018).
## Every value has a schema entry with default and range; anything invalid in the file is
## replaced by the default and logged. Start arguments (--camera=pixel, --tuning=schwer, ...)
## override values for the running session only and are never written.
##
## Input overrides: {"<action>": [{"type": "key", "physical_keycode": 87}, ...]}. They are
## prepared for a rebinding menu after the slice (ADR-011); all events use device -1.

signal changed(key: String)

const FILE_VERSION := 1
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
	"display.smooth_camera": [true],
	"display.screen_shake": [true],
	"display.reduce_flashing": [false],
	"access.timing": [0, 2],
	"access.encounter_speed": [0, 2],
	"debug.overlay": [false],
}
const KEYS_PER_EVENT := {
	"key": ["physical_keycode"], "joy_button": ["button"], "joy_axis": ["axis", "value"]
}

var file_path := ""
var _values: Dictionary[String, Variant] = {}
var _session: Dictionary[String, Variant] = {}
var _input_overrides: Dictionary[String, Array] = {}
var _default_events: Dictionary[String, Array] = {}


func _ready() -> void:
	if file_path.is_empty():
		file_path = RuntimeEnv.user_dir() + "settings.json"
	for action in InputMap.get_actions():
		_default_events[str(action)] = InputMap.action_get_events(action)
	reset_to_defaults(false)
	load_file()
	apply_args(OS.get_cmdline_user_args())
	apply_all()


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
		save_file()
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
		save_file()


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


# --- Side effects ----------------------------------------------------------------------


func apply_all() -> void:
	for key: String in SCHEMA:
		_apply(key)
	_apply_input_overrides()


func _apply(key: String) -> void:
	if AUDIO_BUSES.has(key):
		var bus := AudioServer.get_bus_index(AUDIO_BUSES[key])
		if bus >= 0:
			var step := get_int(key)
			AudioServer.set_bus_mute(bus, step == 0)
			AudioServer.set_bus_volume_db(bus, linear_to_db(step / 10.0) if step > 0 else -80.0)
	elif key == "display.fullscreen" and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			(
				DisplayServer.WINDOW_MODE_FULLSCREEN
				if get_bool(key)
				else DisplayServer.WINDOW_MODE_WINDOWED
			)
		)


# --- Input overrides -------------------------------------------------------------------


func set_input_override(action: String, events: Array[InputEvent]) -> bool:
	var encoded: Array = []
	for event in events:
		var data := encode_event(event)
		if data.is_empty():
			Log.error(Log.Category.INPUT, "unsupported binding", {"action": action})
			return false
		encoded.append(data)
	if not InputMap.has_action(action) or encoded.is_empty():
		Log.error(Log.Category.INPUT, "invalid override", {"action": action})
		return false
	_input_overrides[action] = encoded
	_apply_input_overrides()
	save_file()
	return true


func clear_input_overrides() -> void:
	_input_overrides.clear()
	_apply_input_overrides()
	save_file()


func input_overrides() -> Dictionary:
	return _input_overrides.duplicate(true)


func _apply_input_overrides() -> void:
	for action: String in _default_events:
		InputMap.action_erase_events(action)
		var events: Array = _default_events[action]
		if _input_overrides.has(action):
			events = []
			for data: Dictionary in _input_overrides[action]:
				events.append(decode_event(data))
		for event: InputEvent in events:
			InputMap.action_add_event(action, event)


static func encode_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"type": "key", "physical_keycode": int((event as InputEventKey).physical_keycode)}
	if event is InputEventJoypadButton:
		return {"type": "joy_button", "button": int((event as InputEventJoypadButton).button_index)}
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		return {"type": "joy_axis", "axis": int(motion.axis), "value": signf(motion.axis_value)}
	return {}


## Builds an event from untrusted data; returns null if anything is off.
static func decode_event(data: Dictionary) -> InputEvent:
	var kind: Variant = data.get("type")
	if not kind is String or not KEYS_PER_EVENT.has(kind):
		return null
	for field: String in KEYS_PER_EVENT[kind]:
		var v: Variant = data.get(field)
		if not (v is float or v is int) or not is_finite(float(v)):
			return null
	match kind:
		"key":
			var key := InputEventKey.new()
			key.physical_keycode = clampi(int(data["physical_keycode"]), 0, 0x7FFFFFFF) as Key
			key.device = -1
			return key
		"joy_button":
			var button := InputEventJoypadButton.new()
			button.button_index = clampi(int(data["button"]), 0, 127) as JoyButton
			button.device = -1
			return button
		_:
			var motion := InputEventJoypadMotion.new()
			motion.axis = clampi(int(data["axis"]), 0, 9) as JoyAxis
			motion.axis_value = 1.0 if float(data["value"]) >= 0.0 else -1.0
			motion.device = -1
			return motion


# --- File ------------------------------------------------------------------------------


func save_file() -> Error:
	var data := {"version": FILE_VERSION, "values": _values.duplicate(), "input": _input_overrides}
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
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	return DirAccess.rename_absolute(tmp, file_path)


## Reads the file if it exists. Invalid entries fall back to defaults and are reported.
func load_file() -> void:
	if not FileAccess.file_exists(file_path):
		return
	var text := FileAccess.get_file_as_string(file_path)
	var json := JSON.new()
	if text.length() > 65536 or json.parse(text) != OK or not json.data is Dictionary:
		Log.warn(Log.Category.UI, "settings unreadable, using defaults", {"path": file_path})
		return
	var data: Dictionary = json.data
	var values: Variant = data.get("values")
	if values is Dictionary:
		for key: Variant in values:
			var checked: Variant = validate(str(key), (values as Dictionary)[key])
			if checked == null:
				Log.warn(Log.Category.UI, "setting reset", {"key": str(key)})
			else:
				_values[str(key)] = checked
	var input: Variant = data.get("input")
	if input is Dictionary:
		for action: Variant in input:
			var list: Variant = (input as Dictionary)[action]
			if not (action is String and InputMap.has_action(str(action)) and list is Array):
				Log.warn(Log.Category.INPUT, "binding dropped", {"action": str(action)})
				continue
			var kept: Array = []
			for entry: Variant in list:
				if entry is Dictionary and decode_event(entry) != null:
					kept.append(encode_event(decode_event(entry)))
			if not kept.is_empty():
				_input_overrides[str(action)] = kept
