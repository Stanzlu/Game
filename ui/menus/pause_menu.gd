class_name PauseMenu
extends MenuLayer
## Pause menu (menu action: Esc, Tab, Start). Resume, journal, save, load, settings,
## back to the start menu, quit. Saving is disabled where the scene cannot be resumed.

const MAIN_MENU := "res://core/boot/boot.tscn"

var settings_menu: SettingsMenu
var save_menu: SaveMenu


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
	stack(settings_menu)
	stack(save_menu)


func _build() -> void:
	var can_save := SaveSystem.can_save()
	list.add_action("PAUSE_RESUME", close)
	list.add_action("PAUSE_JOURNAL", _open_journal)
	list.add_action("PAUSE_SAVE", func() -> void: save_menu.open_mode(SaveMenu.Mode.SAVE), can_save)
	list.add_action("PAUSE_LOAD", func() -> void: save_menu.open_mode(SaveMenu.Mode.LOAD))
	list.add_action("PAUSE_SETTINGS", settings_menu.open)
	list.add_action("PAUSE_TO_MENU", _to_main_menu)
	list.add_action("PAUSE_QUIT", func() -> void: get_tree().quit())
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
		if event.is_action_pressed(&"menu") and not MenuLayer.any_open(get_tree()):
			get_viewport().set_input_as_handled()
			open()
		return
	super(event)


func _open_journal() -> void:
	close()
	for node in get_tree().get_nodes_in_group(Journal.JOURNAL_GROUP):
		(node as Journal).open()


func _to_main_menu() -> void:
	close()
	get_tree().change_scene_to_file(MAIN_MENU)
