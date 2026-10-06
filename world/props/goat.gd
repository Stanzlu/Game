extends Node2D
## The goat with Mira's boot (slice, beat 7). It chews, pauses, looks around and chews on.
## After the trade it chews the potato instead. Talking to it uses the "goat" cue.
## Params: "if"/"unless" flags (MapView). Collision keeps the player from walking through.
## "perch": pixels it stands higher (on the woodpile, Game Bible §33: the goat turns up in
## ever more absurd places); "appear_after": seconds before it shows up when the story brings
## it in while the scene runs. When its placement ends it trots off once the talk is over.

const DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const TRADED := "valley.goat_traded"

var _frames: Array[Texture2D] = []
var _frame := 0
var _time := 0.0
var _next_pause := 3.0
var _rng := RandomNumberGenerator.new()
## Seconds until the next bleat: it tells the player where the goat is.
var _next_bleat := 2.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_rng.seed = 41
	_load_frames()
	var body := StaticBody2D.new()
	body.collision_layer = PhysicsLayers.WORLD
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 6)
	shape.shape = rect
	shape.position = Vector2(0, -2)
	body.add_child(shape)
	add_child(body)
	var area := Talk.add_area(self, "INTERACT_EXAMINE", 16.0, Vector2(0, -6), 1)
	area.interacted.connect(func(actor: Node) -> void: Talk.present(self, DIALOGUE, "goat", actor))
	WorldState.flag_changed.connect(_on_flag_changed)


func apply_params(params: Dictionary) -> void:
	var perch := float(params.get("perch", 0.0))
	if perch > 0.0:
		_sprite.position.y -= perch
		z_index = 1
	if params.get("live", false) and params.has("appear_after"):
		_appear(float(params["appear_after"]))


func _appear(after: float) -> void:
	visible = false
	await NodeTimer.after(self, after)
	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, ^"modulate:a", 1.0, 0.8)


## Its placement ended (the trade is done): once nobody talks to it any more, it trots off.
func leave() -> void:
	var box := get_tree().get_first_node_in_group(&"dialogue_presenter")
	while box != null and is_instance_valid(box) and bool(box.get(&"visible")):
		await get_tree().process_frame
	SoundBank.play_at(get_parent(), "goat_bleat", global_position, -6.0)
	var tween := create_tween()
	tween.tween_property(self, ^"position:x", position.x + 28.0, 1.4)
	tween.parallel().tween_property(self, ^"modulate:a", 0.0, 1.4)
	tween.tween_callback(queue_free)


func _load_frames() -> void:
	var entry := PropCatalog.entry(
		"tal/goat_potato" if WorldState.has_flag(TRADED) else "tal/goat_boot"
	)
	if entry.is_empty():
		return
	_frames.clear()
	for path: String in entry.get("textures", []):
		_frames.append(load(path) as Texture2D)
	var anchor: Array = entry.get("anchor", [0, 0])
	_sprite.centered = false
	_sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))
	_sprite.texture = _frames[0]


func _on_flag_changed(id: String, value: bool) -> void:
	if id == TRADED and value:
		_load_frames()
		SoundBank.play_at(self, "goat_munch", global_position, -4.0)


## Chewing: jaw up and down a few times, then a pause.
func _process(delta: float) -> void:
	_next_bleat -= delta
	if _next_bleat <= 0.0:
		_next_bleat = _rng.randf_range(7.0, 14.0)
		SoundBank.play_at(self, "goat_bleat", global_position, -6.0)
	if _frames.size() < 2:
		return
	_time += delta
	if _time < _next_pause:
		var chew := int(_time / 0.28) % 2
		if chew != _frame:
			_frame = chew
			_sprite.texture = _frames[_frame]
	elif _time > _next_pause + 1.6:
		_time = 0.0
		_next_pause = _rng.randf_range(2.0, 4.5)
