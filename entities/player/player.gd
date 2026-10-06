class_name Player
extends CharacterBody2D
## Player character: input → movement model → move_and_slide, plus states, facing,
## footsteps, sitting and interaction. Polls the Input singleton because it lives
## inside the world SubViewport (ADR-012).

signal footstep(surface: StringName, at: Vector2, running: bool)
signal state_changed(state: State)

enum State { IDLE, WALK, RUN, SIT, LOCKED }

const STAND_UP_THRESHOLD := 0.5
const NUDGE_SPEED := 60.0
const INTERACT_COOLDOWN := 0.2
const STATE_NAMES := ["idle", "walk", "run", "sit", "idle"]
## Seconds of standing still before the protagonist blinks and glances around (Game Bible
## §36); random within the range, so it never feels like a timer.
const GLANCE_AFTER := Vector2(4.0, 9.0)

@export var tuning: MovementTuning
@export var sheet: CharacterSheet
@export var snap_eight := true
@export var sprint_toggle := false

var state := State.IDLE
var facing := Facing.Dir.S
## Multiplies all speeds (encounters can slow the player down).
var speed_scale := 1.0
## func(world_position: Vector2) -> StringName; set by the scene that owns the map.
var surface_provider := Callable()
var last_surface := &""
var _locks: Dictionary = {}
var _sprint_latched := false
var _step_accum := 0.0
var _seat_return := Vector2.ZERO
var _interact_cooldown := 0.0
var _prev_physics_pos := Vector2.ZERO
var _curr_physics_pos := Vector2.ZERO
var _idle_time := 0.0
var _next_glance := 5.0
var _glancing := false
var _rng := RandomNumberGenerator.new()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var steps: FootstepPlayer = $Steps
@onready var sensor: InteractionSensor = $InteractionSensor
@onready var prompt: InteractionPrompt = $Prompt
@onready var _collision: CollisionShape2D = $Collision


func _ready() -> void:
	add_to_group(&"player")
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.WORLD | PhysicsLayers.NPC
	motion_mode = MOTION_MODE_FLOATING
	if tuning == null:
		tuning = load("res://entities/player/tuning/direkt.tres")
	sprite.sprite_frames = sheet.build_frames()
	sprite.offset = sheet.feet_offset
	sheet.add_shadow_to(self)
	sensor.target_changed.connect(prompt.show_for)
	sprite.animation_finished.connect(_on_animation_finished)
	_next_glance = _rng.randf_range(GLANCE_AFTER.x, GLANCE_AFTER.y)
	_update_animation(0.0)


func lock(reason: StringName) -> void:
	_locks[reason] = true
	if state != State.SIT:
		_set_state(State.LOCKED)


func unlock(reason: StringName) -> void:
	_locks.erase(reason)
	_interact_cooldown = INTERACT_COOLDOWN


func is_locked() -> bool:
	return not _locks.is_empty()


func read_input() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func teleport(to: Vector2) -> void:
	global_position = to
	velocity = Vector2.ZERO
	_prev_physics_pos = to
	_curr_physics_pos = to
	reset_physics_interpolation()


## Position between the last two physics steps, matching what is rendered with
## physics interpolation on. Cameras follow this, not global_position.
func interpolated_position() -> Vector2:
	return _prev_physics_pos.lerp(_curr_physics_pos, Engine.get_physics_interpolation_fraction())


func sit_on(seat: Vector2, dir: Facing.Dir) -> void:
	if state == State.SIT:
		return
	_seat_return = global_position
	_collision.set_deferred(&"disabled", true)
	teleport(seat)
	facing = dir
	_set_state(State.SIT)
	_update_animation(0.0)
	SoundBank.play_at(self, "sit", global_position, -4.0)


func stand_up() -> void:
	if state != State.SIT:
		return
	teleport(_seat_return)
	_collision.set_deferred(&"disabled", false)
	_set_state(State.IDLE)
	_interact_cooldown = INTERACT_COOLDOWN


func _physics_process(delta: float) -> void:
	_prev_physics_pos = _curr_physics_pos
	_physics_step(delta)
	_curr_physics_pos = global_position


func _physics_step(delta: float) -> void:
	_interact_cooldown = maxf(_interact_cooldown - delta, 0.0)
	var input := Vector2.ZERO if is_locked() else read_input()
	if state == State.SIT:
		sensor.update_target(self, Facing.to_vector(facing), false)
		if input.length() >= STAND_UP_THRESHOLD:
			stand_up()
		return
	var sprinting := _update_sprint(input)
	var target := MovementModel.target_velocity(input, tuning, sprinting, snap_eight, speed_scale)
	velocity = MovementModel.step(velocity, target, tuning, delta)
	var before := global_position
	move_and_slide()
	if input != Vector2.ZERO and get_slide_collision_count() > 0:
		_nudge_around_corner(input, delta)
	var moved := global_position.distance_to(before)
	var speed := moved / delta
	if input.length_squared() > 0.0001:
		var look := MovementModel.snap_to_eight(input) if snap_eight else input
		facing = Facing.from_vector_stable(facing, look)
	if is_locked():
		_set_state(State.LOCKED)
	elif speed < 4.0:
		_set_state(State.IDLE)
	else:
		_set_state(State.RUN if sprinting and speed > tuning.walk_speed * 1.1 else State.WALK)
	_advance_steps(moved, state == State.RUN)
	_update_idle(delta)
	_update_animation(speed)
	sensor.update_target(self, Facing.to_vector(facing), not is_locked())
	if not is_locked() and _interact_cooldown <= 0.0 and Input.is_action_just_pressed(&"interact"):
		sensor.try_interact(self)


func _update_sprint(input: Vector2) -> bool:
	if not sprint_toggle:
		return Input.is_action_pressed(&"sprint")
	if Input.is_action_just_pressed(&"sprint"):
		_sprint_latched = not _sprint_latched
	if input == Vector2.ZERO:
		_sprint_latched = false
	return _sprint_latched


func _nudge_around_corner(input: Vector2, delta: float) -> void:
	if tuning.corner_nudge_px <= 0 or not MovementModel.is_axis_aligned(input):
		return
	var dir := (
		Vector2(signf(input.x), 0) if absf(input.x) > absf(input.y) else Vector2(0, signf(input.y))
	)
	if not test_move(global_transform, dir):
		return
	var side := Vector2(dir.y, dir.x)
	for k in range(1, tuning.corner_nudge_px + 1):
		for s: float in [1.0, -1.0]:
			var offset := side * float(k) * s
			if test_move(global_transform, offset):
				continue
			if not test_move(global_transform.translated(offset), dir):
				global_position += side * s * minf(float(k), NUDGE_SPEED * delta)
				return


func _advance_steps(moved: float, running: bool) -> void:
	if moved <= 0.01:
		_step_accum = 0.0
		return
	var distance := tuning.step_distance_run if running else tuning.step_distance_walk
	if _step_accum == 0.0:
		_step_accum = distance * 0.5
	_step_accum += moved
	if _step_accum < distance:
		return
	_step_accum -= distance
	last_surface = (
		surface_provider.call(global_position) if surface_provider.is_valid() else &"dirt"
	)
	steps.play_surface(last_surface, running)
	footstep.emit(last_surface, global_position, running)


func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	state = new_state
	state_changed.emit(state)


## Long idle: after standing still for a while, blink and glance around once.
func _update_idle(delta: float) -> void:
	if state != State.IDLE:
		_idle_time = 0.0
		_glancing = false
		return
	_idle_time += delta
	if (
		not _glancing
		and _idle_time >= _next_glance
		and CharacterSheet.has_look(sprite.sprite_frames)
	):
		_glancing = true


func _on_animation_finished() -> void:
	if _glancing:
		_glancing = false
		_idle_time = 0.0
		_next_glance = _rng.randf_range(GLANCE_AFTER.x, GLANCE_AFTER.y)


func _update_animation(speed: float) -> void:
	var state_name: String = "look" if _glancing else STATE_NAMES[state]
	var anim := CharacterSheet.animation_name(state_name, facing)
	if sprite.animation != anim:
		sprite.play(anim)
	match state:
		State.WALK:
			sprite.speed_scale = clampf(speed / tuning.walk_speed, 0.5, 1.5)
		State.RUN:
			sprite.speed_scale = clampf(speed / tuning.run_speed, 0.6, 1.4)
		_:
			sprite.speed_scale = 1.0
