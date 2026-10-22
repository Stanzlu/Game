class_name ControlsMenu
extends MenuLayer
## "Steuerung anzeigen": every action with all its keys and its pad buttons, side by side,
## read from the input map (so it stays true when bindings change).

## [action, label key]; movement is shown once for all four directions.
const ROWS: Array[Array] = [
	[&"move_up", "CONTROLS_MOVE"],
	[&"sprint", "CONTROLS_SPRINT"],
	[&"interact", "CONTROLS_INTERACT"],
	[&"cancel", "CONTROLS_BACK"],
	[&"menu", "CONTROLS_MENU"],
	[&"journal", "CONTROLS_JOURNAL"],
]
const SEPARATOR := " / "


func _ready() -> void:
	title_key = "CONTROLS_TITLE"
	panel_width = 380
	layer = 55
	super()


func _build() -> void:
	for row: Array in ROWS:
		list.add_info(row_text(row[0], str(row[1])))
	# two things the input map cannot say: a held key skips, the right stick scrolls
	var skip_keys := SEPARATOR.join(
		[
			_first(&"interact", InputDevice.Kind.KEYBOARD),
			_first(&"interact", InputDevice.Kind.GAMEPAD)
		]
	)
	list.add_info(tr("CONTROLS_SKIP") % skip_keys)
	list.add_info(tr("CONTROLS_SCROLL_ROW"))
	list.add_action("MENU_BACK", close)
	hint.text = tr("CONTROLS_HINT")


## "Label:  keys  ·  buttons" for one action. Esc opens the menu, so "Zurück" leaves it out
## (it still goes back); PlayStation buttons are words here, the glyphs are only in prompts.
static func row_text(action: StringName, label_key: String) -> String:
	var keys := InputDevice.labels_for_kind(action, InputDevice.Kind.KEYBOARD)
	var pad := InputDevice.labels_for_kind(action, InputDevice.Kind.GAMEPAD, true)
	var keys_text := SEPARATOR.join(keys)
	var pad_text := SEPARATOR.join(pad)
	if action == &"move_up":
		keys_text = SEPARATOR.join(
			[
				TranslationServer.translate("CONTROLS_MOVE_KEYS"),
				TranslationServer.translate("CONTROLS_MOVE_ARROWS")
			]
		)
		pad_text = SEPARATOR.join(
			[
				TranslationServer.translate("CONTROLS_MOVE_PAD"),
				TranslationServer.translate("CONTROLS_PAD_DPAD")
			]
		)
	elif action == &"cancel":
		var menu_keys := InputDevice.labels_for_kind(&"menu", InputDevice.Kind.KEYBOARD)
		keys_text = SEPARATOR.join(
			PackedStringArray(
				Array(keys).filter(func(k: String) -> bool: return not menu_keys.has(k))
			)
		)
	return "%s:  %s  ·  %s" % [TranslationServer.translate(label_key), keys_text, pad_text]


func _first(action: StringName, device: InputDevice.Kind) -> String:
	return InputDevice.labels_for_kind(action, device, true)[0]
