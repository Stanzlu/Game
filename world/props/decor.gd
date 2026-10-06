class_name Decor
extends StaticBody2D
## Generic decoration from the prop catalog (ADR-017): sprite variant, optional collision,
## wind sway, ground-level placement, footstep surface with rustle, lights, chimney smoke
## and sparkles. Placed by text maps with params {"sprite": "<style>/<name>"}.
## Glowing parts (emissive layer, halos, light beams) are drawn unshaded in place: correct
## depth sorting, and a night tint (CanvasModulate) or lights do not dim them.
## With params "cue" (and optional "dialogue", "prompt", "radius") it can be looked at:
## interacting shows that dialogue cue (descriptions, small discoveries).
## In symmetric maps (Elysia) MapView passes "mirror" and "seed_position": the prop then
## shows its twin's variant, flipped, with lights and shapes mirrored too; "sway_axis" makes
## plants sway in mirrored unison instead of gusts.

const SWAY_SHADER := preload("res://world/shaders/wind_sway.gdshader")
const SWAY_EMISSIVE_SHADER := preload("res://world/shaders/wind_sway_emissive.gdshader")
const EMISSIVE_SHADER := preload("res://world/shaders/emissive.gdshader")
const FX_DIR := "res://assets/generated/props/fx/"
## sway_axis value for "no symmetry axis" (natural, gusty wind).
const NO_AXIS := -1.0e9

static var _sway_materials: Dictionary = {}
static var _light_texture: GradientTexture2D
static var _emissive_material: ShaderMaterial
static var _additive: CanvasItemMaterial

var sprite_id := ""
var sprite: Sprite2D
## Mirror image of a twin on the other side of a symmetric map.
var mirrored := false
var lights: Array[PointLight2D] = []
## Scales all lamp lights of this prop (DayLight dims lamps by day).
var light_scale := 1.0
var _light_energy: Array[float] = []
var _bob := 0.0
var _time := 0.0
var _glow: Sprite2D
var _beam: Sprite2D


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	set_process(false)


func apply_params(params: Dictionary) -> void:
	# {"sprite_when": {"<flag>": "<sprite>"}}: the story changed how it looks (house lit);
	# MapView rebuilds the prop when that changes while it is on screen
	sprite_id = variant_sprite(params)
	if params.has("cue"):
		_add_inspect(params)
		if sprite_id.is_empty():
			return  # an invisible spot to examine (the basin's water, a window)
	var entry := PropCatalog.entry(sprite_id)
	if entry.is_empty():
		return
	mirrored = bool(params.get("mirror", false))
	var seed_position: Vector2 = params.get("seed_position", global_position)
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = false
	sprite.texture = PropCatalog.texture_for(entry, seed_position)
	var anchor: Array = entry.get("anchor", [0, 0])
	sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))
	if mirrored:
		_mirror_sprite(sprite)
	sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(sprite)
	if entry.get("flat", false):
		z_index = -5
	if entry.has("emissive"):
		var emit := Sprite2D.new()
		emit.name = "Emissive"
		emit.centered = false
		emit.texture = PropCatalog.texture_for(entry, seed_position, "emissive")
		emit.offset = sprite.offset
		emit.flip_h = sprite.flip_h
		emit.material = emissive_material()
		emit.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		add_child(emit)
	if entry.get("beam", false):
		_add_beam()
	if entry.has("shape"):
		_add_shape(entry["shape"])
	var sway := float(entry.get("sway", 0.0))
	if sway > 0.0:
		var axis_x := float(params.get("sway_axis", NO_AXIS))
		sprite.material = sway_material(sway, false, axis_x)
		var emit_node := get_node_or_null("Emissive") as Sprite2D
		if emit_node != null:
			emit_node.material = sway_material(sway, true, axis_x)
	if entry.has("surface"):
		_add_surface(StringName(entry["surface"]), entry.get("rustle", false))
	for light: Dictionary in entry.get("lights", []):
		_add_light(light)
	if entry.has("smoke"):
		_add_smoke(_pos(entry["smoke"]))
	if entry.get("sparkle", false):
		_add_sparkles()
	if entry.has("loop_sound"):
		_add_loop_sound(str(entry["loop_sound"]))
	if entry.has("glow"):
		_add_glow(entry["glow"])
	if entry.has("petal_rain"):
		_add_petal_rain(entry["petal_rain"])
	if entry.has("splash"):
		_add_splash(entry["splash"])
	_bob = float(entry.get("bob", 0.0))
	_time = fmod(global_position.x * 0.13 + global_position.y * 0.07, TAU)
	set_process(
		(
			_bob > 0.0
			or _glow != null
			or _beam != null
			or (entry.get("flicker", false) and not lights.is_empty())
		)
	)


func _process(delta: float) -> void:
	_time += delta
	if _bob > 0.0:
		sprite.position.y = roundf(sin(_time * 1.3) * _bob)
	if _glow != null:
		_glow.modulate.a = 0.55 + 0.2 * sin(_time * 1.7)
	if _beam != null:
		_beam.modulate.a = 0.8 + 0.12 * sin(_time * 0.9) + 0.06 * sin(_time * 2.3)
	for i in lights.size():
		var f := 1.0 + 0.07 * sin(_time * 13.0) + 0.05 * sin(_time * 7.3 + 1.0)
		lights[i].energy = _light_energy[i] * f * light_scale


## Shared sway material. `axis_x` (world x of a symmetry axis) switches to the mirrored,
## gust-free sway of perfect Elysia; NO_AXIS keeps the natural wind.
static func sway_material(
	amount: float, unshaded: bool = false, axis_x: float = NO_AXIS
) -> ShaderMaterial:
	var key := "%s_%s_%s" % [amount, unshaded, axis_x]
	if not _sway_materials.has(key):
		var mat := ShaderMaterial.new()
		mat.shader = SWAY_EMISSIVE_SHADER if unshaded else SWAY_SHADER
		mat.set_shader_parameter("amount", amount)
		if axis_x != NO_AXIS:
			mat.set_shader_parameter("mirror_x", axis_x)
		_sway_materials[key] = mat
	return _sway_materials[key]


static func additive_unshaded() -> CanvasItemMaterial:
	if _additive == null:
		_additive = CanvasItemMaterial.new()
		_additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	return _additive


static func emissive_material() -> ShaderMaterial:
	if _emissive_material == null:
		_emissive_material = ShaderMaterial.new()
		_emissive_material.shader = EMISSIVE_SHADER
	return _emissive_material


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
	shape.position = _pos(spec.get("offset", [0, 0]))
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


## The sprite for these params: the first "sprite_when" flag that is set picks its look,
## otherwise "sprite".
static func variant_sprite(params: Dictionary) -> String:
	var variants: Dictionary = params.get("sprite_when", {})
	for flag_id: String in variants:
		if WorldState.has_flag(flag_id):
			return str(variants[flag_id])
	return str(params.get("sprite", ""))


func _add_inspect(params: Dictionary) -> void:
	var area := Talk.add_area(
		self,
		str(params.get("prompt", "INTERACT_EXAMINE")),
		float(params.get("radius", 12.0)),
		Vector2(0, -4)
	)
	var path := str(params.get("dialogue", Talk.DEFAULT_DIALOGUE))
	var cue := str(params["cue"])
	area.interacted.connect(func(actor: Node) -> void: Talk.present(self, path, cue, actor))


func _add_light(spec: Dictionary) -> void:
	var light := PointLight2D.new()
	light.texture = light_texture()
	light.position = _pos(spec.get("offset", [0, 0]))
	light.color = Color(str(spec.get("color", "#ffffff")))
	light.energy = float(spec.get("energy", 1.0))
	light.texture_scale = float(spec.get("range", 64)) / 32.0
	add_child(light)
	lights.append(light)
	_light_energy.append(light.energy)
	add_to_group(&"lamp_props")


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


## Soft additive halo (crystals, glowing plants). Elysia's "leuchtende Pflanzen".
func _add_glow(spec: Dictionary) -> void:
	_glow = Sprite2D.new()
	_glow.name = "Glow"
	_glow.texture = light_texture()
	var radius := float(spec.get("radius", 16))
	_glow.scale = Vector2.ONE * radius / 32.0
	_glow.position = _pos(spec.get("offset", [0, 0]))
	_glow.self_modulate = Color(str(spec.get("color", "#ffffff")))
	_glow.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_glow.material = additive_unshaded()
	add_child(_glow)


func _add_beam() -> void:
	_beam = Sprite2D.new()
	_beam.name = "Beam"
	_beam.centered = false
	_beam.texture = sprite.texture
	_beam.offset = sprite.offset
	_beam.flip_h = sprite.flip_h
	_beam.material = additive_unshaded()
	add_child(_beam)
	sprite.visible = false
	var motes := CPUParticles2D.new()
	motes.name = "BeamMotes"
	motes.texture = load(FX_DIR + "mote.png")
	motes.amount = 18
	motes.lifetime = 4.0
	motes.preprocess = 4.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(22, 30)
	motes.direction = Vector2(0, -1)
	motes.spread = 20.0
	motes.gravity = Vector2(0, -3)
	motes.initial_velocity_min = 3.0
	motes.initial_velocity_max = 8.0
	var fade := Gradient.new()
	fade.set_color(0, Color(0.85, 1, 0.95, 0))
	fade.add_point(0.4, Color(0.85, 1, 0.95, 0.9))
	fade.set_color(1, Color(0.85, 1, 0.95, 0))
	motes.color_ramp = fade
	motes.material = additive_unshaded()
	motes.position = Vector2(0, -40)
	add_child(motes)


func _add_petal_rain(spec: Dictionary) -> void:
	var petals := CPUParticles2D.new()
	petals.name = "PetalRain"
	petals.position = _pos(spec.get("offset", [0, 0]))
	petals.texture = load(FX_DIR + "petal.png")
	petals.amount = int(spec.get("amount", 12))
	petals.lifetime = 6.0
	petals.preprocess = 6.0
	petals.local_coords = false
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	petals.emission_rect_extents = _vec(spec.get("extents", [40, 20]))
	petals.direction = Vector2(0.4, 1)
	petals.spread = 25.0
	petals.gravity = Vector2(3, 6)
	petals.initial_velocity_min = 4.0
	petals.initial_velocity_max = 10.0
	petals.angular_velocity_min = -90.0
	petals.angular_velocity_max = 90.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.15, Color(1, 1, 1, 1))
	fade.add_point(0.8, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	petals.color_ramp = fade
	petals.z_index = 20
	add_child(petals)


## Droplets and mist where a waterfall lands.
func _add_splash(spec: Dictionary) -> void:
	var drops := CPUParticles2D.new()
	drops.name = "Splash"
	drops.texture = load(FX_DIR + "mote.png")
	drops.amount = int(spec.get("amount", 24))
	drops.lifetime = 0.7
	drops.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	drops.emission_rect_extents = _vec(spec.get("extents", [10, 3]))
	drops.position = _pos(spec.get("offset", [0, 0]))
	drops.direction = Vector2(0, -1)
	drops.spread = 55.0
	drops.gravity = Vector2(0, 140)
	drops.initial_velocity_min = 25.0
	drops.initial_velocity_max = 50.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.95))
	fade.set_color(1, Color(1, 1, 1, 0))
	drops.color_ramp = fade
	drops.z_index = 2
	add_child(drops)
	var mist := CPUParticles2D.new()
	mist.name = "Mist"
	mist.texture = load(FX_DIR + "puff.png")
	mist.amount = 8
	mist.lifetime = 1.6
	mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	mist.emission_rect_extents = _vec(spec.get("extents", [10, 3]))
	mist.position = drops.position
	mist.direction = Vector2(0, -1)
	mist.spread = 40.0
	mist.gravity = Vector2(0, -6)
	mist.initial_velocity_min = 4.0
	mist.initial_velocity_max = 10.0
	var mist_fade := Gradient.new()
	mist_fade.set_color(0, Color(1, 1, 1, 0.5))
	mist_fade.set_color(1, Color(1, 1, 1, 0))
	mist.color_ramp = mist_fade
	mist.z_index = 2
	add_child(mist)


## Flips a sprite around its anchor (the anchor pixel stays where it was).
static func _mirror_sprite(target: Sprite2D) -> void:
	target.flip_h = true
	if target.texture != null:
		target.offset.x = -float(target.texture.get_width()) - target.offset.x


## A position offset from the catalog, mirrored for a mirrored prop.
func _pos(a: Variant) -> Vector2:
	var v := _vec(a)
	return Vector2(-v.x, v.y) if mirrored else v


static func _vec(a: Variant) -> Vector2:
	var arr: Array = a
	return Vector2(float(arr[0]), float(arr[1]))
