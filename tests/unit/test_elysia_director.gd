extends GutTest
## ElysiaDirector: one clock and one set of stages for every Elysia scene (plan 4.6).


func before_each() -> void:
	WorldState.new_game()


func after_all() -> void:
	WorldState.new_game()


func _scene() -> Node:
	var scene := Node.new()
	add_child_autofree(scene)
	return scene


func test_attach_adds_one_director_and_returns_it_again() -> void:
	var scene := _scene()
	var director := ElysiaDirector.attach(scene)
	assert_eq(ElysiaDirector.attach(scene), director)
	assert_eq(
		scene.get_children().filter(func(c: Node) -> bool: return c is ElysiaDirector).size(), 1
	)


func test_nothing_is_earned_at_the_start() -> void:
	ElysiaDirector.attach(_scene())
	assert_eq(ElysiaDirector.stage(), 0)
	assert_false(WorldState.has_flag(ElysiaDirector.stage_flag(1)))
	assert_false(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))


func test_the_market_and_the_stone_earn_the_music_stages() -> void:
	ElysiaDirector.attach(_scene())
	WorldState.set_flag("elysia.chest_tree_opened")
	await wait_process_frames(2)
	assert_eq(ElysiaDirector.stage(), 0, "the chest alone does not shrink the loop any more")
	WorldState.set_flag("elysia.market_seen")
	await wait_process_frames(2)
	assert_true(WorldState.has_flag(ElysiaDirector.stage_flag(1)))
	assert_false(WorldState.has_flag(ElysiaDirector.stage_flag(2)))
	assert_eq(ElysiaDirector.stage(), 1)
	WorldState.set_flag("elysia.stone_taken")
	await wait_process_frames(2)
	assert_eq(ElysiaDirector.stage(), 2)


func test_play_time_earns_them_for_someone_who_dawdles() -> void:
	ElysiaDirector.attach(_scene())
	var stages := AudioDirectorService.ELYSIA_STAGES
	WorldState.state.playtime_seconds = float(stages[1]["after"]) + 10.0
	await wait_process_frames(2)
	assert_eq(ElysiaDirector.stage(), 1, "twenty minutes")
	WorldState.state.playtime_seconds = float(stages[2]["after"]) + 10.0
	await wait_process_frames(2)
	assert_eq(ElysiaDirector.stage(), 2, "forty minutes")


func test_the_sentences_start_by_the_clock_in_any_elysia_scene() -> void:
	ElysiaDirector.attach(_scene())
	WorldState.state.playtime_seconds = ElysiaDirector.LOOPS_AFTER + 1.0
	await wait_process_frames(2)
	assert_true(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))
	assert_eq(ElysiaDirector.stage(), 3)


func test_the_rift_opens_by_the_clock_and_says_so() -> void:
	var director := ElysiaDirector.attach(_scene())
	watch_signals(director)
	WorldState.state.playtime_seconds = ElysiaDirector.LOOPS_AFTER + 1.0
	WorldState.set_flag(ElysiaDirector.LOOPS_FLAG)
	await wait_process_frames(2)
	assert_false(WorldState.has_flag(ElysiaDirector.RIFT_FLAG), "not before the wait is over")
	WorldState.state.playtime_seconds += ElysiaDirector.RIFT_AFTER_LOOPS + 1.0
	await wait_process_frames(2)
	assert_true(WorldState.has_flag(ElysiaDirector.RIFT_FLAG))
	assert_signal_emitted(director, "rift_opened")


func test_a_save_from_before_the_stage_flags_catches_up_on_load() -> void:
	WorldState.set_flag("elysia.market_seen")
	WorldState.set_flag("elysia.stone_taken")
	ElysiaDirector.attach(_scene())
	assert_true(WorldState.has_flag(ElysiaDirector.stage_flag(1)))
	assert_true(WorldState.has_flag(ElysiaDirector.stage_flag(2)))


func test_the_toast_starts_the_sentences_in_any_elysia_scene_and_the_beat_once() -> void:
	ElysiaDirector.attach(_scene())
	assert_false(Beat.reached("irritation"))
	WorldState.set_flag(ElysiaDirector.FEAST_FLAG)
	await wait_process_frames(2)
	assert_true(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))
	assert_eq(ElysiaDirector.stage(), 3)
	assert_true(Beat.reached("irritation"))


func test_a_save_from_the_feast_starts_the_sentences_on_load() -> void:
	WorldState.set_flag(ElysiaDirector.FEAST_FLAG)
	ElysiaDirector.attach(_scene())
	assert_true(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))


func test_the_clock_waits_longer_than_act_one_takes() -> void:
	# Act I is 30 to 45 minutes (docs/akt1/REGIONSBRIEFE.md): nothing starts by the clock inside it
	ElysiaDirector.attach(_scene())
	WorldState.state.playtime_seconds = 45.0 * 60.0
	await wait_process_frames(2)
	assert_false(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG), "not within Act I")
	assert_lt(ElysiaDirector.stage(), 3)


func test_beginning_the_loops_twice_changes_nothing() -> void:
	var director := ElysiaDirector.attach(_scene())
	director.begin_loops()
	director.begin_loops()
	assert_true(WorldState.has_flag(ElysiaDirector.LOOPS_FLAG))


func test_the_music_follows_the_stage_flag_too() -> void:
	var never := func(_flag: String) -> bool: return false
	var by_flag := func(flag: String) -> bool: return flag == ElysiaDirector.stage_flag(2)
	assert_eq(AudioDirectorService.elysia_stage_for(0.0, never), 0)
	assert_eq(AudioDirectorService.elysia_stage_for(0.0, by_flag), 2)
