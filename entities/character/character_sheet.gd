class_name CharacterSheet
extends Resource
## Describes a character sprite sheet and builds SpriteFrames from it at runtime.
## Layout (matches tools/placeholders/make_placeholders.py): one row per state and
## facing (state-major, facing order of Facing.Dir), frames left to right.
## "look" (blink, glance left and right, blink) is the long idle of the look sheets
## (Game Bible §36); sheets whose texture ends before those rows simply do not have it.

const STATES := [
	{"name": "idle", "frames": 2, "fps": 2.0, "loop": true},
	{"name": "walk", "frames": 4, "fps": 8.0, "loop": true},
	{"name": "run", "frames": 4, "fps": 12.0, "loop": true},
	{"name": "sit", "frames": 1, "fps": 1.0, "loop": false},
	{"name": "look", "frames": 4, "fps": 4.0, "loop": false},
]

static var _cache: Dictionary = {}

@export var texture: Texture2D
@export var frame_size := Vector2i(16, 24)
## Offset that puts the character's feet on the node origin.
@export var feet_offset := Vector2(0, -9)
## Optional contact shadow drawn under the feet (look prototype).
@export var shadow: Texture2D


static func animation_name(state: String, dir: Facing.Dir) -> StringName:
	return StringName("%s_%d" % [state, dir])


func build_frames() -> SpriteFrames:
	if texture == null:
		Log.error(Log.Category.CONTENT, "character sheet without texture", {"sheet": resource_path})
		return SpriteFrames.new()
	var key := texture.resource_path
	if _cache.has(key):
		return _cache[key]
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var row := 0
	var rows := floori(float(texture.get_height()) / float(frame_size.y))
	for state: Dictionary in STATES:
		if row + Facing.COUNT > rows:
			break
		for dir in Facing.COUNT:
			var anim := animation_name(state["name"], dir as Facing.Dir)
			frames.add_animation(anim)
			frames.set_animation_loop(anim, state["loop"])
			frames.set_animation_speed(anim, state["fps"])
			for f in int(state["frames"]):
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(Vector2(f * frame_size.x, row * frame_size.y), frame_size)
				frames.add_frame(anim, atlas)
			row += 1
	_cache[key] = frames
	return frames


## True if the sheet has the long idle (blink and glance around).
static func has_look(frames: SpriteFrames) -> bool:
	return frames.has_animation(animation_name("look", Facing.Dir.S))


## Adds the contact shadow (if the sheet has one) below the character's sprite.
func add_shadow_to(character: Node2D) -> void:
	if shadow == null:
		return
	var sprite := Sprite2D.new()
	sprite.name = "Shadow"
	sprite.texture = shadow
	sprite.z_index = -1
	character.add_child(sprite)
	character.move_child(sprite, 0)
