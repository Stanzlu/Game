class_name AntreiberActor
extends Node2D
## The Antreiber in the grey-box encounter: runs ahead of the player, cheers, urges,
## worries; falls silent and sits down once the player stops. Barks come from
## content/dialogue/antreiber/antreiber.dialogue (one cue per mood).
## After the shed (ADR-042) he is not beaten, only slower: `trail` walks behind the player
## without a word, `walk_to` and `sit_down` stage him in the valley and by the fire.

const LEAD := Vector2(40, -14)
## A bark stays long enough to read in the small font: this many characters per second,
## never shorter than BARK_SECONDS; the next one waits a moment after it.
const BARK_SECONDS := 2.2
const BARK_CHARS_PER_SECOND := 14.0
const BARK_GAP := 0.8
## Walking behind: this far back, never faster than this.
const TRAIL_DISTANCE := 26.0
const TRAIL_SPEED := 42.0
## Slower than this he counts as standing; the cycles are drawn for the player's walk and run.
const MOVING_PACE := 6.0
const WALK_CYCLE_SPEED := 88.0
const RUN_CYCLE_SPEED := 144.0
## A bark (or a word) lifts him by a pixel for a moment, like a speaker's breath.
const BOB_PIXELS := 1.0
const BOB_SECONDS := 0.06
const BOB_GAP := 0.12
const CUES := {
	AntreiberModel.Mood.START: "start",
	AntreiberModel.Mood.URGING: "urging",
	AntreiberModel.Mood.CHEERING: "cheering",
	AntreiberModel.Mood.TIRED: "tired",
	AntreiberModel.Mood.WORRIED: "worried",
	AntreiberModel.Mood.PUZZLED: "puzzled",
	AntreiberModel.Mood.PUZZLED_EARLY: "puzzled_early",
	AntreiberModel.Mood.SILENT: "silent",
}

@export var sheet: CharacterSheet
@export var dialogue: DialogueResource

var facing := Facing.Dir.E
var silent := false
## A scene sets this while a dialogue box speaks for him (the house): he bobs with the syllables.
var talking := false:
	set = _set_talking
var _bark_cooldown := 0.0
var _last_mood := -1
var _bark_time := 0.0
var _bobbing := false
var _presenter: Node

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bark: Label = $Bark


func _ready() -> void:
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
	sheet.add_shadow_to(self)
	NpcSteps.attach(self, sprite)
	bark.hide()
	_play("idle")


func update_actor(player: Player, model: AntreiberModel, delta: float) -> void:
	_bark_time = maxf(_bark_time - delta, 0.0)
	if _bark_time == 0.0:
		bark.hide()
	if silent:
		return
	var speed := player.velocity.length()
	var to_target := player.global_position + LEAD - global_position
	var step := to_target.limit_length(maxf(speed * 1.3, 70.0) * delta)
	global_position += step
	# moving is what he actually does this tick, not what the player does: while the player
	# walks, the rest to the target stays under 2 px and he would slide along in the idle pose
	var pace := step.length() / delta if delta > 0.0 else 0.0
	if pace > MOVING_PACE:
		facing = Facing.from_vector_stable(facing, step)
		var running := pace > player.tuning.walk_speed * 1.2
		_play("run" if running else "walk", pace)
	else:
		facing = Facing.from_vector(player.global_position - global_position)
		_play("idle")
	var mood := model.mood(speed, player.tuning.walk_speed)
	_bark_cooldown -= delta
	# a new mood may cut in early, but never into a line that is still being read
	var changed := mood != _last_mood and _bark_cooldown < 1.6 and _bark_time == 0.0
	if changed or _bark_cooldown <= 0.0:
		_last_mood = mood
		_bark_cooldown = randf_range(2.6, 4.0)
		say(mood)


func say(mood: AntreiberModel.Mood) -> void:
	if dialogue == null:
		return
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(dialogue, CUES[mood])
	if line == null:
		return
	bark.text = line.text
	bark.show()
	_center_bark.call_deferred()
	_bark_time = bark_seconds(line.text)
	_bark_cooldown = maxf(_bark_cooldown, _bark_time + BARK_GAP)
	SoundBank.play_at(self, "bark", global_position, -1.0)
	_bob()


## How long a bark stays on screen.
static func bark_seconds(text: String) -> float:
	return maxf(BARK_SECONDS, text.length() / BARK_CHARS_PER_SECOND)


## Label size is only final after the text change has been processed.
func _center_bark() -> void:
	bark.reset_size()
	bark.position = Vector2(-roundf(bark.size.x * 0.5), -30.0 - bark.size.y)


## The player stopped: fall silent, look at them, then sit down.
func resolve(player: Player) -> void:
	silent = true
	facing = Facing.from_vector(player.global_position - global_position)
	_play("idle")
	say(AntreiberModel.Mood.SILENT)
	await NodeTimer.after(self, 2.0)
	facing = Facing.Dir.S
	_play("sit")


## Walks behind the player, a little slower than they do; stands when they stand.
func trail(player: Node2D, delta: float) -> void:
	silent = true
	var to_player := player.global_position - global_position
	if to_player.length() <= TRAIL_DISTANCE:
		facing = Facing.from_vector(to_player)
		_play("idle")
		return
	var target := player.global_position - to_player.normalized() * TRAIL_DISTANCE
	global_position = global_position.move_toward(target, TRAIL_SPEED * delta)
	facing = Facing.from_vector(to_player)
	_play("walk", TRAIL_SPEED)


## Walks to `target` (world position) at `speed` and stands there.
func walk_to(target: Vector2, speed := 36.0) -> void:
	silent = true
	var distance := global_position.distance_to(target)
	if distance > 0.5:
		facing = Facing.from_vector(target - global_position)
		_play("walk", speed)
		var tween := create_tween()
		tween.tween_property(self, ^"global_position", target, distance / speed)
		await tween.finished
	_play("idle")


func face(dir: Facing.Dir) -> void:
	facing = dir
	_play("idle")


func sit_down(dir: Facing.Dir) -> void:
	silent = true
	facing = dir
	_play("sit")


## `pace`: how fast he really moves (px/s); the walk and run cycles are drawn for the player's
## pace, so a slower walker steps slower instead of paddling on the spot.
func _play(state_name: String, pace := WALK_CYCLE_SPEED) -> void:
	var anim := CharacterSheet.animation_name(state_name, facing)
	if sprite.animation != anim:
		sprite.play(anim)
	match state_name:
		"walk":
			sprite.speed_scale = clampf(pace / WALK_CYCLE_SPEED, 0.5, 1.5)
		"run":
			sprite.speed_scale = clampf(pace / RUN_CYCLE_SPEED, 0.6, 1.4)
		_:
			sprite.speed_scale = 1.0


func _set_talking(value: bool) -> void:
	talking = value
	if _presenter != null and is_instance_valid(_presenter):
		_presenter.disconnect(&"syllable", _on_syllable)
	_presenter = null
	if not value:
		return
	var presenter := (
		get_tree().get_first_node_in_group(&"dialogue_presenter") if is_inside_tree() else null
	)
	# the signal belongs to the dialogue box of the menus package: without it he only bobs on barks
	if presenter != null and presenter.has_signal(&"syllable"):
		presenter.connect(&"syllable", _on_syllable)
		_presenter = presenter


func _on_syllable(_character: Variant = null) -> void:
	if talking:
		_bob()


func _bob() -> void:
	if _bobbing:
		return
	_bobbing = true
	sprite.offset = sheet.feet_offset + Vector2(0.0, -BOB_PIXELS)
	await NodeTimer.after(self, BOB_SECONDS)
	sprite.offset = sheet.feet_offset
	await NodeTimer.after(self, BOB_GAP - BOB_SECONDS)
	_bobbing = false
