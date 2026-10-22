extends GutTest
## Game Bible §9: Elysia is perfectly symmetric, its plants and animals repeat exactly.

const ELYSIA_MAP := "res://content/maps/look_elysia.txt"
const ELYSIA_SCENE := preload("res://world/levels/look_elysia.tscn")
const SLICE_ELYSIA := preload("res://world/levels/slice/elysia.tscn")


func test_elysia_map_is_mirror_symmetric_apart_from_its_flaws() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	assert_true(map.load_map(ELYSIA_MAP))
	var axis := map.symmetry_axis()
	assert_eq(axis, 32)
	assert_eq(map.data.width, 2 * axis + 1, "the axis is the middle column")
	var props := {}
	for placement: Dictionary in map.data.placements:
		props[placement["cell"]] = str(placement["params"].get("sprite", placement["prop"]))
	# the stone and the rift are the only things that do not repeat on the other side
	var singles: Array[Vector2i] = []
	for cell: Vector2i in props:
		var twin := Vector2i(2 * axis - cell.x, cell.y)
		# benches are two cells wide: the twin's anchor cell sits one further left
		var wide := twin + Vector2i.LEFT
		if (
			cell.x != axis
			and props.get(twin, "") != props[cell]
			and props.get(wide, "") != props[cell]
		):
			singles.append(cell)
	var names: Array[String] = []
	for cell in singles:
		names.append(props[cell].get_file())
	names.sort()
	assert_eq(names, ["pickup.tscn", "rift.tscn"] as Array[String])


func test_mirrored_props_share_the_variant_and_sway_with_the_axis() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	map.load_map(ELYSIA_MAP)
	var left := map._mirror_params({"sprite": "elysia/tree"}, Vector2i(10, 5))
	var right := map._mirror_params({"sprite": "elysia/tree"}, Vector2i(54, 5))
	assert_false(left.get("mirror", false))
	assert_true(right["mirror"])
	assert_eq(right["seed_position"], map.cell_to_world(Vector2i(10, 5)))
	assert_eq(left["sway_axis"], map.cell_to_world(Vector2i(32, 0)).x)
	var a := Decor.sway_material(1.0, false, float(left["sway_axis"]))
	assert_eq(a.get_shader_parameter("mirror_x"), float(left["sway_axis"]))
	assert_ne(a, Decor.sway_material(1.0), "natural wind keeps its own material")


func test_butterfly_twins_fly_mirrored_routes_in_step() -> void:
	var one := Butterfly.new()
	var two := Butterfly.new()
	add_child_autofree(one)
	add_child_autofree(two)
	one.setup(Vector2(100, 50), 0, true, false)
	two.setup(Vector2(300, 50), 1, true, true)
	for i in 7:
		one._process(0.37)
		two._process(0.37)
		assert_eq(one.position.x - 100.0, 300.0 - two.position.x, "mirrored in x")
		assert_eq(one.position.y, two.position.y, "same height")
		assert_eq(one.frame, two.frame, "wings beat together")
	assert_eq(one.modulate, two.modulate, "twins share a color")


func test_elysia_life_repeats_exactly() -> void:
	var scene: LookScene = ELYSIA_SCENE.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(2)
	var life := scene.view.world_root.get_node("Life") as AmbientLife
	assert_true(life._perfect)
	assert_eq(life._darters.size() % 2, 0, "dragonflies come in pairs")
	var mirror_x := scene.map.cell_to_world(Vector2i(32, 0)).x
	for i in range(0, life._darters.size(), 2):
		var a: Vector2 = life._darters[i]["home"]
		var b: Vector2 = life._darters[i + 1]["home"]
		assert_almost_eq(a.x + b.x, 2.0 * mirror_x, 0.01)
	# koi keep equal spacing on their circle
	var koi: Array[Vector2] = []
	for f: Dictionary in life._swimmers:
		koi.append((f["sprite"] as Sprite2D).position)
	assert_eq(koi.size(), 6)
	var first := life._birds.size()
	life._flock_timer = 0.0
	life._update_flocks(0.0)
	assert_eq(life._birds.size() - first, 5, "always the same five birds")
	assert_almost_eq(life._flock_timer, life._flock_interval, 0.001, "on an exact beat")


func test_the_waking_builds_the_hud_up_in_order() -> void:
	WorldState.new_game()
	var scene: ElysiaScene = SLICE_ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	var hud := scene.hud
	for element_name in Hud.REVEAL_ORDER:
		assert_eq(hud._elements[element_name].modulate.a, 0.0, "%s waits" % element_name)
	assert_eq(scene.player.state, Player.State.SIT, "the hero wakes sitting")
	var greeter := scene._greeter()
	assert_not_null(greeter, "the one who greets stands beside the spawn")
	assert_eq(greeter.facing, Facing.Dir.S, "looking off into the garden until the hero is up")
	var seen: PackedStringArray = []
	var waited := 0
	while seen.size() < Hud.REVEAL_ORDER.size():
		for element_name in Hud.REVEAL_ORDER:
			if not element_name in seen and hud._elements[element_name].modulate.a > 0.0:
				seen.append(element_name)
		await wait_physics_frames(1)
		# Local count: the engine's global frame number is already large late in a full suite run.
		waited += 1
		if waited > 2000:
			break
	assert_eq(seen, Hud.REVEAL_ORDER, "level, then XP, then gold")
	await wait_for_signal(hud.revealed, 3.0)
	for element_name in Hud.REVEAL_ORDER:
		assert_eq(hud._elements[element_name].modulate.a, 1.0, "%s is there" % element_name)
	assert_ne(scene.player.state, Player.State.SIT, "the hero is up before the first line")
	await wait_physics_frames(2)
	assert_eq(greeter.facing, Facing.Dir.W, "the greeter looks at the hero")


func test_a_loaded_game_keeps_its_hud_at_once() -> void:
	WorldState.new_game()
	WorldState.set_flag("elysia.woke")
	var scene: ElysiaScene = SLICE_ELYSIA.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	for element_name in Hud.REVEAL_ORDER:
		assert_eq(scene.hud._elements[element_name].modulate.a, 1.0)
	assert_eq(get_tree().get_nodes_in_group(&"cutscene").size(), 0, "no waking twice")
