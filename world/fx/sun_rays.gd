class_name SunRays
extends Node2D
## Soft beams of low evening light falling in from the top left (ADR-041): after the rain
## the sun comes through, warm and slanted. Screen space, additive, a few wide beams that
## breathe slowly. DayLight fades `strength` in for the evening and out for rain and night.

## [x where the beam starts on the top edge, width in pixels, brightness]
const BEAMS: Array[Array] = [
	[-140.0, 70.0, 1.0],
	[-20.0, 36.0, 0.6],
	[70.0, 96.0, 0.85],
	[230.0, 48.0, 0.55],
	[330.0, 80.0, 0.7],
]
const SLANT := Vector2(0.62, 1.0)
const LENGTH := 520.0
const COLOR := Color(1.0, 0.84, 0.52)
const ALPHA := 0.18

var strength := 0.0:
	set(value):
		strength = clampf(value, 0.0, 1.0)
		visible = strength > 0.005
## When set, the beams start at this world y (the map's top edge): they belong to the
## meadow and would only stripe the sky and the mountains above it.
var view: GameView
var world_top := NAN
var _time := 0.0
var _glow: GradientTexture2D


func _ready() -> void:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	visible = strength > 0.005
	# the low sun: one soft radial glow (three stacked circles read as hard rings)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	gradient.colors = PackedColorArray([Color(COLOR, 1.0), Color(COLOR, 0.35), Color(COLOR, 0.0)])
	_glow = GradientTexture2D.new()
	_glow.gradient = gradient
	_glow.fill = GradientTexture2D.FILL_RADIAL
	_glow.fill_from = Vector2(0.5, 0.5)
	_glow.fill_to = Vector2(1.0, 0.5)
	_glow.width = 128
	_glow.height = 128


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	# the low sun itself, just off screen at the top left: a wide warm glow
	draw_texture_rect(
		_glow,
		Rect2(Vector2(-60.0, -80.0) - Vector2(300, 300), Vector2(600, 600)),
		false,
		Color(1, 1, 1, 0.14 * strength)
	)
	var dir := SLANT.normalized() * LENGTH
	var start_y := _start_y()
	var shift := Vector2(SLANT.x / SLANT.y, 1.0) * (start_y + 10.0)
	for i in BEAMS.size():
		var beam: Array = BEAMS[i]
		var x0 := float(beam[0]) + 6.0 * sin(_time * 0.07 + i)
		var width := float(beam[1])
		var breath := 0.75 + 0.25 * sin(_time * 0.23 + i * 1.7)
		var top := Color(COLOR, ALPHA * float(beam[2]) * breath * strength)
		var a := Vector2(x0, -10.0) + shift
		_draw_feathered_beam(a, width, dir, top)


## A beam whose long edges fade out (a quarter of its width on each side), so it reads as
## light in the air and not as a cut strip.
func _draw_feathered_beam(a: Vector2, width: float, dir: Vector2, top: Color) -> void:
	var clear := Color(top, 0.0)
	var edge := width * 0.25
	var xs := [0.0, edge, width - edge, width]
	var tops := [clear, top, top, clear]
	for k in 3:
		var p0 := a + Vector2(xs[k], 0.0)
		var p1 := a + Vector2(xs[k + 1], 0.0)
		draw_polygon(
			PackedVector2Array([p0, p1, p1 + dir, p0 + dir]),
			PackedColorArray([tops[k], tops[k + 1], clear, clear])
		)


func _start_y() -> float:
	if view == null or is_nan(world_top):
		return -10.0
	var screen_top := world_top - view.camera_position.y + view.viewport.size.y * 0.5
	return maxf(-10.0, screen_top)
