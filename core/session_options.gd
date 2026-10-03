class_name SessionOptions
extends RefCounted
## Phase-1 test options chosen in the pause menu. They live for the running session only;
## the Settings autoload (Phase 2) replaces this with persisted, accessible settings.

const TUNING_PRESETS: PackedStringArray = ["direkt", "weich", "schwer"]

static var tuning_index := 0
static var smooth_camera := true
static var snap_eight := true
static var sprint_toggle := false
static var show_overlay := false


## Reads --camera=pixel|smooth, --tuning=direkt|weich|schwer, --directions=eight|free,
## --sprint=hold|toggle, --overlay from the user arguments (captures, tests, quick A/B runs).
static func apply_args(args: PackedStringArray) -> void:
	for arg in args:
		var parts := arg.trim_prefix("--").split("=", true, 1)
		var value := parts[1] if parts.size() > 1 else ""
		match parts[0]:
			"camera":
				smooth_camera = value != "pixel"
			"tuning":
				tuning_index = maxi(TUNING_PRESETS.find(value), 0)
			"directions":
				snap_eight = value != "free"
			"sprint":
				sprint_toggle = value == "toggle"
			"overlay":
				show_overlay = true


static func tuning() -> MovementTuning:
	return load("res://entities/player/tuning/%s.tres" % TUNING_PRESETS[tuning_index])


static func apply(player: Player, view: GameView) -> void:
	if player != null:
		player.tuning = tuning()
		player.snap_eight = snap_eight
		player.sprint_toggle = sprint_toggle
	if view != null:
		view.set_camera_mode(
			GameView.CameraMode.SMOOTH if smooth_camera else GameView.CameraMode.PIXEL
		)
