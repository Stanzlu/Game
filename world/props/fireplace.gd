extends Node2D
## The fireplace in the house (slice, beat 6). Cold until WorldState.is_fire_lit(); then the
## flames move (three frames), the light flickers and the stones glow. Talking to it uses
## the "fireplace" cue: reading the note, lighting the fire once there is dry wood.

const DIALOGUE := "res://content/dialogue/slice/haus.dialogue"
const DECOR := preload("res://world/props/decor.tscn")
const FRAME_SECONDS := 0.13

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
	lit = want
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
