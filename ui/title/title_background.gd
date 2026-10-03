class_name TitleBackground
extends Node2D
## Animated backdrop of the start menu: Elysia's morning sky with the world tree on its
## floating island (tools/art/make_title.py), drifting clouds in three depths, small islets
## that bob, a waterfall falling into nothing, blossom petals in the wind and now and then
## a flock of birds. Perfect, calm and a little too beautiful (Game Bible §9).

const SKY_SHADER := preload("res://world/shaders/sky.gdshader")
const SCROLL_SHADER := preload("res://ui/title/scroll.gdshader")
const ISLAND := preload("res://assets/generated/title/island.png")
const WATERFALL := preload("res://assets/generated/title/waterfall.png")
const RAYS := preload("res://assets/generated/ui/rays_large.png")
const PROPS := "res://assets/generated/props/elysia/"
const FX := "res://assets/generated/props/fx/"
const SIZE := Vector2(640, 360)
const ISLAND_AT := Vector2(300, 26)
## Where the water leaves the plateau, in island pixels (make_title.py layout).
const FALL_AT := Vector2(286, 215)

var _layers: Array[Dictionary] = []
var _island: Sprite2D
var _fall: TextureRect
var _glow: Sprite2D
var _birds: Array[Dictionary] = []
var _time := 0.0
var _next_flock := 3.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 5
	var sky := ColorRect.new()
	sky.size = SIZE
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = SKY_SHADER
	sky_mat.set_shader_parameter("top", Color(0.36, 0.56, 0.9))
	sky_mat.set_shader_parameter("bottom", Color(1.0, 0.86, 0.9))
	sky_mat.set_shader_parameter("steps", 9.0)
	sky.material = sky_mat
	add_child(sky)
	_glow = Sprite2D.new()
	_glow.texture = RAYS
	_glow.scale = Vector2(1.6, 1.6)
	_glow.position = ISLAND_AT + Vector2(165, 90)
	_glow.modulate = Color(1, 0.95, 0.8, 0.22)
	add_child(_glow)
	_add_drifter(PROPS + "cloud_1.png", Vector2(40, 30), -3.0, 0.0, 0.55)
	_add_drifter(PROPS + "cloud_0.png", Vector2(420, 70), -4.0, 0.0, 0.6)
	_add_drifter(PROPS + "cloud_2.png", Vector2(250, 150), -5.0, 0.0, 0.7)
	_add_drifter(PROPS + "islet_1.png", Vector2(56, 250), -1.2, 2.0, 0.85)
	_add_drifter(PROPS + "islet_0.png", Vector2(220, 300), -1.6, 3.0, 0.92)
	_add_drifter(PROPS + "islet_2.png", Vector2(600, 200), -1.0, 2.0, 0.8)
	_island = Sprite2D.new()
	_island.texture = ISLAND
	_island.centered = false
	_island.position = ISLAND_AT
	add_child(_island)
	_fall = TextureRect.new()
	_fall.texture = WATERFALL
	_fall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fall_mat := ShaderMaterial.new()
	fall_mat.shader = SCROLL_SHADER
	_fall.material = fall_mat
	add_child(_fall)
	_add_petals()
	_add_drifter(PROPS + "cloud_1.png", Vector2(470, 318), -7.0, 0.0, 0.95)
	_add_drifter(PROPS + "cloud_2.png", Vector2(120, 330), -8.0, 0.0, 0.9)


func _add_drifter(path: String, at: Vector2, speed: float, bob: float, alpha: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = load(path)
	sprite.centered = false
	sprite.modulate = Color(1, 1, 1, alpha)
	add_child(sprite)
	_layers.append(
		{"sprite": sprite, "x": at.x, "y": at.y, "speed": speed, "bob": bob, "phase": at.x}
	)


func _add_petals() -> void:
	var petals := CPUParticles2D.new()
	petals.texture = load(FX + "petal.png")
	petals.amount = 26
	petals.lifetime = 9.0
	petals.preprocess = 9.0
	petals.position = ISLAND_AT + Vector2(165, 60)
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	petals.emission_rect_extents = Vector2(90, 40)
	petals.direction = Vector2(-1, 0.4)
	petals.spread = 25.0
	petals.initial_velocity_min = 10.0
	petals.initial_velocity_max = 22.0
	petals.gravity = Vector2(-4, 9)
	petals.angular_velocity_min = -90.0
	petals.angular_velocity_max = 90.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 0.8, 0.9, 0.0))
	fade.add_point(0.1, Color(1, 0.8, 0.9, 1.0))
	fade.set_color(fade.get_point_count() - 1, Color(1, 0.8, 0.9, 0.0))
	petals.color_ramp = fade
	add_child(petals)


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
	var island_bob := roundf(2.0 * sin(_time * 0.6))
	_island.position = ISLAND_AT + Vector2(0, island_bob)
	_fall.position = ISLAND_AT + FALL_AT + Vector2(0, island_bob)
	_glow.rotation = _time * 0.02
	_update_birds(delta)


func _update_birds(delta: float) -> void:
	_next_flock -= delta
	if _next_flock <= 0.0:
		_next_flock = _rng.randf_range(9.0, 16.0)
		_spawn_flock()
	for i in range(_birds.size() - 1, -1, -1):
		var bird: Dictionary = _birds[i]
		var sprite: Sprite2D = bird["sprite"]
		bird["pos"] = (bird["pos"] as Vector2) + (bird["vel"] as Vector2) * delta
		sprite.position = (bird["pos"] as Vector2).round()
		sprite.frame = int(_time * 6.0 + float(bird["phase"])) % 2
		if sprite.position.x < -20 or sprite.position.x > SIZE.x + 20:
			sprite.queue_free()
			_birds.remove_at(i)


func _spawn_flock() -> void:
	var from_left := _rng.randf() < 0.5
	var start := Vector2(-12.0 if from_left else SIZE.x + 12.0, _rng.randf_range(40.0, 150.0))
	var velocity := Vector2(1.0 if from_left else -1.0, _rng.randf_range(-0.12, 0.08)) * 42.0
	for i in _rng.randi_range(3, 5):
		var sprite := Sprite2D.new()
		sprite.texture = load(FX + "bird_fly.png")
		sprite.vframes = 2
		sprite.flip_h = not from_left
		sprite.modulate = Color(0.32, 0.3, 0.46)
		add_child(sprite)
		var offset := Vector2(-signf(velocity.x) * i * 8.0, (i % 2) * 6.0 + i * 2.0)
		_birds.append({"sprite": sprite, "pos": start + offset, "vel": velocity, "phase": float(i)})
