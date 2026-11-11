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


## What a prop says once the story has moved on: the map param "talk_when" is
## {"<flag>": {"dialogue": "res://…", "cue": "…"}} and the first flag that is set wins (a missing
## "dialogue" is the prop's own). Returns [dialogue path, cue]; the prop's own pair when no flag is
## set. Act VI gives the people of Elysia new cues this way (docs/akt6/REGIONSBRIEFE.md, R3) and
## leaves the lines of Act I as they are; StoryLint reads the flags and checks the cues.
static func pick(talk_when: Variant, path: String, cue: String) -> PackedStringArray:
	if talk_when is Dictionary:
		for flag: Variant in talk_when:
			if WorldState.has_flag(str(flag)) and (talk_when as Dictionary)[flag] is Dictionary:
				var spec: Dictionary = (talk_when as Dictionary)[flag]
				return PackedStringArray(
					[str(spec.get("dialogue", path)), str(spec.get("cue", cue))]
				)
	return PackedStringArray([path, cue])


## Shows `cue` of the dialogue file at `path`; await it to continue when the box closed.
## A cue requested while another conversation is open waits for it instead of being lost.
static func present(from: Node, path: String, cue: String, actor: Node = null) -> void:
	var resource := load(path) as DialogueResource
	var tree := from.get_tree()
	var presenter := tree.get_first_node_in_group(&"dialogue_presenter")
	if resource == null or presenter == null:
		Log.error(Log.Category.CONTENT, "dialogue missing", {"path": path, "cue": cue})
		await tree.process_frame
		return
	while is_instance_valid(presenter) and presenter.call(&"is_open"):
		await presenter.get(&"finished")
	if not is_instance_valid(presenter):
		return
	presenter.call(&"present", resource, cue, actor)
	await presenter.get(&"finished")
