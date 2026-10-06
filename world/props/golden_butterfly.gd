extends Node2D
## One of the gardener's three golden butterflies (Elysia miniquest). It flies the same
## figure-eight as every butterfly in Elysia; catching it is effortless, of course. Params:
## {"flag": "<area.name>", "actions": [...] (StateActions), "if": <flag>} (MapView).

const TEXTURE := preload("res://assets/generated/props/fx/golden_butterfly.png")
const SPARKLE := preload("res://assets/generated/props/fx/sparkle.png")
const GOLD := Color(1.0, 0.82, 0.35)
const CATCH_RADIUS := 24.0

var flag := ""
var actions: Array = []
var _butterfly: Butterfly
var _caught := false
var _halo: Sprite2D
var _time := 0.0


func apply_params(params: Dictionary) -> void:
	flag = str(params.get("flag", ""))
	actions = params.get("actions", [])
	if flag.is_empty():
		Log.error(Log.Category.CONTENT, "golden butterfly without flag")
		return
	if WorldState.has_flag(flag):
		queue_free()
		return
	_butterfly = Butterfly.new()
	_butterfly.name = "Butterfly"
	add_child(_butterfly)
	# twins right of Elysia's axis fly the route mirrored, like all its butterflies
	_butterfly.setup(Vector2.ZERO, 0, true, bool(params.get("mirror", false)))
	_butterfly.texture = TEXTURE
	_butterfly.modulate = Color.WHITE
	_add_shine()
	# the area covers the whole loop: catching it is effortless, of course
	var area := Talk.add_area(self, "INTERACT_CATCH", CATCH_RADIUS, Vector2(0, -8), 3)
	area.interacted.connect(_on_caught)


## A soft golden halo and a trail of glitter, so the three read as the quest's goal.
func _add_shine() -> void:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_halo = Sprite2D.new()
	_halo.name = "Halo"
	_halo.texture = Decor.light_texture()
	_halo.scale = Vector2(0.42, 0.42)
	_halo.modulate = Color(GOLD, 0.4)
	_halo.material = additive
	_halo.show_behind_parent = true
	_halo.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_butterfly.add_child(_halo)
	var trail := CPUParticles2D.new()
	trail.name = "Glitter"
	trail.texture = SPARKLE
	trail.material = additive
	trail.amount = 7
	trail.lifetime = 0.9
	trail.local_coords = false
	trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	trail.emission_sphere_radius = 2.0
	trail.direction = Vector2(0, 1)
	trail.spread = 40.0
	trail.gravity = Vector2(0, 10)
	trail.initial_velocity_min = 2.0
	trail.initial_velocity_max = 6.0
	var fade := Gradient.new()
	fade.set_color(0, Color(GOLD, 0.9))
	fade.set_color(1, Color(GOLD, 0.0))
	trail.color_ramp = fade
	trail.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_butterfly.add_child(trail)
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	if _halo != null:
		_halo.modulate.a = 0.32 + 0.12 * sin(_time * 3.1)


func _on_caught(_actor: Node) -> void:
	if _caught:
		return
	_caught = true
	# the flash starts before the flag: MapView then lets it finish (leave)
	_flash()
	WorldState.set_flag(flag)
	AudioDirector.sfx("praise", -4.0)
	StateActions.run(actions, "butterfly:" + flag)


## Its condition turned false (caught, or the quest is over): a last golden flash.
func leave() -> void:
	if not _caught:
		_caught = true
		_flash()


func _flash() -> void:
	if _butterfly == null:
		queue_free()
		return
	var interactable := get_node_or_null("Interactable") as Interactable
	if interactable != null:
		interactable.enabled = false
	var tween := create_tween()
	tween.tween_property(_butterfly, ^"scale", Vector2(1.6, 1.6), 0.18)
	tween.parallel().tween_property(_butterfly, ^"modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)
