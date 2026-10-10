class_name ControlsMenu
extends MenuLayer
## "Steuerung anzeigen": every action with its key and its pad button, side by side, read
## from the input map (so it stays true when bindings change).

## [action, label key]; movement is shown once for all four directions.
const ROWS: Array[Array] = [
	[&"move_up", "CONTROLS_MOVE"],
	[&"sprint", "CONTROLS_SPRINT"],
	[&"interact", "CONTROLS_INTERACT"],
	[&"cancel", "CONTROLS_BACK"],
	[&"menu", "CONTROLS_MENU"],
	[&"journal", "CONTROLS_JOURNAL"],
]


func _ready() -> void:
	title_key = "CONTROLS_TITLE"
	panel_width = 300
	layer = 55
	super()


func _build() -> void:
	for row: Array in ROWS:
		var action: StringName = row[0]
		var keys := InputDevice.label_for_kind(action, InputDevice.Kind.KEYBOARD)
		if action == &"move_up":
			keys = TranslationServer.translate("CONTROLS_MOVE_KEYS")
		var pad := InputDevice.label_for_kind(action, InputDevice.Kind.GAMEPAD)
		list.add_info("%s:  %s  ·  %s" % [tr(str(row[1])), keys, pad])
	list.add_action("MENU_BACK", close)
	hint.text = tr("CONTROLS_HINT")
