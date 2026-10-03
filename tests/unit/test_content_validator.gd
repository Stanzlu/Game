extends GutTest
## The content validator: real content is clean, and each rule catches its problem.

const ContentFixtures := preload("res://tests/unit/content_fixtures.gd")


func _yes(_key: String) -> bool:
	return true


func _no(_key: String) -> bool:
	return false


func after_each() -> void:
	ContentDB.reload()


func test_real_content_has_no_problems() -> void:
	ContentDB.reload()
	assert_eq(ContentValidator.validate_all(), PackedStringArray())
	assert_true(ContentDB.has_quest("side_sandbox_gate"))
	assert_true(ContentDB.has_item("curiosity_tiny_spoon"))


func test_well_formed_quest_passes() -> void:
	var problems := ContentValidator.validate_quest(
		ContentFixtures.quest(), "res://q/side_test.tres", _yes
	)
	assert_eq(problems, PackedStringArray())


func test_broken_quest_reports_each_problem() -> void:
	var q := QuestDef.new()
	q.id = "test_broken"
	q.stages = [
		ContentFixtures.stage("start", ["ghost"]),
		ContentFixtures.stage("lonely", [], ""),
		ContentFixtures.stage("start", [], "done"),
	]
	var text := "\n".join(ContentValidator.validate_quest(q, "res://q/other.tres", _no))
	for expected: String in [
		"must be main_",
		"file name must match",
		"missing translation QUEST_TEST_BROKEN_TITLE",
		"duplicate stage 'start'",
		"final stages need an outcome",
		"unknown stage 'ghost'",
		"'lonely' is unreachable",
	]:
		assert_string_contains(text, expected)


func test_item_rules() -> void:
	var good := ContentFixtures.item("item_stone")
	assert_eq(ContentValidator.validate_item(good, "res://i/item_stone.tres", _yes).size(), 0)
	var bad := ContentFixtures.item("spoon", ItemDef.Kind.CURIOSITY)
	var text := "\n".join(ContentValidator.validate_item(bad, "res://i/item_spoon.tres", _no))
	assert_string_contains(text, "must start with curiosity_")
	assert_string_contains(text, "file name must match")
	assert_string_contains(text, "missing translation SPOON_NAME")


func test_dialogue_lines_need_unique_static_ids() -> void:
	var seen := {}
	var first := "~ a\nMira: Eins. [ID:t_one]\nMira: Zwei.\n=> END\n"
	var problems := ContentValidator.validate_dialogue(first, "res://d.dialogue", seen)
	assert_eq(problems, PackedStringArray(["res://d.dialogue:3: line has no [ID:...]"]))
	var second := "~ b\nMira: Noch mal. [ID:t_one]\n=> END\n"
	problems = ContentValidator.validate_dialogue(second, "res://e.dialogue", seen)
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0].to_lower(), "already", "duplicate across files")


func test_fake_choices_are_found() -> void:
	var fake := "~ a\nMira: Tee? [ID:f1]\n- Ja [ID:f2]\n- Nein [ID:f3]\nMira: Gut. [ID:f4]\n=> END\n"
	var problems := ContentValidator.validate_dialogue(fake, "res://f.dialogue", {})
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "fake choice")
	var real := (
		"~ a\nMira: Tee? [ID:r1]\n- Ja [ID:r2]\n\tMira: Gut. [ID:r3]\n- Nein [ID:r4]\n"
		+ '\tdo WorldState.set_flag("valley.no_tea")\n=> END\n'
	)
	assert_eq(ContentValidator.validate_dialogue(real, "res://r.dialogue", {}).size(), 0)


func test_world_state_calls_are_checked() -> void:
	ContentFixtures.use()
	var text := (
		"~ a\nMira: Hm. [ID:w1]\n"
		+ 'do WorldState.start_quest("side_nope")\n'
		+ 'do WorldState.advance_quest("side_test", "later")\n'
		+ 'do WorldState.add_item("item_nope")\n'
		+ 'do WorldState.set_relationship("mira", "besties")\n'
		+ 'do WorldState.set_flag("no_namespace")\n'
		+ 'do WorldState.set_facet("bravery")\n'
		+ "do WorldState.explode()\n"
		+ 'do WorldState.start_quest("side_test")\n=> END\n'
	)
	var problems := ContentValidator.validate_dialogue(text, "res://w.dialogue", {})
	var joined := "\n".join(problems)
	assert_eq(problems.size(), 7, joined)
	for expected: String in [
		"w.dialogue:3: unknown quest 'side_nope'",
		"has no stage 'later'",
		"unknown item 'item_nope'",
		"unknown relationship state 'besties'",
		"needs a namespace",
		"unknown facet 'bravery'",
		"no method 'explode'",
	]:
		assert_string_contains(joined, expected)


func test_compile_errors_are_reported_with_line() -> void:
	var problems := ContentValidator.validate_dialogue("~ a\n=> nowhere\n", "res://e.dialogue", {})
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "res://e.dialogue:2:")
	assert_string_contains(problems[0], "Unknown cue")


func test_runtime_env_isolates_test_runs() -> void:
	assert_true(RuntimeEnv.is_test_run())
	assert_eq(RuntimeEnv.user_dir(), "user://profiles/test/")
	assert_eq(RuntimeEnv.profile_from_args(["--profile=smoke"]), "smoke")
	assert_eq(RuntimeEnv.profile_from_args(["--profile=../x"]), "")
