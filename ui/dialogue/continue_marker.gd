class_name ContinueMarker
extends Control
## Small "more" triangle in the corner of the dialogue box; bobs by whole pixels while the
## line waits for the player. Colours from theme type "MenuCursor" (follows the skins).

const SHAPE: PackedStringArray = ["xxxxx", ".xxx.", "..x.."]

var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(6, 5)


func _process(delta: float) -> void:
	if is_visible_in_tree():
		_time += delta
		queue_redraw()


func _draw() -> void:
	var color := get_theme_color(&"color", &"MenuCursor")
	var shade := get_theme_color(&"shade", &"MenuCursor")
	var bob := Vector2(0, float(int(_time * 2.4) % 2))
	for y in SHAPE.size():
		for x in SHAPE[y].length():
			if SHAPE[y][x] == "x":
				draw_rect(Rect2(bob + Vector2(x + 1, y + 1), Vector2.ONE), shade)
	for y in SHAPE.size():
		for x in SHAPE[y].length():
			if SHAPE[y][x] == "x":
				draw_rect(Rect2(bob + Vector2(x, y), Vector2.ONE), color)
