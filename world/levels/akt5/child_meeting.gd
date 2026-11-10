class_name ChildMeeting
extends Node
## Act V, G7: the central scene (docs/akt5/REGIONSBRIEFE.md, O8, O9, O10; Bible 15): on the Grat,
## at the edge of the plateau, a child sits and waits. Nothing happens until the player sits down
## on the flat stone beside it, in her own time. Then the grown-up stays with the child: the child
## hums, the six pictures of the child hang as frames in the air round the two of them (only
## those she holds show their picture; the others stay empty, with no line and no count), one
## answer is given or not ("Ich bin da.", the one that asks for nothing if she has trust, the
## silence), and the child is gone. In the valley a shoot grows in the bed (`house.garden_sprout`).
## The lines are `kind.dialogue`, one cue for each part; this node gives them their time, builds
## the frames and sets what follows. A phase of the scene's own steps: the fades count play time,
## the cutscene blocks saving (a game closed in the middle has saved none of it and plays it
## again), and the player stays seated when it is over until she gets up, whenever that is.

const DIALOGUE := "res://content/dialogue/akt5/kind.dialogue"
const BEAT := "grat_child"
const QUEST := "main_mountain_way"
## The flat stone she sits on (its left cell; the child sits on the one to the east of it).
const SEAT_CELL := Vector2i(79, 10)
## How far from the stone's middle she has to sit for it to count as sitting beside the child.
const SEAT_REACH := 20.0
## The frames: the picture's name (its file `fragment_<name>.png`) in the order of the child's
## story, and the radius of the arc they hang on above the two (pixels).
const NAMES: Array[String] = [
	"hallway", "closed_door", "empty_room", "hand", "hiding", "first_house"
]
const ARC_RADIUS := 46.0
const ARC_SPAN := 1.7
const ARC_LIFT := 22.0
## Seconds between one frame and the next to appear, how long each takes, how long they all fade.
const STAGGER := 0.45
const FADE_IN := 0.7
const FADE_OUT := 1.4
## Quiet before the answer and after it (seconds).
const PAUSE := 0.8

var scene: GameScene
var frames: Array[Node2D] = []

var _busy := false
var _clock := 0.0
var _state := 0  # 0 nothing, 1 appearing, 2 shown, 3 fading


func _ready() -> void:
	scene.player.state_changed.connect(_on_player_state)


func _physics_process(delta: float) -> void:
	if _state == 1 or _state == 3:
		_clock += delta
		_apply()


## Whether she holds the picture of this frame (the flags are written out: StoryLint reads
## literals, not lists).
static func held(index: int) -> bool:
	match index:
		0:
			return WorldState.has_flag("fragment.hallway")
		1:
			return WorldState.has_flag("fragment.closed_door")
		2:
			return WorldState.has_flag("fragment.empty_room")
		3:
			return WorldState.has_flag("fragment.hand")
		4:
			return WorldState.has_flag("fragment.hiding")
		5:
			return WorldState.has_flag("fragment.first_house")
	return false


## The pictures she holds, in the order of the frames.
static func held_names() -> Array[String]:
	var list: Array[String] = []
	for i in NAMES.size():
		if held(i):
			list.append(NAMES[i])
	return list


func _on_player_state(state: Player.State) -> void:
	if state == Player.State.SIT:
		_sat.call_deferred()


## She sat down: beside the child, with the child still there, the scene begins (once).
func _sat() -> void:
	if _busy or WorldState.has_flag("grat.child_gone"):
		return
	if scene.player.state != Player.State.SIT:
		return
	if scene.player.global_position.distance_to(_seat_middle()) > SEAT_REACH:
		return
	_busy = true
	await _meet()
	_busy = false


## The middle of the stone's left cell, where the player sits.
func _seat_middle() -> Vector2:
	return scene.map.cell_to_world(SEAT_CELL)


## Between the two of them: the arc of the frames hangs over this point.
func _middle() -> Vector2:
	return _seat_middle() + Vector2(float(scene.map.data.tile_size) * 0.5, 0.0)


func _meet() -> void:
	var cut := Cutscene.begin(scene)
	AudioDirector.sfx("child_hum", -8.0, 1.0)
	await cut.say(DIALOGUE, "child_seat")
	await cut.wait(PAUSE)
	_build()
	_state = 1
	_clock = 0.0
	await cut.say(DIALOGUE, "child_frames")
	await cut.wait(maxf(0.0, STAGGER * float(NAMES.size() - 1) + FADE_IN - _clock))
	_state = 2
	_apply()
	await cut.wait(PAUSE)
	await cut.say(DIALOGUE, "child_answer")
	await cut.wait(PAUSE)
	await cut.say(DIALOGUE, "child_gone")
	# the child is gone; the frames fade, and in the valley a shoot grows in the bed
	WorldState.set_flag("grat.child_gone")
	_state = 3
	_clock = 0.0
	await cut.wait(FADE_OUT)
	_clear()
	WorldState.set_flag("house.garden_sprout")
	if WorldState.quest_stage(QUEST) == "high":
		WorldState.advance_quest(QUEST, "child")
	cut.end()
	Beat.mark(BEAT)


## The six frames on an arc over the two of them, the pictures she holds inside them.
func _build() -> void:
	_clear()
	var entry := PropCatalog.entry("tal/gb_picture_frame")
	var middle := _middle()
	for i in NAMES.size():
		var frame := Node2D.new()
		frame.name = "Frame%d" % i
		frame.z_index = 40
		frame.modulate.a = 0.0
		var t := (float(i) / float(NAMES.size() - 1) - 0.5) * ARC_SPAN
		frame.global_position = (
			middle + Vector2(sin(t) * ARC_RADIUS * 1.6, -cos(t) * ARC_RADIUS - ARC_LIFT)
		)
		var box := Sprite2D.new()
		box.name = "Box"
		box.texture = PropCatalog.texture_for(entry, frame.global_position)
		box.centered = true
		frame.add_child(box)
		if held(i):
			var picture := Sprite2D.new()
			picture.name = "Picture"
			picture.texture = load("res://assets/generated/fragments/fragment_%s.png" % NAMES[i])
			picture.centered = true
			frame.add_child(picture)
		frame.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		scene.map.entities.add_child(frame)
		frames.append(frame)


func _clear() -> void:
	for frame in frames:
		if is_instance_valid(frame):
			frame.queue_free()
	frames.clear()
	_state = 0


## The alpha of each frame from the clock: they come one after another and go together.
func _apply() -> void:
	for i in frames.size():
		if not is_instance_valid(frames[i]):
			continue
		var alpha := 1.0
		if _state == 1:
			alpha = clampf((_clock - STAGGER * float(i)) / FADE_IN, 0.0, 1.0)
		elif _state == 3:
			alpha = clampf(1.0 - _clock / FADE_OUT, 0.0, 1.0)
		frames[i].modulate.a = alpha
