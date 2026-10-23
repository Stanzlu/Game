extends RefCounted
## Shared by the tests of the key layout page: synthetic events, a page that is open and ready,
## and the small questions every test asks of it.

const KB := InputBindings.Device.KEYBOARD
const PAD := InputBindings.Device.GAMEPAD


static func key(code: int, pressed := true, echo := false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code as Key
	event.keycode = code as Key
	event.pressed = pressed
	event.echo = echo
	return event


static func pad_button(index: int, pressed := true) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = index as JoyButton
	event.pressed = pressed
	return event


static func pad_axis(axis: int, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis as JoyAxis
	event.axis_value = value
	return event


static func click(button: int, pressed := true) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button as MouseButton
	event.pressed = pressed
	return event


static func action(name: StringName, pressed := true) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = name
	event.pressed = pressed
	return event


## The encoded key, as the model takes it.
static func data(code: int) -> Dictionary:
	return {"type": "key", "physical_keycode": code}


## The codes of the editable cells of an action ("k70" strings), for readable comparisons.
static func slots(action_name: StringName, device: InputBindings.Device) -> Array[String]:
	var out: Array[String] = []
	for entry in Settings.bindings.slots(action_name, device):
		out.append(BindingCodec.event_id(entry))
	return out


## Starts a capture and lets the arming window pass (tests do not wait 0.3 s).
static func capture(
	menu: ControlsMenu, action_name: StringName, device: InputBindings.Device, cell := 0
) -> void:
	menu.begin_capture(action_name, device, cell)
	if menu.capture != null:
		menu.capture.armed_in = 0.0


static func focus(
	menu: ControlsMenu, action_name: StringName, device: InputBindings.Device
) -> void:
	menu.row_for(action_name, device).button.grab_focus()


## How many lines of text the footer holds right now.
static func footer_lines(menu: ControlsMenu) -> int:
	return maxi(menu.hint.get_line_count(), 1)


## The row texts in the order of the list.
static func button_texts(menu: ControlsMenu) -> Array[String]:
	var out: Array[String] = []
	for button in menu.list.buttons():
		out.append(button.text)
	return out
