class_name InteractionSelector
extends RefCounted
## Picks the best interaction target. Pure function, unit-tested.
##
## Candidates are dictionaries {"position": Vector2, "priority": int, "id": Variant}.
## Targets behind the player are ignored unless very close; among the rest the
## nearest one in the facing direction wins, then priority breaks ties.

const MAX_ANGLE := deg_to_rad(100.0)
const CLOSE_RANGE := 10.0
const FACING_WEIGHT := 12.0


static func pick(origin: Vector2, facing: Vector2, candidates: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = {}
	var best_score := INF
	var forward := facing.normalized() if facing.length_squared() > 0.0 else Vector2.DOWN
	for c: Dictionary in candidates:
		var offset: Vector2 = c["position"] - origin
		var dist := offset.length()
		var angle := absf(forward.angle_to(offset)) if dist > 0.001 else 0.0
		if angle > MAX_ANGLE and dist > CLOSE_RANGE:
			continue
		var score := dist + angle * FACING_WEIGHT - float(c.get("priority", 0)) * 1000.0
		if score < best_score:
			best_score = score
			best = c
	return best
