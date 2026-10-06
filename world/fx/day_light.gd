class_name DayLight
extends Node
## Time of day for a Real-world scene (Game Bible §12, slice beat 7 "Abendlicht"): blends
## world tint, colour grading, lamp brightness, rain and sound between presets.
## Elysia has no day light on purpose: its light never changes.

signal changed(preset: String)

const ORDER := GameState.DAY_PRESETS
## Per preset: world tint, grading (shader parameters), lamp scale, rain, water ripples,
## ambience (path of a soundscape or bed, or "") and music track ("keep" leaves it).
const PRESETS := {
	"regentag":
	{
		# soft summer rain (ADR-041): the greens stay luminous, wet things glisten
		"world_tint": Color(0.88, 0.94, 0.97),
		"saturation": 0.97,
		"contrast": 0.98,
		"brightness": 0.02,
		"tint": Color(0.97, 1.0, 1.02),
		"shadow_tint": Color(0.03, 0.07, 0.08),
		"vignette": 0.1,
		"bloom": 0.3,
		"lamps": 0.15,
		"rain": true,
		"ripples": 0.45,
		"clouds": 0.0,
		"rays": 0.0,
		"ambience": "res://content/audio/tal_regentag.tres",
		"ambience_db": -4.0,
		"music": "silence",
	},
	"abend":
	{
		# golden hour after the rain: warm light, violet shadows, everything glows a little
		"world_tint": Color(1.0, 0.89, 0.76),
		"saturation": 1.1,
		"contrast": 1.05,
		"brightness": 0.04,
		"tint": Color(1.08, 0.98, 0.84),
		"shadow_tint": Color(0.07, 0.03, 0.1),
		"vignette": 0.24,
		"bloom": 0.85,
		"lamps": 0.7,
		"rain": false,
		"ripples": 0.0,
		# the sky breaks up: cloud shadows drift over the meadows, the low sun comes through
		"clouds": 0.16,
		"rays": 1.0,
		"ambience": "res://content/audio/tal_abend.tres",
		"ambience_db": -8.0,
		"music": "valley",
	},
	"nacht":
	{
		"world_tint": Color(0.32, 0.38, 0.58),
		"saturation": 0.82,
		"contrast": 1.06,
		"brightness": 0.0,
		"tint": Color(0.9, 0.97, 1.08),
		"shadow_tint": Color(0.02, 0.03, 0.06),
		"vignette": 0.35,
		"bloom": 0.9,
		"lamps": 1.0,
		"rain": true,
		"ripples": 0.45,
		"clouds": 0.0,
		"rays": 0.0,
		"ambience": "res://content/audio/tal_nacht.tres",
		"ambience_db": -4.0,
		"music": "silence",
	},
}
const GRADE_KEYS: PackedStringArray = [
	"saturation", "contrast", "brightness", "tint", "shadow_tint", "vignette", "bloom"
]

var preset := ""
var world_tint: CanvasModulate
var grade: ShaderMaterial
var ground: ShaderMaterial
var rain: RainFx
var rays: SunRays
var _tween: Tween


## Applies `preset_name`, blended over `seconds` (0 = at once).
func set_preset(preset_name: String, seconds := 4.0) -> void:
	if not PRESETS.has(preset_name):
		Log.error(Log.Category.CONTENT, "unknown day light preset", {"preset": preset_name})
		return
	preset = preset_name
	WorldState.set_day_preset(preset_name)
	var p: Dictionary = PRESETS[preset_name]
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	var t := maxf(seconds, 0.0)
	if world_tint != null:
		_blend(world_tint, ^"color", p["world_tint"], t)
	if grade != null:
		for key in GRADE_KEYS:
			var target: Variant = p[key]
			if target is Color:
				var c: Color = target
				target = Vector3(c.r, c.g, c.b)
			_blend_param(grade, key, target, t)
	if ground != null:
		_blend_param(ground, "ripple_strength", float(p["ripples"]), t)
		_blend_param(ground, "cloud_shadow", float(p["clouds"]), t)
	if rays != null:
		_blend(rays, ^"strength", float(p["rays"]), t)
	for node in get_tree().get_nodes_in_group(&"lamp_props"):
		_blend(node, ^"light_scale", float(p["lamps"]), t)
	if rain != null:
		rain.set_raining(bool(p["rain"]))
	var ambience_path: String = p["ambience"]
	var ambience: Resource = load(ambience_path) if not ambience_path.is_empty() else null
	AudioDirector.set_ambience(ambience, float(p["ambience_db"]), maxf(t, 1.0))
	if str(p["music"]) != "keep":
		AudioDirector.play_music(str(p["music"]), maxf(t, 1.0))
	Log.info(Log.Category.WORLD_STATE, "day light", {"preset": preset_name, "seconds": seconds})
	changed.emit(preset_name)


func _blend(target: Object, property: NodePath, value: Variant, seconds: float) -> void:
	if seconds <= 0.0:
		target.set_indexed(property, value)
	else:
		_running_tween().tween_property(target, property, value, seconds)


func _blend_param(mat: ShaderMaterial, key: String, value: Variant, seconds: float) -> void:
	if seconds <= 0.0:
		mat.set_shader_parameter(key, value)
		return
	var from: Variant = mat.get_shader_parameter(key)
	_running_tween().tween_method(
		func(v: Variant) -> void: mat.set_shader_parameter(key, v), from, value, seconds
	)


func _running_tween() -> Tween:
	if _tween == null:
		_tween = create_tween().set_parallel()
	return _tween


func next_preset(seconds := 4.0) -> String:
	var index := ORDER.find(preset)
	var next := ORDER[(index + 1) % ORDER.size()]
	set_preset(next, seconds)
	return next
