class_name PrototypeMenu
extends MenuLayer
## Start menu submenu: the prototype scenes of the vertical slice in progress and the
## performance test. Each scene starts a new game state (Boot.open_scene).

const SCENES: PackedStringArray = ["look_elysia", "look_tal", "look_wald", "sandbox", "antreiber"]
const LABELS := {
	"look_elysia": "MENU_LOOK_ELYSIA",
	"look_tal": "MENU_LOOK_TAL",
	"look_wald": "MENU_LOOK_WALD",
	"sandbox": "MENU_SANDBOX",
	"antreiber": "MENU_ANTREIBER",
}

## Called with the scene key to open.
var on_scene: Callable
var on_benchmark: Callable


func _ready() -> void:
	title_key = "MENU_PROTOTYPES"
	panel_width = 220
	layer = 50
	follow_mode = false
	sound_set = AudioDirectorService.SoundSet.ELYSIA
	super()


func _build() -> void:
	for key in SCENES:
		list.add_action(LABELS[key], func() -> void: on_scene.call(key))
	list.add_action("MENU_BENCHMARK", func() -> void: on_benchmark.call())
	list.add_action("MENU_BACK", close)
