class_name Fireplace
extends Node2D
## The fireplace in the house (slice, beat 6). Cold until WorldState.is_fire_lit(); then the
## flames move (three frames), the light flickers and the stones glow. Talking to it uses
## the "fireplace" cue: reading the note, lighting the fire once there is dry wood.
## Lighting it in front of the player is a moment: the cold look stays for IGNITE_DELAY
## (the wood lands), then the flames are there, the light flares and embers fly up.

const DIALOGUE := "res://content/dialogue/slice/haus.dialogue"
const DECOR := preload("res://world/props/decor.tscn")
const FRAME_SECONDS := 0.13
const FX_DIR := "res://assets/generated/props/fx/"
## Seconds between the wood landing and the fire taking (the house scene times its sounds to it).
const IGNITE_DELAY := 0.5
const FLARE_COLOR := Color("#ffb060")
const FLARE_ENERGY := 2.4
const FLARE_SECONDS := 1.4
const EMBERS := 14

var lit := false
var _decor: Decor
var _frames: Array[Texture2D] = []
var _emissive: Array[Texture2D] = []
var _frame := 0
var _time := 0.0


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	var area := Talk.add_area(self, "INTERACT_EXAMINE", 22.0, Vector2(0, -2), 2)
	area.interacted.connect(
		func(actor: Node) -> void: Talk.present(self, DIALOGUE, "fireplace", actor)
	)
	WorldState.house_changed.connect(_refresh)
	_refresh()


func apply_params(_params: Dictionary) -> void:
	pass


func _refresh() -> void:
	var want := WorldState.is_fire_lit()
	if _decor != null and want == lit:
		return
	var catching := _decor != null and want and not lit
	lit = want
	if catching:
		_catch_fire()
		return
	_build_look()


## The logs take: after a moment the lit look replaces the cold one with a flare and embers.
func _catch_fire() -> void:
	await NodeTimer.after(self, IGNITE_DELAY)
	if not lit:
		return  # put out again meanwhile (debug): the look was rebuilt cold
	_build_look()
	_flare()


func _build_look() -> void:
	if _decor != null:
		_decor.queue_free()
	_decor = DECOR.instantiate()
	_decor.name = "Decor"
	add_child(_decor)
	_decor.apply_params({"sprite": "haus/fireplace_lit" if lit else "haus/fireplace_cold"})
	_frames.clear()
	_emissive.clear()
	var entry := PropCatalog.entry(_decor.sprite_id)
	for path: String in entry.get("textures", []):
		_frames.append(load(path) as Texture2D)
	for path: String in entry.get("emissive", []):
		_emissive.append(load(path) as Texture2D)
	set_process(lit and _frames.size() > 1)


func _process(delta: float) -> void:
	_time += delta
	# reduced flashing: the flames still move, just slower
	var step := FRAME_SECONDS * (2.0 if Settings.get_bool("display.reduce_flashing") else 1.0)
	if _time < step:
		return
	_time = 0.0
	_frame = (_frame + 1 + randi() % 2) % _frames.size()
	_decor.sprite.texture = _frames[_frame]
	var emit := _decor.get_node_or_null("Emissive") as Sprite2D
	if emit != null and _frame < _emissive.size():
		emit.texture = _emissive[_frame]


## A short burst of light and a few embers rising where the fire sits. Reduced flashing
## leaves out the flare; the embers are slow and few.
func _flare() -> void:
	if not Settings.get_bool("display.reduce_flashing"):
		var light := PointLight2D.new()
		light.name = "FlareLight"
		light.texture = Decor.light_texture()
		light.color = FLARE_COLOR
		light.energy = FLARE_ENERGY
		light.texture_scale = 150.0 / 32.0
		light.position = Vector2(0, -14)
		add_child(light)
		var tween := create_tween()
		(
			tween
			. tween_property(light, ^"energy", 0.0, FLARE_SECONDS)
			. set_trans(Tween.TRANS_EXPO)
			. set_ease(Tween.EASE_OUT)
		)
		tween.tween_callback(light.queue_free)
	var embers := CPUParticles2D.new()
	embers.name = "Embers"
	embers.position = Vector2(0, -14)
	embers.texture = load(FX_DIR + "mote.png")
	embers.one_shot = true
	embers.explosiveness = 0.85
	embers.amount = EMBERS
	embers.lifetime = 0.9
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(9, 2)
	embers.direction = Vector2(0, -1)
	embers.spread = 35.0
	embers.gravity = Vector2(0, -30)
	embers.initial_velocity_min = 12.0
	embers.initial_velocity_max = 34.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 0.75, 0.35, 1.0))
	fade.set_color(1, Color(1.0, 0.4, 0.15, 0.0))
	embers.color_ramp = fade
	embers.material = Decor.additive_unshaded()
	embers.z_index = 1
	add_child(embers)
	embers.emitting = true
	embers.finished.connect(embers.queue_free)
