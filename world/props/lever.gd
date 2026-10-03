extends StaticBody2D
## Toggles linked nodes. Params: {"target": "<link id>", "flag": "<area.name>",
## "actions": [...]}; targets join group "link_<id>" and implement set_linked_state(on).
## With "flag" the lever remembers its state in WorldState (and so in save files); pulling
## it on the first time runs "actions" (StateActions, e.g. a quest step).

var target := ""
var flag := ""
var actions: Array = []
var is_on := false

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	($Interactable as Interactable).interacted.connect(_on_interacted)


func apply_params(params: Dictionary) -> void:
	target = str(params.get("target", ""))
	flag = str(params.get("flag", ""))
	actions = params.get("actions", [])
	if not flag.is_empty() and WorldState.has_flag(flag):
		_set_on(true, false)


func _on_interacted(_actor: Node) -> void:
	_set_on(not is_on, true)
	if is_on and not actions.is_empty():
		StateActions.run(actions, "lever:" + target)


func _set_on(on: bool, by_player: bool) -> void:
	is_on = on
	_sprite.frame = 1 if is_on else 0
	if not flag.is_empty():
		WorldState.set_flag(flag, is_on)
	if by_player:
		SoundBank.play_at(self, "lever", global_position, -4.0)
	if target.is_empty():
		Log.warn(Log.Category.INTERACTION, "lever without target")
		return
	# Deferred: on load the linked gate may not be in the tree yet.
	get_tree().call_group.call_deferred(StringName("link_" + target), &"set_linked_state", is_on)
