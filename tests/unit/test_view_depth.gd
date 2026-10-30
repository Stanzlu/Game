extends GutTest
## Zoom and the depth arc (ADR-043, ADR-045): every place is drawn a little closer (1.25)
## and stays crisp at any window size; Elysia is a flat picture, the valley gets haze,
## mountains beyond the treeline that the rain hides, and Mira's look to the mountains at
## the end.

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


func test_the_zoom_can_change_while_the_scene_runs_in_one_step() -> void:
	# the hermit's hut closes in while she stays (ADR-070 O6): 1.5, 1.75, 2.0 and back
	var view := _view(1.5)
	view.bounds = Rect2(0, 0, 800, 600)
	var target := Node2D.new()
	view.world_root.add_child(target)
	target.position = Vector2(400, 300)
	view.follow(target)
	await wait_process_frames(2)
	view.zoom_to(1.75)
	assert_eq(view.zoom, 1.75)
	assert_eq(view.view_size, Vector2i((Vector2(640, 360) / 1.75).ceil()), "366x206")
	assert_eq(view.viewport.size, view.view_size + Vector2i(2, 2), "plus the border")
	assert_eq(view.display.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR, "sharp shader")
	view.zoom_to(2.0)
	assert_eq(view.view_size, Vector2i(320, 180))
	assert_eq(view.display.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "exact")
	var centre := Vector2(400, 300) + GameView.FOLLOW_OFFSET
	assert_almost_eq(view.camera_position, centre, Vector2.ONE, "placed again at once")
	assert_almost_eq(view.world_to_ui(centre), Vector2(320, 180), Vector2.ONE)
	# before any frame the picture is laid out for the new size, never for the old one
	var half := Vector2(view.viewport.size) * 0.5
	assert_eq(view.viewport.canvas_transform.origin, half - view.camera_position)
	assert_eq(
		view.display.position, (-Vector2.ONE * GameView.BORDER - view.camera_remainder) * view.zoom
	)
	# a room smaller than the picture is centred at the new zoom, whatever the old one framed
	view.bounds = Rect2(100, 100, 224, 160)
	view.zoom_to(1.75)
	view.zoom_to(2.0)
	assert_almost_eq(view.camera_position, Vector2(212, 180), Vector2.ONE, "the middle of the room")
	view.zoom_to(1.5)
	assert_eq(view.view_size, Vector2i(427, 240), "the room's own picture, back in the same call")
	var before := view.viewport.size
	view.zoom_to(1.5)
	assert_eq(view.viewport.size, before, "asking for the zoom it has changes nothing")


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


func test_every_place_is_seen_a_little_closer() -> void:
	for packed: PackedScene in [ELYSIA, TAL, HAUS]:
		if packed != ELYSIA:
			WorldState.set_ui_mode(GameState.UiMode.REAL)
		var scene: GameScene = packed.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(2)
		# the interior is seen closer still (ADR-045, exception for rooms)
		var zoom := 1.5 if packed == HAUS else 1.25
		assert_eq(scene.view.zoom, zoom, scene.name)
		assert_eq(
			scene.view.view_size, Vector2i((Vector2(640, 360) / zoom).ceil()), "640x360 / zoom"
		)
		scene.queue_free()
		await wait_physics_frames(1)


func test_elysia_is_a_flat_picture() -> void:
	var elysia: LookScene = ELYSIA.instantiate()
	add_child_autofree(elysia)
	await wait_physics_frames(2)
	assert_null(elysia.backdrop, "a picture has no distance")
	assert_eq(elysia.depth_haze, 0.0, "no haze")


func test_the_camera_can_look_above_the_valley() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_not_null(tal.backdrop)
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


func test_parallax_can_be_turned_off() -> void:
	assert_true(Settings.get_bool("display.parallax"), "on by default")
	Settings.set_value("display.parallax", false, false)
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_false(tal.backdrop.parallax)


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


func test_the_forest_ends_in_a_baked_treeline() -> void:
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var tal: TalScene = TAL.instantiate()
	add_child_autofree(tal)
	await wait_physics_frames(3)
	assert_not_null(tal.treeline, "a silhouette of crowns, not the map's border")
	var top := tal.map.world_rect().position.y
	assert_eq(tal.treeline.position.y, top - LookScene.TREELINE_ABOVE)
	assert_gt(tal.treeline.z_index, -10, "in front of the ground's first rows")
	assert_eq(tal.treeline.texture.get_width(), int(tal.map.world_rect().size.x), "full width")


func test_the_forest_goes_on_behind_the_treeline() -> void:
	var image := (load("res://assets/generated/maps/tal_treeline.png") as Texture2D).get_image()
	assert_eq(image.get_height(), LookScene.TREELINE_ABOVE + 32, "strip reaches up to the far rows")
	var y := LookScene.TREELINE_ABOVE - 20
	for x in range(0, image.get_width(), 8):
		assert_gt(image.get_pixel(x, y).a, 0.5, "no sky between the rows at x=%d" % x)
	var hazy := 0
	for x in image.get_width():
		var a := image.get_pixel(x, LookScene.TREELINE_ABOVE - 36).a
		if a > 0.0 and a < 0.9:
			hazy += 1
	assert_gt(hazy, 0, "the farthest rows let the mist through")


func test_the_stream_comes_from_beyond_the_forest() -> void:
	var path := "res://content/maps/tal.txt"
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
	var water := 0
	for x in data.width:
		if data.surface_at_cell(Vector2i(x, 0)) == &"water":
			water += 1
	assert_gt(water, 0, "the stream reaches the map's northern edge")
