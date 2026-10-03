class_name MovementModel
extends RefCounted
## Pure top-down movement math (no nodes). Unit-tested in tests/unit/test_movement_model.gd.


## Desired velocity for an input vector (length 0..1; keyboard gives 1, sticks give less).
static func target_velocity(
	input: Vector2,
	tuning: MovementTuning,
	sprinting: bool,
	snap_eight: bool,
	speed_scale: float = 1.0,
) -> Vector2:
	var magnitude := minf(input.length(), 1.0)
	if magnitude < 0.001:
		return Vector2.ZERO
	var dir := input.normalized()
	if snap_eight:
		dir = snap_to_eight(dir)
	var speed := tuning.walk_speed * lerpf(tuning.slow_walk_factor, 1.0, magnitude)
	if sprinting and magnitude >= tuning.sprint_min_tilt:
		speed = tuning.run_speed
	return dir * speed * speed_scale


## Moves the current velocity toward the target with acceleration, deceleration or turn rate.
static func step(
	velocity: Vector2, target: Vector2, tuning: MovementTuning, delta: float
) -> Vector2:
	var rate := tuning.acceleration
	if target == Vector2.ZERO:
		rate = tuning.deceleration
	elif velocity.length_squared() > 1.0 and velocity.dot(target) < 0.0:
		rate = tuning.turn_acceleration
	return velocity.move_toward(target, rate * delta)


static func snap_to_eight(dir: Vector2) -> Vector2:
	return Vector2.from_angle(roundf(dir.angle() / Facing.STEP) * Facing.STEP)


## True when the input is close to one of the four axes (used for corner nudging).
static func is_axis_aligned(dir: Vector2, tolerance: float = 0.2) -> bool:
	return absf(dir.x) < tolerance or absf(dir.y) < tolerance
