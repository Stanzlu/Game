class_name Cutscene
extends Node
## A scripted moment in a scene: the player stands still, menus and saving wait, lines are
## shown one cue after another. Use with await:
##   var cut := Cutscene.begin(self)
##   await cut.say(DIALOGUE, "mira_knock")
##   await cut.wait(1.0)
##   cut.end()

var scene: GameScene
var _running := false


static func begin(on_scene: GameScene) -> Cutscene:
	var cut := Cutscene.new()
	cut.name = "Cutscene"
	cut.scene = on_scene
	on_scene.add_child(cut)
	cut._start()
	return cut


func _start() -> void:
	_running = true
	add_to_group(&"cutscene")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if scene.player != null:
		scene.player.lock(&"cutscene")
	SaveSystem.block(&"cutscene")


## Shows a dialogue cue and returns when it closed.
func say(path: String, cue: String) -> Signal:
	return Talk.present(self, path, cue, null)


func wait(seconds: float) -> Signal:
	return NodeTimer.after(self, seconds)


func end() -> void:
	if not _running:
		return
	_running = false
	if scene != null and is_instance_valid(scene.player):
		scene.player.unlock(&"cutscene")
	SaveSystem.unblock(&"cutscene")
	queue_free()


## While running, menus and the journal stay closed (MenuLayer.any_open).
func is_open() -> bool:
	return _running


func _exit_tree() -> void:
	if _running:
		_running = false
		SaveSystem.unblock(&"cutscene")
