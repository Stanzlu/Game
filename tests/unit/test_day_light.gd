extends GutTest
## DayLight: presets drive world tint, grading, lamps, rain and sound.

const TAL := preload("res://world/levels/look_tal.tscn")


func after_each() -> void:
	AudioDirector.play_music("silence", 0.0)


func test_tal_starts_at_night_and_cycles_presets() -> void:
	var scene: LookScene = TAL.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var day := scene.day_light
	assert_not_null(day)
	assert_eq(day.preset, "nacht")
	assert_eq(day.next_preset(0.0), "regentag")
	await wait_physics_frames(2)
	assert_almost_eq(day.world_tint.color.r, 1.0, 0.01, "overcast day is not darkened")
	assert_true(day.rain.is_raining())
	assert_eq(day.next_preset(0.0), "abend")
	await wait_physics_frames(2)
	assert_false(day.rain.is_raining(), "the rain stops in the evening")
	assert_eq(AudioDirector.current, "valley", "music returns in the evening")
	var lamp := get_tree().get_first_node_in_group(&"lamp_props")
	assert_almost_eq(float(lamp.get("light_scale")), 0.7, 0.01)
	var grade := scene.view.display.material as ShaderMaterial
	assert_almost_eq(float(grade.get_shader_parameter("saturation")), 1.1, 0.01)


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
