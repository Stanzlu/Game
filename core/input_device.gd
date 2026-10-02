extends Node
## Tracks whether the player last used keyboard or gamepad (autoload "InputDevice")
## and provides short labels for actions, e.g. "E" or "A". Used by all prompts.

signal device_changed(kind: Kind)

enum Kind { KEYBOARD, GAMEPAD }
enum Style { XBOX, PLAYSTATION, NINTENDO }

const STICK_THRESHOLD := 0.5

var kind := Kind.KEYBOARD
var style := Style.XBOX


func _input(event: InputEvent) -> void:
	var new_kind := kind
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


func set_kind(new_kind: Kind) -> void:
	if new_kind == kind:
		return
	kind = new_kind
	Log.debug(Log.Category.INPUT, "device changed", {"kind": Kind.keys()[kind]})
	device_changed.emit(kind)


## Short label for the first binding of `action` on the current device.
func label_for(action: StringName) -> String:
	for event: InputEvent in InputMap.action_get_events(action):
		if kind == Kind.KEYBOARD and event is InputEventKey:
			return key_label((event as InputEventKey).physical_keycode)
		if kind == Kind.GAMEPAD and event is InputEventJoypadButton:
			return button_label((event as InputEventJoypadButton).button_index, style)
	return "?"


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
	var logical := DisplayServer.keyboard_get_keycode_from_physical(physical)
	return OS.get_keycode_string(logical if logical != KEY_NONE else physical)


static func button_label(button: JoyButton, pad_style: Style) -> String:
	var face: Array = ["A", "B", "X", "Y"]
	if pad_style == Style.PLAYSTATION:
		face = ["✕", "○", "□", "△"]
	elif pad_style == Style.NINTENDO:
		face = ["B", "A", "Y", "X"]
	match button:
		JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y:
			return face[button]
		JOY_BUTTON_START:
			return "Start"
		JOY_BUTTON_BACK:
			return "Select"
	return "Pad %d" % button


static func style_from_name(joy_name: String) -> Style:
	var n := joy_name.to_lower()
	if n.contains("playstation") or n.contains("dualsense") or n.contains("dualshock"):
		return Style.PLAYSTATION
	if n.contains("ps4") or n.contains("ps5") or n.contains("sony"):
		return Style.PLAYSTATION
	if n.contains("nintendo") or n.contains("switch") or n.contains("joy-con"):
		return Style.NINTENDO
	return Style.XBOX
