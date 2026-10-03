extends GutTest


func test_pixel_mode_rounds_and_has_no_remainder() -> void:
	var parts := CameraMath.split(Vector2(10.6, -3.4), false)
	assert_eq(parts[0], Vector2(11, -3))
	assert_eq(parts[1], Vector2.ZERO)


func test_smooth_mode_keeps_remainder_between_zero_and_one() -> void:
	var parts := CameraMath.split(Vector2(10.6, -3.4), true)
	assert_eq(parts[0], Vector2(10, -4))
	assert_almost_eq(parts[1].x, 0.6, 0.0001)
	assert_almost_eq(parts[1].y, 0.6, 0.0001)


func test_smoothing_is_frame_rate_independent() -> void:
	var a := Vector2.ZERO
	for i in 60:
		a = CameraMath.smooth_toward(a, Vector2(100, 0), 10.0, 1.0 / 60.0)
	var b := Vector2.ZERO
	for i in 144:
		b = CameraMath.smooth_toward(b, Vector2(100, 0), 10.0, 1.0 / 144.0)
	assert_almost_eq(a.x, b.x, 0.01)


func test_clamp_keeps_view_inside_and_centers_small_maps() -> void:
	var half := Vector2(320, 180)
	var big := Rect2(0, 0, 1280, 720)
	assert_eq(CameraMath.clamp_to_bounds(Vector2(0, 0), half, big), Vector2(320, 180))
	assert_eq(CameraMath.clamp_to_bounds(Vector2(2000, 900), half, big), Vector2(960, 540))
	var small := Rect2(0, 0, 320, 200)
	assert_eq(CameraMath.clamp_to_bounds(Vector2(50, 50), half, small), Vector2(160, 100))
