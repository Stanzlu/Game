extends GutTest
## DayLight: presets drive world tint, grading, lamps, rain and sound.

const TAL := preload("res://world/levels/look_tal.tscn")


func before_each() -> void:
	WorldState.new_game()


func after_each() -> void:
	AudioDirector.play_music("silence", 0.0)
	WorldState.new_game()


## The slice arrives in rain and wind and reaches the evening later (Game Bible §56).
func test_tal_starts_on_a_rainy_day_and_cycles_presets() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var day := scene.day_light
	assert_not_null(day)
	assert_eq(day.preset, "regentag")
	# soft summer rain (ADR-041): a touch cooler, but the valley stays bright and green
	assert_gt(day.world_tint.color.get_luminance(), 0.9, "overcast day is not darkened")
	assert_lt(day.world_tint.color.r, day.world_tint.color.b, "only cooler")
	assert_true(day.rain.is_raining())
	assert_eq(AudioDirector.ambience_stream.resource_path.get_file(), "tal_regentag.tres")
	assert_eq(day.next_preset(0.0), "abend")
	await wait_physics_frames(2)
	assert_false(day.rain.is_raining(), "the rain stops in the evening")
	assert_eq(AudioDirector.current, "valley", "music returns in the evening")
	var lamp := get_tree().get_first_node_in_group(&"lamp_props")
	assert_almost_eq(float(lamp.get("light_scale")), 0.7, 0.01)
	var grade := scene.view.display.material as ShaderMaterial
	assert_almost_eq(
		float(grade.get_shader_parameter("saturation")),
		float(DayLight.PRESETS["abend"]["saturation"]),
		0.01
	)
	assert_eq(day.next_preset(0.0), "nacht")
	await wait_physics_frames(2)
	assert_lt(day.world_tint.color.b, 0.9, "night darkens the valley")


## The rain grade stays cool and rich (ADR-041): the audit measured the baked warm ground
## turning grey-green under a green-lifting shadow tint and a thick mist.
func test_the_rainy_day_is_cool_and_rich_not_grey() -> void:
	var rain: Dictionary = DayLight.PRESETS["regentag"]
	var shadow: Color = rain["shadow_tint"]
	assert_lt(shadow.g, 0.03, "no green lift in the shadows")
	assert_gt(shadow.b, shadow.r, "the shadows lean blue")
	assert_lte(float(rain["depth_haze"]), 0.12, "a thin mist")
	assert_gte(float(rain["saturation"]), 1.0, "the colours are not drained")
	var haze: Color = rain["haze_color"]
	assert_gt(haze.get_luminance(), 0.8, "the mist is light, not a grey veil")


## The evening's warm tint and grade multiply the sky: its blue has to be chosen so that it
## still arrives cool at the top (the audit measured grey-beige there).
func test_the_evening_sky_arrives_cool_and_the_backdrop_follows_the_preset() -> void:
	var evening: Dictionary = DayLight.PRESETS["abend"]
	var tint: Color = evening["world_tint"]
	var grade_tint: Color = evening["tint"]
	var top: Color = evening["sky_top"]
	var seen := Color(
		top.r * tint.r * grade_tint.r, top.g * tint.g * grade_tint.g, top.b * tint.b * grade_tint.b
	)
	assert_gt(seen.b, seen.r + 0.15, "cool at the top, not beige")
	var scene: LookScene = load("res://world/levels/slice/tal.tscn").instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	scene.day_light.set_preset("abend", 0.0)
	assert_not_null(scene.backdrop, "the slice valley has mountains behind it")
	assert_eq(scene.backdrop.sky_top, top)
	assert_eq(scene.backdrop.sky_bottom, evening["sky_bottom"])


func test_unknown_preset_is_refused() -> void:
	var day := DayLight.new()
	add_child_autofree(day)
	day.set_preset("polarnacht", 0.0)
	assert_push_error("unknown day light preset")
	assert_eq(day.preset, "")


func test_elysia_has_no_day_light() -> void:
	var scene: LookScene = load("res://world/levels/look_elysia.tscn").instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(2)
	assert_null(scene.day_light, "Elysia's light never changes")


func test_resting_on_the_bench_lets_time_pass() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var bench: Node = null
	for node in scene.find_children("*", "StaticBody2D", true, false):
		if node.get("pass_time") == true:
			bench = node
	assert_not_null(bench, "Tal has a bench that passes time")
	(bench.get_node("Interactable") as Interactable).interact(scene.player)
	assert_eq(scene.player.state, Player.State.SIT)
	await wait_seconds(2.8)
	assert_eq(scene.day_light.preset, "abend", "the rainy day turns into evening")


func test_sitting_down_twice_passes_time_only_once() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var bench: Node = null
	for node in scene.find_children("*", "StaticBody2D", true, false):
		if node.get("pass_time") == true:
			bench = node
	var seat := bench.get_node("Interactable") as Interactable
	seat.interact(scene.player)
	await wait_seconds(1.0)
	scene.player.stand_up()
	seat.interact(scene.player)
	await wait_seconds(3.2)
	assert_eq(scene.day_light.preset, "abend", "one rest, one step")


func test_time_of_day_is_kept_in_the_game_state() -> void:
	WorldState.set_day_preset("abend")
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_eq(scene.day_light.preset, "abend", "a loaded evening stays evening")
	scene.day_light.next_preset(0.0)
	assert_eq(WorldState.day_preset(), "nacht")


func test_entering_in_the_evening_switches_music_once() -> void:
	AudioDirector.play_music("silence", 0.0)
	WorldState.set_day_preset("abend")
	var changes: Array[String] = []
	var record := func(track: String) -> void: changes.append(track)
	AudioDirector.music_changed.connect(record)
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	var first: Resource = AudioDirector.ambience_stream
	assert_eq(
		first.resource_path if first != null else "",
		DayLight.PRESETS["abend"]["ambience"],
		"the evening's ambience from the first frame, not the rainy day's first"
	)
	await wait_physics_frames(4)
	AudioDirector.music_changed.disconnect(record)
	assert_eq(changes, ["valley"] as Array[String], "the evening's music from the start")
	assert_eq(scene.day_light.preset, "abend")


func test_steady_lamps_follow_the_day_too() -> void:
	var lamp := Decor.new()
	add_child_autofree(lamp)
	lamp._add_light({"energy": 2.0})
	lamp.light_scale = 0.5
	assert_almost_eq(lamp.lights[0].energy, 1.0, 0.001, "a lamp without flicker is dimmed by day")
	lamp._add_light({"energy": 1.0})
	assert_almost_eq(lamp.lights[1].energy, 0.5, 0.001, "and one added later as well")
