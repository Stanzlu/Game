class_name GuestWalker
extends Node2D
## A visitor a scene script stages by hand: walks along points, sits down, gets up again
## (Mira coming in from the rain to the fire). Unlike NpcWalker it has no route, no talk
## area and no collision: the script tells it where to go and awaits the moves. Walking
## uses the same sheet states as every other character; later it may merge with the
## Antreiber's actor.

## Speed the walk cycle is drawn for (the player's walk, same as NpcWalker).
const WALK_CYCLE_SPEED := 88.0
const FADE_IN := 0.25

var sheet: CharacterSheet
var facing := Facing.Dir.S
var sprite: AnimatedSprite2D


## A guest with `look` as its sheet; add it to the world and place it before it moves.
static func create(look: CharacterSheet) -> GuestWalker:
	var guest := GuestWalker.new()
	guest.name = "GuestWalker"
	guest.sheet = look
	# moved in tweens every frame: physics interpolation would trail one tick behind
	guest.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	return guest


func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
	add_child(sprite)
	sheet.add_shadow_to(self)
	_play("idle")


## Fades the guest in where it stands (it steps out of the doorway's dark).
func appear() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, ^"modulate:a", 1.0, FADE_IN)


## Walks the points one after the other at `speed` (pixels per second), looking where it
## goes, and stands at the last one.
func walk_to(points: Array[Vector2], speed := 40.0) -> void:
	for point in points:
		var distance := global_position.distance_to(point)
		if distance < 0.5:
			continue
		facing = Facing.from_vector(point - global_position)
		_play("walk", speed)
		var tween := create_tween()
		tween.tween_property(self, ^"global_position", point, distance / speed)
		await tween.finished
	_play("idle")


## Fades out where it stands (it stepped out of the door).
func vanish() -> Signal:
	var tween := create_tween()
	tween.tween_property(self, ^"modulate:a", 0.0, FADE_IN)
	return tween.finished


func face(dir: Facing.Dir) -> void:
	facing = dir
	_play("idle")


## `with_sound` false for a guest that is shown already seated (it took over from a seated
## NPC of the map).
func sit_down(dir: Facing.Dir, with_sound := true) -> void:
	facing = dir
	_play("sit")
	if with_sound:
		SoundBank.play_at(get_parent(), "sit", global_position)


func stand_up() -> void:
	_play("idle")
	SoundBank.play_at(get_parent(), "stand", global_position)


func _play(state_name: String, speed := WALK_CYCLE_SPEED) -> void:
	var anim := CharacterSheet.animation_name(state_name, facing)
	# the walk cycle is drawn for the player's pace; slower walkers step slower, not paddle
	sprite.speed_scale = clampf(speed / WALK_CYCLE_SPEED, 0.5, 1.0) if state_name == "walk" else 1.0
	if sprite.animation != anim:
		sprite.play(anim)
