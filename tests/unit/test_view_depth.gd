extends GutTest
## Zoom and the depth arc (ADR-043): the real world is drawn larger than Elysia and stays
## crisp at any window size; Elysia is a flat picture, the valley gets haze, mountains
## beyond the treeline that the rain hides, leaves in front, and Mira's look to the
## mountains at the end.

const TAL := preload("res://world/levels/slice/tal.tscn")
const HAUS := preload("res://world/levels/slice/haus.tscn")
const ELYSIA := preload("res://world/levels/slice/elysia.tscn")


func before_each() -> void:
	WorldState.new_game()
	SceneTravel.pending_spawn = ""


func after_each() -> void:
	Settings.set_value("display.parallax", true, false)
	AudioDirector.play_music("silence", 0.0)
	WorldState.new_game()
	SceneTravel.pending_spawn = ""


func _view(zoom: float) -> GameView:
	var view := GameView.new()
	view.set_zoom(zoom)
	add_child_autofree(view)
	return view


func test_zoom_shrinks_the_world_and_scales_its_picture() -> void:
	var view := _view(1.5)
	assert_eq(view.view_size, Vector2i(427, 240), "640x360 / 1.5, rounded up")
	assert_eq(view.viewport.size, Vector2i(429, 242), "plus the border")
	assert_eq(view.display.scale, Vector2(1.5, 1.5))
	assert_eq(
		view.display.texture_filter,
		CanvasItem.TEXTURE_FILTER_LINEAR,
		"between whole numbers the sharp shader samples the texture"
	)
	view.set_zoom(2.0)
	assert_eq(view.view_size, Vector2i(320, 180))
	assert_eq(view.display.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "exact")
	view.set_zoom(7.0)
	assert_eq(view.zoom, 3.0, "clamped")


func test_the_world_picture_is_always_sampled_sharp() -> void:
	var view := _view(1.5)
	var mat := view.display.material as ShaderMaterial
	assert_not_null(mat)
	assert_eq(mat.shader, GameView.SHARP_SHADER)
	view.set_post_material(null)
	assert_eq((view.display.material as ShaderMaterial).shader, GameView.SHARP_SHADER)


func test_the_camera_stays_inside_the_map_when_zoomed() -> void:
	var view := _view(1.5)
	view.bounds = Rect2(0, 0, 800, 600)
	var target := Node2D.new()
	view.world_root.add_child(target)
	view.follow(target)
	await wait_seconds(0.2)
	var half := Vector2(view.view_size) * 0.5
	assert_almost_eq(view.camera_position.x, half.x, 1.0, "left edge, not beyond")
	assert_almost_eq(view.camera_position.y, half.y, 1.0, "top edge, not beyond")


func test_world_positions_map_to_the_ui() -> void:
	var view := _view(1.5)
	view.camera_position = Vector2(300, 200)
	assert_almost_eq(view.world_to_ui(Vector2(300, 200)), Vector2(320, 180), Vector2.ONE)
	assert_almost_eq(
		view.world_to_ui(Vector2(310, 200)) - view.world_to_ui(Vector2(300, 200)),
		Vector2(15, 0),
		Vector2(0.01, 0.01),
		"one world pixel covers 1.5 UI pixels"
	)


func test_the_real_world_is_closer_than_elysia() -> void:
	var elysia: LookScene = ELYSIA.instantiate()
	add_child_autofree(elysia)
	await wait_physics_frames(2)
	assert_eq(elysia.view.zoom, 1.0, "Elysia is wide and flat")
	assert_null(elysia.backdrop, "a picture has no distance")
	assert_null(elysia.foreground)
	elysia.queue_free()
	await wait_physics_frames(1)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	for packed: PackedScene in [TAL, HAUS]:
		var scene: GameScene = packed.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(2)
		assert_eq(scene.view.zoom, 1.5, scene.name)
		scene.queue_free()
		await wait_physics_frames(1)


func test_the_camera_can_look_above_the_valley() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_not_null(tal.backdrop)
	assert_not_null(tal.foreground)
	var map_top := tal.map.world_rect().position.y
	assert_eq(tal.view.bounds.position.y, map_top - tal.backdrop_reach, "sky above the map")
	assert_eq(tal.backdrop.get_index(), 0, "behind everything in the world")


func test_mountains_hide_in_the_rain_and_clear_in_the_evening() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	var day := tal.day_light
	assert_eq(day.preset, "regentag")
	assert_almost_eq(tal.backdrop.clear, float(DayLight.PRESETS["regentag"]["mountains"]), 0.01)
	day.set_preset("abend", 0.0)
	assert_eq(tal.backdrop.clear, 1.0, "the evening shows them")
	var grade := tal.view.display.material as ShaderMaterial
	assert_almost_eq(
		float(grade.get_shader_parameter("depth_haze")),
		float(DayLight.PRESETS["abend"]["depth_haze"]),
		0.001
	)
	assert_true(grade.get_shader_parameter("haze_color") is Vector3, "colors go in as vec3")


func test_crest_turns_ignore_small_wiggles() -> void:
	var heights := PackedFloat32Array([0, 5, 10, 8, 9, 2, 1, 6])
	assert_eq(Backdrop.turns(heights, 3.0), PackedInt32Array([0, 2, 6, 7]))
	assert_eq(Backdrop.turns(PackedFloat32Array([4]), 3.0), PackedInt32Array([0]))


func test_far_ranges_move_less_than_near_ones() -> void:
	var last := 0.0
	for ridge: Array in Backdrop.RIDGES:
		var factor: float = ridge[0]
		assert_gt(factor, last, "ordered far to near")
		assert_lt(factor, 1.0, "slower than the ground")
		last = factor


func test_leaves_in_front_move_faster_than_the_ground() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	var leaves := tal.foreground
	var bottom := tal.map.world_rect().end.y
	var rest := Vector2(200, bottom - ForegroundFoliage.RISE)
	var down := Vector2(200, bottom - tal.view.view_size.y * 0.5)
	assert_eq(leaves.position_for(rest, down), rest, "in place with the camera all the way down")
	var up := leaves.position_for(rest, down - Vector2(0, 100))
	assert_almost_eq(up.y - rest.y, 100.0 * (ForegroundFoliage.FACTOR - 1.0), 0.01, "leave first")
	leaves.parallax = false
	assert_eq(leaves.position_for(rest, down - Vector2(0, 100)), rest, "fixed without parallax")


func test_parallax_can_be_turned_off() -> void:
	assert_true(Settings.get_bool("display.parallax"), "on by default")
	Settings.set_value("display.parallax", false, false)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_false(tal.backdrop.parallax)
	assert_false(tal.foreground.parallax)


func test_mira_looks_to_the_mountains_and_the_camera_follows() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_flag("house.mira_visited")
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	tal.player.global_position = tal.map.cell_to_world(TalScene.FIRE_SEAT)
	await wait_seconds(0.5)
	var before := tal.view.camera_position.y
	WorldState.set_flag("valley.mountains_seen")
	await wait_seconds(TalScene.MOUNTAIN_PAN_SECONDS + 1.0)
	var top := tal.view.bounds.position.y + tal.view.view_size.y * 0.5
	assert_lt(tal.view.camera_position.y, before - 100.0, "up, past the treeline")
	assert_almost_eq(tal.view.camera_position.y, top, 2.0, "all the way up")


func test_the_backdrop_is_only_drawn_while_in_view() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	tal.player.global_position = tal.map.cell_to_world(Vector2i(30, 33))
	tal.view.follow(tal.player)
	await wait_seconds(0.3)
	assert_false(tal.backdrop.is_in_view(), "down by the southern forest the sky is out of view")
	tal.player.global_position = tal.map.cell_to_world(Vector2i(30, 5))
	tal.view.follow(tal.player)
	await wait_seconds(0.3)
	assert_true(tal.backdrop.is_in_view(), "at the northern edge the sky shows")
