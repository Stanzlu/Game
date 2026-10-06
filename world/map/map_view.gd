class_name MapView
extends Node2D
## Builds a playable map from a text map at runtime (ADR-004):
## a ground TileMapLayer with collision and surface data, plus y-sorted props.
## Characters are added to `entities` so they sort with props by their feet.

signal built(data: MapData)

const DEFAULT_LEGEND := "res://content/maps/legend.json"
const GROUND_SHADER := preload("res://world/shaders/ground.gdshader")
const REFLECTION_SHADER := preload("res://world/shaders/reflection.gdshader")
const SCATTER_LIGHT_MASK := 0

@export_file("*.txt") var map_path := ""
@export_file("*.json") var legend_path := DEFAULT_LEGEND
## Optional shared y-sorted parent for props (e.g. endless segments that share one actor
## layer). Props spawned there are freed together with this map.
@export var props_parent: Node2D

var data: MapData
var ground: TileMapLayer
## Painted ground from the map's [meta] "ground" texture (ADR-017). The tile layer then
## stays hidden but keeps collision and surface data.
var ground_art: Sprite2D
var reflection_material: ShaderMaterial
var entities: Node2D
var _symbol_tiles: Dictionary = {}
var _external_props: Array[Node] = []
## Placements that follow the story ("if"/"unless" conditions, "sprite_when" looks):
## placement index -> spawned node or null. Untyped: a prop can free itself (a pickup that
## was taken), and a freed instance must not be read into a typed variable.
var _conditional: Dictionary = {}
## Conditional props that removed themselves while wanted (taken, caught): they stay gone
## until their conditions turn false again.
var _retired: Dictionary[int, bool] = {}
## Look of each "sprite_when" placement as spawned: placement index -> sprite id.
var _looks: Dictionary[int, String] = {}


func _ready() -> void:
	WorldState.flag_changed.connect(_on_flag_changed)
	if not map_path.is_empty():
		load_map(map_path)


func _exit_tree() -> void:
	for prop in _external_props:
		if is_instance_valid(prop):
			prop.queue_free()
	_external_props.clear()


## Moves the map, and the props it placed under another parent, to `to` (local position).
## Endless encounters recycle their path pieces this way instead of building new ones.
func shift_to(to: Vector2) -> void:
	var delta := to - position
	position = to
	for prop in _external_props:
		if is_instance_valid(prop):
			(prop as Node2D).global_position += delta


## Loads, validates and builds the map. Returns false (and logs errors) on invalid content.
func load_map(path: String) -> bool:
	map_path = path
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		Log.error(Log.Category.CONTENT, "map file missing or empty", {"path": path})
		return false
	return build_from_text(text, path)


## Builds from map text directly (tests, generated chunks). `source` is used in messages.
func build_from_text(text: String, source: String = "") -> bool:
	var legend := load_legend(legend_path)
	data = MapData.parse(text, legend, source)
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
	if data.meta.has("ground"):
		_apply_baked_ground()
	_spawn_props()
	_spawn_scatter()
	_add_reflections()
	Log.info(
		Log.Category.CONTENT,
		"map built",
		{"path": source, "size": [data.width, data.height], "placements": data.placements.size()}
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


func _apply_baked_ground() -> void:
	var texture := load(str(data.meta["ground"])) as Texture2D
	if texture == null:
		Log.error(Log.Category.CONTENT, "baked ground missing", {"path": data.meta["ground"]})
		return
	var expected := Vector2i(data.width, data.height) * data.tile_size
	if Vector2i(texture.get_size()) != expected:
		Log.warn(
			Log.Category.CONTENT,
			"baked ground size differs from map, re-run tools/art/bake_ground.py",
			{"path": data.meta["ground"], "size": texture.get_size(), "expected": expected}
		)
	ground_art = Sprite2D.new()
	ground_art.name = "GroundArt"
	ground_art.centered = false
	ground_art.texture = texture
	ground_art.z_index = -10
	var mat := ShaderMaterial.new()
	mat.shader = GROUND_SHADER
	if data.meta.has("water"):
		var mask := load(str(data.meta["water"])) as Texture2D
		if mask == null:
			Log.error(Log.Category.CONTENT, "water mask missing", {"path": data.meta["water"]})
		else:
			mat.set_shader_parameter("water_mask", mask)
			mat.set_shader_parameter("has_water", true)
			reflection_material = ShaderMaterial.new()
			reflection_material.shader = REFLECTION_SHADER
			reflection_material.set_shader_parameter("water_mask", mask)
			reflection_material.set_shader_parameter("map_size", Vector2(expected))
	ground_art.material = mat
	add_child(ground_art)
	move_child(ground_art, 0)
	ground.visible = false


## Mirrored, water-masked copies of props and NPCs that stand near water. The player is
## not reflected here (Game Bible §9: Elysia's water reflects everything except the
## protagonist); real-world scenes add the player with add_reflection().
func _add_reflections() -> void:
	if reflection_material == null:
		return
	reflection_material.set_shader_parameter("map_origin", global_position)
	for child in entities.get_children():
		if (
			not child is Node2D
			or child is Player
			or not _near_water(world_to_cell((child as Node2D).global_position))
		):
			continue
		if child is CanvasItem and (child as CanvasItem).z_index < 0:
			continue
		add_reflection(child as Node2D)


## Gives `owner_node` (its child "Sprite") a reflection in open water; with `puddles` it
## also shows in puddles (the protagonist in the real world). Returns the reflection.
func add_reflection(owner_node: Node2D, puddles := false) -> Node2D:
	var sprite := owner_node.get_node_or_null("Sprite") as Node2D
	if reflection_material == null or sprite == null:
		return null
	var mirror: Node2D
	if sprite is AnimatedSprite2D:
		var anim := sprite as AnimatedSprite2D
		var copy := AnimatedSprite2D.new()
		copy.sprite_frames = anim.sprite_frames
		copy.offset = Vector2(anim.offset.x, -anim.offset.y)
		copy.flip_v = true
		copy.flip_h = anim.flip_h
		copy.set_meta(&"source", anim)
		mirror = copy
		copy.set_process(true)
		anim.animation_changed.connect(
			func() -> void:
				copy.play(anim.animation)
				copy.flip_h = anim.flip_h
		)
		anim.frame_changed.connect(
			func() -> void:
				copy.frame = anim.frame
				copy.flip_h = anim.flip_h
		)
		copy.play(anim.animation)
	else:
		var src := sprite as Sprite2D
		var copy_s := Sprite2D.new()
		# the reflection shader fades by UV, so it needs the plain texture, not an atlas
		copy_s.texture = PropCatalog.source_texture(src.texture)
		copy_s.centered = false
		copy_s.flip_v = true
		var h := float(src.texture.get_height()) if src.texture != null else 0.0
		copy_s.offset = Vector2(src.offset.x, -src.offset.y - h)
		mirror = copy_s
	mirror.name = "Reflection"
	if puddles:
		var mat := reflection_material.duplicate() as ShaderMaterial
		mat.set_shader_parameter("puddles", true)
		mat.set_shader_parameter("fade_px", 40.0)
		mat.set_shader_parameter("tint", Color(0.7, 0.8, 0.9, 0.7))
		mirror.material = mat
	else:
		mirror.material = reflection_material
	mirror.z_as_relative = false
	mirror.z_index = -7
	mirror.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	owner_node.add_child(mirror)
	return mirror


func _near_water(cell: Vector2i) -> bool:
	for dy in range(-1, 4):
		for dx in range(-2, 3):
			if data.surface_at_cell(cell + Vector2i(dx, dy)) == &"water":
				return true
	return false


## Small decorations (grass tufts, pebbles, leaves) from [meta] "scatter" rules: plain
## sprites without collision, sorted with the other props, swaying when the catalog says so.
func _spawn_scatter() -> void:
	var rules: Array = data.meta.get("scatter", [])
	var count := 0
	for i in rules.size():
		var rule: Dictionary = rules[i]
		var entry := PropCatalog.entry(str(rule.get("sprite", "")))
		if entry.is_empty():
			continue
		var anchor: Array = entry.get("anchor", [0, 0])
		var sway := float(entry.get("sway", 0.0))
		var flat: bool = entry.get("flat", false)
		var axis_px := (symmetry_axis() + 0.5) * float(data.tile_size)
		var sway_axis := axis_px if symmetry_axis() >= 0 else Decor.NO_AXIS
		for pt in Scatter.points(data, rule, hash(data.source) + i * 7919):
			# right of a symmetry axis: the twin's variant and flip, mirrored
			var right := symmetry_axis() >= 0 and pt.x > axis_px
			var base := Vector2(2.0 * axis_px - pt.x, pt.y) if right else pt
			var sprite := Sprite2D.new()
			sprite.centered = false
			sprite.texture = PropCatalog.texture_for(entry, base * 3.17)
			sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))
			var flip := posmod(int(base.x * 13.0 + base.y * 7.0), 2) == 0
			if flip != right:
				Decor._mirror_sprite(sprite)
			sprite.position = pt
			sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
			# Tiny scatter is not lit by lamps: every lit sprite costs a draw call per light,
			# and the ground under it carries the light pool anyway (docs/PERFORMANCE.md).
			sprite.light_mask = SCATTER_LIGHT_MASK
			if sway > 0.0:
				sprite.material = Decor.sway_material(sway, false, sway_axis)
			if flat:
				sprite.z_index = -5
			entities.add_child(sprite)
			count += 1
	if count > 0:
		Log.debug(Log.Category.CONTENT, "scatter placed", {"path": data.source, "sprites": count})


## Column of the symmetry axis from [meta] "symmetry", or -1.
func symmetry_axis() -> int:
	return int(data.meta.get("symmetry", -1)) if data != null else -1


## In a symmetric map, a prop right of the axis is the mirror image of its twin: same
## texture variant (seeded by the twin's position), flipped. All props learn the axis, so
## their plants sway mirrored around it.
func _mirror_params(params: Dictionary, cell: Vector2i) -> Dictionary:
	var axis := symmetry_axis()
	if axis < 0:
		return params
	var mirrored := params.duplicate()
	mirrored["sway_axis"] = (axis + 0.5) * float(data.tile_size)
	if cell.x > axis:
		mirrored["mirror"] = true
		mirrored["seed_position"] = cell_to_world(Vector2i(2 * axis - cell.x, cell.y))
	return mirrored


func _spawn_props() -> void:
	_conditional.clear()
	_retired.clear()
	_looks.clear()
	for index in data.placements.size():
		var placement: Dictionary = data.placements[index]
		if (placement["prop"] as String).is_empty():
			continue
		var params: Dictionary = placement["params"]
		if params.has("if") or params.has("unless") or params.has("sprite_when"):
			_conditional[index] = null
			if not conditions_met(params):
				continue
		var prop := _spawn_prop(placement)
		if _conditional.has(index):
			_conditional[index] = prop
			if params.has("sprite_when"):
				_looks[index] = Decor.variant_sprite(params)


## `live`: the story brought it in while the scene runs (not on loading); the prop gets
## params "live": true and may make an entrance.
func _spawn_prop(placement: Dictionary, live := false) -> Node2D:
	var scene_path: String = placement["prop"]
	var scene := load(scene_path) as PackedScene
	if scene == null:
		Log.error(Log.Category.CONTENT, "prop scene missing", {"scene": scene_path})
		return null
	var prop := scene.instantiate() as Node2D
	var cell: Vector2i = placement["cell"]
	prop.name = "%s_%d_%d" % [prop.name, cell.x, cell.y]
	if props_parent != null:
		props_parent.add_child(prop)
		prop.global_position = cell_to_world(cell)
		_external_props.append(prop)
	else:
		prop.position = cell_to_world(cell) - global_position
		entities.add_child(prop)
	if prop.has_method("apply_params"):
		var params := _mirror_params(placement["params"], cell)
		if live:
			params = params.duplicate()
			params["live"] = true
		prop.call("apply_params", params)
	return prop


## Story conditions of a placement: "if" (flag or list of flags, all set) and "unless"
## (flag or list, none set). Such props appear and disappear as the flags change, so the
## same map serves every beat (the child, the rift, Mira's camp, the goat).
static func conditions_met(params: Dictionary) -> bool:
	for flag_id in _flag_list(params.get("if", [])):
		if not WorldState.has_flag(flag_id):
			return false
	for flag_id in _flag_list(params.get("unless", [])):
		if WorldState.has_flag(flag_id):
			return false
	return true


static func _flag_list(value: Variant) -> PackedStringArray:
	if value is String:
		return [value]
	var out: PackedStringArray = []
	for item: Variant in value if value is Array else []:
		out.append(str(item))
	return out


func _on_flag_changed(_id: String, _value: bool) -> void:
	if data == null or _conditional.is_empty():
		return
	refresh_conditions()


## Spawns conditional props whose flags became true, lets those whose became false leave
## and rebuilds props whose "sprite_when" look changed (all lights, shapes and layers of
## the new look, mirrored twins included).
func refresh_conditions() -> void:
	for index: int in _conditional.keys():
		var placement: Dictionary = data.placements[index]
		var params: Dictionary = placement["params"]
		var entry: Variant = _conditional[index]
		var alive := is_instance_valid(entry) and not (entry as Node).is_queued_for_deletion()
		if not alive and typeof(entry) == TYPE_OBJECT:
			_retired[index] = true  # it removed itself (taken, caught)
			_conditional[index] = null
		if not conditions_met(params):
			_retired.erase(index)
			if alive:
				_leave(entry as Node)
				_conditional[index] = null
			continue
		if alive and params.has("sprite_when"):
			if Decor.variant_sprite(params) == _looks.get(index, ""):
				continue
			_retire_name(entry as Node)
			(entry as Node).queue_free()
			alive = false
		if alive or _retired.has(index):
			continue
		var prop := _spawn_prop(placement, true)
		_conditional[index] = prop
		if params.has("sprite_when"):
			_looks[index] = Decor.variant_sprite(params)
		if prop != null and _near_water(placement["cell"]) and not prop is Player:
			add_reflection(prop)


## Frees the prop's name for its successor (props are named after their cell).
static func _retire_name(prop: Node) -> void:
	prop.name = "%s_leaving" % prop.name


## A prop whose conditions turned false goes its own way when it has one (the child fades,
## a caught butterfly finishes its flash) and frees itself; others vanish at once.
static func _leave(prop: Node) -> void:
	_retire_name(prop)
	if prop.has_method(&"leave"):
		prop.call(&"leave")
	else:
		prop.queue_free()
