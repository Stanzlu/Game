class_name LookScene
extends GameScene
## Mood scenes of the look prototype (ADR-017): the normal GameScene composition plus
## weather, sky, world light, ambient particles and color grading. Music and ambience come
## from the GameScene exports (AudioDirector).

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
## 1 = sky objects move with depth; 0 = a painted backdrop fixed to the screen (Elysia in the
## slice: a picture, ADR-043).
@export var sky_parallax := 1.0
@export var petals := false
@export var motes := false
## Dim dust drifting in a quiet room (the house).
@export var dust := false
@export var fireflies := false
## Leaves blown through the view in gusts (the real world's wind, Game Bible §12).
@export var wind_leaves := false
## The protagonist shows up in water and puddles. Off in Elysia, whose water reflects
## everything except him (Game Bible §9).
@export var reflect_player := false
## Number of drifting fog banks and their tint (alpha = density).
@export var fog_banks := 0
@export var fog_color := Color(0.75, 0.85, 1.0, 0.16)
## Real-world scenes: start preset of the DayLight ("keine" = fixed look, e.g. Elysia).
@export_enum("keine", "regentag", "abend", "nacht") var day_preset := "keine"
@export_group("Depth")
## The depth arc (ADR-043): Elysia is a flat picture (all off); the real world gets aerial
## haze towards the top of the view, a backdrop beyond the northern treeline (pixels it
## reaches above the map; 0 = none) and dark crowns in front along the southern forest.
@export var depth_haze := 0.0
@export var haze_color := Color(0.78, 0.84, 0.86)
@export var backdrop_reach := 0.0
@export var foreground_foliage := false
@export_group("Life")
## Seconds between bird flocks on average (0 = none) and their tint (dark for bats).
@export var bird_interval := 0.0
@export var bird_tint := Color.WHITE
@export var swimmers := 0
@export_enum("koi.png", "fish_shadow.png") var swimmer_texture := "fish_shadow.png"
@export var dragonflies := 0
## Frogs on the banks of streams and ponds (the real world).
@export var frogs := 0
## Map cells where a butterfly flutters around.
@export var butterfly_cells: PackedVector2Array = []
## Elysia (Game Bible §9, §35): animals, plants and cloud shadows repeat exactly, mirrored
## at the map's symmetry axis. Butterflies then come in twins (odd entries mirror the even).
@export var perfect_loops := false
## Koi circle for perfect loops, in cells: position = center, size = radii.
@export var koi_orbit := Rect2()

@export_group("Grading")
@export var saturation := 1.0
@export var contrast := 1.0
@export var brightness := 0.0
@export var tint := Color.WHITE
@export var shadow_tint := Color.BLACK
@export var vignette := 0.0
@export var bloom := 0.0

var glow_layer: CanvasLayer
var day_light: DayLight
var backdrop: Backdrop
var foreground: ForegroundFoliage


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
	if dust:
		view.world_root.add_child(AmbientParticles.dust(view))
	if fireflies:
		glow_layer.add_child(AmbientParticles.fireflies(view))
	if wind_leaves:
		view.world_root.add_child(AmbientParticles.leaves(view))
	if bird_interval > 0.0 or swimmers > 0 or dragonflies > 0 or frogs > 0:
		var life := AmbientLife.new()
		life.name = "Life"
		view.world_root.add_child(life)
		life.setup(view, map)
		if perfect_loops:
			var ts := float(map.data.tile_size)
			var orbit := Rect2(map.cell_to_world(Vector2i(koi_orbit.position)), koi_orbit.size * ts)
			life.enable_perfect_loops(
				_mirror_x(), orbit if koi_orbit.size != Vector2.ZERO else Rect2()
			)
		if bird_interval > 0.0:
			life.enable_birds(bird_interval, bird_tint)
		life.add_swimmers(swimmers, swimmer_texture)
		life.add_darters(dragonflies)
		life.add_frogs(frogs)
	if fog_banks > 0:
		var fog := FogDrift.new()
		fog.name = "Fog"
		view.world_root.add_child(fog)
		fog.setup(map.world_rect(), fog_banks, fog_color)
	for i in butterfly_cells.size():
		var butterfly := Butterfly.new()
		view.world_root.add_child(butterfly)
		butterfly.setup(
			map.cell_to_world(Vector2i(butterfly_cells[i])), i, perfect_loops, i % 2 == 1
		)
	if reflect_player and player != null:
		map.add_reflection(player, true)
	_add_depth()
	view.set_post_material(_grade_material())
	if day_preset != "keine":
		_setup_day_light()


## Backdrop and foreground of the depth arc (ADR-043). The camera may look up to `reach`
## pixels above the map, where the backdrop lies.
func _add_depth() -> void:
	var moving := Settings.get_bool("display.parallax")
	if backdrop_reach > 0.0:
		backdrop = Backdrop.new()
		backdrop.name = "Backdrop"
		view.world_root.add_child(backdrop)
		view.world_root.move_child(backdrop, 0)
		backdrop.setup(view, map.world_rect(), backdrop_reach)
		backdrop.parallax = moving
		view.bounds = view.bounds.grow_side(SIDE_TOP, backdrop_reach)
	if foreground_foliage:
		foreground = ForegroundFoliage.new()
		foreground.name = "Foreground"
		view.world_root.add_child(foreground)
		foreground.setup(view, map)
		foreground.parallax = moving


func _setup_day_light() -> void:
	day_light = DayLight.new()
	day_light.name = "DayLight"
	add_child(day_light)
	day_light.world_tint = view.world_root.get_node_or_null("WorldTint")
	if day_light.world_tint == null:
		day_light.world_tint = CanvasModulate.new()
		day_light.world_tint.name = "WorldTint"
		view.world_root.add_child(day_light.world_tint)
	day_light.grade = view.display.material as ShaderMaterial
	if map.ground_art != null:
		day_light.ground = map.ground_art.material as ShaderMaterial
	day_light.rain = view.viewport.get_node_or_null("WeatherLayer/Rain")
	day_light.backdrop = backdrop
	# evening sun through the breaking clouds: screen space, above the world, below the UI
	var light_layer := CanvasLayer.new()
	light_layer.name = "LightLayer"
	light_layer.layer = 2
	view.viewport.add_child(light_layer)
	day_light.rays = SunRays.new()
	day_light.rays.name = "SunRays"
	light_layer.add_child(day_light.rays)
	# The time of day is part of the game state (resting passes it); the scene's own
	# preset only applies when none was set yet.
	var start := WorldState.day_preset() if not WorldState.day_preset().is_empty() else day_preset
	day_light.set_preset.call_deferred(start, 0.0)


func _setup_ground() -> void:
	if map.ground_art == null:
		return
	var mat := map.ground_art.material as ShaderMaterial
	mat.set_shader_parameter("ripple_strength", water_ripples)
	mat.set_shader_parameter("glint_strength", water_glints)
	if cloud_shadows > 0.0:
		# perfect loops: one small cloud pattern that visibly comes back ("Wolken wiederholen sich")
		var size := 128 if perfect_loops else 256
		var noise := FastNoiseLite.new()
		noise.frequency = 0.03 if perfect_loops else 0.012
		noise.fractal_octaves = 3
		var texture := NoiseTexture2D.new()
		texture.seamless = true
		texture.width = size
		texture.height = size
		texture.noise = noise
		mat.set_shader_parameter("cloud_noise", texture)
		mat.set_shader_parameter("cloud_shadow", cloud_shadows)
		if perfect_loops:
			mat.set_shader_parameter("cloud_tile", 320.0)
			mat.set_shader_parameter("cloud_velocity", Vector2(16.0, 0.0))


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
	# a rainbow far behind, floating islets in between (Elysia's sky, refs: floating islands)
	var k := sky_parallax
	sky.add_cloud(load(CLOUD_DIR + "rainbow.png"), 140.0, bottom - 120.0, 0.0, 0.1 * k, 0.0, 0.8)
	for c: Array in clouds.slice(0, 2):
		sky.add_cloud(load(c[0]), c[1], c[2], c[3], c[4] * k)
	sky.add_cloud(load(CLOUD_DIR + "islet_1.png"), 420.0, bottom - 62.0, 1.5, 0.22 * k, 2.0)
	sky.add_cloud(load(CLOUD_DIR + "islet_0.png"), 110.0, bottom - 56.0, 2.0, 0.35 * k, 3.0)
	for c: Array in clouds.slice(2):
		sky.add_cloud(load(c[0]), c[1], c[2], c[3], c[4] * k)
	sky.add_cloud(load(CLOUD_DIR + "islet_2.png"), 600.0, bottom - 50.0, 2.5, 0.55 * k, 3.0)


## World x of the map's symmetry axis (cell center), or the map center without one.
func _mirror_x() -> float:
	var axis := map.symmetry_axis()
	if axis < 0:
		return map.world_rect().get_center().x
	return map.cell_to_world(Vector2i(axis, 0)).x


func _grade_material() -> ShaderMaterial:
	return grade_material(
		{
			"saturation": saturation,
			"contrast": contrast,
			"brightness": brightness,
			"tint": tint,
			"shadow_tint": shadow_tint,
			"vignette": vignette,
			"bloom": bloom,
			"depth_haze": depth_haze,
			"haze_color": haze_color,
		}
	)


## The color grading post effect, also for scenes that are not LookScenes (encounters).
## Keys: saturation, contrast, brightness, tint, shadow_tint, vignette, bloom, depth_haze,
## haze_color.
static func grade_material(values: Dictionary) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = GRADE_SHADER
	var tint_color: Color = values.get("tint", Color.WHITE)
	var shadow: Color = values.get("shadow_tint", Color.BLACK)
	mat.set_shader_parameter("saturation", float(values.get("saturation", 1.0)))
	mat.set_shader_parameter("contrast", float(values.get("contrast", 1.0)))
	mat.set_shader_parameter("brightness", float(values.get("brightness", 0.0)))
	mat.set_shader_parameter("tint", Vector3(tint_color.r, tint_color.g, tint_color.b))
	mat.set_shader_parameter("shadow_tint", Vector3(shadow.r, shadow.g, shadow.b))
	mat.set_shader_parameter("vignette", float(values.get("vignette", 0.0)))
	mat.set_shader_parameter("bloom", float(values.get("bloom", 0.0)))
	var haze: Color = values.get("haze_color", Color(0.78, 0.84, 0.86))
	mat.set_shader_parameter("depth_haze", float(values.get("depth_haze", 0.0)))
	mat.set_shader_parameter("haze_color", Vector3(haze.r, haze.g, haze.b))
	return mat
