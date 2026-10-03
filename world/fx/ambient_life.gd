class_name AmbientLife
extends Node2D
## Small animals that make a scene feel alive (look prototype): bird flocks with ground
## shadows crossing the view, fish (or koi) swimming in water cells, dragonflies darting
## over water. Pure decoration: no collision, deterministic enough for captures.

const FX_DIR := "res://assets/generated/props/fx/"

var view: GameView
var map: MapView
var _rng := RandomNumberGenerator.new()
var _flock_timer := 2.0
var _flock_interval := 0.0
var _flock_tint := Color.WHITE
var _birds: Array[Dictionary] = []
var _swimmers: Array[Dictionary] = []
var _darters: Array[Dictionary] = []
var _water_cells: Array[Vector2i] = []
var _time := 0.0


func _init() -> void:
	process_priority = 10
	_rng.seed = 11


func setup(game_view: GameView, map_view: MapView) -> void:
	view = game_view
	map = map_view
	for y in map.data.height:
		for x in map.data.width:
			if (
				map.data.surface_at_cell(Vector2i(x, y)) == &"water"
				and _is_open_water(Vector2i(x, y))
			):
				_water_cells.append(Vector2i(x, y))


## Flocks every `interval` seconds on average; `tint` darkens birds for dusk or bats.
func enable_birds(interval: float, tint: Color = Color.WHITE) -> void:
	_flock_interval = interval
	_flock_tint = tint


func add_swimmers(count: int, texture_name: String) -> void:
	if _water_cells.is_empty():
		return
	var texture := load(FX_DIR + texture_name) as Texture2D
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.vframes = 2
		sprite.z_index = -4
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		var at := _random_water_point()
		sprite.position = at
		_swimmers.append({"sprite": sprite, "pos": at, "goal": _random_water_point(), "rest": 0.0})


func add_darters(count: int) -> void:
	if _water_cells.is_empty():
		return
	var texture := load(FX_DIR + "dragonfly.png") as Texture2D
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.vframes = 2
		sprite.z_index = 30
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		var home := _random_water_point() + Vector2(0, -10)
		sprite.position = home
		_darters.append({"sprite": sprite, "home": home, "pos": home, "goal": home, "rest": 0.0})


func _process(delta: float) -> void:
	_time += delta
	_update_flocks(delta)
	for f: Dictionary in _swimmers:
		_swim(f, delta)
	for d: Dictionary in _darters:
		_dart(d, delta)


func _update_flocks(delta: float) -> void:
	if _flock_interval > 0.0:
		_flock_timer -= delta
		if _flock_timer <= 0.0:
			_flock_timer = _flock_interval * _rng.randf_range(0.6, 1.4)
			_spawn_flock()
	var cam := view.camera_position
	for i in range(_birds.size() - 1, -1, -1):
		var b: Dictionary = _birds[i]
		var pos: Vector2 = b["pos"] + (b["vel"] as Vector2) * delta
		b["pos"] = pos
		var bird: Sprite2D = b["sprite"]
		var shadow: Sprite2D = b["shadow"]
		var wobble := sin(_time * 3.0 + float(b["phase"])) * 2.0
		bird.position = (pos + Vector2(0, wobble)).round()
		bird.frame = 0 if fmod(_time * 6.0 + float(b["phase"]), 1.0) < 0.5 else 1
		shadow.position = (pos + Vector2(18, 46)).round()
		if pos.distance_to(cam) > 520.0:
			bird.queue_free()
			shadow.queue_free()
			_birds.remove_at(i)


func _spawn_flock() -> void:
	var cam := view.camera_position
	var from_left := _rng.randf() < 0.5
	var start := cam + Vector2(-380.0 if from_left else 380.0, _rng.randf_range(-170.0, 60.0))
	var dir := Vector2(1.0 if from_left else -1.0, _rng.randf_range(-0.25, 0.25)).normalized()
	var speed := _rng.randf_range(55.0, 80.0)
	for i in _rng.randi_range(3, 6):
		var bird := Sprite2D.new()
		bird.texture = load(FX_DIR + "bird_fly.png")
		bird.vframes = 2
		bird.z_index = 45
		bird.modulate = _flock_tint
		bird.flip_h = not from_left
		bird.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(bird)
		var shadow := Sprite2D.new()
		shadow.texture = load(FX_DIR + "bird_shadow.png")
		shadow.z_index = -4
		shadow.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(shadow)
		var offset := Vector2(-dir.x * i * 9.0, (i % 2) * 7.0 - 3.0 + i * 2.0)
		(
			_birds
			. append(
				{
					"sprite": bird,
					"shadow": shadow,
					"pos": start + offset,
					"vel": dir * speed,
					"phase": _rng.randf() * TAU,
				}
			)
		)


func _swim(f: Dictionary, delta: float) -> void:
	var sprite: Sprite2D = f["sprite"]
	if float(f["rest"]) > 0.0:
		f["rest"] = float(f["rest"]) - delta
		sprite.frame = 0
		return
	var pos: Vector2 = f["pos"]
	var goal: Vector2 = f["goal"]
	var to_goal := goal - pos
	if to_goal.length() < 2.0:
		f["goal"] = _random_water_point()
		f["rest"] = _rng.randf_range(0.5, 2.5)
		return
	pos += to_goal.normalized() * 12.0 * delta
	f["pos"] = pos
	sprite.position = pos.round()
	sprite.flip_h = to_goal.x < 0.0
	sprite.frame = 0 if fmod(_time * 4.0 + pos.x * 0.1, 1.0) < 0.5 else 1


func _dart(d: Dictionary, delta: float) -> void:
	var sprite: Sprite2D = d["sprite"]
	sprite.frame = 0 if fmod(_time * 18.0, 1.0) < 0.5 else 1
	if float(d["rest"]) > 0.0:
		d["rest"] = float(d["rest"]) - delta
		return
	var pos: Vector2 = d["pos"]
	var goal: Vector2 = d["goal"]
	var to_goal := goal - pos
	if to_goal.length() < 1.5:
		var home: Vector2 = d["home"]
		d["goal"] = home + Vector2(_rng.randf_range(-40, 40), _rng.randf_range(-18, 18))
		d["rest"] = _rng.randf_range(0.3, 1.6)
		return
	pos += to_goal.normalized() * minf(90.0 * delta, to_goal.length())
	d["pos"] = pos
	sprite.position = pos.round()


func _random_water_point() -> Vector2:
	var cell := _water_cells[_rng.randi_range(0, _water_cells.size() - 1)]
	var ts := float(map.data.tile_size)
	return (
		map.cell_to_world(cell)
		+ Vector2(_rng.randf_range(-0.3, 0.3), _rng.randf_range(-0.3, 0.3)) * ts
	)


## Only cells whose four neighbours are water too, so swimmers stay off the banks.
func _is_open_water(cell: Vector2i) -> bool:
	for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if map.data.surface_at_cell(cell + d) != &"water":
			return false
	return true
