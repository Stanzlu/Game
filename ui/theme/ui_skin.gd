class_name UiSkin
extends Node
## Keeps a Control in the skin of the current UI mode (Game Bible §34): Elysia is gold,
## ornaments and warm light; the Real world is minimal, quiet, almost empty.
## Usage: UiSkin.attach(control). The helper node follows mode changes and loaded saves,
## and goes away with the control. Skins only override what differs from the base theme.

const ELYSIA_SKIN := preload("res://ui/theme/elysia_skin.tres")
const REAL_SKIN := preload("res://ui/theme/real_skin.tres")

var _target: Control


static func theme_for(mode: GameState.UiMode) -> Theme:
	return ELYSIA_SKIN if mode == GameState.UiMode.ELYSIA else REAL_SKIN


static func attach(control: Control) -> UiSkin:
	var follower := UiSkin.new()
	follower.name = "UiSkin"
	follower._target = control
	control.add_child(follower)
	return follower


func _ready() -> void:
	WorldState.ui_mode_changed.connect(func(_mode: GameState.UiMode) -> void: apply())
	WorldState.state_replaced.connect(apply)
	apply()


func apply() -> void:
	if is_instance_valid(_target):
		_target.theme = theme_for(WorldState.ui_mode())
