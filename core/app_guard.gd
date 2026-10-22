class_name AppGuardService
extends Node
## Autoload "AppGuard": keeps progress and the player's place safe when the window is
## closed or loses focus (the game has no say in either).
##
## Closing the window (the X, Cmd+Q) writes the autosave first where saving is possible; in a
## conversation, a cutscene or an encounter it just quits. Losing focus (Alt+Tab, a call, a
## notification) opens the pause menu where it may open, otherwise it holds the tree until the
## focus returns: time windows such as Mira's visit or the Antreiber's patience count game
## time, so nothing may run out behind the player's back.

## Automated runs (headless, autopilot) have no player to wait for: focus events are ignored.
var ignore_focus := _is_automated()
var _held_by_focus := false


func _ready() -> void:
	# the window's X reaches _notification; quitting is decided here
	get_tree().auto_accept_quit = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			save_on_close()
			Log.info(Log.Category.BOOT, "window closed")
			get_tree().quit()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focus_lost()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focus_returned()


## Writes the autosave if a game is running and saving is allowed right now.
func save_on_close() -> bool:
	if not SaveSystem.can_save():
		return false
	return SaveSystem.save_slot(SaveService.AUTOSAVE) == OK


## The window lost focus: pause menu where it may open, else hold the tree.
func focus_lost() -> void:
	var tree := get_tree()
	var scene := _game_scene()
	if scene == null or tree.paused or ignore_focus:
		return
	if scene.pause_menu != null and MenuLayer.can_pause(tree):
		scene.pause_menu.open()
		Log.info(Log.Category.UI, "paused: focus lost")
	else:
		tree.paused = true
		_held_by_focus = true
		Log.info(Log.Category.UI, "held: focus lost")


## Releases what focus_lost() held. An opened pause menu stays: the player resumes it.
func focus_returned() -> void:
	if not _held_by_focus:
		return
	_held_by_focus = false
	var scene := _game_scene()
	if scene != null and scene.pause_menu != null and scene.pause_menu.visible:
		return
	get_tree().paused = false


## The running game scene (it is the save context; current_scene is empty during a change).
func _game_scene() -> GameScene:
	return get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene


static func _is_automated() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autopilot"):
			return true
	return false
