class_name LookScene
extends GameScene
## Mood scenes of the look prototype (ADR-017): the normal GameScene composition plus
## weather, sky, world light, ambient particles, ambience and color grading.

enum Weather { CLEAR, RAIN }

const GRADE_SHADER := preload("res://world/shaders/grade.gdshader")
const CLOUD_DIR := "res://assets/generated/props/elysia/"

@export_group("Atmosphere")
@export var weather := Weather.CLEAR
## Multiplies the whole world (CanvasModulate); white = daylight, dark blue = rainy dusk.
@export var world_tint := Color.WHITE
@export var cloud_shadows := 0.0
@export var water_ripples := 0.0
@export var water_glints := 0.65
## Sky behind void map cells; transparent top color = no sky layer.
@export var sky_top := Color(0, 0, 0, 0)
@export var sky_bottom := Color(1, 1, 1, 1)
@export var petals := false
@export var motes := false
@export var fireflies := false
## Map cells where a butterfly flutters around.
@export var butterfly_cells: PackedVector2Array = []
@export var ambience: AudioStream
@export var ambience_db := -6.0

@export_group("Grading")
@export var saturation := 1.0
@export var contrast := 1.0
@export var brightness := 0.0
@export var tint := Color.WHITE
@export var shadow_tint := Color.BLACK
@export var vignette := 0.0
@export var bloom := 0.0

var glow_layer: CanvasLayer


func _build_world() -> void:
	# fireflies fly above everything and are not dimmed by the night tint
	glow_layer = CanvasLayer.new()
	glow_layer.name = "GlowLayer"
	glow_layer.layer = 1
	glow_layer.follow_viewport_enabled = true
	glow_layer.add_to_group(&"glow_layer")
	view.viewport.add_child(glow_layer)
	super._build_world()
	if map == null or map.data == null or not map.data.is_valid():
		return
	_setup_ground()
	if world_tint != Color.WHITE:
		var modulate_node := CanvasModulate.new()
		modulate_node.name = "WorldTint"
		modulate_node.color = world_tint
		view.world_root.add_child(modulate_node)
	if sky_top.a > 0.0:
		_add_sky()
	if weather == Weather.RAIN:
		var layer := CanvasLayer.new()
		layer.name = "WeatherLayer"
		layer.layer = 1
		layer.follow_viewport_enabled = true
		view.viewport.add_child(layer)
		var rain := RainFx.new()
		rain.name = "Rain"
		layer.add_child(rain)
		rain.setup(view)
	if petals:
		view.world_root.add_child(AmbientParticles.petals(view))
	if motes:
		view.world_root.add_child(AmbientParticles.motes(view))
	if fireflies:
		glow_layer.add_child(AmbientParticles.fireflies(view))
	for i in butterfly_cells.size():
		var butterfly := Butterfly.new()
		view.world_root.add_child(butterfly)
		butterfly.setup(map.cell_to_world(Vector2i(butterfly_cells[i])), i)
	if ambience != null:
		var player_node := AudioStreamPlayer.new()
		player_node.name = "Ambience"
		player_node.stream = ambience
		player_node.bus = &"Ambience"
		player_node.volume_db = ambience_db
		player_node.autoplay = true
		add_child(player_node)
	view.set_post_material(_grade_material())


func _setup_ground() -> void:
	if map.ground_art == null:
		return
	var mat := map.ground_art.material as ShaderMaterial
	mat.set_shader_parameter("ripple_strength", water_ripples)
	mat.set_shader_parameter("glint_strength", water_glints)
	if cloud_shadows > 0.0:
		var noise := FastNoiseLite.new()
		noise.frequency = 0.012
		noise.fractal_octaves = 3
		var texture := NoiseTexture2D.new()
		texture.noise = noise
		texture.seamless = true
		texture.width = 256
		texture.height = 256
		mat.set_shader_parameter("cloud_noise", texture)
		mat.set_shader_parameter("cloud_shadow", cloud_shadows)


func _add_sky() -> void:
	var sky := SkyLayer.new()
	sky.name = "Sky"
	view.world_root.add_child(sky)
	view.world_root.move_child(sky, 0)
	sky.setup(view, sky_top, sky_bottom)
	var rect := map.world_rect()
	var bottom := rect.end.y
	# [texture, x on screen, world y, drift speed, parallax]: far clouds first
	var clouds := [
		[CLOUD_DIR + "cloud_2.png", 60.0, bottom - 96.0, 3.0, 0.2],
		[CLOUD_DIR + "cloud_0.png", 380.0, bottom - 104.0, 3.5, 0.25],
		[CLOUD_DIR + "cloud_1.png", 210.0, bottom - 80.0, 5.0, 0.4],
		[CLOUD_DIR + "cloud_1.png", 560.0, bottom - 70.0, 5.5, 0.45],
		[CLOUD_DIR + "cloud_0.png", 20.0, bottom - 46.0, 9.0, 0.7],
		[CLOUD_DIR + "cloud_2.png", 300.0, bottom - 40.0, 10.0, 0.75],
		[CLOUD_DIR + "cloud_1.png", 520.0, bottom - 30.0, 12.0, 0.85],
	]
	for c: Array in clouds:
		sky.add_cloud(load(c[0]), c[1], c[2], c[3], c[4])


func _grade_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = GRADE_SHADER
	mat.set_shader_parameter("saturation", saturation)
	mat.set_shader_parameter("contrast", contrast)
	mat.set_shader_parameter("brightness", brightness)
	mat.set_shader_parameter("tint", Vector3(tint.r, tint.g, tint.b))
	mat.set_shader_parameter("shadow_tint", Vector3(shadow_tint.r, shadow_tint.g, shadow_tint.b))
	mat.set_shader_parameter("vignette", vignette)
	mat.set_shader_parameter("bloom", bloom)
	return mat
