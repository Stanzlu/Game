class_name TitleBackground
extends Node2D
## Animated backdrop of the start menu, in two moods (ADR-030, Game Bible §10 and §56):
##
## ELYSIA (before the crossing): the game pretends to be a classic fantasy RPG. Morning sky,
## the mirror-symmetric island with the world tree and twin waterfalls, islets bobbing in
## pairs, clouds and one flock of birds that come back on an exact beat. Perfect, calm and
## a little too beautiful (Game Bible §9).
## REAL (after the crossing): an evening valley. A crooked tree and the grass move in
## irregular gusts, leaves blow past, a lantern flickers, the first stars come out, birds
## fly when they want to (Game Bible §12).

enum Mode { ELYSIA, REAL }

const SKY_SHADER := preload("res://world/shaders/sky.gdshader")
const SCROLL_SHADER := preload("res://ui/title/scroll.gdshader")
const ISLAND := preload("res://assets/generated/title/island.png")
const WATERFALL := preload("res://assets/generated/title/waterfall.png")
const VALLEY := preload("res://assets/generated/title/valley.png")
const RAYS := preload("res://assets/generated/ui/rays_large.png")
const PROPS := "res://assets/generated/props/elysia/"
const TAL := "res://assets/generated/props/tal/"
const FX := "res://assets/generated/props/fx/"
const SIZE := Vector2(640, 360)
## Island centered under the logo (the whole Elysia title is mirror-symmetric).
const ISLAND_AT := Vector2(155, 44)
## Where the water leaves the plateau, in island pixels (make_title.py layout).
const FALL_AT := Vector2(286, 215)
const VALLEY_Y := 160.0
const FLOCK_BEAT := 8.0

var mode := Mode.ELYSIA
var _layers: Array[Dictionary] = []
var _island: Sprite2D
var _falls: Array[TextureRect] = []
var _glow: Sprite2D
var _lamp_glow: Sprite2D
var _stars: Array[Sprite2D] = []
var _birds: Array[Dictionary] = []
var _time := 0.0
var _next_flock := 3.0
var _rng := RandomNumberGenerator.new()


## Builds the backdrop for `title_mode`; call once, right after the node entered the tree.
func build(title_mode: Mode) -> void:
	mode = title_mode
	_rng.seed = 5
	if mode == Mode.ELYSIA:
		_build_elysia()
	else:
		_build_real()


func _build_elysia() -> void:
	_add_sky(Color(0.36, 0.56, 0.9), Color(1.0, 0.86, 0.9))
	_glow = Sprite2D.new()
	_glow.texture = RAYS
	_glow.scale = Vector2(1.6, 1.6)
	_glow.position = ISLAND_AT + Vector2(165, 110)
	_glow.modulate = Color(1, 0.95, 0.8, 0.22)
	add_child(_glow)
	# clouds wrap around and come back exactly the same (Game Bible §9 "Wolken wiederholen sich")
	_add_drifter(PROPS + "cloud_1.png", Vector2(40, 30), -3.0, 0.0, 0.55)
	_add_drifter(PROPS + "cloud_0.png", Vector2(420, 70), -3.0, 0.0, 0.6)
	_add_drifter(PROPS + "cloud_2.png", Vector2(250, 150), -3.0, 0.0, 0.7)
	# islets in mirrored pairs that bob in step
	for pair: Array in [["islet_1.png", Vector2(40, 236)], ["islet_0.png", Vector2(96, 296)]]:
		var tex := load(PROPS + str(pair[0])) as Texture2D
		var at: Vector2 = pair[1]
		_add_drifter(PROPS + str(pair[0]), at, 0.0, 2.0, 0.9, 0.0)
		var twin := Vector2(SIZE.x - at.x - tex.get_width(), at.y)
		_add_drifter(PROPS + str(pair[0]), twin, 0.0, 2.0, 0.9, 0.0, true)
	_island = Sprite2D.new()
	_island.texture = ISLAND
	_island.centered = false
	_island.position = ISLAND_AT
	add_child(_island)
	for side in 2:
		var fall := TextureRect.new()
		fall.texture = WATERFALL
		fall.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fall.flip_h = side == 1
		var fall_mat := ShaderMaterial.new()
		fall_mat.shader = SCROLL_SHADER
		fall.material = fall_mat
		add_child(fall)
		_falls.append(fall)
	_add_petals()
	_add_drifter(PROPS + "cloud_1.png", Vector2(470, 318), -6.0, 0.0, 0.95)
	_add_drifter(PROPS + "cloud_2.png", Vector2(120, 330), -6.0, 0.0, 0.9)
	_next_flock = 2.0


func _build_real() -> void:
	_add_sky(Color(0.2, 0.22, 0.4), Color(0.98, 0.7, 0.52))
	for i in 14:
		var star := Sprite2D.new()
		star.texture = load(FX + "mote.png")
		star.position = Vector2(_rng.randf_range(200, 630), _rng.randf_range(6, 70)).round()
		star.modulate = Color(1, 0.96, 0.88, 0.0)
		star.set_meta(&"phase", _rng.randf() * TAU)
		star.set_meta(&"rate", _rng.randf_range(0.6, 1.7))
		add_child(star)
		_stars.append(star)
	var dusk := Color(1.0, 0.82, 0.78)
	_add_drifter(PROPS + "cloud_0.png", Vector2(300, 40), -2.2, 0.0, 0.5, 0.0, false, dusk)
	_add_drifter(PROPS + "cloud_2.png", Vector2(60, 92), -3.1, 0.0, 0.45, 0.0, false, dusk)
	_add_drifter(PROPS + "cloud_1.png", Vector2(520, 118), -4.3, 0.0, 0.4, 0.0, false, dusk)
	var valley := Sprite2D.new()
	valley.texture = VALLEY
	valley.centered = false
	valley.position = Vector2(0, VALLEY_Y)
	add_child(valley)
	# the fence along the meadow is not kept up any more
	var fence := ["fence.png", "fence_broken_0.png", "fence.png", "fence_broken_2.png"]
	for i in fence.size():
		_add_prop(TAL + fence[i], Vector2(548 + i * 16, 318), Vector2(9, 14))
	_add_prop(TAL + "fence_post.png", Vector2(612, 320), Vector2(4, 22))
	_add_prop(TAL + "lantern.png", Vector2(392, 306), Vector2(6, 38))
	_add_prop(TAL + "bench.png", Vector2(418, 310), Vector2(10, 18))
	var tree := _add_prop(TAL + "tree_crooked_0.png", Vector2(500, 304), Vector2(50, 101))
	tree.material = Decor.sway_material(1.4)
	var halo := Gradient.new()
	halo.set_color(0, Color(1, 1, 1, 1))
	halo.set_color(1, Color(1, 1, 1, 0))
	var glow := GradientTexture2D.new()
	glow.gradient = halo
	glow.width = 56
	glow.height = 56
	glow.fill = GradientTexture2D.FILL_RADIAL
	glow.fill_from = Vector2(0.5, 0.5)
	glow.fill_to = Vector2(1.0, 0.5)
	_lamp_glow = Sprite2D.new()
	_lamp_glow.texture = glow
	_lamp_glow.position = Vector2(392, 277)
	_lamp_glow.modulate = Color(1.0, 0.62, 0.3, 0.3)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lamp_glow.material = add
	add_child(_lamp_glow)
	_add_leaves()
	_next_flock = 4.0


func _add_sky(top: Color, bottom: Color) -> void:
	var sky := ColorRect.new()
	sky.size = SIZE
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = SKY_SHADER
	sky_mat.set_shader_parameter("top", top)
	sky_mat.set_shader_parameter("bottom", bottom)
	sky_mat.set_shader_parameter("steps", 9.0)
	sky.material = sky_mat
	add_child(sky)


func _add_prop(path: String, base: Vector2, anchor: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(path)
	sprite.centered = false
	sprite.offset = -anchor
	sprite.position = base
	add_child(sprite)
	return sprite


func _add_drifter(
	path: String,
	at: Vector2,
	speed: float,
	bob: float,
	alpha: float,
	phase := NAN,
	flip := false,
	tint := Color.WHITE
) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = load(path)
	sprite.centered = false
	sprite.flip_h = flip
	sprite.modulate = Color(tint.r, tint.g, tint.b, alpha)
	add_child(sprite)
	(
		_layers
		. append(
			{
				"sprite": sprite,
				"x": at.x,
				"y": at.y,
				"speed": speed,
				"bob": bob,
				"phase": at.x if is_nan(phase) else phase,
			}
		)
	)


func _add_petals() -> void:
	var petals := CPUParticles2D.new()
	petals.texture = load(FX + "petal.png")
	petals.amount = 26
	petals.lifetime = 9.0
	petals.preprocess = 9.0
	petals.position = ISLAND_AT + Vector2(165, 70)
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	petals.emission_rect_extents = Vector2(110, 40)
	petals.direction = Vector2(0, 1)
	petals.spread = 20.0
	petals.initial_velocity_min = 8.0
	petals.initial_velocity_max = 8.0
	petals.gravity = Vector2(0, 6)
	petals.angular_velocity_min = 90.0
	petals.angular_velocity_max = 90.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 0.8, 0.9, 0.0))
	fade.add_point(0.1, Color(1, 0.8, 0.9, 1.0))
	fade.set_color(fade.get_point_count() - 1, Color(1, 0.8, 0.9, 0.0))
	petals.color_ramp = fade
	add_child(petals)


func _add_leaves() -> void:
	var leaves := CPUParticles2D.new()
	leaves.name = "Leaves"
	leaves.texture = load(FX + "leaf.png")
	leaves.amount = 10
	leaves.lifetime = 8.0
	leaves.preprocess = 8.0
	leaves.position = Vector2(560, 200)
	leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	leaves.emission_rect_extents = Vector2(90, 110)
	leaves.direction = Vector2(-1, 0.15)
	leaves.spread = 18.0
	leaves.initial_velocity_min = 22.0
	leaves.initial_velocity_max = 48.0
	leaves.gravity = Vector2(-14, 9)
	leaves.angular_velocity_min = -360.0
	leaves.angular_velocity_max = 360.0
	add_child(leaves)


func _process(delta: float) -> void:
	_time += delta
	for layer in _layers:
		var sprite: Sprite2D = layer["sprite"]
		layer["x"] = float(layer["x"]) + float(layer["speed"]) * delta
		var w := float(sprite.texture.get_width())
		if float(layer["x"]) < -w:
			layer["x"] = SIZE.x + 4.0
		var bob := float(layer["bob"]) * sin(_time * 0.8 + float(layer["phase"]))
		sprite.position = Vector2(float(layer["x"]), float(layer["y"]) + bob).round()
	if mode == Mode.ELYSIA:
		var island_bob := roundf(2.0 * sin(_time * 0.6))
		_island.position = ISLAND_AT + Vector2(0, island_bob)
		_falls[0].position = ISLAND_AT + FALL_AT + Vector2(0, island_bob)
		var left_x := float(ISLAND.get_width()) - FALL_AT.x - float(WATERFALL.get_width())
		_falls[1].position = ISLAND_AT + Vector2(left_x, FALL_AT.y + island_bob)
		_glow.rotation = _time * 0.02
	else:
		_update_evening()
	_update_birds(delta)


## Stars fade in and twinkle, the lantern flickers, the leaves come in gusts.
func _update_evening() -> void:
	for star in _stars:
		var t := _time * float(star.get_meta(&"rate")) + float(star.get_meta(&"phase"))
		var rise := clampf(_time / 6.0, 0.0, 1.0)
		star.modulate.a = rise * (0.35 + 0.35 * sin(t))
	var flicker := 0.3 + 0.05 * sin(_time * 13.0) + 0.04 * sin(_time * 7.3 + 1.0)
	_lamp_glow.modulate.a = flicker
	var leaves := get_node_or_null("Leaves") as CPUParticles2D
	if leaves != null:
		var push := sin(_time * 0.37) + 0.6 * sin(_time * 0.91 + 1.3) + 0.3 * sin(_time * 2.3)
		leaves.speed_scale = clampf(0.55 + 0.45 * push, 0.25, 1.8)


func _update_birds(delta: float) -> void:
	_next_flock -= delta
	if _next_flock <= 0.0:
		if mode == Mode.ELYSIA:
			# the same flock on an exact beat, every time (Game Bible §9 and §35)
			_next_flock += FLOCK_BEAT
			_spawn_flock(true, 60.0, Vector2(42, 0), 5)
		else:
			_next_flock = _rng.randf_range(9.0, 16.0)
			var from_left := _rng.randf() < 0.5
			var velocity := (
				Vector2(1.0 if from_left else -1.0, _rng.randf_range(-0.12, 0.08))
				* _rng.randf_range(30.0, 46.0)
			)
			_spawn_flock(from_left, _rng.randf_range(30.0, 120.0), velocity, _rng.randi_range(2, 5))
	for i in range(_birds.size() - 1, -1, -1):
		var bird: Dictionary = _birds[i]
		var sprite: Sprite2D = bird["sprite"]
		bird["pos"] = (bird["pos"] as Vector2) + (bird["vel"] as Vector2) * delta
		sprite.position = (bird["pos"] as Vector2).round()
		sprite.frame = int(_time * 6.0 + float(bird["phase"])) % 2
		if sprite.position.x < -40 or sprite.position.x > SIZE.x + 40:
			sprite.queue_free()
			_birds.remove_at(i)


func _spawn_flock(from_left: bool, height: float, velocity: Vector2, count: int) -> void:
	var start := Vector2(-12.0 if from_left else SIZE.x + 12.0, height)
	var perfect := mode == Mode.ELYSIA
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = load(FX + "bird_fly.png")
		sprite.vframes = 2
		sprite.flip_h = not from_left
		sprite.modulate = Color(0.32, 0.3, 0.46) if perfect else Color(0.22, 0.18, 0.26)
		add_child(sprite)
		var offset: Vector2
		if perfect:
			# a clean V: leader in front, the others in mirrored ranks behind
			var rank := floorf((i + 1) * 0.5)
			offset = Vector2(-rank * 10.0, rank * 6.0 * (-1.0 if i % 2 == 1 else 1.0))
		else:
			offset = Vector2(-signf(velocity.x) * i * 8.0, (i % 2) * 6.0 + i * 2.0)
		var phase := 0.0 if perfect else float(i) * 0.37
		_birds.append({"sprite": sprite, "pos": start + offset, "vel": velocity, "phase": phase})
