class_name JournalMark
extends Control
## The small gem before an open objective in Elysia's journal, drawn like the menu cursor
## (same pattern and colours from the theme type "MenuCursor"): the gold UI has ornaments, no
## ASCII check boxes. Done objectives get no mark and a muted colour instead.

var _pattern: PackedStringArray = MenuCursor.GEM


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(6, 6)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _draw() -> void:
	var color := get_theme_color(&"color", &"MenuCursor")
	var shade := get_theme_color(&"shade", &"MenuCursor")
	for y in _pattern.size():
		for x in _pattern[y].length():
			var c := _pattern[y][x]
			if c == ".":
				continue
			draw_rect(Rect2(Vector2(x + 1, y + 1), Vector2.ONE), shade)
	for y in _pattern.size():
		for x in _pattern[y].length():
			var c := _pattern[y][x]
			if c == ".":
				continue
			var pixel := color
			if c == "o":
				pixel = color.darkened(0.25)
			elif c == "h":
				pixel = color.lightened(0.6)
			draw_rect(Rect2(Vector2(x, y), Vector2.ONE), pixel)
