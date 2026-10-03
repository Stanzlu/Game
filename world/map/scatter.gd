class_name Scatter
extends RefCounted
## Deterministic scatter of small decorations from a map's [meta] "scatter" rules (ADR-017).
## Pure logic: returns map-local positions; MapView turns them into sprites.
##
## Rule: {"sprite": "<catalog id>", "on": "<ground symbols>", "density": 0..1, "spacing": px,
##        "near": "<ground or placement symbols>" (optional), "radius": cells (default 1)}
## Cells with a placement are skipped. The same map and rule always give the same points.


static func points(data: MapData, rule: Dictionary, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var spacing := maxf(float(rule.get("spacing", 12)), 4.0)
	var density := clampf(float(rule.get("density", 0.3)), 0.0, 1.0)
	var on := str(rule.get("on", "."))
	var near := str(rule.get("near", ""))
	var radius := int(rule.get("radius", 1))
	var ts := float(data.tile_size)
	var occupied := {}
	for p: Dictionary in data.placements:
		occupied[p["cell"]] = p["symbol"]
	var out := PackedVector2Array()
	var y := spacing * 0.5
	while y < data.height * ts:
		var x := spacing * 0.5
		while x < data.width * ts:
			# always draw the same number of random values per candidate (stable results)
			var jx := rng.randf_range(-0.4, 0.4) * spacing
			var jy := rng.randf_range(-0.4, 0.4) * spacing
			var roll := rng.randf()
			var pt := Vector2(x + jx, y + jy).round()
			var cell := Vector2i((pt / ts).floor())
			if roll < density and _allowed(data, cell, on, near, radius, occupied):
				out.append(pt)
			x += spacing
		y += spacing
	return out


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
