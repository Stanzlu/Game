extends Node2D
## A stone in the stream (Tal, beat 4 of the slice). Flat, mossy ones hold. Round, wet ones
## tip as soon as the player stands on one: a splash, the cold, and back to the bank they
## came from. Params: {"wobbly": bool}. The cell under a stone is walkable water (map "w").

const DIALOGUE := "res://content/dialogue/slice/tal.dialogue"
const SPLASH := preload("res://assets/generated/props/fx/splash.png")
## Feet must be this close to the stone's middle before it tips (forgiving at the edges).
const TIP_RADIUS := Vector2(6, 5)
const TIP_SECONDS := 0.18

## One fall at a time, even when the feet touch two round stones at once.
static var _falling := false

var wobbly := false
var _sprite: Sprite2D
var _zone: Area2D


func apply_params(params: Dictionary) -> void:
	wobbly = bool(params.get("wobbly", false))
	var entry := PropCatalog.entry("tal/stone_round" if wobbly else "tal/stone_flat")
	if entry.is_empty():
		return
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.centered = false
	_sprite.texture = PropCatalog.texture_for(entry, global_position)
	var anchor: Array = entry.get("anchor", [0, 0])
	# no two stones sit the same: a small offset per stone breaks the grid of the field
	var jitter := Vector2i(hash(global_position) % 5 - 2, hash(global_position * 1.7) % 3 - 1)
	_sprite.offset = -Vector2(float(anchor[0]), float(anchor[1])) + Vector2(jitter)
	_sprite.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(_sprite)
	z_index = -5  # lies in the water: everything walks over it
	if wobbly:
		_add_zone()


func _add_zone() -> void:
	_zone = Area2D.new()
	_zone.name = "Tip"
	_zone.collision_layer = 0
	_zone.collision_mask = PhysicsLayers.PLAYER
	_zone.monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = TIP_RADIUS * 2.0
	shape.shape = rect
	_zone.add_child(shape)
	add_child(_zone)
	_zone.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _falling or not body is Player:
		return
	_falling = true
	var player := body as Player
	var heading := player.velocity
	AudioDirector.sfx("stone_wobble", -3.0)
	var rock := create_tween()
	rock.tween_property(_sprite, ^"rotation", 0.22, TIP_SECONDS * 0.5)
	rock.tween_property(_sprite, ^"rotation", -0.12, TIP_SECONDS * 0.5)
	rock.tween_property(_sprite, ^"rotation", 0.0, 0.25)
	await _fall(player, heading)
	_falling = false


## The player goes into the stream and climbs out on the bank they came from.
func _fall(player: Player, heading: Vector2) -> void:
	player.lock(&"fall")
	await NodeTimer.after(self, TIP_SECONDS)
	var fell_before := WorldState.has_flag("valley.fell_in")
	WorldState.set_flag("valley.fell_twice" if fell_before else "valley.fell_in")
	Log.info(Log.Category.WORLD_STATE, "fell into the stream", {"cell": global_position / 16.0})
	AudioDirector.sfx("splash_fall")
	_splash(player.global_position)
	var sink := player.create_tween()
	sink.tween_property(player.sprite, ^"position:y", 7.0, 0.22).set_ease(Tween.EASE_IN)
	await ScreenFade.fade_out(0.45)
	var bank: Variant = _bank_for(player, heading)
	if bank != null:
		player.teleport(bank)
	player.sprite.position.y = 0.0
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	if scene != null:
		scene.view.follow(player)
	await NodeTimer.after(self, 0.35)
	ScreenFade.fade_in(0.6)
	player.unlock(&"fall")
	await Talk.present(self, DIALOGUE, "fell_in", player)


func _exit_tree() -> void:
	_falling = false


## The marker on the bank the player came from: walking east they came from the west.
func _bank_for(player: Player, heading: Vector2) -> Variant:
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as GameScene
	if scene == null or scene.map == null:
		return null
	var west: Array = scene.map.data.find_marker("spawn_stones_w")
	var east: Array = scene.map.data.find_marker("spawn_stones_e")
	if west.is_empty() or east.is_empty():
		Log.error(Log.Category.CONTENT, "stepping stones without bank markers")
		return null
	var west_pos := scene.map.cell_to_world(west[0]["cell"])
	var east_pos := scene.map.cell_to_world(east[0]["cell"])
	if absf(heading.x) > 4.0:
		return west_pos if heading.x > 0.0 else east_pos
	var here := player.global_position
	return west_pos if here.distance_to(west_pos) < here.distance_to(east_pos) else east_pos


func _splash(at: Vector2) -> void:
	var burst := CPUParticles2D.new()
	burst.name = "Splash"
	burst.texture = SPLASH
	burst.amount = 18
	burst.lifetime = 0.7
	burst.one_shot = true
	burst.explosiveness = 0.9
	burst.direction = Vector2(0, -1)
	burst.spread = 70.0
	burst.gravity = Vector2(0, 260)
	burst.initial_velocity_min = 50.0
	burst.initial_velocity_max = 95.0
	burst.scale_amount_min = 0.6
	burst.scale_amount_max = 1.2
	var fade := Gradient.new()
	fade.set_color(0, Color(0.85, 0.92, 0.95, 0.9))
	fade.set_color(1, Color(0.85, 0.92, 0.95, 0.0))
	burst.color_ramp = fade
	burst.z_index = 20
	burst.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	get_parent().add_child(burst)
	burst.global_position = at
	burst.emitting = true
	burst.finished.connect(burst.queue_free)
