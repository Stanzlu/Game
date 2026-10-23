class_name ControlsNotes
extends ScrollPage
## "Weitere Tasten": what the key layout page cannot show in its rows, because it cannot be
## changed or does not belong to one action: confirming, leaving, the walk, skipping a
## conversation, scrolling the journal. Read only; up and down scroll, "Zurück" leaves.


func _ready() -> void:
	title_key = "BIND_MORE_TITLE"
	panel_width = 420
	layer = 56
	super()


func _build() -> void:
	for key: String in ["BIND_NOTE_ENTER", "BIND_NOTE_ESC", "BIND_NOTE_START", "BIND_NOTE_MENUS"]:
		list.add_info(tr(key))
	# the keys of the moment: a held interact key skips a conversation
	var skip_keys := " / ".join(
		[
			InputDevice.label_for_kind(&"interact", InputDevice.Kind.KEYBOARD, true),
			InputDevice.label_for_kind(&"interact", InputDevice.Kind.GAMEPAD, true)
		]
	)
	list.add_info(tr("CONTROLS_SKIP") % skip_keys)
	list.add_info(tr("CONTROLS_SCROLL_ROW"))
	var walk := (
		"%s · %s" % [InputDevice.move_label(InputDevice.Kind.GAMEPAD), tr("CONTROLS_PAD_DPAD")]
	)
	list.add_info(tr("BIND_PAD_WALK") % walk)
	list.add_action("MENU_BACK", close)
	# nothing here can be changed, and Up and Down scroll: the only cues that stay in view
	hint.text = tr("BIND_MORE_HINT")
	scroll_to_top()
