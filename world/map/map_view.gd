class_name MapView
extends Node2D
## Builds a playable map from a text map at runtime (ADR-004):
## a ground TileMapLayer with collision and surface data, plus y-sorted props.
## Characters are added to `entities` so they sort with props by their feet.

signal built(data: MapData)

const DEFAULT_LEGEND := "res://content/maps/legend.json"

@export_file("*.txt") var map_path := ""
@export_file("*.json") var legend_path := DEFAULT_LEGEND

var data: MapData
var ground: TileMapLayer
var entities: Node2D
var _symbol_tiles: Dictionary = {}


func _ready() -> void:
	if not map_path.is_empty():
		load_map(map_path)


## Loads, validates and builds the map. Returns false (and logs errors) on invalid content.
func load_map(path: String) -> bool:
	map_path = path
	var legend := load_legend(legend_path)
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		Log.error(Log.Category.CONTENT, "map file missing or empty", {"path": path})
		return false
	data = MapData.parse(text, legend, path)
	for message: String in data.errors:
		Log.error(Log.Category.CONTENT, message)
	if not data.is_valid():
		return false
	var atlas := load(str(legend.get("atlas", ""))) as Texture2D
	if atlas == null:
		Log.error(Log.Category.CONTENT, "legend atlas missing", {"atlas": legend.get("atlas")})
		return false
	_clear()
	_build_ground(atlas)
	_spawn_props()
	Log.info(
		Log.Category.CONTENT,
		"map built",
		{"path": path, "size": [data.width, data.height], "placements": data.placements.size()}
	)
	built.emit(data)
	return true


static func load_legend(path: String) -> Dictionary:
	var json := JSON.new()
	var err := json.parse(FileAccess.get_file_as_string(path))
	if err != OK or not json.data is Dictionary:
		Log.error(
			Log.Category.CONTENT,
			"legend missing or invalid JSON",
			{"path": path, "line": json.get_error_line(), "error": json.get_error_message()}
		)
		return {}
	return json.data


func cell_to_world(cell: Vector2i) -> Vector2:
	var s := float(data.tile_size)
	return global_position + Vector2(cell) * s + Vector2(s, s) * 0.5


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(((world_pos - global_position) / float(data.tile_size)).floor())


## Map bounds in world coordinates.
func world_rect() -> Rect2:
	var s := float(data.tile_size)
	return Rect2(global_position, Vector2(data.width, data.height) * s)


## Surface under a world position. Overlay areas (puddles, tall grass) win over tiles.
func surface_at(world_pos: Vector2) -> StringName:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = PhysicsLayers.SURFACE
	for hit: Dictionary in get_world_2d().direct_space_state.intersect_point(query, 4):
		var area := hit["collider"] as Node
		if area != null and area.has_meta("surface"):
			return StringName(area.get_meta("surface"))
	return data.surface_at_cell(world_to_cell(world_pos)) if data != null else &""


func _clear() -> void:
	for child in get_children():
		child.free()
	_symbol_tiles.clear()
	ground = TileMapLayer.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	entities = Node2D.new()
	entities.name = "Entities"
	entities.y_sort_enabled = true
	add_child(entities)


func _build_ground(atlas: Texture2D) -> void:
	var size := Vector2i(data.tile_size, data.tile_size)
	var tile_set := TileSet.new()
	tile_set.tile_size = size
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, PhysicsLayers.WORLD)
	tile_set.set_physics_layer_collision_mask(0, 0)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(0, "surface")
	tile_set.set_custom_data_layer_type(0, TYPE_STRING_NAME)
	var source := TileSetAtlasSource.new()
	source.texture = atlas
	source.texture_region_size = size
	tile_set.add_source(source, 0)
	var grid := Vector2i(atlas.get_size()) / size
	var half := float(data.tile_size) * 0.5
	var square := PackedVector2Array(
		[Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)]
	)
	for symbol: String in data.tiles:
		var def: Dictionary = data.tiles[symbol]
		var coords: Vector2i = def["atlas"]
		if coords.x >= grid.x or coords.y >= grid.y or coords.x < 0 or coords.y < 0:
			Log.error(Log.Category.CONTENT, "atlas coords outside atlas", {"symbol": symbol})
			continue
		if not source.has_tile(coords):
			source.create_tile(coords)
		# One alternative tile per symbol, so equal art can differ in surface or solidity.
		var alt := source.create_alternative_tile(coords)
		var tile_data := source.get_tile_data(coords, alt)
		tile_data.set_custom_data("surface", def["surface"])
		if def["solid"]:
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, 0, square)
		_symbol_tiles[symbol] = [coords, alt]
	ground.tile_set = tile_set
	for y in data.height:
		for x in data.width:
			var entry: Array = _symbol_tiles.get(data.ground_rows[y][x], [])
			if not entry.is_empty():
				ground.set_cell(Vector2i(x, y), 0, entry[0], entry[1])


func _spawn_props() -> void:
	for placement: Dictionary in data.placements:
		var scene_path: String = placement["prop"]
		if scene_path.is_empty():
			continue
		var scene := load(scene_path) as PackedScene
		if scene == null:
			Log.error(Log.Category.CONTENT, "prop scene missing", {"scene": scene_path})
			continue
		var prop := scene.instantiate() as Node2D
		prop.position = cell_to_world(placement["cell"]) - global_position
		entities.add_child(prop)
		if prop.has_method("apply_params"):
			prop.call("apply_params", placement["params"])
