extends Node
## Debug-only input player for reproducible captures and checks.
## Start with: -- --autopilot=res://tools/autopilot/<script>.json
## Script format: [{"t": seconds, "press": ["action", ...], "release": [...], "tap": [...],
## "log": "text"}]. "press"/"release" hold actions for polling code (movement); "tap" sends
## real input events for menus and dialogues: pressed, released TAP_TICKS later, so the
## press survives into a frame even at low capture frame rates. "teleport": [cx, cy] puts the
## player on the centre of a map cell (captures of distant spots without long walks).
## Time counts physics ticks, so runs are deterministic with --fixed-fps.

const TAP_TICKS := 8

var _events: Array = []
var _index := 0
var _ticks := 0
var _tapped: Dictionary[String, int] = {}


static func start_if_requested(tree: SceneTree) -> void:
	if not OS.is_debug_build():
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--autopilot="):
			var pilot: Node = load("res://tools/autopilot/autopilot.gd").new()
			pilot.name = "Autopilot"
			pilot.call(&"load_script", arg.trim_prefix("--autopilot="))
			tree.root.add_child.call_deferred(pilot)
			return


func load_script(path: String) -> void:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Array:
		Log.error(Log.Category.INPUT, "autopilot script invalid", {"path": path})
		return
	_events = json.data
	Log.info(Log.Category.INPUT, "autopilot loaded", {"path": path, "events": _events.size()})


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	var t := float(_ticks) / float(Engine.physics_ticks_per_second)
	_ticks += 1
	for action: String in _tapped.keys():
		if _ticks >= _tapped[action]:
			_send(action, false)
			_tapped.erase(action)
	while _index < _events.size() and float((_events[_index] as Dictionary).get("t", 0.0)) <= t:
		var event: Dictionary = _events[_index]
		for action: String in event.get("release", []):
			Input.action_release(action)
		for action: String in event.get("press", []):
			Input.action_press(action)
		if event.has("teleport"):
			_teleport(event["teleport"])
		for action: String in event.get("tap", []):
			_send(action, true)
			_tapped[action] = _ticks + TAP_TICKS
		if event.has("log"):
			Log.info(Log.Category.INPUT, "autopilot", {"t": t, "note": event["log"]})
		_index += 1


func _send(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func _teleport(cell: Array) -> void:
	var player := get_tree().get_first_node_in_group(&"player")
	if player == null or not player.has_method(&"teleport"):
		Log.warn(Log.Category.INPUT, "autopilot teleport without player")
		return
	player.call(&"teleport", Vector2(float(cell[0]), float(cell[1])) * 16.0 + Vector2(8, 8))
