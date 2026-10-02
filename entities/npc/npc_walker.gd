class_name NpcWalker
extends CharacterBody2D
## Walks a closed route of waypoints. Stops and looks at the player when they come close,
## continues once they leave. Params from the map: {"route": [[dx, dy], ...]} in cells,
## relative to the spawn cell. Basis for Elysia's identically moving NPCs later.

const ATTENTION_RADIUS := 30.0
const RELEASE_RADIUS := 44.0
const ARRIVE_DISTANCE := 2.0
const STUCK_SECONDS := 1.5

@export var sheet: CharacterSheet
@export var speed := 38.0
@export var tile_size := 16

var route: Array[Vector2] = []
var facing := Facing.Dir.S
var attending := false
var _index := 0
var _stuck_time := 0.0
var _origin := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	collision_layer = PhysicsLayers.NPC
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.PLAYER
	motion_mode = MOTION_MODE_FLOATING
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
	sheet.add_shadow_to(self)
	_origin = position
	_play("idle")


func apply_params(params: Dictionary) -> void:
	route.clear()
	for point: Variant in params.get("route", []):
		var p: Array = point
		route.append(Vector2(float(p[0]), float(p[1])) * tile_size)
	speed = float(params.get("speed", speed))


func _physics_process(delta: float) -> void:
	var player := _nearest_player()
	if player != null:
		var dist := global_position.distance_to(player.global_position)
		if dist < ATTENTION_RADIUS:
			attending = true
		elif dist > RELEASE_RADIUS:
			attending = false
	if attending and player != null:
		velocity = Vector2.ZERO
		facing = Facing.from_vector(player.global_position - global_position)
		_play("idle")
		return
	if route.is_empty():
		_play("idle")
		return
	var goal := _origin + route[_index]
	var to_goal := goal - position
	if to_goal.length() <= ARRIVE_DISTANCE:
		_index = (_index + 1) % route.size()
		_stuck_time = 0.0
		return
	velocity = to_goal.normalized() * speed
	var before := position
	move_and_slide()
	if position.distance_to(before) < speed * delta * 0.25:
		_stuck_time += delta
		if _stuck_time > STUCK_SECONDS:
			_index = (_index + 1) % route.size()
			_stuck_time = 0.0
	else:
		_stuck_time = 0.0
	facing = Facing.from_vector_stable(facing, velocity)
	_play("walk")


func _nearest_player() -> Node2D:
	var best: Node2D = null
	for node in get_tree().get_nodes_in_group(&"player"):
		var candidate := node as Node2D
		if candidate == null:
			continue
		if (
			best == null
			or (
				global_position.distance_squared_to(candidate.global_position)
				< global_position.distance_squared_to(best.global_position)
			)
		):
			best = candidate
	return best


func _play(state_name: String) -> void:
	var anim := CharacterSheet.animation_name(state_name, facing)
	if sprite.animation != anim:
		sprite.play(anim)
