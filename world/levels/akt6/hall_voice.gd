class_name HallVoice
extends Node
## Act VI, R4 (docs/akt6/REGIONSBRIEFE.md, O9): the one time the Richter speaks in this act, in the
## hall of mirrors. The great mirror shows her for the first time (`mirror_back` of
## spiegel.dialogue); when she turns from it a voice without a body begins a sentence
## (`voice_first`, a VoiceLine: typed over the picture, not in a box), and she is already on her
## way: the line breaks off in the middle of a word once she has gone far enough ("she is faster
## than he is"); whoever stands still reads it out. After a break-off he calls after her (the lines
## that follow); after a line read to its end he has nothing to add. The next time she enters the
## hall, and only there, he says one sentence in a tone he never had (`voice_late`): nothing about
## her, and it is not cut.
##
## A phase of the physics step (the pauses count play time). Each part sets its flag when it
## begins (`hall.richter_first`, `hall.richter_late`): he speaks once, and a game closed during a
## part does not play it again. The mark that autosaves comes when the part is over.

enum Part { WATCH, SAY, OFF }

const DIALOGUE := "res://content/dialogue/akt6/richter.dialogue"
const MIRROR_CUE := "mirror_back"
const FIRST_CUE := "voice_first"
const LATE_CUE := "voice_late"
const FIRST_FLAG := "hall.richter_first"
const LATE_FLAG := "hall.richter_late"
const FIRST_BEAT := "hall_richter_first"
const LATE_BEAT := "hall_richter_late"
## Pixels from where she stood as the voice began (six cells).
const CUT_DISTANCE := 96.0
## Seconds of play time in the hall before the quiet sentence, once it is quiet.
const LATE_PAUSE := 2.0

var _scene: GameScene
var _part := Part.WATCH
var _late_due := false
var _mirror_seen := false
var _clock := 0.0
var _lines: Array[DialogueLine] = []
var _index := 0
var _first := true
var _line: VoiceLine
var _speaking := false
var _cut := false


## Puts the voice into the hall for someone who has come back; the quiet sentence is due if the
## first part was heard in an earlier visit (decided now: the first part never leads into it).
static func attach(on: GameScene) -> HallVoice:
	if not WorldState.has_flag("elysia.returned"):
		return null
	var voice := HallVoice.new()
	voice.name = "HallVoice"
	voice._scene = on
	voice._late_due = WorldState.has_flag(FIRST_FLAG) and not WorldState.has_flag(LATE_FLAG)
	on.add_child(voice)
	on.dialogue_box.finished.connect(voice._on_dialogue_finished)
	return voice


func _on_dialogue_finished() -> void:
	if _scene.dialogue_box.cue == MIRROR_CUE:
		_mirror_seen = true


func _physics_process(delta: float) -> void:
	match _part:
		Part.WATCH:
			_watch(delta)
		Part.SAY:
			_follow()


func _watch(delta: float) -> void:
	if not _quiet():
		return
	if _mirror_seen and not WorldState.has_flag(FIRST_FLAG):
		_begin(true)
	elif _late_due:
		_clock += delta
		if _clock >= LATE_PAUSE:
			_begin(false)


func _quiet() -> bool:
	return not (
		_scene.dialogue_box.is_open()
		or MenuLayer.any_open(_scene.get_tree())
		or ScreenFade.is_covered()
		or ScreenFade.is_fading()
		or _scene.player.is_locked()
	)


func _begin(first: bool) -> void:
	_part = Part.SAY
	_first = first
	# written out, so the register of the story's flags finds who sets them
	if first:
		WorldState.set_flag("hall.richter_first")
	else:
		WorldState.set_flag("hall.richter_late")
	_lines = await _read(FIRST_CUE if first else LATE_CUE)
	if not is_instance_valid(self):
		return
	_index = 0
	_cut = false
	_next_line()


## The lines of a cue as the dialogue shows them, read without a box.
func _read(cue: String) -> Array[DialogueLine]:
	var read: Array[DialogueLine] = []
	var resource := load(DIALOGUE) as DialogueResource
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, cue)
	while line != null:
		read.append(line)
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	return read


## The next line, or the end: after a line read to its end nothing follows it, after a break-off
## the voice calls after her with the rest.
func _next_line() -> void:
	if _index >= _lines.size() or (_index > 0 and not _cut):
		_finish()
		return
	var line := _lines[_index]
	var distance := CUT_DISTANCE if _first and _index == 0 else 0.0
	_line = VoiceLine.speak(_scene, _scene.player, line.character, line.text, distance)
	_speaking = true
	_index += 1


func _follow() -> void:
	# a freed line compares equal to null, so whether one is on its way is kept apart
	if not _speaking:
		return
	if is_instance_valid(_line):
		_cut = _line.was_cut() or _cut
		return
	_speaking = false
	_line = null
	_next_line()


func _finish() -> void:
	_part = Part.OFF
	Beat.mark(FIRST_BEAT if _first else LATE_BEAT)
