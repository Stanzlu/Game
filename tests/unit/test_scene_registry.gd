extends GutTest
## SceneRegistry: the one place that lists the scenes (smoke runs, performance test).


func test_every_registered_scene_is_smoked() -> void:
	for key: String in SceneRegistry.SCENES:
		assert_true(key in SceneRegistry.SMOKE, "scene '%s' is not in SceneRegistry.SMOKE" % key)


func test_the_smoke_and_benchmark_lists_name_registered_scenes_once() -> void:
	for list: PackedStringArray in [SceneRegistry.SMOKE, SceneRegistry.BENCHMARK]:
		var seen := {}
		for key in list:
			assert_true(SceneRegistry.has(key), "'%s' is not registered" % key)
			assert_false(seen.has(key), "'%s' twice" % key)
			seen[key] = true


func test_the_performance_test_walks_the_registry_list() -> void:
	assert_eq(BenchmarkRunner.SCENES, SceneRegistry.BENCHMARK)
	assert_gt(SceneRegistry.BENCHMARK.size(), 3)


func test_every_scene_in_the_lists_has_a_place_name() -> void:
	# save slots and the performance report show it
	for key in SceneRegistry.BENCHMARK:
		var title := TranslationServer.translate(SceneRegistry.title_key(key))
		assert_ne(String(title), SceneRegistry.title_key(key), "PLACE_ name of '%s'" % key)
