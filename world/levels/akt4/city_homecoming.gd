class_name CityHomecoming
extends Node
## Act IV, S8: the way home ends in the house (docs/akt4/REGIONSBRIEFE.md, O9). A cutscene on
## the first entry in the stage "home" of `main_city_way`: the Antreiber sits at his bench (Act
## III), and Tess comes in as a guest with a purpose: boards on her shoulder, two shelves and a
## strip for the wall that she shows how to hang, once ("Schief. Aber dicht." about the bench),
## a loaf from the one with the slips on the table, a seat on the chair that stays when she
## goes. The act ends quietly: stage "done", the mark of the chapter and the beat in one block,
## no black and no title.
##
## A phase of the physics step as the homecoming of Act III (the pauses count play time; the
## lines and the walks run by themselves and hand the phase on). A game closed meanwhile has
## saved nothing of it (the cutscene blocks saving): the stage is still "home" and it plays
## again from the door.

enum Part { WAIT, IN, KNOCK, BUILD, BENCH, BREAD, CLOSE, LEAVE, END, OFF }

const DIALOGUE := "res://content/dialogue/akt4/heimkehr.dialogue"
const BEAT := "act4_home"
const QUEST := "main_city_way"
const TESS_SHEET := preload("res://entities/character/sheet_tess_look.tres")
const DOOR_CELL := Vector2i(19, 15)
## Where she stands to talk to the player (before the table), at the bench and on her chair. The way
## in runs round the cell of the door's marker, where the player stands when she comes in (as Mira's
## and the hermit's in the house): she never walks through the player.
const WAY_IN: Array[Vector2i] = [Vector2i(18, 14), Vector2i(18, 13), Vector2i(19, 13)]
const BENCH_STAND := Vector2i(23, 13)
const CHAIR_CELL := Vector2i(18, 12)
const SPEED_IN := 40.0
const SPEED_OUT := 45.0
## Pauses between the parts, in seconds of play time.
const PAUSE_IN := 0.8
const PAUSE_KNOCK := 0.9
const PAUSE_BUILD := 0.4
const WORK_SECONDS := 1.4
const PAUSE_END := 0.8

var _scene: HausScene
var _cut: Cutscene
var _tess: GuestWalker
var _part := Part.WAIT
var _clock := 0.0
## True while a line or a walk runs by itself; the phase goes on when it has ended.
var _busy := false


## Puts the homecoming into the house, unless it has been played.
static func attach(on: HausScene) -> CityHomecoming:
	var home := CityHomecoming.new()
	home.name = "CityHomecoming"
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
				_tess_comes()
		Part.BUILD:
			if _clock >= PAUSE_BUILD:
				_build()
		Part.BENCH:
			_at_the_bench()
		Part.BREAD:
			_with_the_bread()
		Part.CLOSE:
			_sits_and_says()
		Part.LEAVE:
			_goes()
		Part.END:
			if _clock >= PAUSE_END:
				_finish()


func _to(part: Part) -> void:
	_part = part
	_clock = 0.0


func _say_in() -> void:
	_busy = true
	await _cut.say(DIALOGUE, "home_in")
	AudioDirector.sfx("door_knock")
	_busy = false
	_to(Part.KNOCK)


## The door opens and she comes in with the boards, to where the table stands; there she talks.
func _tess_comes() -> void:
	_busy = true
	_tess = _scene.stage_guest(DOOR_CELL, TESS_SHEET)
	AudioDirector.sfx("door_open")
	_scene.door_glare()
	_tess.appear()
	await _tess.walk_to(_way(WAY_IN), SPEED_IN)
	await _cut.say(DIALOGUE, "tess_in")
	_busy = false
	_to(Part.BUILD)


## The shelves and the strip are up while the lines speak of them (the flag stands before the first
## line); she shows it once and the hammer goes to the player.
func _build() -> void:
	_busy = true
	AudioDirector.sfx("wood_drop")
	await _cut.say(DIALOGUE, "build")
	await _cut.wait(WORK_SECONDS)
	_busy = false
	_to(Part.BENCH)


func _at_the_bench() -> void:
	_busy = true
	await _tess.walk_to(_way([BENCH_STAND]), SPEED_IN)
	await _cut.say(DIALOGUE, "bench")
	_busy = false
	_to(Part.BREAD)


func _with_the_bread() -> void:
	_busy = true
	await _tess.walk_to(_way([WAY_IN[WAY_IN.size() - 1]]), SPEED_IN)
	await _cut.say(DIALOGUE, "bread")
	_busy = false
	_to(Part.CLOSE)


## She sits on the chair (it appears under her) and says her last words; the house has the last one.
func _sits_and_says() -> void:
	_busy = true
	await _tess.walk_to(_way([CHAIR_CELL]), SPEED_IN)
	WorldState.set_flag("house.guest_tess")
	_tess.sit_down(Facing.Dir.E)
	await _cut.say(DIALOGUE, "home_close")
	_busy = false
	_to(Part.LEAVE)


## She gets up and goes the way she came; the chair stays, the door closes behind her.
func _goes() -> void:
	_busy = true
	_tess.stand_up()
	await _cut.wait(0.5)
	var back: Array[Vector2i] = [WAY_IN[WAY_IN.size() - 1]]
	for i in range(WAY_IN.size() - 2, -1, -1):
		back.append(WAY_IN[i])
	back.append(DOOR_CELL)
	await _tess.walk_to(_way(back), SPEED_OUT)
	AudioDirector.sfx("door_close", -3.0)
	await _tess.vanish()
	_tess.queue_free()
	_tess = null
	_busy = false
	_to(Part.END)


## The act ends, quietly: one block without a wait, so the autosave that the mark asks for is
## written when the cutscene lets go of the room, with all three in it.
func _finish() -> void:
	_to(Part.OFF)
	WorldState.advance_quest(QUEST, "done")
	Chapter.mark("act4")
	Beat.mark(BEAT)
	_cut.end()


func _way(cells: Array[Vector2i]) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for cell in cells:
		points.append(_scene.map.cell_to_world(cell))
	return points
