# gdlint: ignore=max-public-methods
extends GutTest
## Act III, segment W5, the picture of the night wood: nothing there is to find lies under a sprite
## that is drawn over it (a crown, a tuft, a fern), the lantern, the glowing log and the tree one
## can look at stand free, and neither does a crown hang over the one who sits beside the lantern.
## The sprites are compared pixel by pixel, in the order the map draws them in (the layer, then how
## far south the prop stands). That every sprite is in the catalog is tested in
## test_akt3_nachtwald_szene, the scene itself there as well.

const NACHTWALD := preload("res://world/levels/akt3/nachtwald.tscn")
const DIALOGUE := "res://content/dialogue/akt3/nachtwald.dialogue"
## The share of a find that others may draw over (a leaf, a pebble, a twig, a blade of grass).
const SMALL_COVER_LIMIT := 0.15
## What may cover the one who sits: the edge of a crown at the most, never a trunk or the whole of
## her. The generator keeps the crown of every tree off her seat (the reserve over the seat's cell),
## so nothing touches her today; the limit leaves room for a leaf or two.
const SITTER_COVER_LIMIT := 0.02
## Where the seat lies from the lantern's foot (the map's "sit" offset): its east side.
const SEAT_OFFSET := Vector2(18, 2)

static var _images: Dictionary[int, Image] = {}


func before_each() -> void:
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	WorldState.set_day_preset("morgen")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


func _scene() -> NachtwaldScene:
	var scene: NachtwaldScene = NACHTWALD.instantiate()
	add_child_autofree(scene)
	await wait_physics_frames(3)
	return scene


## The Decor with this cue (it keeps the cue as meta), or null.
func _first(scene: GameScene, cue: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and node.has_meta(&"cue") and node.get_meta(&"cue") == cue:
			return node
	return null


## The one Decor with this sprite, or null.
func _with_sprite(scene: GameScene, sprite: String) -> Decor:
	for node in scene.map.entities.get_children():
		if node is Decor and not node.is_queued_for_deletion() and node.sprite_id == sprite:
			return node
	return null


## The things to find and to see: the lantern, the glowing log and the tree one can look at.
func _finds(scene: GameScene) -> Dictionary[String, Decor]:
	return {
		"lantern": _with_sprite(scene, "tal/wd_lantern"),
		"foxfire": _first(scene, "foxfire"),
		"glow_tree": _first(scene, "glow_tree"),
	}


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


## Opaque pixels of `image` (at `rect`) that `over` covers.
func _covered(image: Image, rect: Rect2i, over: Sprite2D) -> int:
	var b := _rect_of(over)
	var common := rect.intersection(b)
	if not common.has_area():
		return 0
	var image_b := _image_of(over)
	var count := 0
	for y in range(common.position.y, common.end.y):
		for x in range(common.position.x, common.end.x):
			if (
				image.get_pixel(x - rect.position.x, y - rect.position.y).a > 0.0
				and image_b.get_pixel(x - b.position.x, y - b.position.y).a > 0.0
			):
				count += 1
	return count


func _opaque(image: Image) -> int:
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.0:
				count += 1
	return count


## Every sprite on the map that stands over the others: props with a picture, the glow that is
## drawn on it, and scatter.
func _drawn(scene: GameScene) -> Array[Sprite2D]:
	var found: Array[Sprite2D] = []
	for node in scene.map.entities.get_children():
		if node.is_queued_for_deletion():
			continue
		if node is Sprite2D:
			found.append(node)
		elif node is Decor and (node as Decor).sprite != null:
			found.append((node as Decor).sprite)
			var glow := node.get_node_or_null("Emissive") as Sprite2D
			if glow != null:
				found.append(glow)
	return found


## How much of an image (a share of its opaque pixels) at `rect`, sorted by `order`, is covered by
## sprites drawn over it, and the name of the first one that does. The sprites of `own` are the
## image's own (a prop and the glow on it) and hide nothing.
func _hidden_share(
	scene: GameScene, image: Image, rect: Rect2i, order: Vector2, own: Node
) -> Array:
	var total := _opaque(image)
	assert_gt(total, 0, "the thing has a picture")
	var hidden := 0
	var first := ""
	for over in _drawn(scene):
		if own != null and over.get_parent() == own:
			continue
		var over_order := _order(scene, over)
		# draws over it: a higher layer, or the same layer and further south
		if over_order.x < order.x or (over_order.x == order.x and over_order.y <= order.y):
			continue
		var cover := _covered(image, rect, over)
		hidden += cover
		if cover > 0 and first.is_empty():
			var parent := over.get_parent()
			first = (parent as Decor).sprite_id if parent is Decor else over.texture.resource_path
	return [float(hidden) / float(total), first]


func _find_share(scene: GameScene, find: Decor) -> Array:
	return _hidden_share(
		scene, _image_of(find.sprite), _rect_of(find.sprite), _order(scene, find.sprite), find
	)


## The picture of the one who sits (the frame on show), where it is drawn, and the key she is
## sorted by: the layer of her sprite and how far south she stands.
func _sitter(scene: GameScene) -> Dictionary:
	var sprite := scene.player.sprite
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var image := texture.get_image()
	if sprite.flip_h:
		image.flip_x()
	var corner := sprite.global_position + sprite.offset
	if sprite.centered:
		corner -= Vector2(texture.get_size()) / 2.0
	return {
		"texture": texture,
		"image": image,
		"flip": sprite.flip_h,
		"corner": corner.round(),
		"order":
		Vector2(float(sprite.z_index + scene.player.z_index), scene.player.global_position.y),
	}


func _sitter_share(scene: GameScene) -> Array:
	var sitter := _sitter(scene)
	var image: Image = sitter["image"]
	var corner: Vector2 = sitter["corner"]
	var rect := Rect2i(Vector2i(corner), image.get_size())
	return _hidden_share(scene, image, rect, sitter["order"], null)


## Sits her down beside the lantern and reads the cue of the sitting to its end.
func _sit_and_read(scene: GameScene) -> void:
	var lantern := _with_sprite(scene, "tal/wd_lantern")
	scene.player.sit_on(lantern.global_position + SEAT_OFFSET, Facing.Dir.W)
	var opened := [false]
	var watch := func() -> bool:
		if scene.dialogue_box.is_open():
			opened[0] = true
			for pressed: bool in [true, false]:
				var event := InputEventAction.new()
				event.action = &"interact"
				event.pressed = pressed
				Input.parse_input_event(event)
		return opened[0] and not scene.dialogue_box.is_open()
	var done: bool = await wait_until(watch, 60.0)
	assert_true(done, "the sitting was read to its end")
	await wait_physics_frames(3)


# --- Nothing hides what there is to find -----------------------------------------------


func test_a_find_is_not_hidden_by_anything_that_stands_over_it() -> void:
	var scene := await _scene()
	assert_gt(_drawn(scene).size(), 200, "the trees and the scatter are all counted")
	var finds := _finds(scene)
	assert_eq(finds.size(), 3)
	for name: String in finds:
		var find := finds[name]
		assert_not_null(find, name)
		var seen := _find_share(scene, find)
		assert_lte(
			seen[0] as float,
			SMALL_COVER_LIMIT,
			"'%s' is %.0f%% under others (%s)" % [name, (seen[0] as float) * 100.0, seen[1]]
		)


func test_the_log_still_lies_free_once_a_piece_is_broken_from_it() -> void:
	WorldState.set_flag("forest.foxfire_taken")
	var scene := await _scene()
	var log := _with_sprite(scene, "tal/wd_foxfire_log_dim")
	assert_not_null(log, "the dark log lies there")
	var seen := _find_share(scene, log)
	assert_lte(seen[0] as float, SMALL_COVER_LIMIT, "under others (%s)" % seen[1])


func test_the_one_who_sits_beside_the_lantern_is_not_under_a_crown_or_a_trunk() -> void:
	var scene := await _scene()
	await _sit_and_read(scene)
	assert_eq(scene.player.state, Player.State.SIT)
	var seen := _sitter_share(scene)
	assert_lte(
		seen[0] as float,
		SITTER_COVER_LIMIT,
		"she is %.0f%% under others (%s)" % [(seen[0] as float) * 100.0, seen[1]]
	)


func test_the_lantern_is_not_under_anything_either_when_she_sits_there() -> void:
	var scene := await _scene()
	await _sit_and_read(scene)
	var seen := _find_share(scene, _with_sprite(scene, "tal/wd_lantern"))
	assert_lte(seen[0] as float, SMALL_COVER_LIMIT, "under others (%s)" % seen[1])


## A copy of the find's own picture on the same spot, `dy` pixels further south (negative: north)
## and on layer `layer`.
func _cover_of(scene: GameScene, find: Node2D, layer: int, dy: float) -> Sprite2D:
	var cover := Sprite2D.new()
	cover.centered = false
	cover.texture = find.sprite.texture
	cover.offset = find.sprite.offset
	cover.flip_h = find.sprite.flip_h
	cover.position = find.global_position + Vector2(0, dy)
	cover.z_index = layer
	scene.map.entities.add_child(cover)
	return cover


func test_the_check_sees_a_sprite_that_does_hide_a_find() -> void:
	var scene := await _scene()
	var finds := _finds(scene)
	for name: String in finds:
		var find := finds[name]
		var before := _find_share(scene, find)
		var layer := int(_order(scene, find.sprite).x)
		# a higher layer hides it, whatever the rows say
		var up := _cover_of(scene, find, layer + 1, 0.0)
		var after_up := _find_share(scene, find)
		up.free()
		assert_gt(after_up[0] as float, 0.6, "'%s' is under its copy one layer up" % name)
		# the same layer decides by the rows: two pixels further south stands in front of it
		var south := _cover_of(scene, find, layer, 2.0)
		var after_south := _find_share(scene, find)
		south.free()
		assert_gt(after_south[0] as float, 0.6, "'%s' is under its copy to the south" % name)
		assert_lt(before[0] as float, after_south[0] as float)
		# two pixels further north (or one layer down) stands behind it and hides nothing
		var north := _cover_of(scene, find, layer, -2.0)
		var after_north := _find_share(scene, find)
		north.free()
		assert_eq(after_north[0], before[0], "'%s': its copy to the north is behind it" % name)
		var down := _cover_of(scene, find, layer - 1, 2.0)
		var after_down := _find_share(scene, find)
		down.free()
		assert_eq(after_down[0], before[0], "'%s': its copy one layer down is behind it" % name)


## A copy of the sitter's own picture where she sits, `dy` pixels further south and on `layer`.
func _sitter_cover(scene: GameScene, layer: int, dy: float) -> Sprite2D:
	var sitter := _sitter(scene)
	var cover := Sprite2D.new()
	cover.centered = false
	cover.texture = sitter["texture"]
	cover.flip_h = sitter["flip"]
	cover.offset = sitter["corner"] - scene.player.global_position
	cover.position = scene.player.global_position + Vector2(0, dy)
	cover.z_index = layer
	scene.map.entities.add_child(cover)
	return cover


func test_the_check_sees_a_sprite_that_hides_the_one_who_sits() -> void:
	var scene := await _scene()
	await _sit_and_read(scene)
	var before := _sitter_share(scene)
	var layer := int(_sitter(scene)["order"].x)
	var up := _sitter_cover(scene, layer + 1, 0.0)
	var after_up := _sitter_share(scene)
	up.free()
	assert_gt(after_up[0] as float, 0.6, "she is under her copy one layer up")
	var south := _sitter_cover(scene, layer, 2.0)
	var after_south := _sitter_share(scene)
	south.free()
	assert_gt(after_south[0] as float, 0.6, "and under her copy to the south")
	var north := _sitter_cover(scene, layer, -2.0)
	var after_north := _sitter_share(scene)
	north.free()
	assert_eq(after_north[0], before[0], "her copy to the north is behind her")
