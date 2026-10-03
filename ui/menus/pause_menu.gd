class_name PauseMenu
extends CanvasLayer
## Pause and test menu (Phase 1). Options let the tester compare movement presets,
## camera modes, direction modes and sprint behaviour. Fully usable with keyboard and pad:
## up/down to move, left/right or confirm to change a value.

signal options_changed

const MAIN_MENU := "res://core/boot/boot.tscn"
const ARROWS := "< %s >"

var _rows: Array[Dictionary] = []

@onready var _list: VBoxContainer = %List


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_add_action("PAUSE_RESUME", close)
	_add_option(
		"PAUSE_TUNING",
		["TUNING_DIREKT", "TUNING_WEICH", "TUNING_SCHWER"],
		func() -> int: return SessionOptions.tuning_index,
		func(i: int) -> void: SessionOptions.tuning_index = i,
	)
	_add_option(
		"PAUSE_CAMERA",
		["CAMERA_SMOOTH", "CAMERA_PIXEL"],
		func() -> int: return 0 if SessionOptions.smooth_camera else 1,
		func(i: int) -> void: SessionOptions.smooth_camera = i == 0,
	)
	_add_option(
		"PAUSE_DIRECTIONS",
		["DIRECTIONS_EIGHT", "DIRECTIONS_FREE"],
		func() -> int: return 0 if SessionOptions.snap_eight else 1,
		func(i: int) -> void: SessionOptions.snap_eight = i == 0,
	)
	_add_option(
		"PAUSE_SPRINT",
		["SPRINT_HOLD", "SPRINT_TOGGLE"],
		func() -> int: return 1 if SessionOptions.sprint_toggle else 0,
		func(i: int) -> void: SessionOptions.sprint_toggle = i == 1,
	)
	_add_option(
		"PAUSE_OVERLAY",
		["OPTION_OFF", "OPTION_ON"],
		func() -> int: return 1 if SessionOptions.show_overlay else 0,
		func(i: int) -> void: SessionOptions.show_overlay = i == 1,
	)
	_add_action("PAUSE_TO_MENU", _to_main_menu)
	_add_action("PAUSE_QUIT", func() -> void: get_tree().quit())


func is_open() -> bool:
	return visible


func open() -> void:
	show()
	get_tree().paused = true
	_refresh()
	(_rows[0]["button"] as Button).grab_focus()
	Log.info(Log.Category.UI, "pause menu open")


func close() -> void:
	hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"menu"):
		if visible:
			close()
		elif not _dialogue_open():
			open()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed(&"cancel"):
		close()
		get_viewport().set_input_as_handled()


func _dialogue_open() -> bool:
	for node in get_tree().get_nodes_in_group(&"dialogue_presenter"):
		if node.has_method(&"is_open") and node.call(&"is_open"):
			return true
	return false


func _add_action(key: String, callback: Callable) -> void:
	var button := _make_button()
	button.pressed.connect(callback)
	_rows.append({"button": button, "key": key})


func _add_option(key: String, values: Array, getter: Callable, setter: Callable) -> void:
	var button := _make_button()
	var row := {"button": button, "key": key, "values": values, "get": getter, "set": setter}
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


func _make_button() -> Button:
	var button := Button.new()
	button.theme_type_variation = &"MenuEntry"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_list.add_child(button)
	return button


func _cycle(row: Dictionary, step: int) -> void:
	var values: Array = row["values"]
	var index := wrapi(int((row["get"] as Callable).call()) + step, 0, values.size())
	(row["set"] as Callable).call(index)
	_refresh()
	options_changed.emit()


func _refresh() -> void:
	for row: Dictionary in _rows:
		var text := tr(row["key"])
		if row.has("values"):
			var values: Array = row["values"]
			text += "  " + ARROWS % tr(values[int((row["get"] as Callable).call())])
		(row["button"] as Button).text = text


func _to_main_menu() -> void:
	close()
	get_tree().change_scene_to_file(MAIN_MENU)
