class_name InteractionSensor
extends Area2D
## Finds interactables around the actor and keeps the best one as `current`.

signal target_changed(target: Interactable)

var current: Interactable


func _ready() -> void:
	collision_layer = 0
	collision_mask = PhysicsLayers.INTERACTABLE
	monitoring = true
	monitorable = false


func update_target(actor: Node2D, facing_vector: Vector2, active: bool) -> void:
	var next: Interactable = null
	if active:
		var candidates: Array[Dictionary] = []
		for area in get_overlapping_areas():
			var it := area as Interactable
			if it != null and it.can_interact(actor):
				candidates.append(
					{"position": it.global_position, "priority": it.interact_priority, "id": it}
				)
		var best := InteractionSelector.pick(actor.global_position, facing_vector, candidates)
		if not best.is_empty():
			next = best["id"]
	if next != current:
		current = next
		target_changed.emit(current)


func try_interact(actor: Node) -> bool:
	if current == null or not is_instance_valid(current):
		return false
	current.interact(actor)
	return true
