extends StaticBody2D
## Two-tile bench. Interacting sits the actor down; any movement stands them up.
## With params "pass_time": true, sitting a while lets the day move on (DayLight of the
## scene: rainy day, evening, night) — resting is how time passes in the Real world.

const SEAT := Vector2(8, 1)
const REST_SECONDS := 2.5

var pass_time := false
## Each sit-down counts; only the latest one may pass time (sit, stand, sit again).
var _rest_serial := 0


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


## Map params: {"sprite": "<style>/<name>"} swaps in art from the prop catalog (ADR-017).
func apply_params(params: Dictionary) -> void:
	pass_time = bool(params.get("pass_time", false))
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
	if pass_time and actor is Player:
		_rest(actor as Player)


func _rest(player: Player) -> void:
	_rest_serial += 1
	var serial := _rest_serial
	await NodeTimer.after(self, REST_SECONDS)
	if serial != _rest_serial or not is_instance_valid(player) or player.state != Player.State.SIT:
		return
	var scene := get_tree().get_first_node_in_group(SaveService.CONTEXT_GROUP) as LookScene
	if scene != null and scene.day_light != null:
		scene.day_light.next_preset(6.0)
