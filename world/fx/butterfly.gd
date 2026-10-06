class_name Butterfly
extends Sprite2D
## A butterfly fluttering in loops around a spot (look prototype). Pixel-snapped path,
## wings flap by switching between two frames. In perfect Elysia (Game Bible §9: "Schmetterlinge
## fliegen dieselben Routen") all of them fly the same route in step; twins fly it mirrored.

const TEXTURE := preload("res://assets/generated/props/fx/butterfly.png")

var home := Vector2.ZERO
var _time := 0.0
var _speed := 1.0
var _side := 1.0


func _init() -> void:
	texture = TEXTURE
	vframes = 2
	z_index = 30
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


## `perfect`: same phase and pace for every butterfly; `twin` mirrors the route.
func setup(at: Vector2, seed_value: int, perfect: bool = false, twin: bool = false) -> void:
	home = at
	var tint := seed_value % 3
	if perfect:
		_time = 0.0
		_speed = 1.0
		_side = -1.0 if twin else 1.0
		tint = floori(seed_value * 0.5) % 3
	else:
		_time = float(seed_value) * 1.7
		_speed = 0.8 + float(seed_value % 3) * 0.15
	modulate = [Color(1, 1, 1), Color(0.75, 0.85, 1.6), Color(1.4, 0.8, 1.2)][tint]
	position = home


func _process(delta: float) -> void:
	_time += delta * _speed
	var offset := Vector2(sin(_time * 0.9) * 26.0 * _side, sin(_time * 1.7 + 0.6) * 12.0 - 10.0)
	offset.y += sin(_time * 9.0) * 1.5
	position = (home + offset).round()
	frame = 0 if fmod(_time * 7.0, 1.0) < 0.5 else 1
	flip_h = (cos(_time * 0.9) * _side) < 0.0
