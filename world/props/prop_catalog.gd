class_name PropCatalog
extends RefCounted
## Sprite catalog written by tools/art/make_sprites.py (ADR-017). Per sprite id
## ("<style>/<name>"): texture variants, anchor, collision shape, wind sway, lights, effects.
## Textures are handed out as regions of one atlas per style, built once at runtime: a
## scene has ~1,700 small sprites, and with one texture the 2D renderer draws them in a few
## batches instead of switching textures hundreds of times per frame (docs/PERFORMANCE.md).

const PATH := "res://assets/generated/props/catalog.json"
const ATLAS_WIDTH := 1024
const ATLAS_PADDING := 1

static var _entries: Dictionary = {}
static var _loaded := false
## Original texture path -> AtlasTexture (or the plain texture if no atlas could be built).
static var _regions: Dictionary = {}
static var _styles_built: Dictionary = {}


static func entry(id: String) -> Dictionary:
	_ensure_loaded()
	if not _entries.has(id):
		Log.error(Log.Category.CONTENT, "unknown prop sprite", {"sprite": id})
		return {}
	return _entries[id]


static func has(id: String) -> bool:
	_ensure_loaded()
	return _entries.has(id)


static func ids() -> Array:
	_ensure_loaded()
	return _entries.keys()


## Picks a texture variant deterministically from a position, so maps look the same each run.
static func texture_for(
	data: Dictionary, seed_position: Vector2, key: String = "textures"
) -> Texture2D:
	var textures: Array = data.get(key, [])
	if textures.is_empty():
		return null
	var index := variant_index(data, seed_position)
	return atlas_texture(str(textures[mini(index, textures.size() - 1)]))


## The texture as a region of its style's atlas; the plain texture where that is not
## possible (headless runs without image data). resource_name keeps the original path.
static func atlas_texture(path: String) -> Texture2D:
	if not _regions.has(path):
		var style := path.get_base_dir().get_file()
		if not _styles_built.has(style):
			_styles_built[style] = true
			_build_atlas(style)
	if not _regions.has(path):
		_regions[path] = load(path)
	return _regions[path]


## The plain texture behind an atlas region (reflections need its own UVs).
static func source_texture(texture: Texture2D) -> Texture2D:
	if texture is AtlasTexture and texture.resource_name.begins_with("res://"):
		return load(texture.resource_name) as Texture2D
	return texture


static func _build_atlas(style: String) -> void:
	_ensure_loaded()
	var paths: PackedStringArray = []
	for id: String in _entries:
		if not id.begins_with(style + "/"):
			continue
		var entry: Dictionary = _entries[id]
		for key: String in ["textures", "emissive"]:
			for p: Variant in entry.get(key, []):
				if not str(p) in paths:
					paths.append(str(p))
	paths.sort()
	var images: Dictionary = {}
	for p in paths:
		var tex := load(p) as Texture2D
		var image := tex.get_image() if tex != null else null
		if image == null or image.is_empty():
			return
		if image.get_format() != Image.FORMAT_RGBA8:
			image.convert(Image.FORMAT_RGBA8)
		images[p] = image
	# shelf packing, tallest first
	var order := Array(paths)
	order.sort_custom(
		func(a: String, b: String) -> bool:
			return (images[a] as Image).get_height() > (images[b] as Image).get_height()
	)
	var spots: Dictionary = {}
	var x := 0
	var y := 0
	var shelf := 0
	for p: String in order:
		var size := (images[p] as Image).get_size() + Vector2i.ONE * ATLAS_PADDING
		if x + size.x > ATLAS_WIDTH:
			x = 0
			y += shelf
			shelf = 0
		spots[p] = Vector2i(x, y)
		x += size.x
		shelf = maxi(shelf, size.y)
	var atlas := Image.create_empty(ATLAS_WIDTH, y + shelf, false, Image.FORMAT_RGBA8)
	for p: String in order:
		var image: Image = images[p]
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), spots[p])
	var texture := ImageTexture.create_from_image(atlas)
	for p: String in order:
		var region := AtlasTexture.new()
		region.atlas = texture
		region.region = Rect2(spots[p], (images[p] as Image).get_size())
		region.resource_name = p
		_regions[p] = region
	Log.debug(
		Log.Category.CONTENT,
		"prop atlas",
		{"style": style, "textures": order.size(), "size": [ATLAS_WIDTH, y + shelf]}
	)


## Same variant for the sprite and its emissive layer.
static func variant_index(data: Dictionary, seed_position: Vector2) -> int:
	var count: int = maxi((data.get("textures", []) as Array).size(), 1)
	var cell := Vector2i((seed_position / 16.0).floor())
	return posmod(cell.x * 7 + cell.y * 13, count)


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(PATH)) != OK or not json.data is Dictionary:
		Log.error(
			Log.Category.CONTENT,
			"prop catalog missing or invalid",
			{"path": PATH, "error": json.get_error_message()}
		)
		return
	_entries = json.data
