class_name Rift
extends Node2D
## The rift: a thin glowing crack in the air at the edge of Elysia. Params:
## {"target": "<scene key>", "spawn": "<marker name>"}. Touching it starts the RiftSequence.
## It flickers unless the player reduced flashing effects. The air around it bends and hums;
## motes drift into it. Touching it, the hero steps into it and the crack swells while Elysia's
## HUD falls apart (RiftSequence).

## How far the hero steps toward the crack, and how long the swelling lasts (about the time
## the HUD needs to fall apart).
const STEP_PIXELS := 8.0
const STEP_SECONDS := 0.45
const SWELL_SECONDS := 3.2
const SWELL_GLOW := 1.7
const SWELL_SCALE := 0.5

var target := "look_tal"
var spawn := ""
## "return" (Act VI, R2): the gap in the valley that leads back into Elysia. Touching it asks first
## (`ElysiaReturn`); the crossing out of Elysia (RiftSequence) is the other way round.
var mode := ""
## Colour of the crack and its glow ("tint": [r, g, b] in the map; the gap in the valley is warm).
var tint := Color.WHITE
var _time := 0.0
## 0..1, how far the crack has swollen (tweened by a touch).
var _swell := 0.0
var _sprite_scale := Vector2.ONE

@onready var _sprite: Sprite2D = $Sprite
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	($Interactable as Interactable).interacted.connect(_on_interacted)
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_sprite.material = additive
	_sprite_scale = _sprite.scale
	_apply_tint()
	AudioDirector.caption.call_deferred("rift_hum", global_position)


func apply_params(params: Dictionary) -> void:
	target = str(params.get("target", target))
	spawn = str(params.get("spawn", ""))
	mode = str(params.get("mode", ""))
	var rgb: Variant = params.get("tint", null)
	if rgb is Array and (rgb as Array).size() == 3:
		tint = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))
		if is_node_ready():
			_apply_tint()
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "rift target unknown", {"target": target})


## The glow and the motes take the colour of the crack (the glow's own is the rift's cool blue).
func _apply_tint() -> void:
	_glow.color = Color(0.6, 0.9, 1.0) * tint
	($Motes as CPUParticles2D).modulate = tint


func _process(delta: float) -> void:
	_time += delta
	var alpha := 0.85
	if not Settings.get_bool("display.reduce_flashing"):
		alpha = 0.7 + 0.3 * absf(sin(_time * 2.3) * sin(_time * 7.1))
	_sprite.modulate = Color(tint.r, tint.g, tint.b, alpha)
	_glow.energy = 0.5 + 0.3 * alpha + SWELL_GLOW * _swell
	_sprite.scale = _sprite_scale * (1.0 + SWELL_SCALE * _swell)


func _on_interacted(actor: Node) -> void:
	if mode == "return":
		ElysiaReturn.start(self, actor)
		return
	touch(actor)
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	if scene == null:
		Log.error(Log.Category.WORLD_STATE, "rift outside a game scene")
		return
	RiftSequence.play(scene, target, true, spawn)


## The hero touches the crack: one step in, the crack swells, the hum goes down.
func touch(actor: Node) -> void:
	($Interactable as Interactable).enabled = false
	AudioDirector.sfx("rift_touch")
	_step_into(actor)
	create_tween().tween_property(self, ^"_swell", 1.0, SWELL_SECONDS).set_trans(Tween.TRANS_SINE)
	var hum := $Hum as AudioStreamPlayer2D
	hum.create_tween().tween_property(hum, ^"volume_db", -40.0, 2.0)


## The question was answered no: the crack is there to be touched again.
func reopen() -> void:
	($Interactable as Interactable).enabled = true


## One step toward the crack and a turn to face it: the touch is something the hero does, not a
## freeze frame. The tween runs in physics steps (like sitting down) so interpolation smooths it.
func _step_into(actor: Node) -> void:
	var player := actor as Player
	if player == null:
		return
	var to_rift := global_position - player.global_position
	if to_rift.length() < 1.0:
		return
	player.facing = Facing.from_vector(to_rift)
	var goal := player.global_position + to_rift.limit_length(STEP_PIXELS)
	var tween := player.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	(
		tween
		. tween_property(player, ^"global_position", goal, STEP_SECONDS)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
