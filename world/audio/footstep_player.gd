class_name FootstepPlayer
extends AudioStreamPlayer2D
## Plays a footstep for a surface. Sound prefixes per surface; unknown surfaces fall back to dirt.

const SURFACE_SOUNDS := {
	&"grass": "footstep_grass",
	&"tall_grass": "rustle",
	&"dirt": "footstep_dirt",
	&"stone": "footstep_stone",
	&"wood": "footstep_wood",
	&"puddle": "footstep_puddle",
	&"water": "footstep_puddle",
}
## Level per surface, walking and running (dB). The step sounds are equally loud, so this
## sets the mix: soft ground stays quiet, hard ground and water carry.
const SURFACE_DB := {
	&"grass": Vector2(-10.0, -6.0),
	&"tall_grass": Vector2(-6.0, -2.0),
	&"dirt": Vector2(-8.0, -4.0),
	&"stone": Vector2(-6.0, -2.0),
	&"wood": Vector2(-6.0, -2.0),
	&"puddle": Vector2(-5.0, -1.0),
	&"water": Vector2(-5.0, -1.0),
}


func _ready() -> void:
	bus = &"SFX"


func play_surface(surface: StringName, running: bool) -> void:
	if not SURFACE_SOUNDS.has(surface):
		surface = &"dirt"
	stream = SoundBank.stream(SURFACE_SOUNDS[surface])
	var levels: Vector2 = SURFACE_DB[surface]
	volume_db = levels.y if running else levels.x
	play()
