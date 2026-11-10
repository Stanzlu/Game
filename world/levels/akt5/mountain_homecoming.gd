class_name MountainHomecoming
extends Node
## Act V, G9: the way down ends in the house (docs/akt5/REGIONSBRIEFE.md, O12, O18). A cutscene on
## the first entry in the stage "home" of `main_mountain_way`: the house is as she left it (a few
## quiet lines). Whoever let the keeper go at the console (the facet `trust`, its third reader) is
## knocked on: he comes in with his clipboard, goes to the fireplace (his "Herd"), checks it, not
## quite, enters what he did not check and keeps a reservation, and stays standing there (the
## flag `house.guest_waechter`, the map shows him). Whoever did not has a quiet house and an empty
## hearth: nothing in the act hangs on him. The act ends quietly: stage "done", the mark of the
## chapter and the beat in one block, no black and no title.
##
## A phase of the physics step like the homecomings of Acts III and IV (the pauses count play time;
## the lines and the walk run by themselves and hand the phase on). A game closed meanwhile has
## saved nothing of it (the cutscene blocks saving): the stage is still "home" and it plays again
## from the door.

enum Part { WAIT, IN, KNOCK, COMES, CLOSE, END, OFF }

const DIALOGUE := "res://content/dialogue/akt5/heimkehr.dialogue"
const BEAT := "act5_home"
const QUEST := "main_mountain_way"
const KEEPER_SHEET := preload("res://entities/character/sheet_waechter_look.tres")
const DOOR_CELL := Vector2i(19, 15)
## His way from the door to the hearth, round the player's arrival cell and the end of the table
## (the map's placement "Ψ" takes over at the last cell, one step in front of the fireplace).
const WAY_IN: Array[Vector2i] = [
	Vector2i(18, 14), Vector2i(17, 13), Vector2i(17, 12), Vector2i(17, 11), Vector2i(17, 10)
]
const SPEED_IN := 38.0
## Pauses between the parts, in seconds of play time.
const PAUSE_IN := 0.8
const PAUSE_KNOCK := 0.9
const PAUSE_SETTLE := 0.6
const PAUSE_END := 0.8

var _scene: HausScene
var _cut: Cutscene
var _keeper: GuestWalker
var _part := Part.WAIT
var _clock := 0.0
## True while a line or a walk runs by itself; the phase goes on when it has ended.
var _busy := false


## Puts the homecoming into the house, unless it has been played.
static func attach(on: HausScene) -> MountainHomecoming:
	var home := MountainHomecoming.new()
	home.name = "MountainHomecoming"
	home._scene = on
	on.add_child(home)
	return home


func _physics_process(delta: float) -> void:
	if _busy or _part == Part.OFF or _scene.player == null:
		return
	_clock += delta
	match _part:
		Part.WAIT:
			# nothing starts while a line is up, a menu or another scene holds the room, or the
			# picture still comes back from the black of the door
			if _scene.is_quiet() and not _scene.player.is_locked():
				_cut = Cutscene.begin(_scene)
				_to(Part.IN)
		Part.IN:
			if _clock >= PAUSE_IN:
				_say_in()
		Part.KNOCK:
			if _clock >= PAUSE_KNOCK:
				_keeper_comes()
		Part.COMES:
			if _clock >= PAUSE_SETTLE:
				_keeper_at_the_hearth()
		Part.CLOSE:
			if _clock >= PAUSE_SETTLE:
				_close()
		Part.END:
			if _clock >= PAUSE_END:
				_finish()


func _to(part: Part) -> void:
	_part = part
	_clock = 0.0


## The house is as she left it; then the knock (only for whoever let the keeper go) or the end.
func _say_in() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "home_in")
	_busy = false
	if WorldState.has_facet("trust"):
		AudioDirector.sfx("door_knock")
		_to(Part.KNOCK)
	else:
		_to(Part.CLOSE)


## The door opens and he comes in, along the way to the hearth.
func _keeper_comes() -> void:
	_busy = true
	_keeper = _scene.stage_guest(DOOR_CELL, KEEPER_SHEET)
	AudioDirector.sfx("door_open")
	_scene.door_glare()
	_keeper.appear()
	await _keeper.walk_to(_way(WAY_IN), SPEED_IN)
	_keeper.face(Facing.Dir.N)
	_busy = false
	_to(Part.COMES)


## He checks the hearth, not quite; the lines are his. Then the map's placement takes him over.
func _keeper_at_the_hearth() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "waechter_in")
	WorldState.set_flag("house.guest_waechter")
	_keeper.queue_free()
	_keeper = null
	_busy = false
	_to(Part.CLOSE)


## The last lines are true with him and without him.
func _close() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "home_close")
	_busy = false
	_to(Part.END)


## The act ends, quietly: one block without a wait, so the autosave that the mark asks for is
## written when the cutscene lets go of the room, with all three in it.
func _finish() -> void:
	_to(Part.OFF)
	WorldState.advance_quest(QUEST, "done")
	Chapter.mark("act5")
	Beat.mark(BEAT)
	_cut.end()


func _way(cells: Array[Vector2i]) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for cell in cells:
		points.append(_scene.map.cell_to_world(cell))
	return points
