extends Node
## Debug-only input player for reproducible captures and checks.
## Start with: -- --autopilot=res://tools/autopilot/<script>.json
## Script format: [{"t": seconds, "press": ["action", ...], "release": [...], "tap": [...],
## "key": [...], "pad": [...], "log": "text"}]. "press"/"release" hold actions for polling code
## (movement); "tap" sends real input events for menus and dialogues: pressed, released TAP_TICKS
## later, so the press survives into a frame even at low capture frame rates. "key": ["F", "Delete"]
## taps real keys (names as Godot spells them, physical keys) and "pad": [0, 6] real gamepad
## buttons (joypad button indices; 3 = Y does nothing in the world, 6 = Start): they pass the
## input device tracking like a player's press, which flips the prompts, and the key layout
## page captures them. While that page captures, send keys and buttons: a tapped ui_* action is
## no key, it passes the capture and moves the focus (only "cancel" ends it). "teleport":
## [cx, cy] puts the player on the centre of a map cell (captures of distant spots without long
## walks).
## "repeat": n with "every": seconds repeats an event. "dialogue": seconds clicks through
## any open conversation for that long (taps interact while a dialogue box is visible,
## picking the first answer), so a stray tap never starts a new one. "give": "<item id>"
## and "flag": "<flag id>" set up story state (captures of later beats without replaying).
## "meet": "<cue>" puts the player just south of the NPC with that dialogue cue, wherever its
## own routine has taken it.
## Version 2 (Act I run, docs/PRODUKTIONSPLAN.md T8): a script no longer has to guess how long the
## game takes. "wait_for": {"flag": "<id>"} | {"beat": "<id>"} | {"scene": "<key>"} |
## {"quest": "<id>", "stage": "<stage>"} | {"dialogue_closed": true} | {"idle": true} stops the
## script clock until the condition holds (with "timeout": seconds of play time, default
## WAIT_TIMEOUT). A timeout is an error in the log, so a stuck run fails the check. While it
## waits, any open conversation is clicked through (first answer). The script clock stands still
## meanwhile, so the "t" of later events counts from the end of the wait. Macros, unrolled at
## load: "talk": "<cue>" (meet, face north, talk, click through to the end), "use": [cx, cy] with
## "face": "up" (the same at a cell, for things without a voice), "enter": "<scene key>" (take the
## door with that target and wait for the scene). "quit": true ends the run. "quest": "<id>" with
## "stage": "<stage>" puts a quest on that stage through the real calls (starts it if it has not
## begun, then advances along its stages; a stage it cannot reach is an error in the log): the one
## thing a script cannot play from a fresh profile when a segment starts in the middle of an act.
## A script that starts with {"relative": true} counts each "t" as the pause after the step before.
## Time counts physics ticks, so runs are deterministic with --fixed-fps.

const TAP_TICKS := 8
const DIALOGUE_TAP_TICKS := 24
## Seconds of play a "wait_for" may take before the run reports an error and goes on.
const WAIT_TIMEOUT := 120.0
## A conversation that never opened (the talk found nobody to talk to) ends a "dialogue_closed"
## wait after this.
const NO_DIALOGUE_AFTER := 3.0
const FACES := {"up": "move_up", "down": "move_down", "left": "move_left", "right": "move_right"}
## Taps of real keys and buttons are kept under "key:F" / "pad:3" next to the action names.
const KEY_PREFIX := "key:"
const PAD_PREFIX := "pad:"

var _events: Array = []
var _index := 0
var _ticks := 0
var _tapped: Dictionary[String, int] = {}
var _dialogue_until := -1.0
## Ticks the script clock stood still (a wait): the script time is the run time minus this.
var _paused_ticks := 0
var _wait: Dictionary = {}
var _wait_started := 0
var _wait_timeout_ticks := 0
var _wait_saw_dialogue := false
## For the calibration of a long run (tools/writing/calibrate.py): ticks a conversation was open and
## the clicks that moved it on (one per line), reported in the log at every end of a wait.
var _dialogue_ticks := 0
var _clicks := 0
var _finished := false
## The straight-line pixels from where the player stands to where a teleport, a meeting or a door
## takes them: the walks a player would have had to make.
var _route_px := 0.0


static func start_if_requested(tree: SceneTree) -> void:
	# once per run: the start menu comes back after the end of the slice
	if not OS.is_debug_build() or tree.root.has_node(^"Autopilot"):
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
	_events = expand(json.data)
	Log.info(Log.Category.INPUT, "autopilot loaded", {"path": path, "events": _events.size()})


## Unrolls "repeat"/"every" events and the macros ("talk", "use", "enter"), and sorts all events by
## time (a stable sort: events at the same time keep the order of the script). A script that
## starts with {"relative": true} counts every "t" as the pause after the end of the step before
## (a macro lasts about a second), so steps can follow each other without anyone adding up times.
static func expand(events: Array) -> Array:
	var out: Array = []
	var relative := not events.is_empty() and bool((events[0] as Dictionary).get("relative", false))
	var cursor := 0.0
	for item: Variant in events:
		var event: Dictionary = item
		if event.has("relative") and event.size() == 1:
			continue
		var times := int(event.get("repeat", 1))
		var start := cursor + float(event.get("t", 0.0)) if relative else float(event.get("t", 0.0))
		for i in times:
			var copy := event.duplicate()
			copy.erase("repeat")
			copy.erase("every")
			copy["t"] = start + i * float(event.get("every", 0.0))
			if i > 0:
				copy.erase("log")
			var unrolled := _macro(copy)
			for unrolled_event: Dictionary in unrolled:
				cursor = maxf(cursor, float(unrolled_event["t"]))
			out.append_array(unrolled)
	# Array.sort_custom is not stable: break ties by the position in the script
	var indexed: Array = []
	for i in out.size():
		indexed.append([out[i], i])
	indexed.sort_custom(
		func(a: Array, b: Array) -> bool:
			var ta: float = a[0]["t"]
			var tb: float = b[0]["t"]
			return ta < tb or (ta == tb and a[1] < b[1])
	)
	return indexed.map(func(pair: Array) -> Dictionary: return pair[0])


## One event with a macro key becomes the events of a short routine; an event without one stays.
static func _macro(event: Dictionary) -> Array:
	var t: float = event["t"]
	var out: Array = []
	if event.has("talk") or event.has("use"):
		var first := event.duplicate()
		var face: String = str(event.get("face", "up"))
		var key: String = "talk" if event.has("talk") else "use"
		if key == "talk":
			first["meet"] = str(first["talk"])
		else:
			first["teleport"] = first["use"]
		first.erase(key)
		first.erase("face")
		out.append(first)
		out.append({"t": t + 0.2, "press": [FACES.get(face, "move_up")]})
		out.append({"t": t + 0.25, "release": [FACES.get(face, "move_up")]})
		out.append({"t": t + 0.6, "tap": ["interact"]})
		out.append({"t": t + 1.2, "wait_for": {"dialogue_closed": true}, "timeout": 60.0})
		return out
	if event.has("enter"):
		var first := event.duplicate()
		var target: String = str(first["enter"])
		first.erase("enter")
		first["door"] = target
		out.append(first)
		out.append({"t": t + 0.4, "wait_for": {"scene": target}, "timeout": 30.0})
		return out
	return [event]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _dialogue_open():
		_dialogue_ticks += 1
	for action: String in _tapped.keys():
		if _ticks >= _tapped[action]:
			_send(action, false)
			_tapped.erase(action)
	if not _wait.is_empty():
		_paused_ticks += 1
		if _wait_ended():
			_wait = {}
		else:
			_click_through()
			return
	var t := float(_ticks - _paused_ticks - 1) / float(Engine.physics_ticks_per_second)
	while (
		_wait.is_empty()
		and _index < _events.size()
		and float((_events[_index] as Dictionary).get("t", 0.0)) <= t
	):
		var event: Dictionary = _events[_index]
		for action: String in event.get("release", []):
			Input.action_release(action)
		for action: String in event.get("press", []):
			Input.action_press(action)
		if event.has("teleport"):
			_teleport(event["teleport"])
		if event.has("meet"):
			_meet(str(event["meet"]))
		if event.has("door"):
			_to_door(str(event["door"]))
		for action: String in event.get("tap", []):
			_tap(action)
		for key_name: String in event.get("key", []):
			_tap(KEY_PREFIX + key_name)
		for button: Variant in event.get("pad", []):
			_tap(PAD_PREFIX + str(int(button)))
		if event.has("give"):
			WorldState.add_item(str(event["give"]), 1, false)
		if event.has("flag"):
			WorldState.set_flag(str(event["flag"]))
		if event.has("quest"):
			_quest(str(event["quest"]), str(event.get("stage", "")))
		if event.has("dialogue"):
			_dialogue_until = t + float(event["dialogue"])
		if event.has("log"):
			Log.info(Log.Category.INPUT, "autopilot", {"t": t, "note": event["log"]})
		if event.get("quit", false):
			# a long run ends with its script, not with a frame count
			_log_finished()
			get_tree().quit()
		_index += 1
		if event.has("wait_for"):
			_begin_wait(event)
	if _wait.is_empty() and t < _dialogue_until:
		_click_through()
	if _wait.is_empty() and _index >= _events.size() and not _events.is_empty():
		_log_finished()


## Once, when the last event is done: the numbers of the run, for tools/writing/calibrate.py.
func _log_finished() -> void:
	if _finished:
		return
	_finished = true
	var numbers := _numbers()
	numbers["seconds"] = int(WorldState.state.playtime_seconds)
	Log.info(Log.Category.INPUT, "autopilot finished", numbers)


## What the run has measured so far: seconds with a conversation open, clicks (lines moved on) and
## the straight-line pixels of the walks it skipped by teleporting.
func _numbers() -> Dictionary:
	return {
		"dialogue_s": _dialogue_seconds(),
		"clicks": _clicks,
		"route_px": int(_route_px),
	}


## Clicks (interact) through an open conversation, now and then; a stray tap never starts one.
func _click_through() -> void:
	if _ticks % DIALOGUE_TAP_TICKS == 0 and _dialogue_open() and not _tapped.has("interact"):
		_clicks += 1
		_send("interact", true)
		_tapped["interact"] = _ticks + TAP_TICKS


func _dialogue_seconds() -> int:
	return int(float(_dialogue_ticks) / float(Engine.physics_ticks_per_second))


func _begin_wait(event: Dictionary) -> void:
	_wait = event["wait_for"]
	_wait_started = _ticks
	_wait_saw_dialogue = false
	var seconds := float(event.get("timeout", WAIT_TIMEOUT))
	_wait_timeout_ticks = _ticks + int(seconds * float(Engine.physics_ticks_per_second))
	Log.info(Log.Category.INPUT, "autopilot waits", {"for": _wait})


## True when the awaited thing happened, or (with an error in the log) when the time ran out.
func _wait_ended() -> bool:
	if _condition_met(_wait):
		var numbers := _numbers()
		numbers["for"] = _wait
		numbers["ticks"] = _ticks - _wait_started
		Log.info(Log.Category.INPUT, "autopilot wait over", numbers)
		return true
	if _ticks >= _wait_timeout_ticks:
		Log.error(Log.Category.INPUT, "autopilot wait timed out", {"for": _wait})
		return true
	return false


func _condition_met(condition: Dictionary) -> bool:
	var met := true
	if condition.has("flag"):
		met = WorldState.has_flag(str(condition["flag"]))
	elif condition.has("beat"):
		met = Beat.reached(str(condition["beat"]))
	elif condition.has("scene"):
		met = _in_scene(str(condition["scene"]))
	elif condition.has("quest"):
		met = WorldState.quest_stage(str(condition["quest"])) == str(condition.get("stage", ""))
	elif condition.has("dialogue_closed"):
		met = _conversation_over()
	elif condition.has("idle"):
		met = _player_is_free()
	else:
		Log.error(Log.Category.INPUT, "autopilot wait unknown", {"for": condition})
	return met


func _in_scene(key: String) -> bool:
	var scene := get_tree().current_scene
	return (
		scene != null
		and SceneRegistry.key_for_path(scene.scene_file_path) == SceneRegistry.resolve(key)
		and not ScreenFade.is_covered()
	)


## A conversation was open and is shut; or none opened for a while (the talk found nobody).
func _conversation_over() -> bool:
	if _dialogue_open():
		_wait_saw_dialogue = true
		return false
	var patience := int(NO_DIALOGUE_AFTER * float(Engine.physics_ticks_per_second))
	return _wait_saw_dialogue or _ticks - _wait_started >= patience


func _player_is_free() -> bool:
	var player := get_tree().get_first_node_in_group(&"player")
	return (
		not _dialogue_open()
		and not ScreenFade.is_covered()
		and player != null
		and not bool(player.call(&"is_locked"))
	)


func _dialogue_open() -> bool:
	var box := get_tree().get_first_node_in_group(&"dialogue_presenter")
	return box != null and bool(box.get(&"visible"))


## A token that stands for no event (a key name Godot does not know) is reported once, at the
## press, and nothing waits to let go of it.
func _tap(token: String) -> void:
	if _send(token, true):
		_tapped[token] = _ticks + TAP_TICKS


## False when the token stands for no event.
func _send(token: String, pressed: bool) -> bool:
	var event := event_for(token, pressed)
	if event == null:
		return false
	Input.parse_input_event(event)
	return true


## The event a tap token stands for: "key:F" a real key press, "pad:3" a real gamepad button, the
## rest an action by name. Null (and an error in the log) for a key name Godot does not know.
static func event_for(token: String, pressed: bool) -> InputEvent:
	if token.begins_with(KEY_PREFIX):
		var code := OS.find_keycode_from_string(token.trim_prefix(KEY_PREFIX))
		if code == KEY_NONE:
			Log.error(Log.Category.INPUT, "autopilot key unknown", {"key": token})
			return null
		var key := InputEventKey.new()
		key.physical_keycode = code
		key.keycode = code
		key.pressed = pressed
		return key
	if token.begins_with(PAD_PREFIX):
		var button := InputEventJoypadButton.new()
		button.button_index = int(token.trim_prefix(PAD_PREFIX)) as JoyButton
		button.pressed = pressed
		return button
	var event := InputEventAction.new()
	event.action = token
	event.pressed = pressed
	return event


## Puts a quest on `stage` with the game's own calls: starts it if it has not begun, then goes the
## shortest way along the stages (`next`). A quest that stands past the stage, or a stage that
## cannot be reached, is an error in the log and changes nothing.
func _quest(quest_id: String, stage: String) -> void:
	var def := ContentDB.quest(quest_id)
	if def == null or not def.has_stage(stage):
		Log.error(
			Log.Category.INPUT, "autopilot quest unknown", {"quest": quest_id, "stage": stage}
		)
		return
	WorldState.start_quest(quest_id)
	var current := WorldState.quest_stage(quest_id)
	var way := quest_way(def, current, stage)
	if way.is_empty() and current != stage:
		Log.error(
			Log.Category.INPUT,
			"autopilot quest unreachable",
			{"quest": quest_id, "from": current, "stage": stage}
		)
		return
	for step in way:
		WorldState.advance_quest(quest_id, step)


## The stages to go through to get from `from` to `to`, `from` left out (the shortest way along
## `next`, the first stage found for a fork); empty when `to` is `from` or cannot be reached.
static func quest_way(def: QuestDef, from: String, to: String) -> PackedStringArray:
	var came_from: Dictionary[String, String] = {from: ""}
	var queue: PackedStringArray = [from]
	while not queue.is_empty():
		var current := queue[0]
		queue.remove_at(0)
		if current == to:
			break
		var stage := def.stage(current)
		if stage == null:
			continue
		for following in stage.next:
			if not came_from.has(following):
				came_from[following] = current
				queue.append(following)
	var way: PackedStringArray = []
	if to == from or not came_from.has(to):
		return way
	var step := to
	while step != from:
		way.insert(0, step)
		step = came_from[step]
	return way


func _teleport(cell: Array) -> void:
	var player := get_tree().get_first_node_in_group(&"player")
	if player == null or not player.has_method(&"teleport"):
		Log.warn(Log.Category.INPUT, "autopilot teleport without player")
		return
	# a seated player gets up first (as any step would make them)
	if player.has_method(&"stand_up"):
		player.call(&"stand_up")
	var target := Vector2(float(cell[0]), float(cell[1])) * 16.0 + Vector2(8, 8)
	_count_route(player, target)
	player.call(&"teleport", target)


## Adds the way from where the player stands (after a change of scene: where they arrived) to `to`.
func _count_route(player: Node2D, to: Vector2) -> void:
	_route_px += player.global_position.distance_to(to)


func _meet(cue: String) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	var scene := get_tree().current_scene
	if scene == null:
		Log.error(Log.Category.INPUT, "autopilot meet: no scene", {"cue": cue})
		return
	for node in scene.find_children("*", "CharacterBody2D", true, false):
		if node is NpcWalker and (node as NpcWalker).cue == cue and player != null:
			if player.has_method(&"stand_up"):
				player.call(&"stand_up")
			var target := (node as Node2D).global_position + Vector2(0, 14)
			_count_route(player, target)
			player.call(&"teleport", target)
			return
	Log.warn(Log.Category.INPUT, "autopilot meet: nobody there", {"cue": cue})


## Takes the door that leads to `target`, as an interaction with it would (or walking into it, for
## an exit): the walk to it is the player's, not the test's.
func _to_door(target: String) -> void:
	var key := SceneRegistry.resolve(target)
	var scene := get_tree().current_scene
	if scene == null:
		Log.error(Log.Category.INPUT, "autopilot enter: no scene", {"target": target})
		return
	for node in scene.find_children("*", "Node2D", true, false):
		var script: Script = node.get_script()
		if script == null or not script.resource_path.ends_with("door.gd"):
			continue
		if SceneRegistry.resolve(str(node.get(&"target"))) != key:
			continue
		var player := get_tree().get_first_node_in_group(&"player") as Node2D
		if player != null:
			_count_route(player, (node as Node2D).global_position)
		SceneTravel.go(node, key, str(node.get(&"spawn")), str(node.get(&"sound")))
		return
	Log.error(Log.Category.INPUT, "autopilot enter: no door", {"target": target})
