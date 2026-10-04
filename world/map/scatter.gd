class_name Scatter
extends RefCounted
## Deterministic scatter of small decorations from a map's [meta] "scatter" rules (ADR-017).
## Pure logic: returns map-local positions; MapView turns them into sprites.
##
## Rule: {"sprite": "<catalog id>", "on": "<ground symbols>", "density": 0..1, "spacing": px,
##        "near": "<ground or placement symbols>" (optional), "radius": cells (default 1),
##        "jitter": 0..0.5 of the spacing (default 0.4, random pattern only),
##        "pattern": "random" (default) | "grid" | "checker", "offset": px (rows, lattices)}
## Cells with a placement are skipped. The same map and rule always give the same points.
## "grid" and "checker" are exact lattices without randomness (Elysia's planted order); in a
## map with [meta] "symmetry" the lattice is centred on the axis, so it mirrors exactly.


static func points(data: MapData, rule: Dictionary, seed_value: int) -> PackedVector2Array:
	var pattern := str(rule.get("pattern", "random"))
	if pattern != "random":
		return _lattice(data, rule, pattern == "checker")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var spacing := maxf(float(rule.get("spacing", 12)), 4.0)
	var density := clampf(float(rule.get("density", 0.3)), 0.0, 1.0)
	var on := str(rule.get("on", "."))
	var near := str(rule.get("near", ""))
	var radius := int(rule.get("radius", 1))
	var jitter := clampf(float(rule.get("jitter", 0.4)), 0.0, 0.5) / 0.4
	var ts := float(data.tile_size)
	var occupied := _occupied(data)
	var out := PackedVector2Array()
	var y := spacing * 0.5
	while y < data.height * ts:
		var x := spacing * 0.5
		while x < data.width * ts:
			# always draw the same number of random values per candidate (stable results)
			var jx := rng.randf_range(-0.4, 0.4) * spacing * jitter
			var jy := rng.randf_range(-0.4, 0.4) * spacing * jitter
			var roll := rng.randf()
			var pt := Vector2(x + jx, y + jy).round()
			var cell := Vector2i((pt / ts).floor())
			if roll < density and _allowed(data, cell, on, near, radius, occupied):
				out.append(pt)
			x += spacing
		y += spacing
	return out


## Exact lattice; `checker` keeps every other point. Centred on the symmetry axis if any.
static func _lattice(data: MapData, rule: Dictionary, checker: bool) -> PackedVector2Array:
	var spacing := maxf(float(rule.get("spacing", 12)), 4.0)
	var on := str(rule.get("on", "."))
	var near := str(rule.get("near", ""))
	var radius := int(rule.get("radius", 1))
	var ts := float(data.tile_size)
	var width := data.width * ts
	var occupied := _occupied(data)
	var columns: Array[Vector2] = []  # (x, column index)
	if data.meta.has("symmetry"):
		var axis_px := (float(data.meta["symmetry"]) + 0.5) * ts
		var k_max := int(ceilf(axis_px / spacing)) + 1
		for k in range(-k_max, k_max + 1):
			var x := axis_px + k * spacing
			var twin := 2.0 * axis_px - x
			if x >= 0.0 and x < width and twin >= 0.0 and twin < width:
				columns.append(Vector2(x, absi(k)))
	else:
		var x := spacing * 0.5
		var i := 0
		while x < width:
			columns.append(Vector2(x, i))
			x += spacing
			i += 1
	var out := PackedVector2Array()
	var y := spacing * 0.5 + float(rule.get("offset", 0.0))
	var row := 0
	while y < data.height * ts:
		for column in columns:
			if checker and (int(column.y) + row) % 2 != 0:
				continue
			var pt := Vector2(column.x, y).round()
			var cell := Vector2i((pt / ts).floor())
			if _allowed(data, cell, on, near, radius, occupied):
				out.append(pt)
		y += spacing
		row += 1
	return out


static func _occupied(data: MapData) -> Dictionary:
	var occupied := {}
	for p: Dictionary in data.placements:
		occupied[p["cell"]] = p["symbol"]
	return occupied


static func _allowed(
	data: MapData, cell: Vector2i, on: String, near: String, radius: int, occupied: Dictionary
) -> bool:
	var symbol := data.tile_symbol_at(cell)
	if symbol.is_empty() or not on.contains(symbol) or occupied.has(cell):
		return false
	if near.is_empty():
		return true
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var c := cell + Vector2i(dx, dy)
			var ground := data.tile_symbol_at(c)
			if not ground.is_empty() and near.contains(ground):
				return true
			if occupied.has(c) and near.contains(str(occupied[c])):
				return true
	return false
