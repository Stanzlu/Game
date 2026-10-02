extends StaticBody2D
## Generic decoration from the prop catalog (ADR-017): sprite variant, optional collision,
## wind sway, ground-level placement, footstep surface with rustle, lights, chimney smoke
## and sparkles. Placed by text maps with params {"sprite": "<style>/<name>"}.

const SWAY_SHADER := preload("res://world/shaders/wind_sway.gdshader")
const FX_DIR := "res://assets/generated/props/fx/"

static var _sway_materials: Dictionary = {}
static var _light_texture: GradientTexture2D

var sprite_id := ""
var sprite: Sprite2D
var lights: Array[PointLight2D] = []
var _light_energy: Array[float] = []
var _bob := 0.0
var _time := 0.0


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	set_process(false)


func apply_params(params: Dictionary) -> void:
	sprite_id = str(params.get("sprite", ""))
	var entry := PropCatalog.entry(sprite_id)
	if entry.is_empty():
		return
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = false
	sprite.texture = PropCatalog.texture_for(entry, global_position)
	var anchor: Array = entry.get("anchor", [0, 0])
	sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))
	sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(sprite)
	if entry.get("flat", false):
		z_index = -5
	if entry.has("shape"):
		_add_shape(entry["shape"])
	var sway := float(entry.get("sway", 0.0))
	if sway > 0.0:
		sprite.material = sway_material(sway)
	if entry.has("surface"):
		_add_surface(StringName(entry["surface"]), entry.get("rustle", false))
	for light: Dictionary in entry.get("lights", []):
		_add_light(light)
	if entry.has("smoke"):
		_add_smoke(_vec(entry["smoke"]))
	if entry.get("sparkle", false):
		_add_sparkles()
	if entry.has("loop_sound"):
		_add_loop_sound(str(entry["loop_sound"]))
	_bob = float(entry.get("bob", 0.0))
	_time = fmod(global_position.x * 0.13 + global_position.y * 0.07, TAU)
	set_process(_bob > 0.0 or (entry.get("flicker", false) and not lights.is_empty()))


func _process(delta: float) -> void:
	_time += delta
	if _bob > 0.0:
		sprite.position.y = roundf(sin(_time * 1.3) * _bob)
	for i in lights.size():
		var f := 1.0 + 0.07 * sin(_time * 13.0) + 0.05 * sin(_time * 7.3 + 1.0)
		lights[i].energy = _light_energy[i] * f


static func sway_material(amount: float) -> ShaderMaterial:
	if not _sway_materials.has(amount):
		var mat := ShaderMaterial.new()
		mat.shader = SWAY_SHADER
		mat.set_shader_parameter("amount", amount)
		_sway_materials[amount] = mat
	return _sway_materials[amount]


static func light_texture() -> GradientTexture2D:
	if _light_texture == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		gradient.add_point(0.45, Color(1, 1, 1, 0.45))
		_light_texture = GradientTexture2D.new()
		_light_texture.gradient = gradient
		_light_texture.fill = GradientTexture2D.FILL_RADIAL
		_light_texture.fill_from = Vector2(0.5, 0.5)
		_light_texture.fill_to = Vector2(1.0, 0.5)
		_light_texture.width = 64
		_light_texture.height = 64
	return _light_texture


func _add_shape(spec: Dictionary) -> void:
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	if spec.has("circle"):
		var circle := CircleShape2D.new()
		circle.radius = float(spec["circle"])
		shape.shape = circle
	elif spec.has("rect"):
		var rect := RectangleShape2D.new()
		rect.size = _vec(spec["rect"])
		shape.shape = rect
	else:
		Log.error(Log.Category.CONTENT, "prop shape needs circle or rect", {"sprite": sprite_id})
		return
	shape.position = _vec(spec.get("offset", [0, 0]))
	add_child(shape)


func _add_surface(surface: StringName, rustle: bool) -> void:
	var area := Area2D.new()
	area.name = "Surface"
	area.collision_layer = PhysicsLayers.SURFACE
	area.collision_mask = PhysicsLayers.PLAYER | PhysicsLayers.NPC if rustle else 0
	area.monitoring = rustle
	area.set_meta(&"surface", surface)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7.0
	shape.shape = circle
	shape.position = Vector2(0, -2)
	area.add_child(shape)
	add_child(area)
	if rustle:
		area.body_entered.connect(_on_rustle)


func _on_rustle(body: Node2D) -> void:
	var side := signf(global_position.x - body.global_position.x)
	sprite.skew = (side if side != 0.0 else 1.0) * 0.4
	var tween := create_tween()
	tween.tween_property(sprite, ^"skew", 0.0, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(
		Tween.EASE_OUT
	)
	SoundBank.play_at(self, "rustle", global_position, -14.0)


func _add_light(spec: Dictionary) -> void:
	var light := PointLight2D.new()
	light.texture = light_texture()
	light.position = _vec(spec.get("offset", [0, 0]))
	light.color = Color(str(spec.get("color", "#ffffff")))
	light.energy = float(spec.get("energy", 1.0))
	light.texture_scale = float(spec.get("range", 64)) / 32.0
	add_child(light)
	lights.append(light)
	_light_energy.append(light.energy)


func _add_smoke(offset: Vector2) -> void:
	var smoke := CPUParticles2D.new()
	smoke.name = "Smoke"
	smoke.position = offset
	smoke.texture = load(FX_DIR + "puff.png")
	smoke.amount = 14
	smoke.lifetime = 4.0
	smoke.preprocess = 4.0
	smoke.direction = Vector2(0.15, -1)
	smoke.spread = 12.0
	smoke.gravity = Vector2(5, -4)
	smoke.initial_velocity_min = 7.0
	smoke.initial_velocity_max = 11.0
	smoke.scale_amount_min = 1.0
	smoke.scale_amount_max = 1.0
	var fade := Gradient.new()
	fade.set_color(0, Color(0.55, 0.57, 0.62, 0.55))
	fade.set_color(1, Color(0.45, 0.47, 0.52, 0.0))
	smoke.color_ramp = fade
	smoke.z_index = 1
	add_child(smoke)


func _add_sparkles() -> void:
	var sparkles := CPUParticles2D.new()
	sparkles.name = "Sparkles"
	sparkles.position = Vector2(0, -8)
	sparkles.texture = load(FX_DIR + "sparkle.png")
	sparkles.amount = 6
	sparkles.lifetime = 0.9
	sparkles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparkles.emission_rect_extents = Vector2(22, 10)
	sparkles.gravity = Vector2.ZERO
	sparkles.initial_velocity_min = 0.0
	sparkles.initial_velocity_max = 0.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.3, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	sparkles.color_ramp = fade
	add_child(sparkles)


func _add_loop_sound(path: String) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		Log.error(Log.Category.AUDIO, "prop loop sound missing", {"path": path})
		return
	var player := AudioStreamPlayer2D.new()
	player.name = "LoopSound"
	player.stream = stream
	player.bus = &"Ambience"
	player.volume_db = -8.0
	player.max_distance = 260.0
	player.autoplay = true
	add_child(player)


static func _vec(a: Variant) -> Vector2:
	var arr: Array = a
	return Vector2(float(arr[0]), float(arr[1]))
