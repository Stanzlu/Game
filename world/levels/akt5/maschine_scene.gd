class_name MaschineScene
extends LookScene
## Act V, G3: the keeper's hall (docs/akt5/REGIONSBRIEFE.md, O4, O5, O6, O19). A room full of pipes,
## dials and steam; in the middle the console with twelve levers, three of them in use, the others
## still under a cloth (G4 takes the cloths away); behind it a small closed door that nobody speaks
## of; the keeper stands at the console and counts. His dialogue tells all of it. This script plays
## the trial of the three levers: the keeper calls an order (`plant.probe`), she pulls the levers,
## a wrong order sends them back with one dry line, the right one is entered (`plant.probe_done`).
## No time, no penalty, nothing is locked; the trial is never needed to leave. The walk of the hero
## moves on when she enters. Before the trial is called, and after it, a lever is only a lever.

const DIALOGUE := "res://content/dialogue/akt5/anlage.dialogue"
const QUEST := "main_mountain_way"
## The order the keeper calls (the words of `probe_offer`): Three, then One, then Two.
const ORDER: Array[int] = [3, 1, 2]
## The levers in use in this segment.
const LIVE: Array[int] = [1, 2, 3]
## The room's cells: the camera stays centred on it (it fits whole at the zoom of an interior).
const ROOM := Rect2i(3, 2, 28, 18)
const PAUSE_BEFORE_ANSWER := 0.5

var _levers: Dictionary = {}
var _pulled: Array[int] = []
var _busy := false


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
	# the trial was done: the three stand down, as the keeper left them
	if WorldState.has_flag("plant.probe_done"):
		for number in LIVE:
			_set_lever(number, true, false)
	if WorldState.quest_stage(QUEST) == "valley":
		WorldState.advance_quest(QUEST, "plant")
	Beat.mark("maschine_enter")


func lever(number: int) -> ConsoleLever:
	return _levers.get(number) as ConsoleLever


func _on_pulled(number: int) -> void:
	if _busy:
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
	for number in LIVE:
		_set_lever(number, false, true)
	_pulled.clear()
	_busy = false


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
