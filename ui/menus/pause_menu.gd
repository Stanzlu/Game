class_name PauseMenu
extends MenuLayer
## Pause menu (menu action: Esc, Tab, Start). Resume, journal, save, load, settings,
## back to the start menu, quit. Saving is disabled where the scene cannot be resumed.

const MAIN_MENU := "res://core/boot/boot.tscn"

var settings_menu: SettingsMenu
var save_menu: SaveMenu
var controls_menu: ControlsMenu
var confirm: ConfirmMenu
## Leaving for the start menu fades out first: the world must stay frozen until the scene
## is gone, or the hero could still walk (and be hit) under the cover.
var _keeping_paused := false


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
	controls_menu = ControlsMenu.new()
	controls_menu.name = "Controls"
	add_child(controls_menu)
	confirm = ConfirmMenu.new()
	confirm.name = "ConfirmLeave"
	add_child(confirm)
	stack(settings_menu)
	stack(save_menu)
	stack(controls_menu)
	stack(confirm)


func _build() -> void:
	var can_save := SaveSystem.can_save()
	list.add_action("PAUSE_RESUME", close)
	list.add_action("PAUSE_JOURNAL", _open_journal)
	list.add_action("PAUSE_SAVE", func() -> void: save_menu.open_mode(SaveMenu.Mode.SAVE), can_save)
	list.add_action("PAUSE_LOAD", func() -> void: save_menu.open_mode(SaveMenu.Mode.LOAD))
	list.add_action("PAUSE_SETTINGS", settings_menu.open)
	list.add_action("SETTINGS_SHOW_CONTROLS", controls_menu.open)
	list.add_action("PAUSE_TO_MENU", func() -> void: _leave(_to_main_menu))
	list.add_action("PAUSE_QUIT", func() -> void: _leave(_quit))
	hint.text = (
		tr("PAUSE_HINT") % [InputDevice.label_for(&"menu"), InputDevice.label_for(&"journal")]
		if can_save
		else tr("SAVE_NOT_HERE")
	)


func open() -> void:
	super()
	get_tree().paused = true


func close() -> void:
	settings_menu.close()
	save_menu.close()
	controls_menu.close()
	super()
	if not _keeping_paused:
		get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		# not during a door fade: leaving the scene then would strand the travel
		if event.is_action_pressed(&"menu") and MenuLayer.can_pause(get_tree()):
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


## Leaving keeps the progress: the autosave is written first where saving is possible; where
## it is not (encounter, conversation) or it fails, the player is asked.
func _leave(then: Callable) -> void:
	if SaveSystem.can_save():
		if SaveSystem.save_slot(SaveService.AUTOSAVE) == OK:
			then.call()
			return
		_ask_to_leave(then, "PAUSE_LEAVE_SAVE_FAILED")
		return
	_ask_to_leave(then, "CONFIRM_LEAVE_UNSAVED")


## The safe answer ("Nein") has the focus; only a deliberate yes leaves.
func _ask_to_leave(then: Callable, question: String) -> void:
	var on_answer := func(yes: bool) -> void:
		if yes:
			then.call()
	confirm.answered.connect(on_answer, CONNECT_ONE_SHOT)
	confirm.ask(question, "CONFIRM_LEAVE_YES", "OPTION_NO")


func _to_main_menu() -> void:
	# The scene change frees this menu, so get_tree() is null afterwards: keep the tree and lift
	# the pause through it, or the start menu would come up frozen.
	var tree := get_tree()
	_keeping_paused = true
	close()
	await ScreenFade.fade_out(0.3)
	tree.paused = false
	tree.change_scene_to_file(MAIN_MENU)
	_keeping_paused = false


func _quit() -> void:
	Log.info(Log.Category.BOOT, "quit requested")
	get_tree().quit()
