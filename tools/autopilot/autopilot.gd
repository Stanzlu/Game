extends Node
## Debug-only input player for reproducible captures and checks.
## Start with: -- --autopilot=res://tools/autopilot/<script>.json
## Script format: [{"t": seconds, "press": ["action", ...], "release": [...], "log": "text"}]
## Time counts physics ticks, so runs are deterministic with --fixed-fps.

var _events: Array = []
var _index := 0
var _ticks := 0


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
	while _index < _events.size() and float((_events[_index] as Dictionary).get("t", 0.0)) <= t:
		var event: Dictionary = _events[_index]
		for action: String in event.get("release", []):
			Input.action_release(action)
		for action: String in event.get("press", []):
			Input.action_press(action)
		if event.has("log"):
			Log.info(Log.Category.INPUT, "autopilot", {"t": t, "note": event["log"]})
		_index += 1
