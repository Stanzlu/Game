extends GutTest


## A walker the way the player is for the camera: a position and a velocity.
class Walker:
	extends Node2D
	var velocity := Vector2.ZERO


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


## Camera x (world pixels) as the display shows it: whole part plus the shifted fraction.
func _shown_x(view: GameView) -> float:
	return view.camera_position.x + view.camera_remainder.x


func _walk_and_stop(sharpness: float, settle_ticks: int) -> float:
	var view := GameView.new()
	add_child_autofree(view)
	view.follow_sharpness = sharpness
	var target := Node2D.new()
	view.add_child(target)
	view.follow(target)
	view._process(1.0 / 60.0)
	# one second at walking pace (96 px/s), then standing: how far is the picture from where
	# it will rest 0.2 s after the stop?
	for i in 60:
		target.global_position.x += 1.6
		view._process(1.0 / 60.0)
	for i in settle_ticks:
		view._process(1.0 / 60.0)
	var after_stop := _shown_x(view)
	for i in 60:
		view._process(1.0 / 60.0)
	return absf(_shown_x(view) - after_stop)


func test_the_picture_does_not_slide_on_after_the_figure_stops() -> void:
	var defaults := GameView.new()
	add_child_autofree(defaults)
	var sharpness := defaults.follow_sharpness
	assert_lt(_walk_and_stop(sharpness, 12), 0.5, "default tuning: settled 0.2 s after the stop")
	assert_lt(_walk_and_stop(sharpness, 6), 0.5, "and nearly so after 0.1 s")
	assert_gt(_walk_and_stop(14.0, 6), 0.5, "the old sharpness still slid on")


## Walks a figure at 96 px/s along each leg ({"dir": Vector2, "ticks": int}) and returns the
## biggest distance the picture moved in one frame and the figure's screen x range (UI px).
func _walk_legs(legs: Array[Dictionary]) -> Dictionary:
	var view := GameView.new()
	add_child_autofree(view)
	var target := Walker.new()
	view.add_child(target)
	target.global_position = Vector2(500, 500)
	view.follow(target)
	view._process(1.0 / 60.0)
	var previous := view.camera_position + view.camera_remainder
	var biggest := 0.0
	var seen_x := Vector2(INF, -INF)
	for leg in legs:
		target.velocity = (leg["dir"] as Vector2) * 96.0
		for i: int in leg["ticks"]:
			target.global_position += (leg["dir"] as Vector2) * 1.6
			view._process(1.0 / 60.0)
			var shown := view.camera_position + view.camera_remainder
			biggest = maxf(biggest, shown.distance_to(previous))
			previous = shown
			var x := view.world_to_ui(target.global_position.round()).x
			seen_x = Vector2(minf(seen_x.x, x), maxf(seen_x.y, x))
	return {"step": biggest, "x": seen_x}


func test_the_picture_does_not_jump_when_the_figure_turns_around() -> void:
	# playtest v0.8.0: down, then up made the picture jump (the look-ahead swung over, 7 px a frame)
	var down_up: Array[Dictionary] = [
		{"dir": Vector2.DOWN, "ticks": 60}, {"dir": Vector2.UP, "ticks": 60}
	]
	var result := _walk_legs(down_up)
	assert_lt(result["step"], 3.0, "walking is 1.6 px a frame; turning around adds no jump")
	var left_right: Array[Dictionary] = [
		{"dir": Vector2.LEFT, "ticks": 60}, {"dir": Vector2.RIGHT, "ticks": 60}
	]
	assert_lt(_walk_legs(left_right)["step"], 3.0)


func test_the_figure_keeps_its_place_on_screen_while_walking() -> void:
	var east: Array[Dictionary] = [{"dir": Vector2.RIGHT, "ticks": 120}]
	var seen_x: Vector2 = _walk_legs(east)["x"]
	assert_lt(absf(seen_x.x - 320.0), 6.0, "only the small follow lag, no lead drifting ahead")
	assert_lt(absf(seen_x.y - 320.0), 6.0)
