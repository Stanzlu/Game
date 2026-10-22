class_name NpcSteps
extends FootstepPlayer
## Footsteps of a character other than the player (Mira, the Antreiber, the child): the same
## sounds on the same frames as the player's (the walk and run cycles put a foot down on
## frames 0 and 2), but a few dB under them, so that the player's own steps stay the lead.
## Positional: heard where the walker is.

## How far under the player's steps these sit.
const BELOW_PLAYER_DB := 6.0

## Surface under a world position; unset means dirt.
var surface_provider := Callable()
## Asked before every step: false keeps the walker quiet (Elysians do not step).
var audible := Callable()
var _sprite: AnimatedSprite2D
## Animation and frame that last put a foot down (or were looked at), so a frame counts once.
var _seen_animation := &""
var _seen_frame := -1


## Adds the steps of `sprite` as a child of `host`.
static func attach(
	host: Node2D, sprite: AnimatedSprite2D, surface := Callable(), gate := Callable()
) -> NpcSteps:
	var steps := NpcSteps.new()
	steps.name = "Steps"
	steps._sprite = sprite
	steps.surface_provider = surface
	steps.audible = gate
	steps.max_distance = SoundBank.HEARING_DISTANCE
	steps.attenuation = SoundBank.HEARING_ATTENUATION
	host.add_child(steps)
	return steps


## The first ancestor that knows the ground under the map (MapView, the Antreiber encounter).
static func surface_finder(from: Node) -> Callable:
	var node := from.get_parent()
	while node != null:
		if node.has_method(&"surface_at"):
			return Callable(node, &"surface_at")
		node = node.get_parent()
	return Callable()


func _physics_process(_delta: float) -> void:
	if _sprite == null:
		return
	var anim := String(_sprite.animation)
	var running := anim.begins_with("run_")
	if not _sprite.is_playing() or not (running or anim.begins_with("walk_")):
		_seen_animation = &""
		_seen_frame = -1
		return
	if _sprite.animation == _seen_animation and _sprite.frame == _seen_frame:
		return
	_seen_animation = _sprite.animation
	_seen_frame = _sprite.frame
	if _sprite.frame % 2 != 0 or (audible.is_valid() and not bool(audible.call())):
		return
	if not surface_provider.is_valid():
		surface_provider = surface_finder(self)
	play_surface(
		surface_provider.call(global_position) if surface_provider.is_valid() else &"dirt", running
	)


func play_surface(surface: StringName, running: bool) -> void:
	# the level is set before the sound starts: no first buffer at the player's loudness
	if not SURFACE_SOUNDS.has(surface):
		surface = &"dirt"
	stream = SoundBank.stream(SURFACE_SOUNDS[surface])
	var levels: Vector2 = SURFACE_DB[surface]
	volume_db = (levels.y if running else levels.x) - BELOW_PLAYER_DB
	if WorldState.ui_mode() == GameState.UiMode.ELYSIA:
		volume_db += ELYSIA_DB
	play()
