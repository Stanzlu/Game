class_name AntreiberActor
extends Node2D
## The Antreiber in the grey-box encounter: runs ahead of the player, cheers, urges,
## worries; falls silent and sits down once the player stops. Barks come from
## content/dialogue/antreiber/antreiber.dialogue (one cue per mood).
## After the shed (ADR-042) he is not beaten, only slower: `trail` walks behind the player
## without a word, `walk_to` and `sit_down` stage him in the valley and by the fire.

const LEAD := Vector2(40, -14)
const BARK_SECONDS := 2.2
## Walking behind: this far back, never faster than this.
const TRAIL_DISTANCE := 26.0
const TRAIL_SPEED := 42.0
const CUES := {
	AntreiberModel.Mood.START: "start",
	AntreiberModel.Mood.URGING: "urging",
	AntreiberModel.Mood.CHEERING: "cheering",
	AntreiberModel.Mood.TIRED: "tired",
	AntreiberModel.Mood.WORRIED: "worried",
	AntreiberModel.Mood.PUZZLED: "puzzled",
	AntreiberModel.Mood.SILENT: "silent",
}

@export var sheet: CharacterSheet
@export var dialogue: DialogueResource

var facing := Facing.Dir.E
var silent := false
var _bark_cooldown := 0.0
var _last_mood := -1
var _bark_time := 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bark: Label = $Bark


func _ready() -> void:
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
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
	global_position += to_target.limit_length(maxf(speed * 1.3, 70.0) * delta)
	var moving := to_target.length() > 2.0 and speed > 5.0
	if moving:
		facing = Facing.Dir.E
		_play("run" if speed > player.tuning.walk_speed * 1.2 else "walk")
	else:
		facing = Facing.from_vector(player.global_position - global_position)
		_play("idle")
	var mood := model.mood(speed, player.tuning.walk_speed)
	_bark_cooldown -= delta
	if (mood != _last_mood and _bark_cooldown < 1.6) or _bark_cooldown <= 0.0:
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
	_bark_time = BARK_SECONDS
	SoundBank.play_at(self, "bark", global_position, -10.0)


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
	_play("walk")


## Walks to `target` (world position) at `speed` and stands there.
func walk_to(target: Vector2, speed := 36.0) -> void:
	silent = true
	var distance := global_position.distance_to(target)
	if distance > 0.5:
		facing = Facing.from_vector(target - global_position)
		_play("walk")
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


func _play(state_name: String) -> void:
	var anim := CharacterSheet.animation_name(state_name, facing)
	if sprite.animation != anim:
		sprite.play(anim)
