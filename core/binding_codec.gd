class_name BindingCodec
extends RefCounted
## Input events as plain data, for settings.json and for the binding rules (ADR-048).
## {"type": "key", "physical_keycode": 87}, {"type": "joy_button", "button": 0},
## {"type": "joy_axis", "axis": 5, "value": 1.0}. Only physical keys are stored (ADR-011), the
## device is never stored: every decoded event listens to all devices (device -1).
## Decoding is strict: anything out of range or not a whole number is refused, never clamped
## into something that looks valid (a clamped key 0 would leave an action without a key).

const TYPE_KEY := "key"
const TYPE_BUTTON := "joy_button"
const TYPE_AXIS := "joy_axis"
## JOY_BUTTON_SDL_MAX: the buttons 0..25 are real buttons.
const BUTTON_COUNT := 26
## JOY_AXIS_SDL_MAX: the axes 0..5 (4 and 5 are the triggers).
const AXIS_COUNT := 6
## The last code point that exists (the engine complains about anything above it).
const LAST_CODE_POINT := 0x10FFFF
## Codes of the engine's named special keys (measured with the round trip below, Godot 4.7).
const LAST_NAMED_SPECIAL := KEY_JIS_KANA


## Encodes a key, pad button or pad axis. {} for everything else: mouse, action, touch, MIDI,
## a key code that is no key, a pad axis at exactly 0 and a trigger pulled the wrong way.
static func encode(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var code := int((event as InputEventKey).physical_keycode)
		return {"type": TYPE_KEY, "physical_keycode": code} if key_is_valid(code) else {}
	if event is InputEventJoypadButton:
		var button := int((event as InputEventJoypadButton).button_index)
		return {"type": TYPE_BUTTON, "button": button} if _button_ok(button) else {}
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if not _axis_ok(int(motion.axis), motion.axis_value):
			return {}
		return {"type": TYPE_AXIS, "axis": int(motion.axis), "value": signf(motion.axis_value)}
	return {}


## Builds an event from untrusted data (a file, a dictionary from JSON: whole numbers arrive as
## floats, 87.0 is fine, 87.9 is not). Null unless everything is in range. Always device -1.
static func decode(data: Variant) -> InputEvent:
	if not data is Dictionary:
		return null
	var fields := data as Dictionary
	var kind: Variant = fields.get("type")
	if not kind is String:
		return null
	match str(kind):
		TYPE_KEY:
			return _decode_key(fields)
		TYPE_BUTTON:
			return _decode_button(fields)
		TYPE_AXIS:
			return _decode_axis(fields)
	return null


## decode(encode(...)) for untrusted dictionaries: the normalised dictionary or {}.
static func normalize(data: Variant) -> Dictionary:
	var event := decode(data)
	return encode(event) if event != null else {}


## Stable identity of an encoded event: "k87", "b0", "a5+", "a1-". Compare events with this,
## never with InputMap.action_has_event (that compares modifiers and device too).
static func event_id(data: Dictionary) -> String:
	match str(data.get("type", "")):
		TYPE_KEY:
			return "k%d" % _whole(data.get("physical_keycode"))
		TYPE_BUTTON:
			return "b%d" % _whole(data.get("button"))
		TYPE_AXIS:
			var way := "+" if float(data.get("value", 0.0)) > 0.0 else "-"
			return "a%d%s" % [_whole(data.get("axis")), way]
	return ""


## 0 = keyboard (InputBindings.Device.KEYBOARD), 1 = gamepad, -1 = not an event.
static func device_of(data: Dictionary) -> int:
	match str(data.get("type", "")):
		TYPE_KEY:
			return 0
		TYPE_BUTTON, TYPE_AXIS:
			return 1
	return -1


## True for the pad axes that are triggers (they rest at 0 and only pull towards +1).
static func is_trigger(axis: int) -> bool:
	return axis == JOY_AXIS_TRIGGER_LEFT or axis == JOY_AXIS_TRIGGER_RIGHT


## A physical key code the engine knows by name. 1 <= code < KEY_UNKNOWN, not KEY_SPECIAL, and
## OS.find_keycode_from_string(OS.get_keycode_string(code)) == code: the round trip refuses
## codes that are no key (99999, lower-case letters) and modifier-masked codes such as Shift+A
## (they are above KEY_UNKNOWN). The engine prints a complaint when it is asked to name an
## impossible code point, so those are filtered first.
static func key_is_valid(code: int) -> bool:
	if code <= 0 or code >= KEY_UNKNOWN or code == KEY_SPECIAL:
		return false
	if code < KEY_SPECIAL:
		if code > LAST_CODE_POINT or (code >= 0xD800 and code <= 0xDFFF):
			return false
	elif code > LAST_NAMED_SPECIAL and not (code >= KEY_KP_MULTIPLY and code <= KEY_KP_9):
		return false
	return OS.find_keycode_from_string(OS.get_keycode_string(code)) == code


static func _decode_key(fields: Dictionary) -> InputEvent:
	var code := _whole(fields.get("physical_keycode"), 1.0, float(KEY_UNKNOWN) - 1.0)
	if code < 0 or not key_is_valid(code):
		return null
	var key := InputEventKey.new()
	key.physical_keycode = code as Key
	key.device = -1
	return key


static func _decode_button(fields: Dictionary) -> InputEvent:
	var index := _whole(fields.get("button"), 0.0, float(BUTTON_COUNT) - 1.0)
	if index < 0:
		return null
	var button := InputEventJoypadButton.new()
	button.button_index = index as JoyButton
	button.device = -1
	return button


static func _decode_axis(fields: Dictionary) -> InputEvent:
	var axis := _whole(fields.get("axis"), 0.0, float(AXIS_COUNT) - 1.0)
	var value: Variant = fields.get("value")
	if axis < 0 or not (value is float or value is int):
		return null
	if not _axis_ok(axis, float(value)):
		return null
	var motion := InputEventJoypadMotion.new()
	motion.axis = axis as JoyAxis
	motion.axis_value = signf(float(value))
	motion.device = -1
	return motion


static func _button_ok(button: int) -> bool:
	return button >= 0 and button < BUTTON_COUNT


## Axis in range, value a real number other than 0, and triggers only towards +1.
static func _axis_ok(axis: int, value: float) -> bool:
	if axis < 0 or axis >= AXIS_COUNT or not is_finite(value) or value == 0.0:
		return false
	return value > 0.0 or not is_trigger(axis)


## A whole number from untrusted data as int, or -1 if it is not one or outside min..max.
## Floats are compared before they are cast (1e30 must not wrap around).
static func _whole(value: Variant, low := -INF, high := INF) -> int:
	if not (value is int or value is float):
		return -1
	var number := float(value)
	if not is_finite(number) or number != floorf(number) or number < low or number > high:
		return -1
	return int(number)
