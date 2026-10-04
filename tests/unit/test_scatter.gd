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


func test_zero_jitter_keeps_random_rules_on_the_lattice() -> void:
	var data := MapData.parse(MAP, LEGEND)
	var pts := Scatter.points(data, {"on": ".", "density": 1.0, "spacing": 8, "jitter": 0}, 3)
	for pt in pts:
		assert_eq(fposmod(pt.x - 4.0, 8.0), 0.0, "x on the lattice")
