# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W4, the picture of the Flutlichtung: every sprite the map names is in the
## catalog, and nothing there is to find lies under a sprite that is drawn over it (a crown, a
## tuft, a reed).
## The sprites are compared pixel by pixel, in the order the map draws them in (the layer, then how
## far south the prop stands). The scene itself is tested in test_akt3_flutlichtung_szene.

const FLUT := preload("res://world/levels/akt3/flutlichtung.tscn")
## The share of a find that others may draw over (a leaf, a pebble, a twig, a blade of grass).
const SMALL_COVER_LIMIT := 0.15
## The things to find: a Decor with this cue, each a sprite of its own.
const FINDS: Array[String] = [
	"flood_trail", "flood_mark", "flood_camp", "nest", "fork", "driftwood", "stones"
]

static var _images: Dictionary[int, Image] = {}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")


func after_each() -> void:
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> FlutlichtungScene:
	var scene: FlutlichtungScene = FLUT.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The Decor with this cue (it keeps the cue as meta), or null.
func _first(scene: GameScene, cue: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


# --- Pixels: what a sprite hides of another ---------------------------------------------


func _image_of(sprite: Sprite2D) -> Image:
	var key := sprite.texture.get_instance_id() * 2 + (1 if sprite.flip_h else 0)
	if not _images.has(key):
		var image := sprite.texture.get_image()
		if sprite.flip_h:
			image.flip_x()
		_images[key] = image
	return _images[key]


func _rect_of(sprite: Sprite2D) -> Rect2i:
	var corner := (sprite.global_position + sprite.offset).round()
	return Rect2i(Vector2i(corner), Vector2i(sprite.texture.get_size()))


## The key a sprite is sorted by (the node the map sorts: the prop, or the scatter sprite itself)
## and its layer (flat things lie on the ground, under everything that stands).
func _order(scene: GameScene, sprite: Sprite2D) -> Vector2:
	var owner_node: Node2D = sprite
	var layer := sprite.z_index
	if sprite.get_parent() != scene.map.entities:
		owner_node = sprite.get_parent() as Node2D
		layer += owner_node.z_index
	return Vector2(float(layer), owner_node.global_position.y)


## Opaque pixels of `under` that `over` covers.
func _covered(under: Sprite2D, over: Sprite2D) -> int:
	var a := _rect_of(under)
	var b := _rect_of(over)
	var common := a.intersection(b)
	if not common.has_area():
		return 0
	var image_a := _image_of(under)
	var image_b := _image_of(over)
	var count := 0
	for y in range(common.position.y, common.end.y):
		for x in range(common.position.x, common.end.x):
			if (
				image_a.get_pixel(x - a.position.x, y - a.position.y).a > 0.0
				and image_b.get_pixel(x - b.position.x, y - b.position.y).a > 0.0
			):
				count += 1
	return count


func _opaque(sprite: Sprite2D) -> int:
	var image := _image_of(sprite)
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.0:
				count += 1
	return count


## Every sprite on the map that stands over the others: props with a picture and scatter.
func _drawn(scene: GameScene) -> Array[Sprite2D]:
	var found: Array[Sprite2D] = []
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node is Sprite2D:
			found.append(node)
		elif node is Decor and (node as Decor).sprite != null:
			found.append((node as Decor).sprite)
	return found


func test_every_sprite_of_the_map_is_in_the_catalog_and_every_prop_exists() -> void:
	var scene := await _scene()
	var sprites: Dictionary[String, bool] = {}
	for placement: Dictionary in scene.map.data.placements:
		assert_true(ResourceLoader.exists(placement["prop"]) or placement["prop"] == "", "prop")
		var params: Dictionary = placement["params"]
		if params.has("sprite"):
			sprites[params["sprite"]] = true
		for sprite: String in (params.get("sprite_when", {}) as Dictionary).values():
			sprites[sprite] = true
		if params.has("sheet"):
			assert_true(ResourceLoader.exists(params["sheet"]), "sheet " + params["sheet"])
	for rule: Dictionary in scene.map.data.meta["scatter"]:
		sprites[rule["sprite"]] = true
	assert_gte(sprites.size(), 20)
	for sprite: String in sprites:
		assert_true(PropCatalog.has(sprite), "sprite '%s' is in the catalog" % sprite)
	for key: String in ["ground", "water"]:
		assert_true(ResourceLoader.exists(scene.map.data.meta[key]), "the baked " + key)


# --- Nothing hides what there is to find ---------------------------------------------------


## How much of a find (a share of its opaque pixels) is covered by sprites drawn over it, and the
## name of the first one that does.
func _hidden_share(scene: GameScene, find: Sprite2D) -> Array:
	var total := _opaque(find)
	assert_gt(total, 0, "the find has a picture")
	var hidden := 0
	var first := ""
	var find_order := _order(scene, find)
	for over in _drawn(scene):
		if over == find:
			continue
		var order := _order(scene, over)
		# draws over it: a higher layer, or the same layer and further south
		if order.x < find_order.x or (order.x == find_order.x and order.y <= find_order.y):
			continue
		var cover := _covered(find, over)
		hidden += cover
		if cover > 0 and first.is_empty():
			var parent := over.get_parent()
			first = (parent as Decor).sprite_id if parent is Decor else over.texture.resource_path
	return [float(hidden) / float(total), first]


func test_a_find_is_not_hidden_by_anything_that_stands_over_it() -> void:
	var scene := await _scene()
	assert_gt(_drawn(scene).size(), 500, "the trees and the scatter are all counted")
	for cue: String in FINDS:
		var find := _first(scene, cue)
		assert_not_null(find, cue)
		var seen := _hidden_share(scene, find.sprite)
		assert_lte(
			seen[0] as float,
			SMALL_COVER_LIMIT,
			"'%s' is %.0f%% under others (%s)" % [cue, (seen[0] as float) * 100.0, seen[1]]
		)


func test_the_check_sees_a_sprite_that_does_hide_a_find() -> void:
	var scene := await _scene()
	for cue: String in ["nest", "flood_mark", "stones"]:
		var find := _first(scene, cue)
		var before := _hidden_share(scene, find.sprite)
		# the same picture, two pixels south of it and one layer up: in front of it
		var cover := Sprite2D.new()
		cover.centered = false
		cover.texture = find.sprite.texture
		cover.offset = find.sprite.offset
		cover.flip_h = find.sprite.flip_h
		cover.position = find.global_position + Vector2(0, 2)
		cover.z_index = 1
		scene.map.entities.add_child(cover)
		var after := _hidden_share(scene, find.sprite)
		cover.free()
		assert_gt(after[0] as float, 0.6, "'%s' is under its copy" % cue)
		assert_lt(before[0] as float, after[0] as float)
