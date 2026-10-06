class_name Talk
extends RefCounted
## Shared helpers for props that start a conversation or a description: an Interactable
## area on the prop, and presenting a dialogue cue through the scene's DialogueBox.

const DEFAULT_DIALOGUE := "res://content/dialogue/slice/tal.dialogue"


## Adds an Interactable with a round area to `owner` and returns it.
static func add_area(
	owner: Node2D, prompt_key: String, radius: float, offset := Vector2(0, -4), priority := 0
) -> Interactable:
	var area := Interactable.new()
	area.name = "Interactable"
	area.prompt_key = prompt_key
	area.prompt_offset = Vector2(0, offset.y - radius - 10.0)
	area.interact_priority = priority
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	shape.position = offset
	area.add_child(shape)
	owner.add_child(area)
	return area


## Shows `cue` of the dialogue file at `path`. Returns the presenter's `finished` signal (or
## an already finished one when nothing could be shown) so callers can await it.
static func present(from: Node, path: String, cue: String, actor: Node = null) -> Signal:
	var resource := load(path) as DialogueResource
	var presenter := from.get_tree().get_first_node_in_group(&"dialogue_presenter")
	if resource == null or presenter == null:
		Log.error(Log.Category.CONTENT, "dialogue missing", {"path": path, "cue": cue})
		return from.get_tree().process_frame
	presenter.call(&"present", resource, cue, actor)
	return presenter.get(&"finished")
