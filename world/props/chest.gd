extends StaticBody2D
## Elysia's treasure chest. Params: {"flag": "<area.name>", "actions": [...]} (StateActions,
## e.g. loot, gold, XP, a quest step). Opens once; the flag keeps it open after loading.

const SPARKLE := preload("res://assets/generated/props/fx/sparkle.png")

var flag := ""
var actions: Array = []
var is_open := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	_interactable.interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	flag = str(params.get("flag", ""))
	actions = params.get("actions", [])
	if flag.is_empty():
		Log.error(Log.Category.CONTENT, "chest without flag")
	elif WorldState.has_flag(flag):
		_show_open()


func _on_interacted(_actor: Node) -> void:
	if is_open:
		return
	_show_open()
	WorldState.set_flag(flag)
	AudioDirector.sfx("chest_open")
	_burst()
	StateActions.run(actions, "chest:" + flag)


## The lid jumps, the chest squashes, and light and sparkles spill out.
func _burst() -> void:
	var tween := _sprite.create_tween()
	_sprite.scale = Vector2(1.2, 0.8)
	tween.tween_property(_sprite, ^"scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC)
	var sparkles := CPUParticles2D.new()
	sparkles.texture = SPARKLE
	sparkles.one_shot = true
	sparkles.explosiveness = 0.85
	sparkles.amount = 24
	sparkles.lifetime = 1.1
	sparkles.position = Vector2(0, -10)
	sparkles.direction = Vector2.UP
	sparkles.spread = 55.0
	sparkles.initial_velocity_min = 40.0
	sparkles.initial_velocity_max = 90.0
	sparkles.gravity = Vector2(0, 70)
	sparkles.damping_min = 20.0
	sparkles.damping_max = 40.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 0.95, 0.7, 1))
	fade.set_color(1, Color(1, 0.8, 0.4, 0))
	sparkles.color_ramp = fade
	add_child(sparkles)
	sparkles.emitting = true
	sparkles.finished.connect(sparkles.queue_free)


func _show_open() -> void:
	is_open = true
	_sprite.frame = 1
	_interactable.enabled = false
