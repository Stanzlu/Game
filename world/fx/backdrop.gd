class_name Backdrop
extends Node2D
## What lies beyond the valley's northern treeline (ADR-043): a sky and mountain ranges in
## layers that move the slower the farther away they are. In the rain the mist hides them;
## in the evening they are there, the way Mira looks at them at the end. Elysia has none:
## it is a picture, not a place. Drawn in the world viewport, so edges stay pixel art.

## [parallax, height above the treeline, amplitude, shadow, lit, peak spacing, snow, base
## haze], far to near. Light comes from the left (the evening sun): the faces turned to it
## are warm, the others keep the cool blue of the sky. Each range fades into the haze at its
## foot, so the ranges separate the way real ones do.
const RIDGES := [
	[0.16, 92.0, 34.0, Color("#9aaec2"), Color("#d8d3cb"), 74.0, true, 0.75],
	[0.3, 64.0, 24.0, Color("#738aa0"), Color("#a6a69c"), 52.0, false, 0.6],
	[0.48, 38.0, 14.0, Color("#4a616e"), Color("#6f7a6c"), 34.0, false, 0.5],
]
const SKY_TOP := Color("#7d9fc0")
## The horizon: warm, the way the evening haze is.
const SKY_BOTTOM := Color("#efd9c0")
const MIST := Color("#c3cdd0")
const SNOW := Color("#f2efe8")
const SNOW_SHADE := Color("#b6c3d4")
const CANOPY := [Color("#132e20"), Color("#1d4028"), Color("#2c5c30")]
const STEP := 3.0
## Wiggles of the crest smaller than this (px) do not make a face of their own.
const FACE_MIN := 6.0

var view: GameView
## World y of the treeline (the map's top edge) and the backdrop's reach above it.
var top_y := 0.0
var reach := 128.0
var width := 0.0
## 0 = mist hides the mountains (rain), 1 = clear (evening). DayLight blends it.
var clear := 1.0:
	set(value):
		clear = clampf(value, 0.0, 1.0)
		queue_redraw()
## False when the player turned parallax off (Settings "display.parallax").
var parallax := true
var _profiles: Array[PackedFloat32Array] = []
## Per range: the columns where the crest turns (valleys and peaks, alternating).
var _turns: Array[PackedInt32Array] = []
var _canopy: Array[Vector3] = []
var _last_camera := Vector2.INF
var _showing := true


func _init() -> void:
	z_index = -20
	process_priority = 10
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func setup(game_view: GameView, map_rect: Rect2, reach_px := 128.0) -> void:
	view = game_view
	top_y = map_rect.position.y
	reach = reach_px
	width = map_rect.size.x
	var rng := RandomNumberGenerator.new()
	rng.seed = 43
	var span := width + float(GameView.BASE_SIZE.x) * 2.0
	for ridge: Array in RIDGES:
		var heights := PackedFloat32Array()
		var spacing: float = ridge[5]
		var knots := PackedFloat32Array()
		var fine := PackedFloat32Array()
		for i in int(span / spacing) + 3:
			knots.append(rng.randf())
		for i in int(span / (spacing * 0.37)) + 3:
			fine.append(rng.randf())
		for i in int(span / STEP) + 2:
			var x := i * STEP
			# ridged noise: sharp peaks and saddles, mountains rather than hills
			var big := 1.0 - absf(2.0 * _value(knots, x / spacing) - 1.0)
			var small := _value(fine, x / (spacing * 0.37))
			var n := big * 0.78 + small * 0.22
			heights.append(float(ridge[1]) + float(ridge[2]) * (2.0 * n - 1.0))
		_profiles.append(heights)
		_turns.append(turns(heights, FACE_MIN))
	# the treeline: crowns of the forest at the map's top edge, fixed to the ground
	var x := -8.0
	while x < width + 8.0:
		var radius := rng.randf_range(6.0, 11.0)
		_canopy.append(Vector3(x, top_y + rng.randf_range(1.0, 5.0), radius))
		x += rng.randf_range(radius * 0.8, radius * 1.4)


## Smooth 1D value noise over `knots` (0..1) at position `t` (in knot spacings).
static func _value(knots: PackedFloat32Array, t: float) -> float:
	var i := int(floorf(t))
	var f := t - i
	f = f * f * (3.0 - 2.0 * f)
	return lerpf(
		knots[clampi(i, 0, knots.size() - 1)], knots[clampi(i + 1, 0, knots.size() - 1)], f
	)


## Indices where `heights` turns from rising to falling or back, ignoring wiggles smaller than
## `threshold`; starts with 0 and ends with the last index.
static func turns(heights: PackedFloat32Array, threshold: float) -> PackedInt32Array:
	var result := PackedInt32Array([0])
	if heights.size() < 2:
		return result
	var rising := heights[1] >= heights[0]
	var extreme := 0
	for i in range(1, heights.size()):
		var beyond := heights[i] >= heights[extreme] if rising else heights[i] <= heights[extreme]
		if beyond:
			extreme = i
		elif absf(heights[extreme] - heights[i]) > threshold:
			result.append(extreme)
			rising = not rising
			extreme = i
	if result[result.size() - 1] != heights.size() - 1:
		result.append(heights.size() - 1)
	return result


func _process(_delta: float) -> void:
	if view == null or view.camera_position == _last_camera:
		return
	_last_camera = view.camera_position
	# redrawn only while it is in view (and once more to clear it when it leaves)
	var showing := is_in_view()
	if showing or _showing:
		queue_redraw()
	_showing = showing


## True when the camera sees anything above the treeline.
func is_in_view() -> bool:
	return view != null and view.camera_position.y - view.view_size.y * 0.5 < top_y + 8.0


func _draw() -> void:
	if not is_in_view():
		return
	var cam := view.camera_position
	var half := Vector2(view.view_size) * 0.5
	var left := cam.x - half.x - 4.0
	var right := cam.x + half.x + 4.0
	var sky_top := top_y - reach
	draw_polygon(
		PackedVector2Array(
			[
				Vector2(left, sky_top),
				Vector2(right, sky_top),
				Vector2(right, top_y + 8.0),
				Vector2(left, top_y + 8.0)
			]
		),
		PackedColorArray([SKY_TOP, SKY_TOP, SKY_BOTTOM, SKY_BOTTOM])
	)
	for r in RIDGES.size():
		_draw_ridge(r, cam, left, right)
	# mist in front of the mountains, behind the trees
	if clear < 1.0:
		var mist := Color(MIST, (1.0 - clear) * 0.92)
		draw_rect(Rect2(left, sky_top, right - left, reach + 8.0), mist)
	for crown in _canopy:
		var c := Vector2(crown.x, crown.y)
		if c.x < left - crown.z or c.x > right + crown.z:
			continue
		draw_circle(c.round(), crown.z, CANOPY[0])
		draw_circle((c + Vector2(-1, -2)).round(), crown.z * 0.7, CANOPY[1])
		draw_circle((c + Vector2(-2, -4)).round(), crown.z * 0.35, CANOPY[2])


## One mountain range: far ranges barely move with the camera (they are far away).
func _draw_ridge(index: int, cam: Vector2, left: float, right: float) -> void:
	var ridge: Array = RIDGES[index]
	var f: float = ridge[0] if parallax else 1.0
	# the range sits where it was drawn when the camera is at the left of the valley; it
	# shifts with the camera by (1 - f) of its movement
	var shift := cam.x * (1.0 - f) - float(GameView.BASE_SIZE.x)
	var heights := _profiles[index]
	var first := maxi(int((left - shift) / STEP) - 1, 0)
	var last := mini(int((right - shift) / STEP) + 2, heights.size() - 1)
	if last - first < 1:
		return
	var base := top_y + 8.0
	var points := PackedVector2Array()
	for i in range(first, last + 1):
		points.append(_crest(heights, i, shift))
	points.append(Vector2(points[points.size() - 1].x, base))
	points.append(Vector2(points[0].x, base))
	draw_colored_polygon(points, ridge[3])
	# the faces turned to the light: from a valley up to the peak, then down the peak's
	# spine, which leans away from the light, and straight back to the valley
	var bends := _turns[index]
	var lit_columns := PackedByteArray()
	lit_columns.resize(last - first + 1)
	for k in bends.size() - 1:
		var a := bends[k]
		var b := bends[k + 1]
		if heights[b] <= heights[a] or b < first or a > last:
			continue
		var face := PackedVector2Array()
		for i in range(a, b + 1):
			face.append(_crest(heights, i, shift))
			if i >= first and i <= last:
				lit_columns[i - first] = 1
		# the face narrows into the valley it rises from, like a pyramid's side
		var peak := face[face.size() - 1]
		face.append(Vector2(peak.x + (b - a) * STEP * 0.3, base).round())
		draw_colored_polygon(face, ridge[4])
	if ridge[6]:
		var snow_line: float = float(ridge[1]) + float(ridge[2]) * 0.35
		for i in range(first, last + 1):
			if heights[i] > snow_line:
				var cap := minf((heights[i] - snow_line) * 0.6, 8.0)
				var white := SNOW if lit_columns[i - first] == 1 else SNOW_SHADE
				draw_rect(Rect2(_crest(heights, i, shift), Vector2(STEP, cap)), white)
	# the foot of the range disappears in the haze
	var haze_top := top_y - float(ridge[1]) * 0.6
	var haze := Color(SKY_BOTTOM, ridge[7])
	draw_polygon(
		PackedVector2Array(
			[
				Vector2(left, haze_top),
				Vector2(right, haze_top),
				Vector2(right, base),
				Vector2(left, base)
			]
		),
		PackedColorArray([Color(haze, 0.0), Color(haze, 0.0), haze, haze])
	)


func _crest(heights: PackedFloat32Array, i: int, shift: float) -> Vector2:
	return Vector2(shift + i * STEP, top_y - heights[i]).round()
