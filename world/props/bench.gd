extends StaticBody2D
## Two-tile bench. Interacting sits the actor down; any movement stands them up.

const SEAT := Vector2(8, 1)


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


## Map params: {"sprite": "<style>/<name>"} swaps in art from the prop catalog (ADR-017).
func apply_params(params: Dictionary) -> void:
	if not params.has("sprite"):
		return
	var entry := PropCatalog.entry(str(params["sprite"]))
	if entry.is_empty():
		return
	var sprite: Sprite2D = $Sprite
	sprite.texture = PropCatalog.texture_for(entry, global_position)
	var anchor: Array = entry.get("anchor", [0, 0])
	sprite.offset = -Vector2(float(anchor[0]), float(anchor[1]))


func _on_interacted(actor: Node) -> void:
	if actor.has_method(&"sit_on"):
		actor.call(&"sit_on", global_position + SEAT, Facing.Dir.S)
