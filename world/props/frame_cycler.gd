extends Sprite2D
## Cycles through hframes at a fixed rate (flags, birds, simple loops).

@export var frame_seconds := 0.35
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time >= frame_seconds:
		_time = 0.0
		frame = (frame + 1) % maxi(hframes, 1)
