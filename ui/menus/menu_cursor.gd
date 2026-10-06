class_name MenuCursor
extends Control
## The selection marker of a menu list: glides to the focused row and bobs by whole pixels.
## Its look comes from the theme type "MenuCursor" (colors: color, shade; constants: style),
## so it follows the skins: Elysia shows a gold gem, the Real world a short line.

enum Style { ARROW, GEM, DASH }

const ARROW: PackedStringArray = ["x...", "xx..", "xxx.", "xxxx", "xxx.", "xx..", "x..."]
const GEM: PackedStringArray = ["..o..", ".oxo.", "oxhxo", ".oxo.", "..o.."]
const DASH: PackedStringArray = ["xxxx"]
const GLIDE := 28.0

var target: Control
var _time := 0.0


func _ready() -> void:
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(6, 9)


## Jumps instead of gliding (when a menu opens).
func snap() -> void:
	if target != null and is_instance_valid(target):
		global_position = _target_position()


func _process(delta: float) -> void:
	visible = target != null and is_instance_valid(target) and target.is_visible_in_tree()
	if not visible:
		return
	_time += delta
	var goal := _target_position()
	if global_position.distance_to(goal) > 40.0:
		global_position = goal
	else:
		global_position = global_position.lerp(goal, 1.0 - exp(-delta * GLIDE))
	global_position = global_position.round()
	queue_redraw()


func _target_position() -> Vector2:
	var rect := target.get_global_rect()
	var rows := _pattern().size()
	return Vector2(rect.position.x + 4.0, rect.position.y + floorf((rect.size.y - rows) * 0.5))


func _pattern() -> PackedStringArray:
	match get_theme_constant(&"style", &"MenuCursor"):
		Style.GEM:
			return GEM
		Style.DASH:
			return DASH
	return ARROW


func _draw() -> void:
	var color := get_theme_color(&"color", &"MenuCursor")
	var shade := get_theme_color(&"shade", &"MenuCursor")
	var style := get_theme_constant(&"style", &"MenuCursor")
	# Arrow and gem bob by one pixel; the Real dash only breathes.
	var bob := Vector2(float(int(_time * 2.5) % 2), 0.0) if style != Style.DASH else Vector2.ZERO
	if style == Style.DASH:
		color.a *= 0.7 + 0.3 * sin(_time * 3.0)
	var rows := _pattern()
	for y in rows.size():
		for x in rows[y].length():
			var c := rows[y][x]
			if c == ".":
				continue
			var at := bob + Vector2(x, y)
			draw_rect(Rect2(at + Vector2(1, 1), Vector2.ONE), shade)
			var pixel := color
			if c == "o":
				pixel = color.darkened(0.25)
			elif c == "h":
				pixel = color.lightened(0.6)
			draw_rect(Rect2(at, Vector2.ONE), pixel)
