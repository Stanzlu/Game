class_name ForegroundFoliage
extends Node2D
## Leaves between the camera and the valley (ADR-043): dark crowns along the southern forest,
## the part of the world nearest to the camera in this view. They slide past a little faster
## than the ground, so the world gets a front as well as a back: when the camera comes down to
## the forest they rise into the bottom of the view, when it moves away they leave first.
## Never over a path that leaves the map. Elysia has none.

## How much faster than the ground they move (1 = fixed to the ground).
const FACTOR := 1.22
## Close and out of the light: darker than anything on the ground. Each leaf is lit a little
## on the side towards the sun (top left).
const LEAF_DARK := Color("#06100a")
const LEAF_MID := Color("#0c1c12")
const LEAF_LIT := Color("#183322")
const EXIT_CLEARANCE := 4
## Size of a baked crown in world pixels (centered on where it rests).
const SIZE := Vector2i(128, 72)
## How far the crowns rise above the map's bottom edge when the camera is down there.
const RISE := 10.0

var view: GameView
## False when the player turned parallax off (Settings "display.parallax").
var parallax := true
## Per crown: "rest" (world position with the camera at the bottom of the map) and
## "texture" (baked leaves, centered on it).
var _crowns: Array[Dictionary] = []
## Where the camera is when it is all the way down at the southern forest.
var _camera_down := Vector2.ZERO
var _last_camera := Vector2.INF


func _init() -> void:
	z_index = 40
	process_priority = 10
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


## Grows crowns along the bottom edge of `map` where it is forest, about `spacing` cells
## apart.
func setup(game_view: GameView, map: MapView, spacing := 4, seed_value := 7) -> void:
	view = game_view
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var data := map.data
	var bottom := map.world_rect().end.y
	_camera_down = Vector2(0.0, bottom - view.view_size.y * 0.5)
	for x in range(spacing / 2, data.width, spacing):
		var cell := Vector2i(x, data.height - 1)
		if not data.is_solid(cell) or _near_exit(data, cell):
			continue
		var rest := Vector2(map.cell_to_world(cell).x + rng.randf_range(-12.0, 12.0), bottom - RISE)
		_crowns.append({"rest": rest.round(), "texture": _bake(rng)})


## Paints one crown into a texture: many big leaves heaped into a mass with a leafy top edge.
## The leaves are bigger than any on the ground (they are closer). Baked once, so they stay
## crisp pixels and overlap without stacking transparency.
static func _bake(rng: RandomNumberGenerator) -> ImageTexture:
	var image := Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	var middle := Vector2(SIZE) * 0.5
	var leaves: Array[Vector3] = []
	for i in rng.randi_range(34, 44):
		var x := rng.randfn(0.0, 22.0)
		# the crown is round on top: higher in the middle
		var top := -14.0 * (1.0 - minf(absf(x) / 48.0, 1.0))
		var y := top + absf(rng.randfn(0.0, 11.0))
		leaves.append(Vector3(x, y, rng.randf_range(4.0, 7.5)))
	# the lower leaves are nearer and cover the ones above them
	leaves.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.y < b.y)
	for leaf in leaves:
		var c := middle + Vector2(leaf.x, leaf.y)
		var r := leaf.z
		for y in range(int(c.y - r), int(c.y + r) + 1):
			for x in range(int(c.x - r), int(c.x + r) + 1):
				if x < 0 or y < 0 or x >= SIZE.x or y >= SIZE.y:
					continue
				var d := Vector2(x + 0.5, y + 0.5) - c
				if d.length() > r:
					continue
				var towards_light := -(d.x + d.y) / r
				var color := LEAF_DARK
				if towards_light > 1.05:
					color = LEAF_LIT
				elif towards_light > 0.4:
					color = LEAF_MID
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _process(_delta: float) -> void:
	if view != null and view.camera_position != _last_camera:
		_last_camera = view.camera_position
		queue_redraw()


## Where a crown resting at `rest` is drawn with the camera at `camera`.
func position_for(rest: Vector2, camera: Vector2) -> Vector2:
	if not parallax:
		return rest
	# closer than the ground: it moves FACTOR times as fast, around the spot where it rests
	var down := Vector2(rest.x, _camera_down.y)
	return rest + (down - camera) * (FACTOR - 1.0)


func _draw() -> void:
	if view == null:
		return
	var cam := view.camera_position
	var reach := Vector2(view.view_size) * 0.5 + Vector2(SIZE) * 0.5
	for crown: Dictionary in _crowns:
		var at := position_for(crown["rest"], cam)
		if absf(at.x - cam.x) > reach.x or absf(at.y - cam.y) > reach.y:
			continue
		draw_texture(crown["texture"], (at - Vector2(SIZE) * 0.5).round())


## Keeps paths that leave the map free.
static func _near_exit(data: MapData, cell: Vector2i) -> bool:
	for d in range(-EXIT_CLEARANCE, EXIT_CLEARANCE + 1):
		if not data.is_solid(cell + Vector2i(d, 0)):
			return true
	return false
