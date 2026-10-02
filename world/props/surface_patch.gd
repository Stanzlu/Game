extends Node2D
## Flat decal with its own footstep surface (puddles and similar).

@export var surface := &"puddle"


func _ready() -> void:
	var area: Area2D = $Area
	area.collision_layer = PhysicsLayers.SURFACE
	area.collision_mask = 0
	area.monitoring = false
	area.set_meta(&"surface", surface)
