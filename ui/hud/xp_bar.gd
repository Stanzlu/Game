class_name XpBar
extends Control
## Elysia's XP bar: gold rim, banded fill, a highlight that sweeps across every few seconds
## (everything in Elysia shines). The fill glides to its value; a level-up fills it to the
## end, flashes and starts again from zero. Drawn in whole pixels.

const RIM := Color(1, 0.84, 0.4)
const RIM_DARK := Color(0.55, 0.32, 0.1)
const INK := Color(0.16, 0.06, 0.14)
const BACK := Color(0.2, 0.12, 0.3)
const FILL := Color(1, 0.8, 0.3)
const FILL_TOP := Color(1, 0.95, 0.7)
const FILL_LOW := Color(0.88, 0.55, 0.16)
const SHINE_EVERY := 3.2

## Target fill 0..1.
var ratio := 0.0
var _shown := 0.0
var _flash := 0.0
var _time := 0.0
var _wraps := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(88, 8)


## Sets the fill; `levels` > 0 runs the bar to the end that many times first.
func set_ratio(value: float, levels := 0, instant := false) -> void:
	ratio = clampf(value, 0.0, 1.0)
	_wraps = levels
	if instant:
		_shown = ratio
		_wraps = 0
	queue_redraw()


func shown_ratio() -> float:
	return _shown


func _process(delta: float) -> void:
	_time += delta
	var goal := 1.0 if _wraps > 0 else ratio
	_shown = move_toward(_shown, goal, delta * 1.6)
	if _wraps > 0 and _shown >= 1.0:
		_wraps -= 1
		_shown = 0.0
		_flash = 1.0
	_flash = maxf(_flash - delta * 3.0, 0.0)
	queue_redraw()


func _draw() -> void:
	var w := floorf(size.x)
	var h := floorf(size.y)
	draw_rect(Rect2(0, 0, w, h), INK)
	draw_rect(Rect2(1, 0, w - 2, 1), RIM)
	draw_rect(Rect2(0, 1, 1, h - 2), RIM)
	draw_rect(Rect2(1, h - 1, w - 2, 1), RIM_DARK)
	draw_rect(Rect2(w - 1, 1, 1, h - 2), RIM_DARK)
	var inner := Rect2(2, 2, w - 4, h - 4)
	draw_rect(inner, BACK)
	var fill_w := floorf(inner.size.x * _shown)
	if fill_w > 0:
		var fill := Rect2(inner.position, Vector2(fill_w, inner.size.y))
		draw_rect(fill, FILL.lerp(Color.WHITE, _flash))
		draw_rect(Rect2(fill.position, Vector2(fill_w, 1)), FILL_TOP)
		draw_rect(Rect2(fill.position + Vector2(0, fill.size.y - 1), Vector2(fill_w, 1)), FILL_LOW)
		# the sweeping highlight: a 2px slanted band
		var phase := fmod(_time, SHINE_EVERY) / 0.8
		if phase < 1.0:
			var x := floorf(phase * (fill_w + 6.0)) - 3.0
			for row in int(fill.size.y):
				var px := x + row
				if px >= 0 and px < fill_w - 1:
					draw_rect(
						Rect2(fill.position + Vector2(px, row), Vector2(2, 1)), Color(1, 1, 1, 0.75)
					)
