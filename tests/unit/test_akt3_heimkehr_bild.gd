extends GutTest
## Act III, segment W6, the picture of the house when she comes home: the bench, the plan on the
## wall and the chair of the guest are not drawn over by anything that stands in front of them
## (the Antreiber at the bench, the cat on his lap, the hermit on his chair, she herself on the
## cells where she talks to them), nobody who sits is hidden, the cat lies in front of the one she
## lies on, and every spot to talk from can be reached. The sprites are compared pixel by pixel,
## in the order the map draws them in (the layer, then how far south the prop stands, then its place
## in the tree). That every sprite is in the catalog and the scene itself are tested in
## test_akt3_heimkehr_weg and test_akt3_heimkehr_szene.

const HAUS := preload("res://world/levels/slice/haus.tscn")
const FIXTURE := "res://tests/fixtures/saves/v2_akt2_end.json"
const QUEST := "main_forest_way"
const WAY: Array[String] = ["leave", "brook", "wood", "night", "home", "done"]
## The share of a thing that others may draw over (a hand, a hem, a shadow's edge).
const SMALL_COVER_LIMIT := 0.15
## What may cover the one who sits: nothing but the edge of a hand or a cat's tail.
const SITTER_COVER_LIMIT := 0.02
## What may cover her when she stands beside or in front of what she talks to.
const STANDING_COVER_LIMIT := 0.15
## What she may hide of what she talks to, and what may hide of her when she stands behind it (a
## bench in front of her reaches her waist): never most of it.
const HALF := 0.5
## The plan hangs on the wall right above the cell she reads it from: raised eight pixels, her head
## reaches the lowest line of it and no more.
const PLAN_LIMIT := 0.25
## How far from a thing (in cells) she can stand to talk to it.
const TALK_REACH := 2
## The cells the earlier runs of the autopilot (slice, Act II) put her on in this room: whether she
## can stand there does not change (some are walls or the bucket, then it stays so).
const OLD_WAYS: Array[Vector2i] = [
	Vector2i(16, 10),
	Vector2i(17, 12),
	Vector2i(22, 11),
	Vector2i(25, 9),
	Vector2i(19, 9),
	Vector2i(20, 13),
	Vector2i(14, 14),
	Vector2i(17, 10),
	Vector2i(12, 12),
]

static var _images: Dictionary[int, Image] = {}


func before_each() -> void:
	# no scene of these tests leaves its room for another: the doors only note where they lead
	SceneTravel.stay = true
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 3, false)


func after_each() -> void:
	Input.action_release(&"move_down")
	Settings.set_value("text.auto_advance", false, false)
	Settings.set_value("text.speed", 1, false)
	SceneTravel.pending_spawn = ""
	SceneTravel.arrival_fade = -1.0
	SceneTravel.stay = false
	SceneTravel.last_target = ""
	WorldState.new_game()
	ScreenFade.fade_in(0.0)
	get_tree().paused = false


## The room as it stays when the walk is over: the bench, the Antreiber at it, the cat on his lap
## (fed) and the chair of the guest (he has been). Nothing plays, so the picture stands still.
func _room(fed := true, chair := true) -> HausScene:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)
	WorldState.set_flag("beat.act3_morning")
	WorldState.set_day_preset("morgen")
	if not fed:
		WorldState.clear_flag("house.cat_fed")
	if chair:
		WorldState.set_flag("house.guest_hermit")
	WorldState.start_quest(QUEST)
	for stage: String in WAY.slice(1):
		assert_true(WorldState.advance_quest(QUEST, stage), "to " + stage)
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	await wait_physics_frames(3)
	assert_false(scene.is_homecoming(), "nothing plays: the picture stands still")
	return scene


func _alive(scene: GameScene) -> Array[Node]:
	return scene.map.entities.get_children().filter(
		func(node: Node) -> bool: return not node.is_queued_for_deletion()
	)


## The one Decor with this sprite, or null.
func _decor(scene: GameScene, sprite: String) -> Decor:
	for node in _alive(scene):
		if node is Decor and node.sprite_id == sprite:
			return node
	return null


## The cat on the Antreiber's lap (the one with the cue of the bench).
func _lap_cat(scene: GameScene) -> Decor:
	for node in _alive(scene):
		if node is Decor and node.has_meta(&"cue") and node.get_meta(&"cue") == "cat_bench":
			return node
	return null


func _antreiber(scene: GameScene) -> NpcWalker:
	for node in _alive(scene):
		if node is NpcWalker and (node as NpcWalker).cue == "antreiber_bench":
			return node
	return null


func _guest(scene: GameScene) -> GuestWalker:
	for node in _alive(scene):
		if node is GuestWalker:
			return node
	return null


# --- Pixels: what a sprite hides of another ---------------------------------------------


## The image of a texture, flipped as the sprite shows it (kept: it is read often).
func _image_of(texture: Texture2D, flipped: bool) -> Image:
	var key := texture.get_instance_id() * 2 + (1 if flipped else 0)
	if not _images.has(key):
		var image := texture.get_image()
		if flipped:
			image.flip_x()
		_images[key] = image
	return _images[key]


## A picture on the map: its image, the pixels it lies on, the key the map draws it by (the layer,
## how far south it stands, its place among its siblings), the node it belongs to and a name.
func _pic(scene: GameScene, sprite: Node2D, label: String) -> Dictionary:
	var texture: Texture2D
	var corner: Vector2
	var flipped := false
	if sprite is AnimatedSprite2D:
		var animated := sprite as AnimatedSprite2D
		texture = animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
		corner = animated.global_position + animated.offset
		if animated.centered:
			corner -= Vector2(texture.get_size()) / 2.0
		flipped = animated.flip_h
	else:
		var plain := sprite as Sprite2D
		texture = plain.texture
		corner = plain.global_position + plain.offset
		flipped = plain.flip_h
	var owner_node: Node2D = sprite
	var layer := sprite.z_index
	if sprite.get_parent() != scene.map.entities:
		owner_node = sprite.get_parent() as Node2D
		layer += owner_node.z_index
	var image := _image_of(texture, flipped)
	return {
		"image": image,
		"rect": Rect2i(Vector2i(corner.round()), image.get_size()),
		"order": Vector3(float(layer), owner_node.global_position.y, float(owner_node.get_index())),
		"owner": owner_node,
		"label": label,
	}


## Every picture the map draws: props with a picture and the glow on them, scatter, the people who
## stand or sit (an AnimatedSprite2D, whose picture is the frame on show), the guest, and her.
func _pics(scene: GameScene, with_player := true) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for node in _alive(scene):
		if node is Sprite2D:
			found.append(_pic(scene, node, str(node.name)))
		elif node is Decor and (node as Decor).sprite != null:
			found.append(_pic(scene, (node as Decor).sprite, (node as Decor).sprite_id))
			var glow := node.get_node_or_null("Emissive") as Sprite2D
			if glow != null:
				found.append(_pic(scene, glow, (node as Decor).sprite_id + " (glow)"))
		elif node is NpcWalker:
			found.append(_pic(scene, (node as NpcWalker).sprite, "man " + (node as NpcWalker).cue))
		elif node is GuestWalker:
			found.append(_pic(scene, (node as GuestWalker).sprite, "guest"))
		elif node is Player and with_player:
			found.append(_pic(scene, (node as Player).sprite, "she"))
	return found


## Opaque pixels of `pic` that `over` covers.
func _covered(pic: Dictionary, over: Dictionary) -> int:
	var rect: Rect2i = pic["rect"]
	var b: Rect2i = over["rect"]
	var common := rect.intersection(b)
	if not common.has_area():
		return 0
	var image: Image = pic["image"]
	var image_b: Image = over["image"]
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


## True if `a` is drawn over `b`: a higher layer, or the same layer and further south, or the same
## row and later in the tree.
func _over(a: Dictionary, b: Dictionary) -> bool:
	var oa: Vector3 = a["order"]
	var ob: Vector3 = b["order"]
	if oa.x != ob.x:
		return oa.x > ob.x
	if oa.y != ob.y:
		return oa.y > ob.y
	return oa.z > ob.z


## How much of `pic` (a share of its opaque pixels) is covered by pictures drawn over it, and the
## name of the one that covers most. A thing's own pictures (a prop and its glow) hide nothing of
## it; `except` names pictures that do not count (the cat that lies on the Antreiber on purpose).
func _hidden_share(scene: GameScene, pic: Dictionary, with_player := true, except := "") -> Array:
	var total := _opaque(pic["image"])
	assert_gt(total, 0, "'%s' has a picture" % pic["label"])
	var hidden := 0
	var worst := 0
	var first := ""
	for over in _pics(scene, with_player):
		if over["owner"] == pic["owner"] or not _over(over, pic):
			continue
		if not except.is_empty() and over["label"] == except:
			continue
		var cover := _covered(pic, over)
		hidden += cover
		if cover > worst:
			worst = cover
			first = over["label"]
	return [float(hidden) / float(total), first]


func _share_text(share: Array) -> String:
	return "%.1f%% under others (%s)" % [(share[0] as float) * 100.0, share[1]]


# --- The things: the picture of each ------------------------------------------------------


func _thing(scene: GameScene, name: String) -> Dictionary:
	match name:
		"bench":
			return _pic(scene, _decor(scene, "haus/workbench").sprite, "bench")
		"plan":
			return _pic(scene, _decor(scene, "haus/plan_board").sprite, "plan")
		"chair":
			return _pic(scene, _decor(scene, "haus/guest_chair").sprite, "chair")
		"cat":
			return _pic(scene, _lap_cat(scene).sprite, "cat")
		"antreiber":
			return _pic(scene, _antreiber(scene).sprite, "antreiber")
	return {}


func test_the_bench_the_plan_the_chair_and_the_cat_are_not_under_other_pictures() -> void:
	var scene := await _room()
	assert_gt(_pics(scene).size(), 8, "the room and its people were counted")
	for name: String in ["bench", "plan", "chair", "cat"]:
		var share := _hidden_share(scene, _thing(scene, name))
		assert_lte(share[0] as float, SMALL_COVER_LIMIT, "'%s' is %s" % [name, _share_text(share)])
	assert_push_error_count(0)


func test_the_antreiber_at_the_bench_is_not_under_the_bench_or_anything_but_the_cat() -> void:
	var scene := await _room()
	var share := _hidden_share(scene, _thing(scene, "antreiber"), true, "haus/cat_sleep")
	assert_lte(share[0] as float, SITTER_COVER_LIMIT, "he is %s" % _share_text(share))
	# the cat is what lies on him: she may cover a good part of his lap and no more
	var with_cat := _hidden_share(scene, _thing(scene, "antreiber"))
	assert_lte(
		with_cat[0] as float, SMALL_COVER_LIMIT * 2.0, "with the cat: " + _share_text(with_cat)
	)
	var empty := await _room(false)
	var alone := _hidden_share(empty, _thing(empty, "antreiber"))
	assert_lte(alone[0] as float, SITTER_COVER_LIMIT, "without her: " + _share_text(alone))
	assert_push_error_count(0)


func test_the_cat_lies_south_of_the_man_she_lies_on_and_in_front_of_him() -> void:
	var scene := await _room()
	var man := _thing(scene, "antreiber")
	var cat := _thing(scene, "cat")
	var man_key: Vector3 = man["order"]
	var cat_key: Vector3 = cat["order"]
	assert_eq(cat_key.x, man_key.x, "on the same layer")
	assert_gt(cat_key.y, man_key.y, "the cat stands further south")
	assert_true(_over(cat, man), "and is drawn over him")
	assert_false(_over(man, cat))
	assert_gt(_covered(man, cat), 0, "she lies on him: her picture is on his")
	var bench := _thing(scene, "bench")
	var bench_key: Vector3 = bench["order"]
	assert_eq(scene.map.world_to_cell(_antreiber(scene).global_position), Vector2i(22, 14))
	assert_eq(scene.map.world_to_cell(_lap_cat(scene).global_position), Vector2i(22, 15))
	assert_gte(bench_key.x, 0.0, "the bench is a thing that stands")
	assert_push_error_count(0)


# --- Where she stands to talk to them ----------------------------------------------------


## True if she can stand on this cell: it is floor and nothing solid (the bench, a man, the table)
## is in her way.
func _standable(scene: HausScene, cell: Vector2i) -> bool:
	if scene.map.data.is_solid(cell):
		return false
	var spot := scene.map.cell_to_world(cell)
	return not scene.player.test_move(Transform2D(0.0, spot), Vector2(0.01, 0.0))


func _stand(scene: HausScene, cell: Vector2i, facing: Facing.Dir) -> void:
	scene.player.global_position = scene.map.cell_to_world(cell)
	scene.player.velocity = Vector2.ZERO
	scene.player.facing = facing
	await wait_physics_frames(2)


## The cells from which she can talk to `thing`: she can stand there, and looking at it she has it
## as the thing to talk to (the same choice the key makes).
func _talk_cells(scene: HausScene, thing: Node2D) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	var home := scene.map.world_to_cell(thing.global_position)
	for dy in range(-TALK_REACH, TALK_REACH + 1):
		for dx in range(-TALK_REACH, TALK_REACH + 1):
			var cell := home + Vector2i(dx, dy)
			if cell == home or not _standable(scene, cell):
				continue
			var spot := scene.map.cell_to_world(cell)
			await _stand(scene, cell, Facing.from_vector(thing.global_position - spot))
			var current := scene.player.sensor.current
			if current != null and current.get_parent() == thing:
				found.append(cell)
	return found


## The things she talks to: the bench, the Antreiber, the cat on his lap and the plan.
func _talkers(scene: HausScene) -> Dictionary:
	return {
		"bench": _decor(scene, "haus/workbench"),
		"antreiber": _antreiber(scene),
		"cat": _lap_cat(scene),
		"plan": _decor(scene, "haus/plan_board"),
	}


func test_she_can_talk_to_each_of_them_and_neither_hides_nor_is_hidden_there() -> void:
	var scene := await _room()
	var talkers := _talkers(scene)
	for name: String in talkers:
		var thing := talkers[name] as Node2D
		assert_not_null(thing, name)
		var home := scene.map.world_to_cell(thing.global_position)
		var cells := await _talk_cells(scene, thing)
		assert_gte(cells.size(), 2, "'%s' can be talked to from %s" % [name, cells])
		var in_front := 0
		for cell in cells:
			var facing := Facing.from_vector(thing.global_position - scene.map.cell_to_world(cell))
			await _stand(scene, cell, facing)
			var cat := "haus/cat_sleep" if name == "antreiber" else ""
			var hidden := _hidden_share(scene, _thing(scene, name), true, cat)
			assert_lte(
				hidden[0] as float,
				PLAN_LIMIT if name == "plan" else HALF,
				"she at %s: '%s' is %s" % [cell, name, _share_text(hidden)]
			)
			var herself := _hidden_share(scene, _pic(scene, scene.player.sprite, "she"), false)
			# beside it or in front of it nothing draws over her; behind it (north) the bench or the
			# man stands in front of her, as a counter does
			var behind := cell.y < home.y
			assert_lte(
				herself[0] as float,
				HALF if behind else STANDING_COVER_LIMIT,
				(
					"she at %s (%s) is %s"
					% [cell, "behind '%s'" % name if behind else name, _share_text(herself)]
				)
			)
			in_front += 0 if behind else 1
		assert_gte(in_front, 1, "'%s' can be talked to from the front or the side" % name)
	assert_push_error_count(0)


func test_the_room_is_as_walkable_as_before_the_bench_took_its_corner() -> void:
	# the room as it was (the Antreiber at the fire) and as it is
	WorldState.set_flag("house.mira_visited")
	WorldState.set_flag("house.fire_lit")
	WorldState.set_flag("house.antreiber_by_fire")
	var old: HausScene = HAUS.instantiate()
	old.mira_after = 120.0
	add_child_autofree(old)
	await wait_physics_frames(3)
	assert_false(WorldState.has_flag("house.workbench"))
	var before := _floor_cells(old, true)
	old.free()
	await wait_physics_frames(2)
	WorldState.new_game()
	WorldState.set_ui_mode(GameState.UiMode.REAL)
	var scene := await _room()
	var now := _floor_cells(scene, true)
	assert_gt(before.size(), 60, "the floor of the room was counted")
	var lost: Array[Vector2i] = []
	for cell in before:
		if not cell in now:
			lost.append(cell)
	assert_lte(lost.size(), 6, "the bench and the man take a few cells of the corner: %s" % [lost])
	for cell in lost:
		assert_true(cell.x >= 21 and cell.y >= 12, "%s is in the corner" % cell)
	# every cell she can stand on is joined to the door: no pocket behind the bench
	var reached := _reachable(scene, Vector2i(19, 14))
	for cell in now:
		assert_true(cell in reached, "%s is joined to the door" % cell)
	for cell in OLD_WAYS:
		assert_eq(cell in now, cell in before, "the old way to %s is as free as it was" % cell)
	for name: String in ["bench", "antreiber", "cat", "plan"]:
		var cells := await _talk_cells(scene, _talkers(scene)[name])
		for cell in cells:
			assert_true(cell in reached, "she gets to %s to talk to the %s" % [cell, name])
	assert_push_error_count(0)


## The floor cells of the room she can stand on.
func _floor_cells(scene: HausScene, _standing: bool) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for y in range(HausScene.ROOM.position.y, HausScene.ROOM.end.y):
		for x in range(HausScene.ROOM.position.x, HausScene.ROOM.end.x):
			if _standable(scene, Vector2i(x, y)):
				found.append(Vector2i(x, y))
	return found


## The cells joined to `start` by steps of one cell over cells she can stand on.
func _reachable(scene: HausScene, start: Vector2i) -> Array[Vector2i]:
	var seen: Array[Vector2i] = [start]
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next := cell + step
			if not next in seen and _standable(scene, next):
				seen.append(next)
				queue.append(next)
	return seen


# --- The hermit on his chair --------------------------------------------------------------


## The key a player presses to move the text on, as the real input path takes it.
func _confirm() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)


## The room at the moment the hermit has sat down: the real scene, played up to there, with the
## lines moved on as a player moves them.
func _room_with_the_guest() -> HausScene:
	var result := SaveCodec.decode(FileAccess.get_file_as_string(FIXTURE))
	assert_true(result.ok, result.error)
	WorldState.replace_state(result.state)
	WorldState.set_flag("beat.act3_morning")
	WorldState.set_day_preset("morgen")
	WorldState.set_flag("forest.hermit_invited")
	WorldState.start_quest(QUEST)
	for stage: String in WAY.slice(1, 5):
		assert_true(WorldState.advance_quest(QUEST, stage), "to " + stage)
	var scene: HausScene = HAUS.instantiate()
	scene.mira_after = 120.0
	add_child_autofree(scene)
	var polls := [0]
	var sat := func() -> bool:
		polls[0] += 1
		if polls[0] % 8 == 0 and scene.dialogue_box.is_open():
			_confirm()
		return WorldState.has_flag("house.guest_hermit")
	var came: bool = await wait_until(sat, 90.0)
	assert_true(came, "the hermit sat down")
	await wait_physics_frames(3)
	return scene


func test_the_hermit_on_his_chair_is_seen_and_so_is_the_chair() -> void:
	var scene := await _room_with_the_guest()
	var guest := _guest(scene)
	assert_not_null(guest, "he sits")
	assert_true(str(guest.sprite.animation).begins_with("sit"), "sitting")
	var man := _pic(scene, guest.sprite, "guest")
	var chair := _thing(scene, "chair")
	assert_true(_over(man, chair), "he is drawn over the chair he sits on")
	var seen := _hidden_share(scene, man)
	assert_lte(seen[0] as float, SITTER_COVER_LIMIT, "he is %s" % _share_text(seen))
	var host := _hidden_share(scene, _thing(scene, "antreiber"), true, "haus/cat_sleep")
	assert_lte(host[0] as float, SITTER_COVER_LIMIT, "the Antreiber is %s" % _share_text(host))
	# the chair stands under him, and enough of it shows round him to be read as one
	var under := _covered(chair, man)
	assert_gt(under, 0, "he sits on it")
	var showing := 1.0 - float(under) / float(_opaque(chair["image"]))
	assert_gte(
		showing,
		0.25,
		"a quarter of the chair at least shows round him (%.0f%%)" % (showing * 100.0)
	)
	var rest := _hidden_share(scene, chair, true)
	assert_eq(rest[1], "guest", "and it is only he who sits on it")
	assert_push_error_count(0)


func test_the_check_knows_the_people_who_sit_or_stand() -> void:
	var scene := await _room_with_the_guest()
	var names: Array[String] = []
	for pic in _pics(scene):
		names.append(pic["label"])
	for label: String in [
		"man antreiber_bench", "guest", "she", "haus/workbench", "haus/guest_chair"
	]:
		assert_true(label in names, "the check sees '%s'" % label)
	var without := _pics(scene, false).filter(
		func(pic: Dictionary) -> bool: return pic["label"] == "she"
	)
	assert_eq(without.size(), 0, "and leaves her out when asked to")


# --- The check itself: does it see what it should? ----------------------------------------


## A copy of the picture of `find` (a prop's own sprite) on the same spot, `dy` pixels further south
## (negative: north) and on `layer`; it is added last, so it stands last among its siblings.
func _cover_of(scene: GameScene, find: Sprite2D, layer: int, dy: float) -> Sprite2D:
	var cover := Sprite2D.new()
	cover.name = "Cover"
	cover.centered = false
	cover.texture = find.texture
	cover.offset = find.offset
	cover.flip_h = find.flip_h
	cover.position = find.get_parent().global_position + Vector2(0, dy)
	cover.z_index = layer
	scene.map.entities.add_child(cover)
	return cover


func test_the_check_sees_a_sprite_that_does_hide_a_thing() -> void:
	var scene := await _room()
	for name: String in ["bench", "plan", "chair", "cat"]:
		var find := _thing(scene, name)
		var sprite: Sprite2D = (find["owner"] as Node).get_node("Sprite")
		var before := _hidden_share(scene, find)
		var layer := int((find["order"] as Vector3).x)
		# a higher layer hides it, whatever the rows say
		var up := _cover_of(scene, sprite, layer + 1, 0.0)
		var after_up := _hidden_share(scene, find)
		up.free()
		assert_gt(after_up[0] as float, 0.6, "'%s' is under its copy one layer up" % name)
		# the same layer decides by the rows: two pixels further south stands in front of it
		var south := _cover_of(scene, sprite, layer, 2.0)
		var after_south := _hidden_share(scene, find)
		south.free()
		assert_gt(after_south[0] as float, 0.6, "'%s' is under its copy to the south" % name)
		assert_lt(before[0] as float, after_south[0] as float)
		# the same row: the one added last (later in the tree) stands in front
		var tied := _cover_of(scene, sprite, layer, 0.0)
		var after_tied := _hidden_share(scene, find)
		tied.free()
		assert_gt(after_tied[0] as float, 0.6, "'%s' is under its copy in the same row" % name)
		# two pixels further north (or one layer down) stands behind it and hides nothing
		var north := _cover_of(scene, sprite, layer, -2.0)
		var after_north := _hidden_share(scene, find)
		north.free()
		assert_eq(after_north[0], before[0], "'%s': its copy to the north is behind it" % name)
		var down := _cover_of(scene, sprite, layer - 1, 2.0)
		var after_down := _hidden_share(scene, find)
		down.free()
		assert_eq(after_down[0], before[0], "'%s': its copy one layer down is behind it" % name)


func test_the_check_sees_a_sprite_that_hides_the_man_who_sits() -> void:
	var scene := await _room()
	var man := _antreiber(scene)
	var find := _thing(scene, "antreiber")
	var animated := man.sprite
	var texture := animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
	var before := _hidden_share(scene, find, true, "haus/cat_sleep")
	var layer := int((find["order"] as Vector3).x)
	for case: Array in [[layer + 1, 0.0, true], [layer, 2.0, true], [layer, -2.0, false]]:
		var cover := Sprite2D.new()
		cover.name = "Cover"
		cover.centered = false
		cover.texture = texture
		cover.flip_h = animated.flip_h
		cover.offset = (
			animated.offset - Vector2(texture.get_size()) / 2.0
			if animated.centered
			else animated.offset
		)
		cover.position = man.global_position + Vector2(0, case[1] as float)
		cover.z_index = case[0] as int
		scene.map.entities.add_child(cover)
		var after := _hidden_share(scene, find, true, "haus/cat_sleep")
		cover.free()
		if case[2]:
			assert_gt(after[0] as float, 0.6, "he is under his copy %s" % [case])
		else:
			assert_eq(after[0], before[0], "his copy to the north is behind him")


func test_the_check_sees_her_on_the_bench_and_a_cell_that_is_blocked() -> void:
	var scene := await _room()
	var bench := _thing(scene, "bench")
	var apart := _hidden_share(scene, bench)
	assert_lte(apart[0] as float, SMALL_COVER_LIMIT, "she stands far from it")
	# she on the bench's own cell, south of its middle: a good part of it is under her
	var south_of_the_bench := Vector2i(24, 15)
	await _stand(scene, south_of_the_bench, Facing.Dir.N)
	scene.player.global_position += Vector2(0, 4)
	await wait_physics_frames(1)
	var near := _hidden_share(scene, bench)
	assert_gt(near[0] as float, apart[0] as float, "she covers some of it, standing in front")
	assert_eq(near[1], "she")
	var alone := _hidden_share(scene, bench, false)
	assert_eq(alone[0], apart[0], "asked to leave her out, the check does")
	# the cells: the bench is a wall of three, the door's is free, the wall is no floor
	for x: int in [23, 24, 25]:
		assert_false(
			_standable(scene, Vector2i(x, 14)), "she does not walk through the bench at %d" % x
		)
	assert_true(_standable(scene, Vector2i(24, 15)), "she can stand in front of it")
	assert_true(_standable(scene, Vector2i(19, 14)), "the way to the door is free")
	assert_false(_standable(scene, Vector2i(19, 6)), "the wall is no floor")
	# looking away from the bench she has nothing to talk to
	await _stand(scene, south_of_the_bench, Facing.Dir.S)
	var current := scene.player.sensor.current
	assert_true(current == null or current.get_parent() != _decor(scene, "haus/workbench"))
	assert_push_error_count(0)
