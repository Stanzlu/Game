class_name Butterfly
extends Sprite2D
## A butterfly fluttering in loops around a spot (look prototype). Pixel-snapped path,
## wings flap by switching between two frames.

const TEXTURE := preload("res://assets/generated/props/fx/butterfly.png")

var home := Vector2.ZERO
var _time := 0.0
var _speed := 1.0


func _init() -> void:
	texture = TEXTURE
	vframes = 2
	z_index = 30
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func setup(at: Vector2, seed_value: int) -> void:
	home = at
	_time = float(seed_value) * 1.7
	_speed = 0.8 + float(seed_value % 3) * 0.15
	modulate = [Color(1, 1, 1), Color(0.75, 0.85, 1.6), Color(1.4, 0.8, 1.2)][seed_value % 3]
	position = home


func _process(delta: float) -> void:
	_time += delta * _speed
	var offset := Vector2(sin(_time * 0.9) * 26.0, sin(_time * 1.7 + 0.6) * 12.0 - 10.0)
	offset.y += sin(_time * 9.0) * 1.5
	position = (home + offset).round()
	frame = 0 if fmod(_time * 7.0, 1.0) < 0.5 else 1
	flip_h = cos(_time * 0.9) < 0.0
