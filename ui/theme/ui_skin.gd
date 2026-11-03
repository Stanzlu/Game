class_name UiSkin
extends Node
## Keeps a Control in the skin of the current UI mode (Game Bible §34): Elysia is gold,
## ornaments and warm light; the Real world is minimal, quiet, almost empty.
## Usage: UiSkin.attach(control). The helper node follows mode changes and loaded saves,
## and goes away with the control. Skins only override what differs from the base theme.
## The third skin, "personal" (§34 "Später": handwriting, notes, colours; ADR-071 O17), is the Real
## skin of the end of Act IV on: the same quiet layout in a hand's palette and Patrick Hand. It is
## worn, not saved: the mode stays REAL, the chapter mark decides.

const ELYSIA_SKIN := preload("res://ui/theme/elysia_skin.tres")
const REAL_SKIN := preload("res://ui/theme/real_skin.tres")
const PERSONAL_SKIN := preload("res://ui/theme/personal_skin.tres")
const PERSONAL_FONT := preload("res://assets/fonts/patrickhand/PatrickHand-Regular.ttf")
const PIXEL_LARGE_FONT := preload("res://assets/fonts/jersey15/Jersey15-Regular.ttf")
## The chapter from which the Real world wears the personal skin: the shelves hang, the act is over.
const PERSONAL_FROM := "act4"
## Body text in pixels, normal and large. The pixel fonts sit at sizes that render crisp (Jersey 10
## at 19, Jersey 15 at 27, ADR-026); the hand is drawn smaller for the same height of a line.
const PIXEL_SIZE := {false: 19, true: 27}
const PERSONAL_SIZE := {false: 20, true: 27}

var _target: Control


## True while the Real world's interface wears the hand (never in Elysia, never before the end of
## Act IV).
static func personal() -> bool:
	return WorldState.ui_mode() == GameState.UiMode.REAL and Chapter.reached(PERSONAL_FROM)


static func theme_for(mode: GameState.UiMode) -> Theme:
	if mode == GameState.UiMode.ELYSIA:
		return ELYSIA_SKIN
	return PERSONAL_SKIN if Chapter.reached(PERSONAL_FROM) else REAL_SKIN


## The size of body text in the skin that is worn now.
static func body_size(large: bool) -> int:
	return (PERSONAL_SIZE if personal() else PIXEL_SIZE)[large]


## The font of large body text in the skin that is worn now (normal text follows the theme).
static func large_font() -> Font:
	return PERSONAL_FONT if personal() else PIXEL_LARGE_FONT


static func attach(control: Control) -> UiSkin:
	var follower := UiSkin.new()
	follower.name = "UiSkin"
	follower._target = control
	control.add_child(follower)
	return follower


func _ready() -> void:
	WorldState.ui_mode_changed.connect(func(_mode: GameState.UiMode) -> void: apply())
	WorldState.state_replaced.connect(apply)
	WorldState.flag_changed.connect(_on_flag_changed)
	apply()


func apply() -> void:
	if is_instance_valid(_target):
		_target.theme = theme_for(WorldState.ui_mode())


func _on_flag_changed(id: String, _value: bool) -> void:
	if id == Chapter.flag_for(PERSONAL_FROM):
		apply()
