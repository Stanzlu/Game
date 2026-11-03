extends GutTest
## Act V, segment G4: the load (docs/akt5/REGIONSBRIEFE.md, O4). A run of the levers at the console:
## a lever that is down springs up after its period and asks to be pulled again, in four waves with
## three, six, nine and twelve levers in use. The last wave cannot be kept by anyone, at no setting
## of "more time" and "pace of encounters" (the test reckons it), and nothing fails: the run only
## stops. This file tests the model (`LoadRun`) without a scene; the hall with the run is tested in
## test_akt5_last_szene, what the keeper says in test_akt5_last_text.

var _run: LoadRun
var _levers: Dictionary = {}


func before_each() -> void:
	WorldState.new_game()
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)
	_levers = {}
	_run = LoadRun.new()
	add_child_autofree(_run)
	for number: int in range(1, 13):
		var lever := ConsoleLever.new()
		add_child_autofree(lever)
		(
			lever
			. apply_params(
				{
					"n": number,
					"active": number <= 3,
					"sprite_up": "tal/ma_lever_%d_up" % number,
					"sprite_down": "tal/ma_lever_%d_down" % number,
					"radius": 12,
				}
			)
		)
		_levers[number] = lever
	_run.levers = _levers


func after_each() -> void:
	Settings.set_value("access.timing", 0, false)
	Settings.set_value("access.encounter_speed", 0, false)
	WorldState.new_game()


## Plays `seconds` of play time in ticks of a sixtieth.
func _play(seconds: float, at_console := true, talking := false) -> void:
	var left := seconds
	while left > 0.0:
		var tick := minf(left, 1.0 / 60.0)
		_run.step(tick, at_console, talking)
		left -= tick


func _lever(number: int) -> ConsoleLever:
	return _levers[number] as ConsoleLever


func _all_settings() -> Array[float]:
	var stretches: Array[float] = []
	for timing: float in Settings.TIMING_FACTORS:
		for pace: float in Settings.ENCOUNTER_SPEEDS:
			stretches.append(timing / pace)
	return stretches


# --- The reckoning -----------------------------------------------------------------------------


func test_four_waves_with_three_six_nine_and_twelve_levers_each_asking_more() -> void:
	assert_eq(LoadRun.WAVES.size(), 4)
	for wave: int in range(1, 5):
		assert_eq(LoadRun.levers_in(wave), wave * 3)
	for stretch: float in _all_settings():
		for wave: int in range(1, 4):
			assert_gt(
				LoadRun.demand(wave + 1, stretch),
				LoadRun.demand(wave, stretch),
				"wave %d asks more than %d at stretch %s" % [wave + 1, wave, stretch]
			)
			assert_lt(LoadRun.period(wave + 1, stretch), LoadRun.period(wave, stretch))


func test_the_first_wave_is_calm_at_every_setting_and_the_last_cannot_be_kept_at_any() -> void:
	var stretches := _all_settings()
	assert_eq(stretches.size(), 9, "three times three settings")
	for stretch: float in stretches:
		assert_true(LoadRun.possible(1, stretch), "wave one can be kept at %s" % stretch)
		assert_lt(
			LoadRun.demand(1, stretch), LoadRun.hand_rate() * 0.25, "and leaves room to breathe"
		)
		assert_false(
			LoadRun.possible(4, stretch),
			(
				"wave four asks %s pulls a second of a hand that gives %s"
				% [LoadRun.demand(4, stretch), LoadRun.hand_rate()]
			)
		)


func test_the_calmest_setting_stretches_four_times_and_still_the_last_wave_asks_too_much() -> void:
	Settings.set_value("access.timing", 2, false)
	Settings.set_value("access.encounter_speed", 2, false)
	assert_eq(LoadRun.stretch(), 4.0, "twice the time at half the pace")
	assert_gt(LoadRun.demand(4, LoadRun.stretch()), LoadRun.hand_rate())
	assert_false(LoadRun.possible(4, LoadRun.stretch()))
	var normal := LoadRun.demand(4, 1.0)
	assert_gt(normal, 4.0 * LoadRun.hand_rate(), "at normal pace it asks several hands")


func test_the_waves_get_longer_with_more_time_and_not_with_the_pace() -> void:
	var normal := LoadRun.wave_seconds(2)
	Settings.set_value("access.encounter_speed", 2, false)
	assert_eq(LoadRun.wave_seconds(2), normal, "the pace of the encounter does not stretch a wave")
	Settings.set_value("access.timing", 2, false)
	assert_eq(LoadRun.wave_seconds(2), normal * 2.0, "more time does")


# --- The run ----------------------------------------------------------------------------------


func test_the_run_begins_with_the_three_levers_of_the_trial_and_nothing_else_in_use() -> void:
	_lever(1).set_down(true)
	_run.begin()
	assert_eq(_run.state, LoadRun.State.RUNNING)
	for number: int in range(1, 13):
		assert_eq(_lever(number).active, number <= 3, "lever %d" % number)
	assert_eq(_run.open_count(), 2, "one is held, two ask")


func test_a_pulled_lever_holds_for_its_period_and_springs_up_again() -> void:
	_run.begin()
	var period := LoadRun.period(1, 1.0)
	_run.pull(2)
	assert_true(_lever(2).down)
	_play(period - 0.5)
	assert_true(_lever(2).down, "still held")
	_play(1.0)
	assert_false(_lever(2).down, "it springs up and asks again")
	_run.pull(2)
	assert_true(_lever(2).down, "and she holds it again")


func test_a_lever_that_is_not_in_use_is_not_pulled_and_a_held_one_is_not_pulled_twice() -> void:
	_run.begin()
	_run.pull(7)
	assert_false(_lever(7).down, "under its cloth")
	_run.pull(1)
	var before := _lever(1).down
	_run.pull(1)
	assert_eq(_lever(1).down, before)


func test_the_settings_stretch_every_period() -> void:
	Settings.set_value("access.timing", 2, false)
	Settings.set_value("access.encounter_speed", 2, false)
	_run.begin()
	_run.pull(1)
	_play(LoadRun.period(1, 1.0) + 1.0)
	assert_true(_lever(1).down, "four times the period: still held")
	_play(LoadRun.period(1, 4.0))
	assert_false(_lever(1).down)


func test_the_next_wave_takes_in_the_next_three_levers_and_says_so() -> void:
	_run.begin()
	var waves := []
	_run.wave_began.connect(func(wave: int) -> void: waves.append(wave))
	_play(LoadRun.wave_seconds(1) + 0.1)
	assert_eq(waves, [2])
	assert_eq(_run.wave, 2)
	for number: int in range(1, 13):
		assert_eq(_lever(number).active, number <= 6, "lever %d" % number)
	for number: int in [4, 5, 6]:
		assert_false(_lever(number).down, "the new ones stand up and ask")


func test_after_the_fourth_wave_the_run_stops_where_it_stands_and_fails_nothing() -> void:
	var over := []
	_run.overloaded.connect(func() -> void: over.append(true))
	_run.begin()
	for wave: int in range(1, 5):
		_play(LoadRun.wave_seconds(wave) + 0.1)
	assert_eq(over, [true], "once")
	assert_eq(_run.state, LoadRun.State.OVER)
	var open := _run.open_count()
	_play(60.0)
	assert_eq(_run.open_count(), open, "nothing moves any more")
	assert_eq(_run.state, LoadRun.State.OVER)
	var flags := WorldState.state.flags.duplicate()
	_play(5.0)
	assert_eq(WorldState.state.flags, flags, "the model sets no flag")


func test_whoever_leaves_the_console_is_waited_for_and_loses_nothing() -> void:
	_run.begin()
	_run.pull(1)
	var events := []
	_run.waited.connect(func() -> void: events.append("waited"))
	_run.returned.connect(func() -> void: events.append("returned"))
	_play(LoadRun.AWAY_SECONDS - 0.5, false)
	assert_eq(events, [], "a short step away costs nothing")
	_play(1.0, false)
	assert_eq(events, ["waited"])
	assert_true(_run.is_waiting())
	var wave_time_before := _run._wave_time
	var held_before := _lever(1).down
	_play(LoadRun.period(1, 1.0) * 3.0, false)
	assert_eq(_lever(1).down, held_before, "while she is away nothing springs up")
	assert_eq(_run._wave_time, wave_time_before, "and the wave does not run")
	_play(0.1, true)
	assert_eq(events, ["waited", "returned"])
	assert_false(_run.is_waiting())


func test_a_run_begun_without_her_waits_until_she_stands_at_the_console() -> void:
	_run.begin(2, false)
	assert_eq(_run.wave, 2)
	var time := _run._wave_time
	_play(10.0, false)
	assert_eq(_run._wave_time, time, "nothing runs without her")
	_play(LoadRun.READY_SECONDS - 0.5, true)
	assert_eq(_run._wave_time, time, "she gets a moment at the console first")
	_play(1.0, true)
	assert_gt(_run._wave_time, time)


func test_nothing_runs_while_anyone_speaks() -> void:
	_run.begin()
	_run.pull(1)
	_play(LoadRun.period(1, 1.0) * 2.0, true, true)
	assert_true(_lever(1).down, "a conversation takes no time")
	assert_eq(_run._wave_time, 0.0)


func test_the_trouble_is_the_share_of_levers_in_use_that_stand_up() -> void:
	_run.begin()
	assert_eq(_run.trouble(), 1.0, "three of three ask")
	for number: int in [1, 2, 3]:
		_run.pull(number)
	assert_eq(_run.trouble(), 0.0, "all held")
	_run.pull(1)  # already held: nothing changes
	_play(LoadRun.period(1, 1.0) + 0.5)
	assert_eq(_run.trouble(), 1.0, "all sprang up")
	var idle := LoadRun.new()
	add_child_autofree(idle)
	assert_eq(idle.trouble(), 0.0, "no load, no trouble")
