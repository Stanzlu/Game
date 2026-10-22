extends Node
## Tracks whether the player last used keyboard or gamepad (autoload "InputDevice")
## and provides short labels for actions, e.g. "E" or "A". Used by all prompts.

signal device_changed(kind: Kind)
## The keys or buttons behind the labels changed (the player rebound something; emitted by
## Settings). Prompts that show a key name connect this as well as `device_changed`.
signal labels_changed

enum Kind { KEYBOARD, GAMEPAD }
enum Style { XBOX, PLAYSTATION, NINTENDO }

const STICK_THRESHOLD := 0.5
## Face buttons of a PlayStation pad as words, in button order (A, B, X, Y).
const PS_WORD_KEYS: Array[String] = [
	"CONTROLS_PS_CROSS", "CONTROLS_PS_CIRCLE", "CONTROLS_PS_SQUARE", "CONTROLS_PS_TRIANGLE"
]
## Held movement actions that would stay pressed when a pad vanishes mid-stride.
const HELD_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right", &"sprint"
]

var kind := Kind.KEYBOARD
var style := Style.XBOX


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _input(event: InputEvent) -> void:
	var new_kind := kind
	if event is InputEventMouseMotion:
		_show_mouse(true)
		return
	if event is InputEventKey or event is InputEventJoypadButton:
		# playing with keys or a pad: the pointer gets out of the picture
		_show_mouse(false)
	if event is InputEventKey or event is InputEventMouseButton:
		new_kind = Kind.KEYBOARD
	elif event is InputEventJoypadButton:
		new_kind = Kind.GAMEPAD
	elif event is InputEventJoypadMotion:
		if absf((event as InputEventJoypadMotion).axis_value) > STICK_THRESHOLD:
			new_kind = Kind.GAMEPAD
	if new_kind == Kind.GAMEPAD:
		style = style_from_name(Input.get_joy_name(event.device))
	set_kind(new_kind)


## A pad that is unplugged mid-game leaves its prompts and a held stick behind: with no pad
## left the labels go back to the keyboard and the movement actions are let go.
func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if connected or not Input.get_connected_joypads().is_empty():
		return
	for action in HELD_ACTIONS:
		Input.action_release(action)
	set_kind(Kind.KEYBOARD)
	Log.info(Log.Category.INPUT, "gamepad disconnected")


func _show_mouse(show: bool) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode := Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_HIDDEN
	if Input.mouse_mode != mode:
		Input.mouse_mode = mode


func set_kind(new_kind: Kind) -> void:
	if new_kind == kind:
		return
	kind = new_kind
	Log.debug(Log.Category.INPUT, "device changed", {"kind": Kind.keys()[kind]})
	device_changed.emit(kind)


## Short label for the first binding of `action` on the current device.
func label_for(action: StringName) -> String:
	return label_for_kind(action, kind)


## Short label for the first binding of `action` on keyboard or gamepad (sticks and
## triggers as "Stick"/"Trigger" when the action has no button).
func label_for_kind(action: StringName, device: Kind) -> String:
	var labels := labels_for_kind(action, device)
	return labels[0] if not labels.is_empty() else "?"


## Labels of every binding of `action` on keyboard or gamepad, without repeats: keys in the
## order of the input map; buttons first, then sticks and triggers ("Stick"/"Trigger").
## `words` spells the PlayStation face buttons out (Kreuz, Kreis, ...) where a page shows
## them in the body font, which has no such glyphs.
func labels_for_kind(action: StringName, device: Kind, words := false) -> PackedStringArray:
	var labels := PackedStringArray()
	var axes := PackedStringArray()
	for event: InputEvent in InputMap.action_get_events(action):
		var label := ""
		if device == Kind.KEYBOARD and event is InputEventKey:
			label = key_label((event as InputEventKey).physical_keycode)
		elif device == Kind.GAMEPAD and event is InputEventJoypadButton:
			label = button_label((event as InputEventJoypadButton).button_index, style, words)
		elif device == Kind.GAMEPAD and event is InputEventJoypadMotion:
			var axis := (event as InputEventJoypadMotion).axis
			var axis_label := TranslationServer.translate(
				"KEY_TRIGGER" if axis >= JOY_AXIS_TRIGGER_LEFT else "KEY_STICK"
			)
			if not axes.has(axis_label):
				axes.append(axis_label)
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
	labels.append_array(axes)
	return labels


static func key_label(physical: Key) -> String:
	match physical:
		KEY_SPACE:
			return TranslationServer.translate("KEY_SPACE")
		KEY_ESCAPE:
			return "Esc"
		KEY_SHIFT:
			return TranslationServer.translate("KEY_SHIFT")
		KEY_ENTER, KEY_KP_ENTER:
			return "Enter"
		KEY_BACKSPACE:
			return "Backspace"
	var logical := KEY_NONE
	# Layout lookup needs a real display server (not available headless).
	if DisplayServer.get_name() != "headless":
		logical = DisplayServer.keyboard_get_keycode_from_physical(physical)
	return OS.get_keycode_string(logical if logical != KEY_NONE else physical)


static func button_label(button: JoyButton, pad_style: Style, words := false) -> String:
	var face: Array = ["A", "B", "X", "Y"]
	if pad_style == Style.PLAYSTATION:
		# "×" instead of "✕": the key-cap font has it (no fallback glyph)
		face = ["×", "○", "□", "△"]
		if words:
			face = PS_WORD_KEYS.map(func(key: String) -> String: return tr_key(key))
	elif pad_style == Style.NINTENDO:
		face = ["B", "A", "Y", "X"]
	match button:
		JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y:
			return face[button]
		JOY_BUTTON_START:
			return "Start"
		JOY_BUTTON_BACK:
			return "Select"
		JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER:
			return shoulder_label(button == JOY_BUTTON_LEFT_SHOULDER, pad_style)
		JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT:
			return tr_key("CONTROLS_PAD_DPAD")
	return "Pad %d" % button


static func shoulder_label(left: bool, pad_style: Style) -> String:
	match pad_style:
		Style.PLAYSTATION:
			return "L1" if left else "R1"
		Style.NINTENDO:
			return "L" if left else "R"
	return "LB" if left else "RB"


static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)


static func style_from_name(joy_name: String) -> Style:
	var n := joy_name.to_lower()
	if n.contains("playstation") or n.contains("dualsense") or n.contains("dualshock"):
		return Style.PLAYSTATION
	if n.contains("ps4") or n.contains("ps5") or n.contains("sony"):
		return Style.PLAYSTATION
	if n.contains("nintendo") or n.contains("switch") or n.contains("joy-con"):
		return Style.NINTENDO
	return Style.XBOX
