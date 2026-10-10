class_name InteractionSelector
extends RefCounted
## Picks the best interaction target. Pure function, unit-tested.
##
## Candidates are dictionaries {"position": Vector2, "priority": int, "id": Variant}.
## Targets behind the player are ignored unless very close; among the rest the
## nearest one in the facing direction wins. Priority is worth a few pixels (a door right
## beside you does not beat the person you face), and the current target keeps a small
## bonus so the prompt does not flicker between two things at the same distance.

const MAX_ANGLE := deg_to_rad(100.0)
const CLOSE_RANGE := 10.0
const FACING_WEIGHT := 12.0
const PRIORITY_WEIGHT := 12.0
const STICKY_BONUS := 6.0


static func pick(
	origin: Vector2, facing: Vector2, candidates: Array[Dictionary], current: Variant = null
) -> Dictionary:
	var best: Dictionary = {}
	var best_score := INF
	var forward := facing.normalized() if facing.length_squared() > 0.0 else Vector2.DOWN
	for c: Dictionary in candidates:
		var offset: Vector2 = c["position"] - origin
		var dist := offset.length()
		var angle := absf(forward.angle_to(offset)) if dist > 0.001 else 0.0
		if angle > MAX_ANGLE and dist > CLOSE_RANGE:
			continue
		var score := dist + angle * FACING_WEIGHT - float(c.get("priority", 0)) * PRIORITY_WEIGHT
		if current != null and c.get("id") == current:
			score -= STICKY_BONUS
		if score < best_score:
			best_score = score
			best = c
	return best
