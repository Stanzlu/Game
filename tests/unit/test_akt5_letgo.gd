extends GutTest
## Act V, segment G5: the way out of the load (docs/akt5/REGIONSBRIEFE.md, O4, O10). The model of
## the letting go: once she has stepped away from the console, the levers go down by themselves,
## one after the other, in the order of the trial and then Four to Twelve; half way something goes
## wrong, a little later a lamp goes out, and when the last lever is down the hall settles. The
## clock is play time and runs only while she is away and nobody speaks. What the scene does with
## it is tested in test_akt5_letgo_szene, what the keeper says in test_akt5_letgo_text.

var _log: Array = []


func after_each() -> void:
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)


func _letgo() -> LetGo:
	var model := LetGo.new()
	autofree(model)
	_log = []
	model.began.connect(func() -> void: _log.append("began"))
	model.fell.connect(func(number: int, _index: int) -> void: _log.append(number))
	model.mid.connect(func() -> void: _log.append("mid"))
	model.defect.connect(func() -> void: _log.append("defect"))
	model.finished.connect(func() -> void: _log.append("finished"))
	return model


## Plays `seconds` of play time in ticks of a sixtieth.
func _play(model: LetGo, seconds: float, away := true, talking := false) -> void:
	var ticks := int(ceil(seconds * 60.0))
	for i in ticks:
		model.step(1.0 / 60.0, away, talking)


func test_the_levers_go_down_in_the_order_of_the_trial_and_then_four_to_twelve() -> void:
	assert_eq(LetGo.ORDER.slice(0, 3), MaschineScene.ORDER, "Three, One, Two as the keeper called")
	assert_eq(LetGo.ORDER.slice(3), [4, 5, 6, 7, 8, 9, 10, 11, 12])
	var sorted := LetGo.ORDER.duplicate()
	sorted.sort()
	assert_eq(sorted, range(1, 13), "every lever goes down once")


func test_nothing_happens_before_she_has_stepped_away() -> void:
	var model := _letgo()
	_play(model, 60.0)
	assert_eq(_log, [], "an unbegun letting go has no clock")
	assert_eq(model.state, LetGo.State.IDLE)
	assert_eq(model.fallen, 0)


func test_it_begins_once() -> void:
	var model := _letgo()
	model.begin()
	model.begin()
	assert_eq(_log, ["began"])
	assert_eq(model.state, LetGo.State.RUNNING)


func test_the_whole_course_from_the_first_step_away_to_the_settled_hall() -> void:
	var model := _letgo()
	model.begin()
	_play(model, LetGo.seconds() + 1.0)
	var falls: Array = _log.filter(func(entry: Variant) -> bool: return entry is int)
	assert_eq(falls, LetGo.ORDER, "all twelve, in order, each once")
	assert_eq(_log[0], "began")
	assert_eq(_log[-1], "finished", "and the end comes last")
	assert_eq(_log.count("mid"), 1)
	assert_eq(_log.count("defect"), 1)
	assert_eq(model.state, LetGo.State.DONE)
	assert_eq(model.fallen, 12)


func test_something_goes_wrong_half_way_and_a_lamp_goes_out_a_little_later() -> void:
	var model := _letgo()
	model.begin()
	_play(model, LetGo.fall_time(LetGo.MID_INDEX) + 0.1)
	assert_true(_log.has("mid"), "the burst of steam comes with the sixth lever")
	assert_false(_log.has("defect"), "the lamp is not out yet")
	assert_eq(model.fallen, LetGo.MID_INDEX + 1)
	_play(model, LetGo.fall_time(LetGo.DEFECT_INDEX) - LetGo.fall_time(LetGo.MID_INDEX))
	assert_true(_log.has("defect"), "it goes out with the ninth lever")
	assert_lt(LetGo.MID_INDEX, LetGo.DEFECT_INDEX)
	assert_lt(LetGo.DEFECT_INDEX, LetGo.ORDER.size() - 1, "and the hall goes on after it")


func test_the_levers_fall_at_an_even_beat() -> void:
	for i in range(1, LetGo.ORDER.size()):
		assert_almost_eq(
			LetGo.fall_time(i) - LetGo.fall_time(i - 1), LetGo.FALL_EVERY, 0.0001, "a bar of clicks"
		)
	assert_gt(LetGo.FIRST_FALL, 0.0, "the first one does not fall the moment she steps away")
	assert_gt(LetGo.seconds(), LetGo.fall_time(LetGo.ORDER.size() - 1), "the hall settles last")


func test_the_clock_runs_only_while_she_is_away() -> void:
	var model := _letgo()
	model.begin()
	_play(model, 10.0, false)
	assert_eq(model.elapsed, 0.0, "at the console it stands still")
	_play(model, 1.0)
	assert_almost_eq(model.elapsed, 1.0, 0.05)
	_play(model, 30.0, false)
	assert_almost_eq(model.elapsed, 1.0, 0.05, "and it waits for her where it stood")
	assert_eq(model.fallen, 0)


func test_the_clock_stands_still_while_anyone_speaks() -> void:
	var model := _letgo()
	model.begin()
	_play(model, 5.0, true, true)
	assert_eq(model.elapsed, 0.0)
	_play(model, LetGo.FIRST_FALL + 0.1)
	assert_eq(model.fallen, 1)


func test_one_event_comes_per_tick_even_for_a_long_tick() -> void:
	var model := _letgo()
	model.begin()
	model.step(100.0, true, false)
	assert_eq(model.fallen, 1, "the scene may start to speak at an event: the next waits")
	var before := _log.size()
	model.step(0.0, true, false)
	assert_gt(_log.size(), before, "and the next tick goes on")


func test_the_course_does_not_depend_on_more_time_or_the_pace_of_encounters() -> void:
	# waiting is no skill: the settings that stretch the load do not stretch it
	var plain := LetGo.seconds()
	Settings.set_value("access.timing", 2, false)
	Settings.set_value("access.encounter_speed", 2, false)
	assert_eq(LetGo.seconds(), plain)
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)


func test_the_wait_is_short_enough_to_stand_through() -> void:
	assert_lt(LetGo.seconds(), 30.0, "half a minute at most")
	assert_gt(LetGo.seconds(), 15.0, "long enough to be a wait")


func test_a_course_already_through_has_no_events_left() -> void:
	var model := _letgo()
	model.finish_silently()
	assert_eq(model.state, LetGo.State.DONE)
	assert_eq(model.fallen, 12)
	_play(model, 60.0)
	assert_eq(_log, [], "nothing is told twice")
