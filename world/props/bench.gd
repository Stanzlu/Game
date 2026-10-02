extends StaticBody2D
## Two-tile bench. Interacting sits the actor down; any movement stands them up.

const SEAT := Vector2(8, 1)


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


func _on_interacted(actor: Node) -> void:
	if actor.has_method(&"sit_on"):
		actor.call(&"sit_on", global_position + SEAT, Facing.Dir.S)
