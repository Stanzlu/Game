extends GutTest

var model: AntreiberModel


func before_each() -> void:
	model = AntreiberModel.new()


func _run(
	seconds: float, speed: float, sprinting: bool, input: bool = true, sitting := false
) -> void:
	var dt := 1.0 / 60.0
	for i in roundi(seconds * 60.0):
		model.update(dt, speed * dt * model.speed_scale(), input, sprinting, sitting)


func test_walking_makes_the_goal_recede() -> void:
	var start := model.goal_distance
	_run(3.0, 84.0, false)
	assert_gt(model.goal_distance, start)
	assert_false(model.is_resolved())


func test_sprinting_makes_it_recede_faster() -> void:
	var walker := AntreiberModel.new()
	var dt := 1.0 / 60.0
	for i in 120:
		walker.update(dt, 84.0 * dt, true, false, false)
	_run(2.0, 84.0, true)
	assert_gt(model.goal_distance, walker.goal_distance)


func test_long_sprints_build_fatigue_and_slow_down() -> void:
	_run(10.0, 140.0, true)
	assert_gt(model.fatigue, 0.4)
	assert_lt(model.speed_scale(), 0.85)
	assert_false(model.is_resolved(), "running never resolves it")


func test_fatigue_recovers_when_not_sprinting() -> void:
	_run(8.0, 140.0, true)
	var tired := model.fatigue
	_run(2.0, 84.0, false)
	assert_lt(model.fatigue, tired)


func test_standing_still_resolves_after_the_set_time() -> void:
	watch_signals(model)
	_run(6.0, 84.0, false)
	_run(2.9, 0.0, false, false)
	assert_false(model.is_resolved())
	_run(0.2, 0.0, false, false)
	assert_true(model.is_resolved())
	assert_signal_emitted(model, "resolved")


func test_any_input_resets_stillness() -> void:
	_run(6.0, 84.0, false)
	_run(2.5, 0.0, false, false)
	_run(0.1, 0.0, false, true)
	_run(2.5, 0.0, false, false)
	assert_false(model.is_resolved())


func test_sitting_resolves_twice_as_fast() -> void:
	_run(6.0, 84.0, false)
	_run(1.6, 0.0, false, false, true)
	assert_true(model.is_resolved())


func test_goal_never_comes_closer_than_minimum() -> void:
	model.goal_distance = AntreiberModel.MIN_GOAL_DISTANCE
	_run(5.0, 84.0, false)
	assert_gte(model.goal_distance, AntreiberModel.MIN_GOAL_DISTANCE)


func test_moods_follow_behaviour() -> void:
	assert_eq(model.mood(84.0, 84.0), AntreiberModel.Mood.START)
	_run(2.0, 84.0, false)
	assert_eq(model.mood(84.0, 84.0), AntreiberModel.Mood.URGING)
	assert_eq(model.mood(140.0, 84.0), AntreiberModel.Mood.CHEERING)
	assert_eq(model.mood(10.0, 84.0), AntreiberModel.Mood.WORRIED)
	_run(1.5, 0.0, false, false)
	assert_eq(model.mood(0.0, 84.0), AntreiberModel.Mood.PUZZLED)


func test_encounter_speed_slows_everything_down() -> void:
	var gentle := AntreiberModel.new()
	gentle.encounter_speed = 0.5
	var dt := 1.0 / 60.0
	for i in 300:
		gentle.update(dt, 140.0 * dt, true, true, false)
	_run(5.0, 140.0, true)
	assert_lt(gentle.fatigue, model.fatigue)


func test_standing_at_the_start_does_not_resolve() -> void:
	_run(10.0, 0.0, false, false)
	assert_false(model.is_resolved(), "the race has to be tried first")
	assert_false(model.is_engaged())
