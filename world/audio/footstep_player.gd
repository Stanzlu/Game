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
## Level per surface, walking and running (dB). The step files share one loudness
## (STEP_LOUDNESS in tools/placeholders/make_placeholders.py, peaks at most -6 dBFS), so this
## sets the mix: walking sits at the level of the bed (hard ground and water a little over),
## and tall grass is no more than 3 dB from grass, so crossing the border does not jump.
const SURFACE_DB := {
	&"grass": Vector2(-5.0, -1.0),
	&"tall_grass": Vector2(-8.0, -4.0),
	&"dirt": Vector2(-3.0, 1.0),
	&"stone": Vector2(-2.0, 2.0),
	&"wood": Vector2(-2.0, 2.0),
	&"puddle": Vector2(-1.0, 3.0),
	&"water": Vector2(-1.0, 3.0),
}
## Elysia is led by its music: the steps stay under it.
const ELYSIA_DB := -3.0


func _ready() -> void:
	bus = &"SFX"


func play_surface(surface: StringName, running: bool) -> void:
	if not SURFACE_SOUNDS.has(surface):
		surface = &"dirt"
	stream = SoundBank.stream(SURFACE_SOUNDS[surface])
	var levels: Vector2 = SURFACE_DB[surface]
	volume_db = levels.y if running else levels.x
	if WorldState.ui_mode() == GameState.UiMode.ELYSIA:
		volume_db += ELYSIA_DB
	play()
