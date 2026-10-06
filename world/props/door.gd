extends Node2D
## A way into another place: a house door, or the edge of a map. Params:
## {"target": "<scene key>", "spawn": "<marker name>"} plus optional "prompt"
## (INTERACT_ENTER), "auto": true (walking into it is enough, for map edges), "size": [w, h]
## in tiles for auto exits, "sound" (door_open), "if"/"unless" flags (MapView).

const TILE := 16

var target := ""
var spawn := ""
var sound := "door_open"
var auto := false


func apply_params(params: Dictionary) -> void:
	target = str(params.get("target", ""))
	spawn = str(params.get("spawn", ""))
	sound = str(params.get("sound", sound if not params.get("auto", false) else ""))
	auto = bool(params.get("auto", false))
	if not SceneRegistry.has(target):
		Log.error(Log.Category.CONTENT, "door target unknown", {"target": target})
		return
	if auto:
		_add_zone(params.get("size", [1, 1]))
	else:
		var area := Talk.add_area(
			self, str(params.get("prompt", "INTERACT_ENTER")), 10.0, Vector2(0, -6), 2
		)
		area.interacted.connect(
			func(_actor: Node) -> void: SceneTravel.go(self, target, spawn, sound)
		)


func _add_zone(size: Array) -> void:
	var zone := Area2D.new()
	zone.name = "Exit"
	zone.collision_layer = 0
	zone.collision_mask = PhysicsLayers.PLAYER
	zone.monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(float(size[0]), float(size[1])) * TILE
	shape.shape = rect
	zone.add_child(shape)
	add_child(zone)
	zone.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		SceneTravel.go(self, target, spawn, sound)
