class_name ControlsMenu
extends MenuLayer
## "Tastenbelegung" (Game Bible §50, ADR-048): every rebindable action with its two cells for
## the keyboard and for the gamepad. A row opens a capture ("Drücke die neue Taste"), the rules
## live in Settings.bindings (InputBindings) and in BindingCapture; this page shows, asks and
## explains. The section of the device used last comes first (decided when the page opens).
##
## A cell is picked with Left/Right on a row, ONE column for the whole page (Up/Down keep it);
## a row whose second cell cannot be reached yet (the first is empty) shows the first free one.
## While a capture waits, every key and pad event is eaten here (`_input`), the rest of the list
## is dimmed and the mouse cannot move the focus. Every handler is inert while the page is
## hidden: the pause menu and the settings menu each own one page, and a hidden one must not
## take the focus of the shown one.

const KEYBOARD_ROWS: Array[StringName] = [
	&"move_up",
	&"move_down",
	&"move_left",
	&"move_right",
	&"sprint",
	&"interact",
	&"cancel",
	&"menu",
	&"journal",
]
const GAMEPAD_ROWS: Array[StringName] = [&"sprint", &"interact", &"cancel", &"menu", &"journal"]
const LABEL_KEYS := {
	&"move_up": "CONTROLS_MOVE_UP",
	&"move_down": "CONTROLS_MOVE_DOWN",
	&"move_left": "CONTROLS_MOVE_LEFT",
	&"move_right": "CONTROLS_MOVE_RIGHT",
	&"sprint": "CONTROLS_SPRINT",
	&"interact": "CONTROLS_INTERACT",
	&"cancel": "CONTROLS_BACK",
	&"menu": "CONTROLS_MENU",
	&"journal": "CONTROLS_JOURNAL",
}
## A message in the footer stays this long (it also goes at the next key press).
const MESSAGE_SECONDS := 2.5
## The panel never grows wider than this (large text, long names).
const MAX_PANEL_WIDTH := 620.0
## Questions need more room than the narrow default of a ConfirmMenu.
const QUESTION_WIDTH := 300
## The rest of the list while a capture waits.
const DIM_ALPHA := 0.5
## Keys whose names a cell always has room for; a longer one is cut short (an exotic key never
## changes the size of the page).
const SAMPLE_KEYS: Array[int] = [KEY_RIGHT, KEY_SPACE, KEY_SHIFT, KEY_BACKSPACE]
## The footer is this many lines high in every state, so the panel does not jump.
const FOOTER_LINES := 2

## Shortened by tests.
var message_seconds := MESSAGE_SECONDS
## The running capture; null while the page waits for a choice.
var capture: BindingCapture

var _order: Array[InputBindings.Device] = []
var _rows: Array[BindingRow] = []
var _column := 0
var _target_action := &""
var _target_device := InputBindings.Device.KEYBOARD
var _target_cell := 0
var _dimmed: Array[Control] = []
var _filters: Dictionary = {}
var _message_active := false
var _message_serial := 0
var _confirm: ConfirmMenu
var _answer: Callable
var _notes: ControlsNotes


func _ready() -> void:
	title_key = "CONTROLS_TITLE"
	panel_width = 440
	layer = 55
	super()
	set_process(false)
	Settings.bindings.changed.connect(_on_bindings_changed)
	InputDevice.device_changed.connect(_on_device_changed)
	InputDevice.labels_changed.connect(_on_labels_changed)


func open() -> void:
	_end_capture()
	_column = 0
	var pad_first := InputDevice.kind == InputDevice.Kind.GAMEPAD
	var first := InputBindings.Device.GAMEPAD if pad_first else InputBindings.Device.KEYBOARD
	var second := InputBindings.Device.KEYBOARD if pad_first else InputBindings.Device.GAMEPAD
	_order = [first, second]
	_end_message()
	super()


func close() -> void:
	_end_capture()
	_drop_question()
	if _notes != null:
		_notes.close()
	super()


func is_capturing() -> bool:
	return capture != null


## What the cell shows now: the key, "–" for a free cell, "…" while it waits for a key.
func cell_text(action: StringName, device: InputBindings.Device, cell: int) -> String:
	var row := row_for(action, device)
	return row.cell_text(cell) if row != null else ""


## The pinned keys shown next to the cells of a row ("Enter", "Esc", "Start").
func fixed_text(action: StringName, device: InputBindings.Device) -> String:
	var row := row_for(action, device)
	return row.fixed_text() if row != null else ""


## The cell that a press on this row would change.
func selected_cell(action: StringName, device: InputBindings.Device) -> int:
	return _shown_cell(action, device)


## Shows the labels of the model in the cells again (nothing is built anew: the cursor and the
## scroll position stay).
func refresh_cells() -> void:
	for row in _rows:
		_show_row(row)
	_apply_geometry()


## The wanted cell is clamped to one the row can show; the key press that follows is bound there.
func begin_capture(action: StringName, device: InputBindings.Device, cell: int) -> void:
	var row := row_for(action, device)
	if capture != null or not visible or row == null:
		return
	if not Settings.bindings.is_editable(action, device):
		return
	_target_action = action
	_target_device = device
	_target_cell = clampi(cell, 0, _reachable(action, device))
	capture = BindingCapture.new(device)
	title.text = "BIND_PRESS_KEY" if device == InputBindings.Device.KEYBOARD else "BIND_PRESS_PAD"
	_dim_but(row)
	_end_message()
	set_process(true)
	refresh_cells()
	_refresh_hint()


## What `_input` does with an event while a capture waits.
func handle_capture(event: InputEvent) -> void:
	if capture == null:
		return
	if _is_press(event):
		_end_message()
		_refresh_hint()
	var outcome := capture.feed(event)
	match outcome.kind:
		BindingCapture.Kind.EVENT:
			_bind(outcome.data)
		BindingCapture.Kind.CANCEL:
			_end_capture()
			AudioDirector.ui("back", list.sound_skin)
		BindingCapture.Kind.CLEAR:
			_clear(_target_action, _target_device, _target_cell)
		BindingCapture.Kind.STICK:
			_refuse(tr("BIND_STICK"))
		BindingCapture.Kind.OTHER_DEVICE:
			_refuse(_wrong_device_text())
		BindingCapture.Kind.INVALID:
			_refuse(tr("BIND_INVALID"))


func _process(delta: float) -> void:
	if capture != null:
		capture.tick(delta)


func _input(event: InputEvent) -> void:
	if not visible or capture == null:
		return
	if event is InputEventMouseButton:
		_on_capture_click(event as InputEventMouseButton)
	elif (
		event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion
	):
		InputDevice.observe(event)
		handle_capture(event)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_end_capture()


func _on_cancel() -> void:
	if capture == null:
		super()
		return
	_end_capture()
	AudioDirector.ui("back", list.sound_skin)


## Large text: the fonts, the cells and the footer are measured again.
func _on_setting_changed(key: String) -> void:
	super(key)
	if key == "text.large" and visible:
		_end_capture()
		rebuild.call_deferred()


# --- Build ---------------------------------------------------------------------------------


func _build() -> void:
	_rows.clear()
	for device in _order:
		var keyboard := device == InputBindings.Device.KEYBOARD
		list.add_header("BIND_KEYBOARD" if keyboard else "BIND_PAD")
		for action in KEYBOARD_ROWS if keyboard else GAMEPAD_ROWS:
			_add_row(action, device)
	list.add_action("BIND_MORE_PAGE", _open_notes)
	list.add_action("BIND_RESET_ALL", _ask_reset)
	list.add_action("MENU_BACK", close)
	_reserve_footer()
	refresh_cells()
	hint.text = ""
	_message_active = false


func _add_row(action: StringName, device: InputBindings.Device) -> void:
	var press := func() -> void: begin_capture(action, device, _shown_cell(action, device))
	var row := BindingRow.new(list, action, device, str(LABEL_KEYS[action]), press)
	# the rows are found again by action and device, never held by a connection (a row that
	# holds itself would never be freed)
	row.step_requested.connect(_on_step.bind(action, device))
	row.cell_pressed.connect(_on_cell_pressed.bind(action, device))
	row.clear_requested.connect(_on_clear_requested.bind(action, device))
	row.focus_changed.connect(_on_row_focus.bind(action, device))
	_rows.append(row)


## Cells as wide as the widest sample and as high as a line, rows as wide as the widest row:
## nothing moves when a key changes.
func _apply_geometry() -> void:
	if _rows.is_empty():
		return
	var cell := _rows[0].cell_size(_samples())
	for row in _rows:
		row.fit(cell)


func _samples() -> PackedStringArray:
	var samples := PackedStringArray()
	for code in SAMPLE_KEYS:
		samples.append(InputDevice.key_label(code as Key))
	# the PlayStation words are the longest button names (Quadrat, Dreieck)
	for button: JoyButton in [JOY_BUTTON_X, JOY_BUTTON_Y]:
		samples.append(InputDevice.button_label(button, InputDevice.Style.PLAYSTATION, true))
	return samples


## The footer is two lines high in every state: the panel is centred, so a footer that grows
## and shrinks would move the whole page.
func _reserve_footer() -> void:
	var font := hint.get_theme_font(&"font")
	var size := hint.get_theme_font_size(&"font_size")
	var spacing := hint.get_theme_constant(&"line_spacing")
	hint.custom_minimum_size.y = ceilf(FOOTER_LINES * font.get_height(size) + spacing)


func _show_row(row: BindingRow) -> void:
	var texts := PackedStringArray()
	for data in Settings.bindings.slots(row.action, row.device):
		texts.append(InputDevice.data_label(data, true))
	var selected := -1
	if capture != null and _is_target(row):
		selected = _target_cell
	elif row.button.has_focus():
		selected = _shown_cell(row.action, row.device)
	row.show_cells(
		texts, _pinned_text(row.action, row.device), selected, capture != null and _is_target(row)
	)


func _pinned_text(action: StringName, device: InputBindings.Device) -> String:
	var names := PackedStringArray()
	for data in Settings.bindings.fixed(action, device):
		var text := InputDevice.data_label(data, true)
		if not text.is_empty() and not names.has(text):
			names.append(text)
	return " ".join(names)


# --- Cells and rows --------------------------------------------------------------------------


## The row of an action on a device; null where the page has none (walking on the pad).
func row_for(action: StringName, device: InputBindings.Device) -> BindingRow:
	for row in _rows:
		if row.action == action and row.device == device:
			return row
	return null


func _is_target(row: BindingRow) -> bool:
	return row.action == _target_action and row.device == _target_device


## The highest cell the row can show: the first free one, or the last.
func _reachable(action: StringName, device: InputBindings.Device) -> int:
	return mini(Settings.bindings.slots(action, device).size(), InputBindings.SLOTS - 1)


## The page-wide column, clamped for this row only.
func _shown_cell(action: StringName, device: InputBindings.Device) -> int:
	return mini(_column, _reachable(action, device))


func _on_step(step: int, action: StringName, device: InputBindings.Device) -> void:
	if not visible or capture != null:
		return
	var shown := _shown_cell(action, device)
	var wanted := clampi(shown + step, 0, InputBindings.SLOTS - 1)
	if wanted > _reachable(action, device):
		return
	_column = wanted
	if wanted != shown:
		AudioDirector.ui("tick", list.sound_skin)
		refresh_cells()


func _on_cell_pressed(cell: int, action: StringName, device: InputBindings.Device) -> void:
	if not visible or capture != null:
		return
	_column = mini(cell, _reachable(action, device))
	refresh_cells()


func _on_clear_requested(cell: int, action: StringName, device: InputBindings.Device) -> void:
	if not visible or capture != null:
		return
	_clear(action, device, _shown_cell(action, device) if cell < 0 else cell)


func _on_row_focus(action: StringName, device: InputBindings.Device) -> void:
	if not visible:
		return
	var row := row_for(action, device)
	if row == null or not is_instance_valid(row.button):
		return
	_show_row(row)
	if capture == null:
		_end_message()
		_refresh_hint()


func _on_bindings_changed(_actions: PackedStringArray) -> void:
	_refresh_all()


func _on_device_changed(_kind: int) -> void:
	_refresh_all()


func _on_labels_changed() -> void:
	_refresh_all()


func _refresh_all() -> void:
	if not visible:
		return
	refresh_cells()
	_refresh_hint()


# --- Footer ----------------------------------------------------------------------------------


## The footer shows what the page is doing, unless a message is on.
func _refresh_hint() -> void:
	if visible and not _message_active:
		hint.text = _state_hint()


func _state_hint() -> String:
	if capture != null:
		return _capture_hint()
	for row in _rows:
		if row.button.has_focus():
			var arguments := [
				InputDevice.label_for(&"interact", true),
				_clear_label(),
				InputDevice.label_for(&"cancel", true)
			]
			return tr("BIND_HINT") % arguments
	return ""


func _capture_hint() -> String:
	var cancel := InputDevice.key_label(KEY_ESCAPE)
	if InputDevice.kind == InputDevice.Kind.GAMEPAD:
		var start := InputDevice.button_label(JOY_BUTTON_START, InputDevice.style, true)
		return tr("BIND_CAPTURE_PAD") % [_action_name(_target_action), start]
	if _target_device == InputBindings.Device.GAMEPAD and Input.get_connected_joypads().is_empty():
		return tr("BIND_NO_PAD") % cancel
	return tr("BIND_CAPTURE_KEYS") % [_action_name(_target_action), cancel, _clear_label()]


## The key that empties a cell. Mac keyboards have no forward-delete key: Fn+Delete sends it.
static func clear_label(
	kind: InputDevice.Kind, style: InputDevice.Style, os_name: String
) -> String:
	if kind == InputDevice.Kind.GAMEPAD:
		return InputDevice.button_label(JOY_BUTTON_Y, style, true)
	if os_name == "macOS":
		return TranslationServer.translate("BIND_CLEAR_MAC")
	return InputDevice.key_label(KEY_DELETE)


func _clear_label() -> String:
	return clear_label(InputDevice.kind, InputDevice.style, OS.get_name())


## A message in the footer; the state hint comes back after a while, at the next key press and
## when the focus moves.
func _say(text: String) -> void:
	hint.text = text
	_message_active = true
	_message_serial += 1
	var serial := _message_serial
	await NodeTimer.after(self, message_seconds)
	if serial == _message_serial and visible:
		_message_active = false
		_refresh_hint()


func _end_message() -> void:
	_message_serial += 1
	_message_active = false


# --- Capture -----------------------------------------------------------------------------------


func _is_press(event: InputEvent) -> bool:
	if event is InputEventKey:
		return (event as InputEventKey).pressed and not (event as InputEventKey).echo
	return event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed


## A click ends the capture and is eaten (a second click acts); the wheel goes on scrolling.
func _on_capture_click(click: InputEventMouseButton) -> void:
	var buttons := [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]
	if click.pressed and buttons.has(click.button_index):
		_end_capture()
		get_viewport().set_input_as_handled()


## Whoever wants a message after the end of a capture says it afterwards: one that was on
## (the last refusal) must not outlive the capture it was about.
func _end_capture() -> void:
	if capture == null:
		return
	capture.reset()
	capture = null
	set_process(false)
	_end_message()
	title.text = title_key
	for node in _dimmed:
		if is_instance_valid(node):
			node.modulate.a = 1.0
			if _filters.has(node):
				node.mouse_filter = _filters[node]
	_dimmed.clear()
	_filters.clear()
	refresh_cells()
	_refresh_hint()


## The rest of the list steps back and the mouse stops moving the focus.
func _dim_but(row: BindingRow) -> void:
	for node in list.get_children():
		if node is MenuCursor or node == row.button or not node is Control:
			continue
		var control := node as Control
		control.modulate.a = DIM_ALPHA
		_dimmed.append(control)
		if control is Button:
			_filters[control] = control.mouse_filter
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _wrong_device_text() -> String:
	if _target_device == InputBindings.Device.KEYBOARD:
		return tr("BIND_ONLY_KEY")
	return tr("BIND_ONLY_PAD")


## The capture goes on: the next key can be tried at once.
func _refuse(text: String) -> void:
	AudioDirector.ui("back", list.sound_skin)
	_say(text)
	var row := row_for(_target_action, _target_device)
	if row != null:
		row.nudge(_target_cell)


# --- Rules answered ------------------------------------------------------------------------------


func _bind(data: Dictionary) -> void:
	var action := _target_action
	var device := _target_device
	var cell := _target_cell
	var result := Settings.bindings.bind(action, device, cell, data)
	match result.code:
		InputBindings.Code.OK:
			_bound(action, device, cell, _done_text(action, data))
		InputBindings.Code.UNCHANGED:
			_end_capture()
			AudioDirector.ui("tick", list.sound_skin)
		InputBindings.Code.CONFLICT:
			_conflict(result, action, device, cell)
		InputBindings.Code.BAD_SLOT:
			# the list shrank under the capture: the key goes to the first free cell
			var free := Settings.bindings.slots(action, device).size()
			_target_cell = mini(free, InputBindings.SLOTS - 1)
			_bind(data)
		InputBindings.Code.NOT_EDITABLE, InputBindings.Code.UNKNOWN_ACTION:
			_end_capture()
		_:
			_refuse(_refusal_text(result, action))


func _bound(action: StringName, device: InputBindings.Device, cell: int, text: String) -> void:
	_end_capture()
	AudioDirector.ui("confirm", list.sound_skin)
	_say(text)
	var row := row_for(action, device)
	if row != null:
		row.flash(cell)


func _done_text(action: StringName, data: Dictionary) -> String:
	return tr("BIND_DONE") % [_action_name(action), InputDevice.data_label(data, true)]


func _refusal_text(result: InputBindings.Result, action: StringName) -> String:
	var label := InputDevice.data_label(result.data, true)
	var texts := {
		InputBindings.Code.RESERVED: _reserved_text(label, result.owners),
		InputBindings.Code.STICK: tr("BIND_STICK"),
		InputBindings.Code.TRIGGER: tr("BIND_TRIGGER") % _action_name(&"sprint"),
		InputBindings.Code.WRONG_DEVICE: _wrong_device_text(),
		InputBindings.Code.SAME_ACTION: tr("BIND_SAME_ACTION") % [_action_name(action), label],
	}
	return str(texts.get(result.code, tr("BIND_INVALID")))


## Why a key cannot be taken: nobody may hold it (Enter, Esc, Page Up ...), walking holds it for
## good, or it is kept for the one or two actions that may have it (Space, Tab): reserved, not
## fixed, because the player can put it there.
func _reserved_text(label: String, owners: Array[StringName]) -> String:
	var names := PackedStringArray()
	for holder in owners:
		var named := _owner_name(holder)
		if not names.has(named):
			names.append(named)
	if names.is_empty():
		return tr("BIND_FIXED_KEY") % label
	if names.size() == 1:
		return tr("BIND_RESERVED_FOR") % [label, names[0]]
	return tr("BIND_RESERVED_TWO") % [label, names[0], names[1]]


## The name of the action that owns a reserved key; the four walk actions are one.
func _owner_name(action: StringName) -> String:
	if InputBindings.PAD_FIXED_ACTIONS.has(action):
		return tr("CONTROLS_MOVE")
	return _action_name(action)


func _action_name(action: StringName) -> String:
	return tr(str(LABEL_KEYS.get(action, "")))


func _conflict(
	result: InputBindings.Result, action: StringName, device: InputBindings.Device, cell: int
) -> void:
	var label := InputDevice.data_label(result.data, true)
	var holder := _action_name(result.other)
	var data := result.data
	var resolve := InputBindings.Resolve.SWAP
	var text := ""
	var yes := "BIND_SWAP"
	if result.can_swap:
		var moved := InputDevice.data_label(Settings.bindings.slots(action, device)[cell], true)
		text = tr("BIND_ASK_SWAP") % [label, holder, moved]
	elif result.can_take:
		resolve = InputBindings.Resolve.TAKE
		text = tr("BIND_ASK_TAKE") % [label, holder]
		yes = "BIND_TAKE"
	else:
		var sole := "BIND_SOLE" if device == InputBindings.Device.KEYBOARD else "BIND_SOLE_PAD"
		_refuse(tr(sole) % [label, holder])
		return
	_end_capture()
	var settle := func() -> void: _settle(action, device, cell, data, resolve, result.other)
	_ask(text, yes, settle)


func _settle(
	action: StringName,
	device: InputBindings.Device,
	cell: int,
	data: Dictionary,
	resolve: InputBindings.Resolve,
	other: StringName
) -> void:
	var result := Settings.bindings.bind(action, device, cell, data, resolve)
	if not result.ok():
		_say(tr("BIND_INVALID"))
		return
	AudioDirector.ui("confirm", list.sound_skin)
	if resolve == InputBindings.Resolve.SWAP:
		_say(tr("BIND_DONE_SWAP") % [_action_name(action), _action_name(other)])
	else:
		_say(_done_text(action, data))
	var row := row_for(action, device)
	if row != null:
		row.flash(cell)


func _clear(action: StringName, device: InputBindings.Device, cell: int) -> void:
	var slots := Settings.bindings.slots(action, device)
	if cell >= slots.size():
		_refuse_idle(tr("BIND_NOTHING"))
		return
	var label := InputDevice.data_label(slots[cell], true)
	var code := Settings.bindings.clear(action, device, cell)
	if code == InputBindings.Code.OK:
		_end_capture()
		AudioDirector.ui("close", list.sound_skin)
		_say(tr("BIND_CLEARED") % [label, _action_name(action)])
		return
	var last := "BIND_LAST" if device == InputBindings.Device.KEYBOARD else "BIND_LAST_PAD"
	_refuse_idle(tr(last) % _action_name(action))


## A refusal on a cell that is not being captured: only sound and footer.
func _refuse_idle(text: String) -> void:
	if capture != null:
		_refuse(text)
		return
	AudioDirector.ui("back", list.sound_skin)
	_say(text)


# --- Questions and the second page -------------------------------------------------------------


## Asks with the safe answer preselected; `on_yes` runs only after a yes.
func _ask(text: String, yes: String, on_yes: Callable) -> void:
	var menu := _question()
	_drop_question()
	_answer = func(accepted: bool) -> void:
		if accepted:
			on_yes.call()
	menu.answered.connect(_answer, CONNECT_ONE_SHOT)
	menu.ask_text(text, yes, "BIND_ABORT")


func _question() -> ConfirmMenu:
	if _confirm == null:
		_confirm = ConfirmMenu.new()
		_confirm.name = "Question"
		_confirm.panel_width_override = QUESTION_WIDTH
		_confirm.follow_mode = follow_mode
		_confirm.sound_set = sound_set
		add_child(_confirm)
		stack(_confirm)
	return _confirm


## A question that was never answered (the page closed under it) must not fire later.
func _drop_question() -> void:
	if _confirm == null:
		return
	if _answer.is_valid() and _confirm.answered.is_connected(_answer):
		_confirm.answered.disconnect(_answer)
	_confirm.close()


func _ask_reset() -> void:
	if not Settings.bindings.is_overridden():
		AudioDirector.ui("tick", list.sound_skin)
		_say(tr("BIND_ALREADY_DEFAULT"))
		return
	_ask(tr("BIND_ASK_RESET_ALL"), "BIND_RESET_YES", _reset_all)


func _reset_all() -> void:
	Settings.bindings.reset()
	list.focus_index(0)
	_say(tr("BIND_RESET_DONE"))


func _open_notes() -> void:
	if _notes == null:
		_notes = ControlsNotes.new()
		_notes.name = "Notes"
		_notes.follow_mode = follow_mode
		_notes.sound_set = sound_set
		add_child(_notes)
		stack(_notes)
	_notes.open()
