class_name OptionList
extends VBoxContainer
## Menu rows for keyboard and gamepad: actions, choices (left/right or confirm cycles the
## value), headers and plain info lines. Up/down moves through the enabled rows and wraps.
## All labels are translation keys; values are shown as "< value >".
## A MenuCursor marks the focused row; moving, confirming and changing values make the
## menu sounds of the current world (AudioDirector.ui).

signal value_changed(key: String)

const ARROWS := "<  %s  >"

## Which menu sounds to play (the start menu always uses the Real set).
var sound_skin := AudioDirectorService.SoundSet.FOLLOW
var cursor: MenuCursor
var _rows: Array[Dictionary] = []
## Focus set by code (opening, rebuilding) makes no sound.
var _quiet := false


func _ready() -> void:
	cursor = MenuCursor.new()
	cursor.name = "Cursor"
	add_child(cursor)
	Settings.changed.connect(_on_setting_changed)


## Large text (Game Bible §50) changes the font: rows measure themselves again.
func _on_setting_changed(key: String) -> void:
	if key == "text.large":
		refresh.call_deferred()


func clear_rows() -> void:
	for row in _rows:
		var node: Control = row["node"]
		remove_child(node)
		node.queue_free()
	_rows.clear()


func add_header(key: String) -> Label:
	var label := Label.new()
	label.theme_type_variation = &"MutedLabel"
	label.text = key
	add_child(label)
	_rows.append({"node": label, "key": key})
	return label


## Any other control (e.g. a table); removed with the rows.
func add_custom(control: Control) -> Control:
	add_child(control)
	_rows.append({"node": control})
	return control


## A line of text that cannot be focused (status, hints). `text` is shown as given.
func add_info(text: String) -> Label:
	var label := Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	add_child(label)
	_rows.append({"node": label})
	return label


## `label` overrides the translated key (e.g. slot descriptions).
func add_action(key: String, callback: Callable, enabled := true, label := "") -> Button:
	var button := _make_button()
	button.pressed.connect(func() -> void: AudioDirector.ui("confirm", sound_skin))
	button.pressed.connect(callback)
	button.disabled = not enabled
	_rows.append({"node": button, "key": key, "label": label})
	_refresh_row(_rows[-1])
	return button


## `values` are translation keys (or plain numbers); getter returns the index, setter takes it.
func add_choice(key: String, values: Array, getter: Callable, setter: Callable) -> Button:
	var button := _make_button()
	var value_label := Label.new()
	value_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	value_label.offset_right = -4
	button.add_child(value_label)
	var row := {
		"node": button,
		"key": key,
		"values": values,
		"get": getter,
		"set": setter,
		"value_label": value_label,
	}
	button.pressed.connect(func() -> void: _cycle(row, 1))
	button.gui_input.connect(
		func(event: InputEvent) -> void:
			if event.is_action_pressed(&"ui_left"):
				_cycle(row, -1)
				button.accept_event()
			elif event.is_action_pressed(&"ui_right"):
				_cycle(row, 1)
				button.accept_event()
	)
	_rows.append(row)
	_refresh_row(row)
	return button


## Choice for a Settings key. Booleans show Off/On unless `values` names false and true.
func add_setting(key: String, label_key: String, values: Array = []) -> Button:
	var is_bool := SettingsService.default_value(key) is bool
	var shown: Array = values if not values.is_empty() else ["OPTION_OFF", "OPTION_ON"]
	return add_choice(
		label_key,
		shown,
		func() -> int: return int(Settings.get_bool(key)) if is_bool else Settings.get_int(key),
		func(i: int) -> void: Settings.set_value(key, bool(i) if is_bool else i),
	)


func focus_first() -> void:
	focus_index(0)


## Focuses the n-th enabled row without a sound (clamped), and puts the cursor there.
func focus_index(index: int) -> void:
	var list := buttons()
	if list.is_empty():
		return
	_quiet = true
	list[clampi(index, 0, list.size() - 1)].grab_focus()
	_quiet = false
	cursor.snap()


func refresh() -> void:
	for row in _rows:
		_refresh_row(row)
	_link_focus()


func buttons() -> Array[Button]:
	var found: Array[Button] = []
	for row in _rows:
		if row["node"] is Button and not (row["node"] as Button).disabled:
			found.append(row["node"])
	return found


func _make_button() -> Button:
	var button := Button.new()
	button.theme_type_variation = &"MenuEntry"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.focus_mode = Control.FOCUS_ALL
	button.focus_entered.connect(_on_focus.bind(button))
	# The interact key (E) confirms like ui_accept; keys bound to both fire only once.
	button.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event.is_action_pressed(&"interact")
				and not event.is_action_pressed(&"ui_accept")
				and not button.disabled
			):
				button.accept_event()
				button.pressed.emit()
	)
	add_child(button)
	return button


func _on_focus(button: Button) -> void:
	cursor.target = button
	if not _quiet:
		AudioDirector.ui("move", sound_skin)


func _cycle(row: Dictionary, step: int) -> void:
	AudioDirector.ui("tick", sound_skin)
	var values: Array = row["values"]
	var index := wrapi(int((row["get"] as Callable).call()) + step, 0, values.size())
	(row["set"] as Callable).call(index)
	refresh()
	value_changed.emit(str(row["key"]))


func _refresh_row(row: Dictionary) -> void:
	var node: Control = row["node"]
	if not node is Button:
		return
	var text: String = row["label"] if not str(row.get("label", "")).is_empty() else tr(row["key"])
	var button := node as Button
	button.text = text
	if row.has("values"):
		var values: Array = row["values"]
		var index := clampi(int((row["get"] as Callable).call()), 0, values.size() - 1)
		var value: Variant = values[index]
		var value_label := row["value_label"] as Label
		value_label.text = ARROWS % (tr(value) if value is String else str(value))
		# the value sits on top of the button: reserve room so label and value never overlap
		var font := button.get_theme_font(&"font")
		var size := button.get_theme_font_size(&"font_size")
		var need := (
			font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			+ font.get_string_size(value_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			+ 34.0
		)
		button.custom_minimum_size.x = ceilf(need)


## Up/down wraps around and skips disabled rows and labels.
func _link_focus() -> void:
	var list := buttons()
	for i in list.size():
		var prev := list[(i - 1 + list.size()) % list.size()]
		var next := list[(i + 1) % list.size()]
		list[i].focus_neighbor_top = list[i].get_path_to(prev)
		list[i].focus_neighbor_bottom = list[i].get_path_to(next)
		list[i].focus_previous = list[i].focus_neighbor_top
		list[i].focus_next = list[i].focus_neighbor_bottom
