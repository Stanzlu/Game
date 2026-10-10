extends GutTest
## Scatter rules for small decorations (ADR-017).

const LEGEND := {
	"tile_size": 16,
	"symbols":
	{
		".": {"atlas": [0, 0], "surface": "grass"},
		",": {"atlas": [2, 0], "surface": "dirt"},
		"~": {"atlas": [5, 0], "surface": "water", "solid": true},
		"T": {"ground": ".", "prop": "res://world/props/bush.tscn"},
	},
}
const MAP := "......\n..T...\n......\n,,,,,,\n~~~~~~"


func test_points_are_deterministic() -> void:
	var data := MapData.parse(MAP, LEGEND)
	var rule := {"on": ".", "density": 0.6, "spacing": 6}
	assert_eq(Scatter.points(data, rule, 42), Scatter.points(data, rule, 42))
	assert_ne(Scatter.points(data, rule, 42), Scatter.points(data, rule, 43))


func test_points_respect_ground_and_placements() -> void:
	var data := MapData.parse(MAP, LEGEND)
	var pts := Scatter.points(data, {"on": ".", "density": 1.0, "spacing": 5}, 1)
	assert_gt(pts.size(), 20)
	for pt in pts:
		var cell := Vector2i((pt / 16.0).floor())
		assert_eq(data.tile_symbol_at(cell), ".", "only on grass: %s" % cell)
		assert_ne(cell, Vector2i(2, 1), "never on a placement cell")


func test_near_limits_points_to_the_neighbourhood() -> void:
	var data := MapData.parse(MAP, LEGEND)
	var pts := Scatter.points(data, {"on": ",", "near": "~", "density": 1.0, "spacing": 5}, 1)
	assert_gt(pts.size(), 0)
	var none := Scatter.points(data, {"on": ".", "near": "~", "density": 1.0, "spacing": 5}, 1)
	assert_eq(none.size(), 0, "grass is never next to the water here")
	var by_tree := Scatter.points(data, {"on": ".", "near": "T", "density": 1.0, "spacing": 5}, 1)
	for pt in by_tree:
		var cell := Vector2i((pt / 16.0).floor())
		assert_lte(absi(cell.x - 2), 1)
		assert_lte(absi(cell.y - 1), 1)


func test_lattices_are_exact_and_mirror_around_the_axis() -> void:
	var text := ".......\n.......\n.......\n.......\n.......\n.......\n......."
	var data := MapData.parse(text, LEGEND)
	data.meta["symmetry"] = 3
	var grid := Scatter.points(data, {"on": ".", "spacing": 8, "pattern": "grid"}, 1)
	assert_eq(grid, Scatter.points(data, {"on": ".", "spacing": 8, "pattern": "grid"}, 99))
	var axis_px := 3.5 * 16.0
	for pt in grid:
		assert_has(grid, Vector2(2.0 * axis_px - pt.x, pt.y), "mirror twin of %s" % pt)
	var checker := Scatter.points(data, {"on": ".", "spacing": 8, "pattern": "checker"}, 1)
	assert_lt(checker.size(), grid.size())
	for pt in checker:
		assert_has(checker, Vector2(2.0 * axis_px - pt.x, pt.y))


func test_clump_leaves_bare_patches_deterministically() -> void:
	var rows: PackedStringArray = []
	for y in 30:
		rows.append(".".repeat(40))
	var data := MapData.parse("\n".join(rows), LEGEND)
	var even := {"on": ".", "density": 1.0, "spacing": 6}
	var clumped := {"on": ".", "density": 1.0, "spacing": 6, "clump": 56}
	var pts := Scatter.points(data, clumped, 7)
	assert_eq(pts, Scatter.points(data, clumped, 7), "same map, rule and seed: same clumps")
	assert_ne(pts, Scatter.points(data, clumped, 8), "another seed: other clumps")
	var all := Scatter.points(data, even, 7)
	assert_lt(pts.size(), all.size())
	assert_true(pts.size() > all.size() / 5, "clumps, not an empty map")
	# count points per 24 px block: without clumps every block is full, with clumps some
	# blocks stay bare and others keep (nearly) the full density
	var per_block_all := _per_block(all, 24.0)
	var per_block := _per_block(pts, 24.0)
	var bare := 0
	var dense := 0
	for block: Vector2i in per_block_all:
		var n: int = per_block.get(block, 0)
		bare += 1 if n == 0 else 0
		dense += 1 if n * 4 >= int(per_block_all[block]) * 3 else 0
	assert_eq(per_block_all.size(), 27 * 20, "without clumps no block is empty")
	assert_gt(bare, 20, "bare patches between the clumps")
	assert_gt(dense, 20, "dense clumps")


func _per_block(pts: PackedVector2Array, size: float) -> Dictionary:
	var out := {}
	for pt in pts:
		var block := Vector2i((pt / size).floor())
		out[block] = int(out.get(block, 0)) + 1
	return out


func test_value_noise_is_smooth_and_in_range() -> void:
	for i in 200:
		var p := Vector2(i * 0.37, i * 0.21)
		var v := Scatter.value_noise(p, 11)
		assert_between(v, 0.0, 1.0)
		assert_eq(v, Scatter.value_noise(p, 11))
		assert_almost_eq(v, Scatter.value_noise(p + Vector2(0.01, 0.0), 11), 0.05)


func test_zero_jitter_keeps_random_rules_on_the_lattice() -> void:
	var data := MapData.parse(MAP, LEGEND)
	var pts := Scatter.points(data, {"on": ".", "density": 1.0, "spacing": 8, "jitter": 0}, 3)
	for pt in pts:
		assert_eq(fposmod(pt.x - 4.0, 8.0), 0.0, "x on the lattice")
