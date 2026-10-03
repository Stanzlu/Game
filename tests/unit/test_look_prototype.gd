extends GutTest
## Look prototype (ADR-017): generated prop catalog, baked ground and look scenes.

const LOOK_MAPS := [
	"res://content/maps/look_elysia.txt",
	"res://content/maps/look_tal.txt",
	"res://content/maps/look_wald.txt",
]
const LOOK_SCENES := [
	"res://world/levels/look_elysia.tscn",
	"res://world/levels/look_tal.tscn",
	"res://world/levels/look_wald.tscn",
]
const DECOR_SCENE := preload("res://world/props/decor.tscn")


func test_catalog_entries_point_to_existing_textures() -> void:
	var ids := PropCatalog.ids()
	assert_gt(ids.size(), 0, "catalog must not be empty")
	for id: String in ids:
		var entry := PropCatalog.entry(id)
		var textures: Array = entry.get("textures", [])
		assert_gt(textures.size(), 0, "%s has no textures" % id)
		for path: String in textures:
			assert_true(ResourceLoader.exists(path), "%s: missing %s" % [id, path])
		assert_eq((entry.get("anchor", []) as Array).size(), 2, "%s needs an anchor" % id)
		if entry.has("shape"):
			var shape: Dictionary = entry["shape"]
			assert_true(shape.has("circle") or shape.has("rect"), "%s: bad shape" % id)


func test_look_maps_reference_known_sprites_and_baked_art() -> void:
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	for path: String in LOOK_MAPS:
		var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
		assert_true(data.is_valid(), "%s: %s" % [path, data.errors])
		for key: String in ["style", "ground", "water"]:
			assert_true(data.meta.has(key), "%s: [meta] needs %s" % [path, key])
		var ground := load(str(data.meta.get("ground", ""))) as Texture2D
		assert_not_null(ground, "%s: baked ground missing" % path)
		if ground != null:
			assert_eq(
				Vector2i(ground.get_size()),
				Vector2i(data.width, data.height) * data.tile_size,
				"%s: re-run tools/art/bake_ground.py" % path
			)
		for p: Dictionary in data.placements:
			var params: Dictionary = p["params"]
			if params.has("sprite"):
				assert_true(PropCatalog.has(params["sprite"]), "%s: %s" % [path, params["sprite"]])


func test_baked_ground_hides_tiles_but_keeps_collision() -> void:
	var map := MapView.new()
	add_child_autofree(map)
	assert_true(map.load_map(LOOK_MAPS[1]))
	assert_not_null(map.ground_art)
	assert_false(map.ground.visible, "tile layer is replaced by the painted ground")
	await wait_physics_frames(2)
	var query := PhysicsPointQueryParameters2D.new()
	query.position = map.cell_to_world(Vector2i(0, 10))
	query.collision_mask = PhysicsLayers.WORLD
	var hits := map.get_world_2d().direct_space_state.intersect_point(query, 4)
	assert_gt(hits.size(), 0, "solid border cell must still collide")


func test_decor_builds_sprite_shape_and_lights_from_catalog() -> void:
	var lantern: Node2D = DECOR_SCENE.instantiate()
	add_child_autofree(lantern)
	lantern.call(&"apply_params", {"sprite": "tal/lantern"})
	assert_not_null(lantern.get_node_or_null("Sprite"))
	assert_not_null(lantern.get_node_or_null("Shape"))
	assert_eq((lantern.get("lights") as Array).size(), 1)
	var grass: Node2D = DECOR_SCENE.instantiate()
	add_child_autofree(grass)
	grass.call(&"apply_params", {"sprite": "tal/tall_grass"})
	var surface := grass.get_node_or_null("Surface") as Area2D
	assert_not_null(surface)
	if surface != null:
		assert_eq(surface.get_meta(&"surface"), &"tall_grass")
	assert_null(grass.get_node_or_null("Shape"), "tall grass is walkable")


func test_look_scenes_build_their_atmosphere() -> void:
	for path: String in LOOK_SCENES:
		var scene: LookScene = (load(path) as PackedScene).instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(2)
		assert_not_null(scene.player, "%s: player spawned" % path)
		assert_not_null(scene.view.display.material, "%s: grading applied" % path)
		assert_eq(AudioDirector.ambience_stream, scene.ambience, "%s: ambience playing" % path)
		assert_not_null(scene.ambience, "%s: has ambience" % path)
	var tal: LookScene = get_child(get_child_count() - 2)
	assert_not_null(tal.view.viewport.get_node_or_null("WeatherLayer/Rain"), "tal has rain")
	assert_not_null(tal.view.world_root.get_node_or_null("WorldTint"), "tal is darkened")
	var wald: LookScene = get_child(get_child_count() - 1)
	assert_not_null(wald.glow_layer.get_node_or_null("Fireflies"), "wald has fireflies")
	var emissive := 0
	for node in wald.map.entities.get_children():
		if node.get_node_or_null("Emissive") != null:
			emissive += 1
	assert_gt(emissive, 10, "glowing props have an unshaded emissive layer")
