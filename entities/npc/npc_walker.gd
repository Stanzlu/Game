class_name NpcWalker
extends CharacterBody2D
## Walks a closed route of waypoints. Stops and looks at the player when they come close,
## continues once they leave. Params from the map: {"route": [[dx, dy], ...]} in cells,
## relative to the spawn cell. Basis for Elysia's identically moving NPCs later.
## With params "cue" (and optional "dialogue") the NPC can be talked to; it stays put and
## faces the player until the conversation ends.
## With "glance": true it blinks and looks around now and then while standing (people of
## the real world, Game Bible §36). Elysians never do: their attention is perfect.

const ATTENTION_RADIUS := 30.0
const RELEASE_RADIUS := 44.0
const ARRIVE_DISTANCE := 2.0
const STUCK_SECONDS := 1.5
const DEFAULT_DIALOGUE := "res://content/dialogue/sandbox/sandbox.dialogue"
const TALK_RADIUS := 14.0

@export var sheet: CharacterSheet
@export var speed := 38.0
@export var tile_size := 16

var route: Array[Vector2] = []
var facing := Facing.Dir.S
var attending := false
var talking := false
var dialogue_path := DEFAULT_DIALOGUE
var cue := ""
var glances := false
var _index := 0
var _idle_time := 0.0
var _next_glance := 3.0
var _glancing := false
var _rng := RandomNumberGenerator.new()
var _stuck_time := 0.0
var _origin := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	collision_layer = PhysicsLayers.NPC
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.PLAYER
	motion_mode = MOTION_MODE_FLOATING
	_apply_sheet()
	_origin = position
	sprite.animation_finished.connect(_on_animation_finished)
	_rng.seed = hash(name)
	_next_glance = _rng.randf_range(2.5, 6.0)
	_play("idle")


## Map params: route (cells, relative), speed, optional sheet (res:// path of a CharacterSheet).
func apply_params(params: Dictionary) -> void:
	if params.has("sheet"):
		var override := load(str(params["sheet"])) as CharacterSheet
		if override == null:
			Log.error(Log.Category.CONTENT, "npc sheet missing", {"sheet": params["sheet"]})
		else:
			sheet = override
			_apply_sheet()
			_play("idle")
	route.clear()
	for point: Variant in params.get("route", []):
		var p: Array = point
		route.append(Vector2(float(p[0]), float(p[1])) * tile_size)
	speed = float(params.get("speed", speed))
	glances = bool(params.get("glance", false))
	if params.has("cue"):
		cue = str(params["cue"])
		dialogue_path = str(params.get("dialogue", DEFAULT_DIALOGUE))
		_add_talk_area()


func _add_talk_area() -> void:
	var area := Interactable.new()
	area.name = "Interactable"
	area.prompt_key = "INTERACT_TALK"
	area.prompt_offset = Vector2(0, -36)
	area.interact_priority = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = TALK_RADIUS
	shape.shape = circle
	shape.position = Vector2(0, -4)
	area.add_child(shape)
	add_child(area)
	area.interacted.connect(_on_talk)


func _on_talk(actor: Node) -> void:
	var resource := load(dialogue_path) as DialogueResource
	var presenter := get_tree().get_first_node_in_group(&"dialogue_presenter")
	if resource == null or presenter == null:
		Log.error(Log.Category.CONTENT, "npc dialogue missing", {"path": dialogue_path, "cue": cue})
		return
	talking = true
	if actor is Node2D:
		facing = Facing.from_vector((actor as Node2D).global_position - global_position)
	presenter.connect(&"finished", func() -> void: talking = false, CONNECT_ONE_SHOT)
	presenter.call(&"present", resource, cue, actor)


func _apply_sheet() -> void:
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
	var old_shadow := get_node_or_null("Shadow")
	if old_shadow != null:
		old_shadow.free()
	sheet.add_shadow_to(self)


func _physics_process(delta: float) -> void:
	if talking:
		velocity = Vector2.ZERO
		_play("idle")
		return
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
	if state_name == "idle" and glances:
		_idle_time += get_physics_process_delta_time()
		if (
			not _glancing
			and _idle_time >= _next_glance
			and CharacterSheet.has_look(sprite.sprite_frames)
		):
			_glancing = true
		if _glancing:
			state_name = "look"
	else:
		_idle_time = 0.0
		_glancing = false
	var anim := CharacterSheet.animation_name(state_name, facing)
	if sprite.animation != anim:
		sprite.play(anim)


func _on_animation_finished() -> void:
	if _glancing:
		_glancing = false
		_idle_time = 0.0
		_next_glance = _rng.randf_range(2.5, 6.0)
