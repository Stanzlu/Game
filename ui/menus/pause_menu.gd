class_name PauseMenu
extends MenuLayer
## Pause menu (menu action: Esc, Tab, Start). Resume, journal, save, load, settings,
## back to the start menu, quit. Saving is disabled where the scene cannot be resumed.

const MAIN_MENU := "res://core/boot/boot.tscn"

var settings_menu: SettingsMenu
var save_menu: SaveMenu
var confirm: ConfirmMenu


func _ready() -> void:
	title_key = "PAUSE_TITLE"
	layer = 40
	super()
	settings_menu = SettingsMenu.new()
	settings_menu.name = "SettingsMenu"
	add_child(settings_menu)
	save_menu = SaveMenu.new()
	save_menu.name = "SaveMenu"
	add_child(save_menu)
	confirm = ConfirmMenu.new()
	confirm.name = "ConfirmLeave"
	add_child(confirm)
	stack(settings_menu)
	stack(save_menu)
	stack(confirm)


func _build() -> void:
	var can_save := SaveSystem.can_save()
	list.add_action("PAUSE_RESUME", close)
	list.add_action("PAUSE_JOURNAL", _open_journal)
	list.add_action("PAUSE_SAVE", func() -> void: save_menu.open_mode(SaveMenu.Mode.SAVE), can_save)
	list.add_action("PAUSE_LOAD", func() -> void: save_menu.open_mode(SaveMenu.Mode.LOAD))
	list.add_action("PAUSE_SETTINGS", settings_menu.open)
	list.add_action("PAUSE_TO_MENU", func() -> void: _leave(_to_main_menu))
	list.add_action("PAUSE_QUIT", func() -> void: _leave(_quit))
	hint.text = "" if can_save else tr("SAVE_NOT_HERE")


func open() -> void:
	super()
	get_tree().paused = true


func close() -> void:
	settings_menu.close()
	save_menu.close()
	super()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		# not during a door fade: leaving the scene then would strand the travel
		if event.is_action_pressed(&"menu") and MenuLayer.can_open(get_tree()):
			get_viewport().set_input_as_handled()
			open()
		return
	super(event)


## The journal opens over the pause menu; closing it comes back here.
func _open_journal() -> void:
	for node in get_tree().get_nodes_in_group(Journal.JOURNAL_GROUP):
		var journal := node as Journal
		if not journal.opened.is_connected(_hide_for_journal):
			journal.opened.connect(_hide_for_journal)
			journal.closed.connect(_show_after_journal)
		journal.open()


func _hide_for_journal() -> void:
	if visible:
		frame.hide()
		backdrop.hide()


func _show_after_journal() -> void:
	if visible:
		frame.show()
		backdrop.show()


## Leaving keeps the progress: the autosave is written first where saving is possible;
## where it is not (encounter, conversation), the player is asked.
func _leave(then: Callable) -> void:
	if SaveSystem.can_save():
		SaveSystem.save_slot(SaveService.AUTOSAVE)
		then.call()
		return
	var on_answer := func(yes: bool) -> void:
		if yes:
			then.call()
	confirm.answered.connect(on_answer, CONNECT_ONE_SHOT)
	confirm.ask("CONFIRM_LEAVE_UNSAVED", "CONFIRM_LEAVE_YES", "OPTION_NO")


func _to_main_menu() -> void:
	close()
	await ScreenFade.fade_out(0.3)
	get_tree().change_scene_to_file(MAIN_MENU)


func _quit() -> void:
	Log.info(Log.Category.BOOT, "quit requested")
	get_tree().quit()
