extends Area2D
## Runs world actions once when the player enters. Params: {"flag": "<area.name>",
## "actions": [...], "size": [w, h]} (size in tiles, default 1×1). The flag marks the zone
## as used, so it stays used after loading a save.

const TILE := 16

var flag := ""
var actions: Array = []


func _ready() -> void:
	collision_layer = 0
	collision_mask = PhysicsLayers.PLAYER
	monitorable = false
	body_entered.connect(_on_body_entered)


func apply_params(params: Dictionary) -> void:
	flag = str(params.get("flag", ""))
	actions = params.get("actions", [])
	var size: Array = params.get("size", [1, 1])
	var shape := RectangleShape2D.new()
	shape.size = Vector2(float(size[0]), float(size[1])) * TILE
	($Shape as CollisionShape2D).shape = shape
	if flag.is_empty():
		Log.error(Log.Category.CONTENT, "trigger zone without flag")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player") or flag.is_empty() or WorldState.has_flag(flag):
		return
	WorldState.set_flag(flag)
	StateActions.run(actions, "zone:" + flag)
