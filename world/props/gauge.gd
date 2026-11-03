class_name Gauge
extends Decor
## A dial with a needle (Act V, the keeper's hall, docs/akt5/REGIONSBRIEFE.md O5 and O20). The face
## is the prop's own picture, the needle a second picture turned about its hub; one of the dials
## trembles a little (a picture effect without a flash). The tremble reads "display.screen_shake":
## with the setting off the needle rests. Params: {"sprite": "<face>", "needle": "<sprite>",
## "needle_at": [x, y] (the hub, in pixels from the prop's anchor), "angle": <resting degrees>,
## "tremble": <bool>, "amplitude": <degrees>}.

const TREMBLE_HZ := 5.3

var needle: Sprite2D
## Degrees the needle wanders at full trouble (the sign says to which side).
var drift := 32.0
var _rest := 0.0
var _amplitude := 0.0
var _phase := 0.0
var _trouble := 0.0
var _clock := 0.0


func apply_params(params: Dictionary) -> void:
	super(params)
	var entry := PropCatalog.entry(str(params.get("needle", "")))
	if entry.is_empty() or sprite == null:
		return
	needle = Sprite2D.new()
	needle.name = "Needle"
	needle.centered = false
	needle.texture = PropCatalog.texture_for(entry, global_position)
	var anchor: Array = entry.get("anchor", [0, 0])
	needle.offset = -Vector2(float(anchor[0]), float(anchor[1]))
	var hub: Array = params.get("needle_at", [0, 0])
	needle.position = Vector2(float(hub[0]), float(hub[1]))
	_rest = float(params.get("angle", 0.0))
	needle.rotation_degrees = _rest
	needle.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_child(needle)
	if bool(params.get("tremble", false)):
		_amplitude = float(params.get("amplitude", 1.6))
		_phase = fmod(global_position.x * 0.31 + global_position.y * 0.17, TAU)
		set_process(true)


## How far the load has pushed the needle off its mark, 0 to 1 (the hall's scene sets it): the
## needle wanders from "Normal" by `drift` degrees at 1 and trembles a little more.
func set_trouble(value: float) -> void:
	_trouble = clampf(value, 0.0, 1.0)
	_apply()


func _process(delta: float) -> void:
	super(delta)
	_clock += delta
	_apply()


func _apply() -> void:
	if needle == null:
		return
	var moving := _amplitude > 0.0 and Settings.get_bool("display.screen_shake")
	var tremble := sin(_clock * TREMBLE_HZ + _phase) * _amplitude * (1.0 + _trouble)
	needle.rotation_degrees = _rest + _trouble * drift + (tremble if moving else 0.0)
