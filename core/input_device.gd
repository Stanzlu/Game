extends Node
## Tracks whether the player last used keyboard or gamepad (autoload "InputDevice")
## and provides short labels for actions, e.g. "E" or "A" (by default: the player may rebind
## the keys, ADR-048; the labels read the live InputMap). Used by all prompts, which also
## listen to `labels_changed`.

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
## Keys that have a German name of their own (translation keys in ui.csv).
const NAMED_KEYS := {
	KEY_UP: "KEY_ARROW_UP",
	KEY_DOWN: "KEY_ARROW_DOWN",
	KEY_LEFT: "KEY_ARROW_LEFT",
	KEY_RIGHT: "KEY_ARROW_RIGHT",
	KEY_PAGEUP: "KEY_PAGE_UP",
	KEY_PAGEDOWN: "KEY_PAGE_DOWN",
	KEY_DELETE: "KEY_DELETE",
	KEY_INSERT: "KEY_INSERT",
	KEY_HOME: "KEY_HOME",
	KEY_END: "KEY_END",
	KEY_CTRL: "KEY_CTRL",
	KEY_SPACE: "KEY_SPACE",
	KEY_SHIFT: "KEY_SHIFT",
}
## The keypad: "Num 5" (translation KEY_NUMPAD) with the character on the key.
const KEYPAD_KEYS := {
	KEY_KP_0: "0",
	KEY_KP_1: "1",
	KEY_KP_2: "2",
	KEY_KP_3: "3",
	KEY_KP_4: "4",
	KEY_KP_5: "5",
	KEY_KP_6: "6",
	KEY_KP_7: "7",
	KEY_KP_8: "8",
	KEY_KP_9: "9",
	KEY_KP_ADD: "+",
	KEY_KP_SUBTRACT: "-",
	KEY_KP_MULTIPLY: "*",
	KEY_KP_DIVIDE: "/",
	KEY_KP_PERIOD: ",",
}
## Held movement actions that would stay pressed when a pad vanishes mid-stride.
const HELD_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right", &"sprint"
]

var kind := Kind.KEYBOARD
var style := Style.XBOX


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _input(event: InputEvent) -> void:
	observe(event)


## Follows an event: which device was used last, the pad's style, the mouse pointer. `_input`
## calls this for everything; a page that consumes key and pad events itself (the key capture)
## calls it too, because this autoload sits last in the order and would never see them.
func observe(event: InputEvent) -> void:
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


## Short label for the first binding of `action` on the current device (`words`: see
## labels_for_kind).
func label_for(action: StringName, words := false) -> String:
	return label_for_kind(action, kind, words)


## Short label for the first binding of `action` on keyboard or gamepad ("?" if it has none,
## which the layout rules prevent but a page must survive).
func label_for_kind(action: StringName, device: Kind, words := false) -> String:
	var labels := labels_for_kind(action, device, words)
	return labels[0] if not labels.is_empty() else "?"


## Labels of every binding of `action` on keyboard or gamepad, without repeats, in the order
## of the input map (own keys first, pinned ones behind; buttons, sticks and triggers as they
## come). `words` spells the PlayStation face buttons out (Kreuz, Kreis, ...) where a page
## shows them in the body font, which has no such glyphs.
func labels_for_kind(action: StringName, device: Kind, words := false) -> PackedStringArray:
	var labels := PackedStringArray()
	for event: InputEvent in InputMap.action_get_events(action):
		var is_key := event is InputEventKey
		if is_key != (device == Kind.KEYBOARD):
			continue
		var label := event_label(event, words)
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
	return labels


## What a key, button or axis event is called on the current pad ("" for anything else).
func event_label(event: InputEvent, words := false) -> String:
	if event is InputEventKey:
		return key_label((event as InputEventKey).physical_keycode)
	if event is InputEventJoypadButton:
		return button_label((event as InputEventJoypadButton).button_index, style, words)
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if BindingCodec.is_trigger(motion.axis):
			return trigger_label(motion.axis == JOY_AXIS_TRIGGER_LEFT, style)
		return tr_key("KEY_STICK")
	return ""


## The same for an event as the layout model holds it (BindingCodec data).
func data_label(data: Dictionary, words := false) -> String:
	var event := BindingCodec.decode(data)
	return event_label(event, words) if event != null else ""


## What the walk keys are called together: "WASD" when the first keys are single letters,
## "Pfeiltasten" when all four are arrows, otherwise the four names with spaces. The pad
## walks with the stick.
func move_label(device: Kind) -> String:
	if device == Kind.GAMEPAD:
		return tr_key("CONTROLS_MOVE_PAD")
	var labels := PackedStringArray()
	for action: StringName in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		labels.append(label_for_kind(action, Kind.KEYBOARD))
	var arrows := PackedStringArray()
	for key: String in ["KEY_ARROW_UP", "KEY_ARROW_LEFT", "KEY_ARROW_DOWN", "KEY_ARROW_RIGHT"]:
		arrows.append(tr_key(key))
	var letters := true
	var all_arrows := true
	for label in labels:
		letters = letters and label.length() == 1
		all_arrows = all_arrows and arrows.has(label)
	if letters:
		return "".join(labels)
	return tr_key("CONTROLS_MOVE_ARROWS") if all_arrows else " ".join(labels)


static func key_label(physical: Key) -> String:
	var named := _named_key(physical)
	if not named.is_empty():
		return named
	var logical := KEY_NONE
	# Layout lookup needs a real display server (not available headless).
	if DisplayServer.get_name() != "headless":
		logical = DisplayServer.keyboard_get_keycode_from_physical(physical)
	var shown := shown_code(physical, logical)
	# printable keys by the character on the cap (";" and not "Semicolon")
	if shown > KEY_SPACE and shown < KEY_SPECIAL:
		return String.chr(shown).to_upper()
	return OS.get_keycode_string(shown as Key)


## The code a key is named after: the character the layout puts on it, if the layout says a
## printable one. A driver can answer with a keypad or other special code for a printable key
## (Comma comes back as the keypad's period under Xvfb): that is not believed, the physical
## key is named instead.
static func shown_code(physical: Key, logical: Key) -> int:
	var printable := logical > KEY_SPACE and logical < KEY_SPECIAL
	return int(logical if printable else physical)


## Keys with a German name of their own; "" for the rest.
static func _named_key(physical: Key) -> String:
	match physical:
		KEY_ESCAPE:
			return "Esc"
		KEY_ENTER, KEY_KP_ENTER:
			return "Enter"
		KEY_BACKSPACE:
			return "Backspace"
	if NAMED_KEYS.has(physical):
		var translation_key: String = NAMED_KEYS[physical]
		return tr_key(translation_key)
	if KEYPAD_KEYS.has(physical):
		var character: String = KEYPAD_KEYS[physical]
		return tr_key("KEY_NUMPAD") % character
	return ""


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
		JOY_BUTTON_LEFT_STICK:
			return "L3"
		JOY_BUTTON_RIGHT_STICK:
			return "R3"
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


## The trigger as the pad calls it: LT/RT, L2/R2 on PlayStation, ZL/ZR on Nintendo.
static func trigger_label(left: bool, pad_style: Style) -> String:
	match pad_style:
		Style.PLAYSTATION:
			return "L2" if left else "R2"
		Style.NINTENDO:
			return "ZL" if left else "ZR"
	return "LT" if left else "RT"


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
