class_name Facing
extends RefCounted
## Eight facing directions in screen space (y points down). Order matches the sprite
## sheet rows written by tools/placeholders/make_placeholders.py.

enum Dir { E, SE, S, SW, W, NW, N, NE }

const COUNT := 8
const STEP := TAU / COUNT


static func from_vector(v: Vector2) -> Dir:
	return wrapi(roundi(v.angle() / STEP), 0, COUNT) as Dir


## Keeps the current facing unless the new direction is clearly closer to another one.
## Prevents flicker between neighbours when an analog stick sits near a boundary.
static func from_vector_stable(current: Dir, v: Vector2, margin_rad: float = 0.14) -> Dir:
	if v.length_squared() < 0.0001:
		return current
	var diff := absf(angle_difference(to_vector(current).angle(), v.angle()))
	if diff <= STEP * 0.5 + margin_rad:
		return current
	return from_vector(v)


static func to_vector(dir: Dir) -> Vector2:
	return Vector2.from_angle(float(dir) * STEP)
