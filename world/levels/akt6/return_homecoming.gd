class_name ReturnHomecoming
extends Node
## Act VI, R8: the way home from Elysia ends in the house (docs/akt6/REGIONSBRIEFE.md, O13 to
## O15, O18). A cutscene on the first entry in the stage "home" of `main_return_way`: the house
## is as she left it (a few quiet lines). Whoever stood up from the table in the inn (the flag
## `elysia.stood_up`) is knocked on: the host comes in without a bowl in his hands, goes to the
## fire, sits down and has nothing to offer (the same face, without an offer), and stays (the flag
## `house.guest_host`, the map shows him); the drover at the bench reads the visit off his sheet
## on the wall. Elysia's song comes home (`melody.elysia_home`, a tune and no fragment), the last
## lines are true with him and without him, and the act ends quietly: stage "done", the mark of the
## chapter and the beat in one block, no black and no title.
##
## A phase of the physics step like the homecomings of Acts III to V (the pauses count play time;
## the lines and the walk run by themselves and hand the phase on). A game closed meanwhile has
## saved nothing of it (the cutscene blocks saving): the stage is still "home" and it plays again
## from the door. Nothing in the act hangs on the host.

enum Part { WAIT, IN, KNOCK, COMES, HOST, DROVER, SONG, CLOSE, END, OFF }

const DIALOGUE := "res://content/dialogue/akt6/heimkehr.dialogue"
const BEAT := "act6_home"
const QUEST := "main_return_way"
const HOST_SHEET := preload("res://entities/character/sheet_host_look.tres")
const DOOR_CELL := Vector2i(19, 15)
## His way from the door to the fire, round the player's arrival cell and west of the table; the
## map's placement "Φ" takes over at the last cell, directly under the fireplace.
const WAY_IN: Array[Vector2i] = [
	Vector2i(18, 14),
	Vector2i(17, 13),
	Vector2i(17, 12),
	Vector2i(17, 11),
	Vector2i(16, 11),
	Vector2i(16, 10)
]
const SPEED_IN := 38.0
## Pauses between the parts, in seconds of play time.
const PAUSE_IN := 0.8
const PAUSE_KNOCK := 0.9
const PAUSE_SETTLE := 0.6
const PAUSE_END := 0.8

var _scene: HausScene
var _cut: Cutscene
var _host: GuestWalker
var _part := Part.WAIT
var _clock := 0.0
## True while a line or a walk runs by itself; the phase goes on when it has ended.
var _busy := false


## Puts the homecoming into the house, unless it has been played.
static func attach(on: HausScene) -> ReturnHomecoming:
	var home := ReturnHomecoming.new()
	home.name = "ReturnHomecoming"
	home._scene = on
	on.add_child(home)
	return home


## True while the way home waits in the house: the stage is "home" and the act has not ended.
static func due() -> bool:
	return WorldState.quest_stage(QUEST) == "home" and not Beat.reached(BEAT)


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
				_host_comes()
		Part.COMES:
			if _clock >= PAUSE_SETTLE:
				_host_at_the_fire()
		Part.HOST:
			if _clock >= PAUSE_SETTLE:
				_drover_reads_the_sheet()
		Part.DROVER:
			if _clock >= PAUSE_SETTLE:
				_song()
		Part.SONG:
			if _clock >= PAUSE_SETTLE:
				_song()
		Part.CLOSE:
			if _clock >= PAUSE_SETTLE:
				_close()
		Part.END:
			if _clock >= PAUSE_END:
				_finish()


func _to(part: Part) -> void:
	_part = part
	_clock = 0.0


## The house is as she left it; then the knock (only for whoever stood up from the table) or
## the song.
func _say_in() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "home_in")
	_busy = false
	if WorldState.has_flag("elysia.stood_up"):
		AudioDirector.sfx("door_knock")
		_to(Part.KNOCK)
	else:
		_to(Part.SONG)


## The door opens and he comes in, along the way to the fire, and sits down there.
func _host_comes() -> void:
	_busy = true
	_host = _scene.stage_guest(DOOR_CELL, HOST_SHEET)
	AudioDirector.sfx("door_open")
	_scene.door_glare()
	_host.appear()
	await _host.walk_to(_way(WAY_IN), SPEED_IN)
	_host.sit_down(Facing.Dir.N)
	_busy = false
	_to(Part.COMES)


## He has nothing to offer; the lines are his. Then the map's placement takes him over.
func _host_at_the_fire() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "host_in")
	WorldState.set_flag("house.guest_host")
	_host.queue_free()
	_host = null
	_busy = false
	_to(Part.HOST)


## The drover at the bench reads the visit off the sheet on the wall (only with the host).
func _drover_reads_the_sheet() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "antreiber_visit")
	_busy = false
	_to(Part.DROVER)


## Elysia's song comes home: the same notes as in the garden, slower, in the house. The flag is
## the memory that it was heard; the sound plays every time the homecoming plays (a game closed in
## the middle hears it again).
func _song() -> void:
	_busy = true
	_part = Part.SONG
	WorldState.set_flag("melody.elysia_home")
	AudioDirector.sfx("elysia_home", -2.0, 1.0)
	await _cut.say(DIALOGUE, "home_song")
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
	Chapter.mark("act6")
	Beat.mark(BEAT)
	_cut.end()


func _way(cells: Array[Vector2i]) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for cell in cells:
		points.append(_scene.map.cell_to_world(cell))
	return points
