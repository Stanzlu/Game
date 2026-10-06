class_name AmbientLife
extends Node2D
## Small animals that make a scene feel alive (look prototype): bird flocks with ground
## shadows crossing the view, fish (or koi) swimming in water cells, dragonflies darting
## over water, frogs on the banks that hop off when someone comes too close (the real
## world, ADR-041). Pure decoration: no collision, deterministic enough for captures.
##
## Perfect loops (Elysia, Game Bible §9 and §35): the same flock in the same formation
## crosses on an exact beat, koi circle the pool evenly spaced, dragonflies fly mirrored
## figure eights. Nothing is random, so attentive players start to notice the repetition.

const FX_DIR := "res://assets/generated/props/fx/"
## Frogs hop off when someone comes this close; one hop takes this long.
const FROG_SHY := 30.0
const FROG_HOP_SECONDS := 0.42

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
var _bank_cells: Array[Vector2i] = []
var _frogs: Array[Dictionary] = []
var _time := 0.0
var _perfect := false
var _mirror_x := 0.0
var _orbit := Rect2()


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
			elif _is_bank(Vector2i(x, y)):
				_bank_cells.append(Vector2i(x, y))


## Flocks every `interval` seconds on average; `tint` darkens birds for dusk or bats.
func enable_birds(interval: float, tint: Color = Color.WHITE) -> void:
	_flock_interval = interval
	_flock_tint = tint


## Switches to perfect loops. `mirror_x` is the world x of the symmetry axis; `orbit`
## (center and radii in pixels) is the koi circle; an empty orbit keeps koi wandering.
func enable_perfect_loops(mirror_x: float, orbit: Rect2 = Rect2()) -> void:
	_perfect = true
	_mirror_x = mirror_x
	_orbit = orbit


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
		(
			_swimmers
			. append(
				{
					"sprite": sprite,
					"pos": at,
					"goal": _random_water_point(),
					"rest": 0.0,
					"angle": TAU * float(i) / float(count),
				}
			)
		)


## Dragonflies over open water. With perfect loops they come in mirrored pairs.
func add_darters(count: int) -> void:
	if _water_cells.is_empty():
		return
	var texture := load(FX_DIR + "dragonfly.png") as Texture2D
	var homes: Array[Vector2] = []
	var twins: Array[bool] = []
	for i in count:
		var home := _random_water_point() + Vector2(0, -10)
		if _perfect:
			if i % 2 == 1:
				home = Vector2(2.0 * _mirror_x - homes[i - 1].x, homes[i - 1].y)
			else:
				home = _water_point_left_of(_mirror_x - 24.0) + Vector2(0, -10)
		homes.append(home)
		twins.append(_perfect and i % 2 == 1)
	if _perfect and count % 2 == 1:
		homes.append(Vector2(2.0 * _mirror_x - homes[-1].x, homes[-1].y))
		twins.append(true)
	for i in homes.size():
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.vframes = 2
		sprite.z_index = 30
		sprite.flip_h = twins[i]
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		var home := homes[i]
		sprite.position = home
		(
			_darters
			. append(
				{
					"sprite": sprite,
					"home": home,
					"pos": home,
					"goal": home,
					"rest": 0.0,
					"twin": twins[i],
				}
			)
		)


## Frogs sitting on the banks. They hop a little now and then, and away from anyone who
## comes within reach.
func add_frogs(count: int) -> void:
	if _bank_cells.is_empty():
		return
	var texture := load(FX_DIR + "frog.png") as Texture2D
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.vframes = 2
		sprite.offset = Vector2(0, -3)
		# above the grass tufts on the bank, so one actually sees them
		sprite.z_index = 1
		sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(sprite)
		var at := _random_bank_point()
		sprite.position = at
		sprite.flip_h = _rng.randf() < 0.5
		(
			_frogs
			. append(
				{
					"sprite": sprite,
					"pos": at,
					"from": at,
					"to": at,
					"hop": -1.0,
					"rest": _rng.randf_range(3.0, 9.0),
				}
			)
		)


func _process(delta: float) -> void:
	_time += delta
	_update_flocks(delta)
	if not _frogs.is_empty():
		var player := get_tree().get_first_node_in_group(&"player") as Node2D
		for frog: Dictionary in _frogs:
			_frog(frog, delta, player)
	for f: Dictionary in _swimmers:
		if _perfect and _orbit.size != Vector2.ZERO:
			_circle(f)
		else:
			_swim(f, delta)
	for d: Dictionary in _darters:
		if _perfect:
			_figure_eight(d)
		else:
			_dart(d, delta)


func _update_flocks(delta: float) -> void:
	if _flock_interval > 0.0:
		_flock_timer -= delta
		if _flock_timer <= 0.0:
			if _perfect:
				_flock_timer += _flock_interval
				_spawn_perfect_flock()
			else:
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
		var offset := Vector2(-dir.x * i * 9.0, (i % 2) * 7.0 - 3.0 + i * 2.0)
		_add_bird(start + offset, dir * speed, not from_left, _rng.randf() * TAU)


## Always the same five birds in a clean V, left to right, wings beating together.
func _spawn_perfect_flock() -> void:
	var start := view.camera_position + Vector2(-380.0, -110.0)
	for i in 5:
		var rank := floorf((i + 1) * 0.5)
		var side := -1.0 if i % 2 == 1 else 1.0
		_add_bird(start + Vector2(-rank * 12.0, rank * 8.0 * side), Vector2(64.0, 0.0), false, 0.0)


func _add_bird(at: Vector2, velocity: Vector2, flip: bool, phase: float) -> void:
	var bird := Sprite2D.new()
	bird.texture = load(FX_DIR + "bird_fly.png")
	bird.vframes = 2
	bird.z_index = 45
	bird.modulate = _flock_tint
	bird.flip_h = flip
	bird.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(bird)
	var shadow := Sprite2D.new()
	shadow.texture = load(FX_DIR + "bird_shadow.png")
	shadow.z_index = -4
	shadow.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(shadow)
	_birds.append({"sprite": bird, "shadow": shadow, "pos": at, "vel": velocity, "phase": phase})


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


## Koi evenly spaced on one ellipse, all at the same pace, tails in step.
func _circle(f: Dictionary) -> void:
	var sprite: Sprite2D = f["sprite"]
	var a := float(f["angle"]) + _time * 0.2
	var radii := _orbit.size
	sprite.position = (_orbit.position + Vector2(cos(a) * radii.x, sin(a) * radii.y)).round()
	sprite.flip_h = sin(a) > 0.0
	sprite.frame = 0 if fmod(_time * 4.0, 1.0) < 0.5 else 1


## One figure eight per 4.8 s around the home point; twins fly it mirrored.
func _figure_eight(d: Dictionary) -> void:
	var sprite: Sprite2D = d["sprite"]
	var t := _time * 1.3
	var side := -1.0 if bool(d["twin"]) else 1.0
	var home: Vector2 = d["home"]
	sprite.position = (home + Vector2(sin(t) * 28.0 * side, sin(t * 2.0) * 9.0)).round()
	sprite.frame = 0 if fmod(_time * 18.0, 1.0) < 0.5 else 1


func _water_point_left_of(max_x: float) -> Vector2:
	for attempt in 32:
		var at := _random_water_point()
		if at.x < max_x:
			return at
	return _random_water_point()


func _random_water_point() -> Vector2:
	var cell := _water_cells[_rng.randi_range(0, _water_cells.size() - 1)]
	var ts := float(map.data.tile_size)
	return (
		map.cell_to_world(cell)
		+ Vector2(_rng.randf_range(-0.3, 0.3), _rng.randf_range(-0.3, 0.3)) * ts
	)


func _frog(f: Dictionary, delta: float, player: Node2D) -> void:
	var sprite: Sprite2D = f["sprite"]
	var pos: Vector2 = f["pos"]
	if float(f["hop"]) >= 0.0:
		var t := minf(float(f["hop"]) + delta / FROG_HOP_SECONDS, 1.0)
		f["hop"] = t
		pos = (f["from"] as Vector2).lerp(f["to"], t)
		f["pos"] = pos
		sprite.position = pos + Vector2(0, -7.0 * sin(PI * t))
		sprite.frame = 1
		if t >= 1.0:
			f["hop"] = -1.0
			f["rest"] = _rng.randf_range(4.0, 12.0)
			sprite.frame = 0
		return
	f["rest"] = float(f["rest"]) - delta
	var away := Vector2.ZERO
	if player != null and player.global_position.distance_to(pos) < FROG_SHY:
		away = (pos - player.global_position).normalized()
	elif float(f["rest"]) > 0.0:
		return
	# hop: away from the player, or a little way along the bank
	var target := (
		pos
		+ (away * 40.0 if away != Vector2.ZERO else Vector2.from_angle(_rng.randf() * TAU) * 20.0)
	)
	f["from"] = pos
	f["to"] = _nearest_bank_point(target)
	f["hop"] = 0.0
	sprite.flip_h = (f["to"] as Vector2).x < pos.x


func _random_bank_point() -> Vector2:
	var cell := _bank_cells[_rng.randi() % _bank_cells.size()]
	return map.cell_to_world(cell) + Vector2(_rng.randf_range(-5, 5), _rng.randf_range(-4, 4))


func _nearest_bank_point(near: Vector2) -> Vector2:
	var best := _bank_cells[0]
	var best_d := INF
	for cell in _bank_cells:
		var d := map.cell_to_world(cell).distance_squared_to(near)
		if d < best_d:
			best_d = d
			best = cell
	return map.cell_to_world(best) + Vector2(_rng.randf_range(-4, 4), _rng.randf_range(-3, 3))


## Walkable land right next to water: where frogs sit.
func _is_bank(cell: Vector2i) -> bool:
	if map.data.surface_at_cell(cell) == &"water" or map.data.is_solid(cell):
		return false
	for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if map.data.surface_at_cell(cell + d) == &"water":
			return true
	return false


## Only cells whose four neighbours are water too, so swimmers stay off the banks.
func _is_open_water(cell: Vector2i) -> bool:
	for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if map.data.surface_at_cell(cell + d) != &"water":
			return false
	return true
