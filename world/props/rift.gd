extends Node2D
## The rift: a thin glowing crack in the air at the edge of Elysia. Params:
## {"target": "<scene key>"}. Touching it starts the RiftSequence. It flickers unless the
## player reduced flashing effects. The air around it bends and hums; motes drift into it.

var target := "look_tal"
var _time := 0.0

@onready var _sprite: Sprite2D = $Sprite
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	($Interactable as Interactable).interacted.connect(_on_interacted)
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_sprite.material = additive


func apply_params(params: Dictionary) -> void:
	target = str(params.get("target", target))
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "rift target unknown", {"target": target})


func _process(delta: float) -> void:
	_time += delta
	if Settings.get_bool("display.reduce_flashing"):
		_sprite.modulate.a = 0.85
	else:
		_sprite.modulate.a = 0.7 + 0.3 * absf(sin(_time * 2.3) * sin(_time * 7.1))
	_glow.energy = 0.5 + 0.3 * _sprite.modulate.a


func _on_interacted(_actor: Node) -> void:
	($Interactable as Interactable).enabled = false
	AudioDirector.sfx("rift_touch")
	var hum := $Hum as AudioStreamPlayer2D
	hum.create_tween().tween_property(hum, ^"volume_db", -40.0, 2.0)
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	if scene == null:
		Log.error(Log.Category.WORLD_STATE, "rift outside a game scene")
		return
	RiftSequence.play(scene, target)
