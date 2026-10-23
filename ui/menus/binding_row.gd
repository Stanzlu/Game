class_name BindingRow
extends RefCounted
## One row of the key layout page (ADR-048): the action's name on the left, on the right the
## pinned keys as muted text (Enter, Esc, Start: they cannot be changed) and the two editable
## cells. The row is an OptionList button, so focus, sounds, hover and the cursor are those of
## every menu; this class adds the cells and the keys the page reads itself on a focused row:
## Left/Right pick the cell, Delete and pad Y clear it, the mouse picks and clears.
## The page owns the rules; the row only reports what was asked (signals) and shows what it is told.

## Left or Right was pressed: -1 or 1.
signal step_requested(step: int)
## A mouse press landed on this cell.
signal cell_pressed(cell: int)
## Delete, pad Y or a right click: the cell to empty.
signal clear_requested(cell: int)
signal focus_changed

enum State { FILLED, EMPTY, SELECTED, CAPTURING }

const EMPTY_TEXT := "–"
const CAPTURE_TEXT := "…"
## Between the cells, and between the pinned keys and the cells.
const GAP := 4.0
const FIXED_GAP := 8.0
## The cells end this far from the right edge of the row.
const RIGHT_INSET := 4.0
## At least this much stays free between the name and what stands right of it.
const NAME_GAP := 12.0
const PULSE_SECONDS := 0.45
const PULSE_LOW := 0.55
const FLASH_SECONDS := 0.25
const FLASH_COLOR := Color(1.7, 1.7, 1.7)
const NUDGE_PIXELS := 2.0
const NUDGE_SECONDS := 0.03

var action: StringName
var device: InputBindings.Device
var button: Button

var _box: HBoxContainer
var _fixed: Label
var _slots: Array[Control] = []
var _panels: Array[PanelContainer] = []
var _labels: Array[Label] = []
var _states: Array[State] = []
var _pulse: Tween


## Adds the row to `list`. `label_key` names the action; `on_press` starts the capture.
func _init(
	list: OptionList,
	for_action: StringName,
	for_device: InputBindings.Device,
	label_key: String,
	on_press: Callable
) -> void:
	action = for_action
	device = for_device
	button = list.add_action(label_key, on_press)
	_box = HBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.alignment = BoxContainer.ALIGNMENT_END
	_box.add_theme_constant_override(&"separation", int(GAP))
	_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_box.offset_right = -RIGHT_INSET
	button.add_child(_box)
	_fixed = Label.new()
	_fixed.theme_type_variation = &"BindFixed"
	_fixed.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_fixed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fixed.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fixed.size_flags_vertical = Control.SIZE_FILL
	_box.add_child(_fixed)
	for i in InputBindings.SLOTS:
		_add_cell()
	button.gui_input.connect(_on_gui_input)
	button.focus_entered.connect(focus_changed.emit)
	button.focus_exited.connect(focus_changed.emit)


# --- Show --------------------------------------------------------------------------------


## Shows the cells: `texts` are the labels of the filled ones (the rest is empty), `fixed_text`
## the pinned keys, `selected` the lit cell (-1 none), `capturing` the "…" in it.
func show_cells(
	texts: PackedStringArray, fixed_text: String, selected: int, capturing: bool
) -> void:
	_fixed.text = fixed_text
	_fixed.visible = not fixed_text.is_empty()
	for i in _slots.size():
		var filled := i < texts.size()
		var state := State.FILLED if filled else State.EMPTY
		var text := texts[i] if filled else EMPTY_TEXT
		if i == selected:
			state = State.CAPTURING if capturing else State.SELECTED
			text = CAPTURE_TEXT if capturing else text
		_set_cell(i, state, text)
	_update_pulse()


## What cell `index` shows now.
func cell_text(index: int) -> String:
	return _labels[index].text


func cell_state(index: int) -> State:
	return _states[index]


func fixed_text() -> String:
	return _fixed.text if _fixed.visible else ""


func cell_node(index: int) -> Control:
	return _slots[index]


## Where what stands right of the name begins (screen x): the pinned keys, else the first cell.
func content_left() -> float:
	var first: Control = _fixed if _fixed.visible else _slots[0]
	return first.get_global_rect().position.x


## The size of a cell: as wide as the widest of `samples` (so no key changes the page) and
## as high as a line of text plus the frame.
func cell_size(samples: PackedStringArray) -> Vector2:
	var label := _labels[0]
	var font := label.get_theme_font(&"font")
	var size := label.get_theme_font_size(&"font_size")
	var frame := _panels[0].get_theme_stylebox(&"panel").get_minimum_size()
	var widest := 0.0
	for text in samples:
		widest = maxf(widest, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
	return Vector2(ceilf(widest + frame.x), ceilf(font.get_height(size) + frame.y))


## Sizes the cells and the row (name, pinned keys, cells); returns the width the row needs.
func fit(cell: Vector2) -> float:
	for slot in _slots:
		slot.custom_minimum_size = cell
	var font := button.get_theme_font(&"font")
	var size := button.get_theme_font_size(&"font_size")
	var margin := button.get_theme_stylebox(&"normal").get_margin(SIDE_LEFT)
	var need := margin + font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	need += NAME_GAP + RIGHT_INSET + GAP + cell.x * _slots.size()
	if _fixed.visible:
		var fixed_font := _fixed.get_theme_font(&"font")
		var fixed_size := _fixed.get_theme_font_size(&"font_size")
		need += (
			FIXED_GAP
			+ fixed_font.get_string_size(_fixed.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fixed_size).x
		)
	button.custom_minimum_size = Vector2(ceilf(need), cell.y)
	return ceilf(need)


## A key was pressed that cannot be used: the cell shakes a little (not for players who turned
## shaking or flashing off).
func nudge(cell: int) -> void:
	if (
		not Settings.get_bool("display.screen_shake")
		or Settings.get_bool("display.reduce_flashing")
	):
		return
	var panel := _panels[cell]
	var tween := panel.create_tween()
	for x: float in [NUDGE_PIXELS, -NUDGE_PIXELS, NUDGE_PIXELS, -NUDGE_PIXELS, 0.0]:
		tween.tween_property(panel, ^"position:x", x, NUDGE_SECONDS)


## A new key lands in the cell: it lights up for a moment.
func flash(cell: int) -> void:
	if Settings.get_bool("display.reduce_flashing"):
		return
	var panel := _panels[cell]
	panel.modulate = FLASH_COLOR
	panel.create_tween().tween_property(panel, ^"modulate", Color.WHITE, FLASH_SECONDS)


# --- Cells (private) ---------------------------------------------------------------------


func _add_cell() -> void:
	# The cell sits in a plain Control: only there can it be moved (nudge), a container
	# would put it back
	var slot := Control.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	slot.add_child(panel)
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# a name that does not fit is cut short, the cell never grows
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	panel.add_child(label)
	_box.add_child(slot)
	_slots.append(slot)
	_panels.append(panel)
	_labels.append(label)
	_states.append(State.EMPTY)
	_set_cell(_slots.size() - 1, State.EMPTY, EMPTY_TEXT)


func _set_cell(index: int, state: State, text: String) -> void:
	_states[index] = state
	_labels[index].text = text
	var panel_type := &"BindCell"
	var label_type := &"BindCellLabel"
	if state == State.EMPTY:
		panel_type = &"BindCellEmpty"
		label_type = &"BindFixed"
	elif state != State.FILLED:
		panel_type = &"BindCellActive"
		label_type = &"BindCellActiveLabel"
	_panels[index].theme_type_variation = panel_type
	_labels[index].theme_type_variation = label_type


## The cell that waits for a key pulses (not for players who turned flashing off). Only its
## fill and frame do: the "…" in it keeps its full strength, or it would vanish at the low point.
func _update_pulse() -> void:
	if _pulse != null and _pulse.is_valid():
		_pulse.kill()
	for panel in _panels:
		panel.self_modulate.a = 1.0
	var at := _states.find(State.CAPTURING)
	if at < 0 or Settings.get_bool("display.reduce_flashing"):
		return
	var panel := _panels[at]
	_pulse = panel.create_tween().set_loops()
	_pulse.tween_property(panel, ^"self_modulate:a", PULSE_LOW, PULSE_SECONDS)
	_pulse.tween_property(panel, ^"self_modulate:a", 1.0, PULSE_SECONDS)


# --- Input (private) ---------------------------------------------------------------------


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_left"):
		step_requested.emit(-1)
		button.accept_event()
	elif event.is_action_pressed(&"ui_right"):
		step_requested.emit(1)
		button.accept_event()
	elif event is InputEventKey:
		_on_key(event as InputEventKey)
	elif event is InputEventJoypadButton:
		_on_pad_button(event as InputEventJoypadButton)
	elif event is InputEventMouseButton:
		_on_mouse(event as InputEventMouseButton)


## Delete clears the selected cell. A held key repeats: only the first press counts.
func _on_key(key: InputEventKey) -> void:
	var code := key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	if key.pressed and not key.echo and code == KEY_DELETE:
		clear_requested.emit(-1)
		button.accept_event()


## Pad Y clears the selected cell. Y can never be bound, but the confirm button is left alone
## whatever it is.
func _on_pad_button(pad: InputEventJoypadButton) -> void:
	if pad.pressed and pad.button_index == JOY_BUTTON_Y and not pad.is_action_pressed(&"interact"):
		clear_requested.emit(-1)
		button.accept_event()


## A left press on a cell picks it (the click itself then starts the capture, like on any
## row); a right press on a cell empties it.
func _on_mouse(click: InputEventMouseButton) -> void:
	if not click.pressed:
		return
	var cell := _cell_at(click)
	if cell < 0:
		return
	if click.button_index == MOUSE_BUTTON_LEFT:
		cell_pressed.emit(cell)
	elif click.button_index == MOUSE_BUTTON_RIGHT:
		button.grab_focus()
		clear_requested.emit(cell)
		button.accept_event()


func _cell_at(click: InputEventMouseButton) -> int:
	var point := button.get_global_transform() * click.position
	for i in _slots.size():
		if _slots[i].get_global_rect().has_point(point):
			return i
	return -1
