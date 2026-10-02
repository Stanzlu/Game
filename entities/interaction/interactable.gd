class_name Interactable
extends Area2D
## Something the player can interact with. Add as child of a prop and give it a
## CollisionShape2D. The player's InteractionSensor finds it and calls interact().

signal interacted(actor: Node)

## Translation key of the verb shown in the prompt, e.g. INTERACT_READ.
@export var prompt_key := "INTERACT_EXAMINE"
## Higher wins when several interactables are equally close.
@export var interact_priority := 0
@export var enabled := true
## Where the prompt appears, relative to this node.
@export var prompt_offset := Vector2(0, -20)


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	monitoring = false
	monitorable = true


func can_interact(_actor: Node) -> bool:
	return enabled and is_visible_in_tree()


func interact(actor: Node) -> void:
	if not can_interact(actor):
		return
	Log.info(
		Log.Category.INTERACTION, "interact", {"target": str(get_parent().name), "verb": prompt_key}
	)
	interacted.emit(actor)
