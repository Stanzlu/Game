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
const COLOR := Color(1.0, 0.86, 0.58)
const ALPHA := 0.13

var strength := 0.0:
	set(value):
		strength = clampf(value, 0.0, 1.0)
		visible = strength > 0.005
var _time := 0.0


func _ready() -> void:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = additive
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	visible = strength > 0.005


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	# the low sun itself, just off screen at the top left: a wide warm glow
	var glow := Color(COLOR, 0.16 * strength)
	for r: float in [260.0, 190.0, 120.0]:
		draw_circle(Vector2(-60.0, -80.0), r, Color(glow, glow.a * (1.0 - r / 320.0)))
	var dir := SLANT.normalized() * LENGTH
	for i in BEAMS.size():
		var beam: Array = BEAMS[i]
		var x0 := float(beam[0]) + 6.0 * sin(_time * 0.07 + i)
		var width := float(beam[1])
		var breath := 0.75 + 0.25 * sin(_time * 0.23 + i * 1.7)
		var top := Color(COLOR, ALPHA * float(beam[2]) * breath * strength)
		var bottom := Color(COLOR, 0.0)
		var a := Vector2(x0, -10.0)
		var b := Vector2(x0 + width, -10.0)
		draw_polygon(
			PackedVector2Array([a, b, b + dir, a + dir]),
			PackedColorArray([top, top, bottom, bottom])
		)
