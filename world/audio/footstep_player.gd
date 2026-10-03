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


func _ready() -> void:
	bus = &"SFX"


func play_surface(surface: StringName, running: bool) -> void:
	stream = SoundBank.stream(SURFACE_SOUNDS.get(surface, "footstep_dirt"))
	volume_db = -2.0 if running else -6.0
	play()
