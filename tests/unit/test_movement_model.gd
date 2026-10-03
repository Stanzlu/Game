extends GutTest

var tuning: MovementTuning


func before_each() -> void:
	tuning = MovementTuning.new()
	tuning.walk_speed = 80.0
	tuning.run_speed = 140.0
	tuning.acceleration = 1000.0
	tuning.deceleration = 2000.0
	tuning.turn_acceleration = 4000.0
	tuning.slow_walk_factor = 0.5


func _simulate(velocity: Vector2, target: Vector2, seconds: float) -> Vector2:
	var v := velocity
	for i in roundi(seconds * 60.0):
		v = MovementModel.step(v, target, tuning, 1.0 / 60.0)
	return v


func test_no_input_means_no_target() -> void:
	assert_eq(MovementModel.target_velocity(Vector2.ZERO, tuning, true, true), Vector2.ZERO)


func test_full_keyboard_input_walks_at_walk_speed() -> void:
	var v := MovementModel.target_velocity(Vector2.RIGHT, tuning, false, true)
	assert_almost_eq(v.length(), 80.0, 0.001)


func test_diagonal_is_not_faster() -> void:
	var v := MovementModel.target_velocity(Vector2(1, 1).normalized(), tuning, false, true)
	assert_almost_eq(v.length(), 80.0, 0.001)


func test_small_tilt_walks_slowly() -> void:
	var v := MovementModel.target_velocity(Vector2(0.3, 0), tuning, false, true)
	assert_almost_eq(v.length(), 80.0 * lerpf(0.5, 1.0, 0.3), 0.001)


func test_sprint_needs_enough_tilt() -> void:
	assert_almost_eq(
		MovementModel.target_velocity(Vector2.RIGHT, tuning, true, true).length(), 140.0, 0.001
	)
	assert_lt(MovementModel.target_velocity(Vector2(0.3, 0), tuning, true, true).length(), 140.0)


func test_speed_scale_reduces_speed() -> void:
	var v := MovementModel.target_velocity(Vector2.RIGHT, tuning, true, true, 0.5)
	assert_almost_eq(v.length(), 70.0, 0.001)


func test_eight_direction_snapping() -> void:
	var raw := Vector2(1, 0.3)
	var snapped := MovementModel.target_velocity(raw, tuning, false, true)
	assert_almost_eq(snapped.normalized().angle(), 0.0, 0.0001)
	var free := MovementModel.target_velocity(raw, tuning, false, false)
	assert_almost_eq(free.normalized().angle(), raw.angle(), 0.0001)


func test_accelerates_to_target_and_not_beyond() -> void:
	var target := Vector2(80, 0)
	var v := _simulate(Vector2.ZERO, target, 0.05)
	assert_almost_eq(v.x, 50.0, 1.0)
	assert_eq(_simulate(Vector2.ZERO, target, 1.0), target)


func test_decelerates_to_standstill() -> void:
	var v := MovementModel.step(Vector2(80, 0), Vector2.ZERO, tuning, 1.0 / 60.0)
	assert_almost_eq(v.x, 80.0 - 2000.0 / 60.0, 0.001)
	assert_eq(_simulate(Vector2(80, 0), Vector2.ZERO, 0.1), Vector2.ZERO)


func test_turnaround_uses_turn_rate() -> void:
	var v := MovementModel.step(Vector2(80, 0), Vector2(-80, 0), tuning, 0.01)
	assert_almost_eq(v.x, 80.0 - 40.0, 0.001)


func test_axis_alignment() -> void:
	assert_true(MovementModel.is_axis_aligned(Vector2.UP))
	assert_false(MovementModel.is_axis_aligned(Vector2(1, 1).normalized()))


func test_presets_load_and_are_ordered_by_responsiveness() -> void:
	var direkt := load("res://entities/player/tuning/direkt.tres") as MovementTuning
	var weich := load("res://entities/player/tuning/weich.tres") as MovementTuning
	var schwer := load("res://entities/player/tuning/schwer.tres") as MovementTuning
	assert_not_null(direkt)
	assert_not_null(weich)
	assert_not_null(schwer)
	if direkt == null or weich == null or schwer == null:
		return
	assert_gt(direkt.acceleration, weich.acceleration)
	assert_gt(weich.acceleration, schwer.acceleration)
	for t: MovementTuning in [direkt, weich, schwer]:
		assert_gt(t.run_speed, t.walk_speed)
		assert_true(t.display_key.begins_with("TUNING_"))
