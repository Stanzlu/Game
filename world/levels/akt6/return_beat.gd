class_name ReturnBeat
extends Node
## Act VI, R1 (docs/akt6/REGIONSBRIEFE.md, O1, O3): the two quiet cutscenes of the day after the
## mountains, each played once in the scene that holds the player.
## - The morning: "Weiter" after the end of Act V begins the day after, in the house (or, for a game
##   saved outside, in the valley). A few lines of things, nothing is asked; then the walk "Der Weg
##   zurück" begins and the morning is marked (the mark autosaves).
## - The quiet: the first time she comes into the house after Mira has gone her way. A light that
##   is not from here, for a breath (the flag `valley.rift_light`, which R2 reads: the gap in the
##   valley), and the walk moves on to "pull". Nothing pulls: she can leave it be.
##
## A phase of the physics step like the homecomings of Acts III to V (the pauses count play time;
## the lines run by themselves and hand the phase on). A game closed during the lines has marked
## nothing: it plays again, and everything it sets is idempotent.

enum Kind { MORNING, QUIET }
enum Part { WAIT, SAY, OFF }

const DIALOGUE := "res://content/dialogue/akt6/leere.dialogue"
const QUEST := "main_return_way"
const MORNING_BEAT := "act6_morning"
const QUIET_BEAT := "act6_quiet"
## Pauses before the first line, in seconds of play time: the picture is up, the room holds still.
const PAUSE_MORNING := 0.8
const PAUSE_QUIET := 1.2

var _scene: GameScene
var _kind := Kind.MORNING
var _cue := ""
var _cut: Cutscene
var _part := Part.WAIT
var _clock := 0.0
var _busy := false


## True while the day after the mountains has not begun: the end of Act V is reached, the morning
## is not marked.
static func morning_due() -> bool:
	return Chapter.reached("act5") and not Beat.reached(MORNING_BEAT)


## Before the map is built (it reads the flag when it spawns its props): Mira stands at her old
## camp from the first picture of the day.
static func prepare_morning() -> void:
	WorldState.set_flag("valley.mira_leaving")


static func quiet_due() -> bool:
	return WorldState.has_flag("valley.mira_left") and not Beat.reached(QUIET_BEAT)


## Puts the morning into the scene (`cue`: its lines for this place), unless it has been told.
static func attach_morning(on: GameScene, cue: String) -> ReturnBeat:
	return _attach(on, Kind.MORNING, cue)


## Puts the quiet of the house into the scene, unless it has been told.
static func attach_quiet(on: GameScene) -> ReturnBeat:
	return _attach(on, Kind.QUIET, "house_empty")


static func _attach(on: GameScene, kind: Kind, cue: String) -> ReturnBeat:
	var beat := ReturnBeat.new()
	beat.name = "ReturnBeat%s" % ("Morning" if kind == Kind.MORNING else "Quiet")
	beat._scene = on
	beat._kind = kind
	beat._cue = cue
	on.add_child(beat)
	return beat


func _physics_process(delta: float) -> void:
	if _busy or _part == Part.OFF or _scene.player == null:
		return
	_clock += delta
	match _part:
		Part.WAIT:
			# nothing starts while a line is up, a menu or another scene holds the room, or the
			# picture still comes back from the black of a door or of the load
			if _quiet():
				_cut = Cutscene.begin(_scene)
				_part = Part.SAY
				_clock = 0.0
		Part.SAY:
			if _clock >= (PAUSE_MORNING if _kind == Kind.MORNING else PAUSE_QUIET):
				_play()


func _quiet() -> bool:
	return not (
		_scene.dialogue_box.is_open()
		or MenuLayer.any_open(_scene.get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
		or _scene.player.is_locked()
	)


func _play() -> void:
	_busy = true
	await _cut.say(DIALOGUE, _cue)
	_busy = false
	_part = Part.OFF
	# one block without a wait: the autosave that the mark asks for is written when the cutscene
	# lets go of the room, with all of it in it
	if _kind == Kind.MORNING:
		if not WorldState.is_quest_started(QUEST):
			WorldState.start_quest(QUEST)
		Beat.mark(MORNING_BEAT)
	else:
		WorldState.set_flag("valley.rift_light")
		if not WorldState.is_quest_started(QUEST):
			WorldState.start_quest(QUEST)
		WorldState.advance_quest(QUEST, "pull")
		Beat.mark(QUIET_BEAT)
	_cut.end()
