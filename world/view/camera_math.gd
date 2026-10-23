class_name CameraMath
extends RefCounted
## Pure helpers for the pixel camera (ADR-012). Unit-tested.


## Frame-rate independent exponential approach. `sharpness` ~ 1/seconds.
static func smooth_toward(
	current: Vector2, target: Vector2, sharpness: float, delta: float
) -> Vector2:
	if sharpness <= 0.0:
		return target
	return current.lerp(target, 1.0 - exp(-sharpness * delta))


## Splits a camera position into the integer part used inside the pixel-snapped world
## and the remainder the world display is shifted by. Pixel mode rounds and drops it.
static func split(position: Vector2, smooth: bool) -> Array[Vector2]:
	if not smooth:
		return [position.round(), Vector2.ZERO]
	var whole := position.floor()
	return [whole, position - whole]


## Keeps the view inside the map. If the map is smaller than the view, it is centered.
static func clamp_to_bounds(center: Vector2, half_view: Vector2, bounds: Rect2) -> Vector2:
	var result := center
	for axis in 2:
		var lo := bounds.position[axis] + half_view[axis]
		var hi := bounds.end[axis] - half_view[axis]
		result[axis] = (lo + hi) * 0.5 if lo > hi else clampf(center[axis], lo, hi)
	return result
