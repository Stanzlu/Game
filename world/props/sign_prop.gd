extends StaticBody2D
## A sign whose text comes from a dialogue file. Params: {"dialogue": path, "cue": name}.
## Any node in group "dialogue_presenter" shows it (usually the scene's DialogueBox).

var dialogue_path := "res://content/dialogue/sandbox/sandbox.dialogue"
var cue := "sign_default"


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	dialogue_path = str(params.get("dialogue", dialogue_path))
	cue = str(params.get("cue", cue))


func _on_interacted(actor: Node) -> void:
	var resource := load(dialogue_path) as DialogueResource
	if resource == null:
		Log.error(Log.Category.CONTENT, "sign dialogue missing", {"path": dialogue_path})
		return
	get_tree().call_group(&"dialogue_presenter", &"present", resource, cue, actor)
