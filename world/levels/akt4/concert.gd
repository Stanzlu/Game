class_name Concert
extends Node
## Act IV, S6: Lio's worst concert in the world (docs/akt4/REGIONSBRIEFE.md, O10), a cutscene on
## the square in the evening. It goes wrong in the process (a string, a lamp, the entry, the
## goat, the wind) and the evening is a good one all the same: nobody goes. The lines are
## `konzert.dialogue`, the nine parts below one cue each; this node only gives them their time
## and the sounds that belong to a line.
##
## A phase of the physics step (the pauses count play time; a closed game has saved nothing of
## it, the cutscene blocks saving: the quest stage is still "evening", the beat is not set, and
## it plays again). The sounds come with the flags the lines set: the string with
## `city.string_snapped`, the tune with `melody.lio_concert`. The song runs for its length
## whatever the player reads; the last part waits for it. At the end the beat is set and the
## room is free: the square stays as it is, lit, with its people.

const DIALOGUE := "res://content/dialogue/akt4/konzert.dialogue"
const BEAT := "city_concert"
## Seconds the tune of the concert lasts (make_slice_sfx.py, lio_concert_0).
const SONG_SECONDS := 19.2
## Second of the tune in which the hands clap (Tess, a little beside the beat), if she is there.
const CLAP_AT := 12.6
## Where she stands for the concert and how far from it counts as "elsewhere" (pixels).
const ARRIVAL_MARKER := "spawn_abend"
const ARRIVAL_SLACK := 12.0
## The parts: the cue, the quiet before it (seconds) and whether the part waits for the tune.
const PARTS: Array[Dictionary] = [
	{"cue": "arrive", "pause": 1.0},
	{"cue": "intro", "pause": 0.8},
	{"cue": "snap", "pause": 0.6},
	{"cue": "hold", "pause": 0.8},
	{"cue": "goat", "pause": 0.8},
	{"cue": "entry", "pause": 0.6},
	{"cue": "wind", "pause": 0.6},
	{"cue": "song", "pause": 0.8},
	{"cue": "finale", "pause": 0.4, "after_song": true},
]

var _scene: StadtScene
var _cut: Cutscene
## Index of the part that is next, -1 until the cutscene has begun.
var _part := -1
var _clock := 0.0
var _busy := false
## Seconds the tune has been playing, -1 while it has not begun.
var _song_age := -1.0
var _clapped := false


## Puts the concert into the scene, unless it has been played.
static func attach(on: StadtScene) -> Concert:
	var concert := Concert.new()
	concert.name = "Concert"
	concert._scene = on
	on.add_child(concert)
	return concert


func _ready() -> void:
	# a pause in a line stops the game, not the tune that is playing: the tune's age runs on
	process_mode = Node.PROCESS_MODE_ALWAYS
	WorldState.flag_changed.connect(_on_flag_changed)


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	if id == "city.string_snapped":
		AudioDirector.sfx("string_snap", -2.0, 1.0)
	elif id == "melody.lio_concert":
		AudioDirector.sfx("lio_concert", -2.0, 1.0)
		_song_age = 0.0


func _physics_process(delta: float) -> void:
	if _song_age >= 0.0:
		_song_age += delta
		if not _clapped and _song_age >= CLAP_AT and WorldState.has_flag("city.board_done"):
			_clapped = true
			AudioDirector.sfx("crowd_clap", -4.0, 1.0)
	if _busy or _scene.player == null or _part >= PARTS.size():
		return
	_clock += delta
	if _part < 0:
		# nothing starts while a line is up, a menu or another scene holds the room, or the picture
		# still comes back from the black of the door
		if _scene.quiet() and not _scene.player.is_locked():
			_cut = Cutscene.begin(_scene)
			_take_place()
			_part = 0
			_clock = 0.0
		return
	var spec := PARTS[_part]
	if _clock < float(spec["pause"]):
		return
	if spec.get("after_song", false) and _song_age >= 0.0 and _song_age < SONG_SECONDS:
		return
	_play(str(spec["cue"]))


## She stands before the stage, looking at it, whichever way she came (a game loaded in the evening
## begins wherever it was saved, a door sends her with the facing she left with).
func _take_place() -> void:
	var player := _scene.player
	var marker := _scene.map.data.find_marker(ARRIVAL_MARKER)
	if not marker.is_empty():
		var at := _scene.map.cell_to_world(marker[0]["cell"])
		if player.global_position.distance_to(at) > ARRIVAL_SLACK:
			player.teleport(at)
			_scene.view.follow(player)
	player.facing = Facing.Dir.N


func _play(cue: String) -> void:
	_busy = true
	await _cut.say(DIALOGUE, cue)
	_busy = false
	_part += 1
	_clock = 0.0
	if _part >= PARTS.size():
		_finish()


## The evening is over: the beat saves it, the cutscene ends in the same block.
func _finish() -> void:
	Beat.mark(BEAT)
	_cut.end()
