class_name MaschineScene
extends LookScene
## Act V, G3 and G4: the keeper's hall (docs/akt5/REGIONSBRIEFE.md, O4, O5, O6, O19, O20). A room
## full of pipes, dials and steam; in the middle the console with twelve levers, three of them in
## use, the others under a cloth; behind it a small closed door that nobody speaks of; the keeper
## stands at the console and counts. His dialogue tells all of it. This script plays the trial of
## the three levers (G3): the keeper calls an order (`plant.probe`), she pulls the levers, a wrong
## order sends them back with one dry line, the right one is entered (`plant.probe_done`). Then
## the load (G4): on his offer (`plant.load`) the `LoadRun` begins, wave after wave takes the
## cloths away (`plant.wave_*`), the dials, the steam and the lamps show what is not kept, and
## after the fourth wave it stops: it cannot be kept (`plant.overload`). Nothing fails, nothing is
## locked, no one is hurried by anything but play time; whoever leaves the console is waited for.
## The walk of the hero moves on when she enters and again at the end of the load. Outside the
## trial and the run a lever is only a lever.

const DIALOGUE := "res://content/dialogue/akt5/anlage.dialogue"
const LAST := "res://content/dialogue/akt5/last.dialogue"
const QUEST := "main_mountain_way"
## The order the keeper calls (the words of `probe_offer`): Three, then One, then Two.
const ORDER: Array[int] = [3, 1, 2]
## The levers in use in this segment.
const LIVE: Array[int] = [1, 2, 3]
## The room's cells: the camera stays centred on it (it fits whole at the zoom of an interior).
const ROOM := Rect2i(4, 4, 25, 14)
## The cells from which she tends the console: in front of it and to its sides.
const CONSOLE_AREA := Rect2i(6, 4, 21, 7)
const PAUSE_BEFORE_ANSWER := 0.5
## How fast the dials, the steam and the lamps follow the load (per second, 0 to 1).
const TROUBLE_RATE := 0.5
## The lamps dim at most to this much of their light.
const LAMP_LOW := 0.45

var _levers: Dictionary = {}
var _pulled: Array[int] = []
var _busy := false
var _run: LoadRun
var _speaking := false
var _trouble := 0.0
var _gauges: Array[Gauge] = []
var _steam: Array[Decor] = []
var _lamps: Array[Decor] = []


func _ready() -> void:
	music = "silence"
	super()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	for node in map.entities.get_children():
		if node is ConsoleLever:
			var lever := node as ConsoleLever
			_levers[lever.number] = lever
			lever.pulled.connect(_on_pulled)
	_collect_effects()
	# the trial was done: the three stand down, as the keeper left them
	if WorldState.has_flag("plant.probe_done"):
		for number in LIVE:
			_set_lever(number, true, false)
	if WorldState.quest_stage(QUEST) == "valley":
		WorldState.advance_quest(QUEST, "plant")
	_run = LoadRun.new()
	_run.name = "LoadRun"
	_run.levers = _levers
	add_child(_run)
	_run.wave_began.connect(_on_wave_began)
	_run.waited.connect(_on_waited)
	_run.returned.connect(_on_returned)
	_run.overloaded.connect(_on_overloaded)
	if WorldState.has_flag("plant.overload"):
		# the load stopped: every lever is in use and stands as it stood
		_run.state = LoadRun.State.OVER
		_run.wave = LoadRun.WAVES.size()
		for number: int in _levers:
			(_levers[number] as ConsoleLever).set_active(true)
	elif WorldState.has_flag("plant.load"):
		# a game loaded in the middle of the load: it goes on from the wave she reached, when she is back
		_run.begin(_wave_from_flags(), false)
	WorldState.flag_changed.connect(_on_flag_changed)
	Beat.mark("maschine_enter")


func _physics_process(delta: float) -> void:
	_run.step(delta, _at_console(), _talking())
	_follow_trouble(delta)


## The keeper calls the trial: whatever she pulled before stands up again, and the order begins
## with the first lever (a lever left down from the free phase would otherwise be ignored).
func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	if id == "plant.probe":
		_reset_levers(false)
	elif id == "plant.load":
		_run.begin(1, true)
		Beat.mark("maschine_load")


func lever(number: int) -> ConsoleLever:
	return _levers.get(number) as ConsoleLever


func _on_pulled(number: int) -> void:
	if _busy:
		return
	if _run.state == LoadRun.State.RUNNING:
		_run.pull(number)
		return
	var pulled_lever := lever(number)
	if not WorldState.has_flag("plant.probe") or WorldState.has_flag("plant.probe_done"):
		# not called, or done: it is a lever, it goes down and up
		_set_lever(number, not pulled_lever.down, true)
		return
	if pulled_lever.down:
		return
	_set_lever(number, true, true)
	_pulled.append(number)
	var at := _pulled.size() - 1
	if _pulled[at] != ORDER[at]:
		_wrong()
	elif _pulled.size() == ORDER.size():
		_right()


func _set_lever(number: int, down: bool, with_sound: bool) -> void:
	var target := lever(number)
	if target != null:
		target.set_down(down, with_sound)


## Wrong order: one line, and the three go back (nothing is lost).
func _wrong() -> void:
	_busy = true
	await NodeTimer.after(self, PAUSE_BEFORE_ANSWER)
	var cut := Cutscene.begin(self)
	await cut.say(DIALOGUE, "lever_wrong")
	cut.end()
	_reset_levers(true)
	_busy = false


## The three stand up again (a click for each that was down) and the order begins anew.
func _reset_levers(with_sound: bool) -> void:
	for number in LIVE:
		var target := lever(number)
		if target != null and target.down:
			target.set_down(false, with_sound)
	_pulled.clear()


## Right order: he enters it. The levers stay down.
func _right() -> void:
	_busy = true
	await NodeTimer.after(self, PAUSE_BEFORE_ANSWER)
	var cut := Cutscene.begin(self)
	await cut.say(DIALOGUE, "lever_right")
	WorldState.set_flag("plant.probe_done")
	Beat.mark("maschine_probe")
	cut.end()
	_busy = false


# --- The load (G4) -----------------------------------------------------------------------------


## The wave she reached, read from the flags that took the cloths off.
func _wave_from_flags() -> int:
	if WorldState.has_flag("plant.wave_four"):
		return 4
	if WorldState.has_flag("plant.wave_three"):
		return 3
	if WorldState.has_flag("plant.wave_two"):
		return 2
	return 1


func _at_console() -> bool:
	return CONSOLE_AREA.has_point(map.world_to_cell(player.global_position))


## The run stands still while anyone speaks (the keeper's lines never cost her time).
func _talking() -> bool:
	return (
		_speaking
		or dialogue_box.is_open()
		or not get_tree().get_nodes_in_group(&"cutscene").is_empty()
	)


func _on_wave_began(wave: int) -> void:
	match wave:
		2:
			WorldState.set_flag("plant.wave_two")
		3:
			WorldState.set_flag("plant.wave_three")
		4:
			WorldState.set_flag("plant.wave_four")
	await _say(LAST, ["", "", "wave_two", "wave_three", "wave_four"][wave])


func _on_waited() -> void:
	await _say(LAST, "load_wait")


func _on_returned() -> void:
	await _say(LAST, "load_back")


## The fourth wave has run its time: the keeper reckons it up, and it stops where it stands.
func _on_overloaded() -> void:
	await _say(LAST, "load_over")
	WorldState.set_flag("plant.overload")
	if WorldState.quest_stage(QUEST) == "plant":
		WorldState.advance_quest(QUEST, "load")
	Beat.mark("maschine_overload")


## One cue of the keeper's, played as a cutscene (a line at a time, nothing runs meanwhile).
func _say(path: String, cue: String) -> void:
	_speaking = true
	var cut := Cutscene.begin(self)
	await cut.say(path, cue)
	cut.end()
	_speaking = false


## Every dial, a steam cloud and a lamp the hall has, found once.
func _collect_effects() -> void:
	for node in map.entities.get_children():
		if node is Gauge:
			_gauges.append(node as Gauge)
		elif node is Decor:
			var decor := node as Decor
			if decor.sprite_id == "tal/ma_steam":
				_steam.append(decor)
			elif not decor.lights.is_empty():
				_lamps.append(decor)
	# the dials wander to both sides
	for i in _gauges.size():
		_gauges[i].drift = absf(_gauges[i].drift) * (1.0 if i % 2 == 0 else -1.0)


## The dials wander off their mark, the steam thickens and the lamps dim as the load is not kept:
## slowly and in steps of the picture, never a flash.
func _follow_trouble(delta: float) -> void:
	var goal := _run.trouble()
	if is_equal_approx(_trouble, goal):
		return
	_trouble = move_toward(_trouble, goal, delta * TROUBLE_RATE)
	for gauge in _gauges:
		gauge.set_trouble(_trouble)
	for cloud in _steam:
		cloud.modulate.a = 0.7 + 0.3 * _trouble
		cloud.scale = Vector2.ONE * (1.0 + 0.5 * _trouble)
	for lamp in _lamps:
		lamp.light_scale = lerpf(1.0, LAMP_LOW, _trouble)
