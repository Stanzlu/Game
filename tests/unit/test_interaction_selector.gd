extends GutTest


func _c(pos: Vector2, priority: int = 0, id: String = "") -> Dictionary:
	return {"position": pos, "priority": priority, "id": id}


func test_empty_returns_empty() -> void:
	var none: Array[Dictionary] = []
	assert_true(InteractionSelector.pick(Vector2.ZERO, Vector2.RIGHT, none).is_empty())


func test_prefers_target_in_facing_direction() -> void:
	var cands: Array[Dictionary] = [
		_c(Vector2(-12, 0), 0, "behind"), _c(Vector2(14, 0), 0, "ahead")
	]
	assert_eq(InteractionSelector.pick(Vector2.ZERO, Vector2.RIGHT, cands)["id"], "ahead")


func test_ignores_far_targets_behind_but_accepts_very_close_ones() -> void:
	var far_behind: Array[Dictionary] = [_c(Vector2(-16, 0), 0, "behind")]
	assert_true(InteractionSelector.pick(Vector2.ZERO, Vector2.RIGHT, far_behind).is_empty())
	var close_behind: Array[Dictionary] = [_c(Vector2(-6, 0), 0, "close")]
	assert_eq(InteractionSelector.pick(Vector2.ZERO, Vector2.RIGHT, close_behind)["id"], "close")


func test_priority_wins_among_nearby_targets() -> void:
	var cands: Array[Dictionary] = [
		_c(Vector2(8, 0), 0, "near"), _c(Vector2(14, 2), 1, "important")
	]
	assert_eq(InteractionSelector.pick(Vector2.ZERO, Vector2.RIGHT, cands)["id"], "important")
