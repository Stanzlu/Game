class_name InfoOverlay
extends CanvasLayer
## Development info (FPS, frame time, player state, surface, save state). Toggle with
## debug_overlay (F3) or in the settings. Helps to talk about movement feel with numbers.

var _scene: GameScene
var _label: Label


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"OverlayPanel"
	panel.position = Vector2(4, 4)
	add_child(panel)
	_label = Label.new()
	panel.add_child(_label)


func attach(scene: GameScene) -> void:
	_scene = scene


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_overlay"):
		Settings.set_value("debug.overlay", not Settings.get_bool("debug.overlay"))
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible or _scene == null:
		return
	var lines := PackedStringArray()
	lines.append(
		(
			"FPS %d  %.1f ms"
			% [Engine.get_frames_per_second(), 1000.0 / maxf(Engine.get_frames_per_second(), 1.0)]
		)
	)
	var p := _scene.player
	if p != null and is_instance_valid(p):
		lines.append("Pos %d, %d" % [roundi(p.global_position.x), roundi(p.global_position.y)])
		lines.append("Tempo %d px/s" % roundi(p.velocity.length()))
		lines.append("%s · %s" % [Player.State.keys()[p.state], Facing.Dir.keys()[p.facing]])
		lines.append("Boden %s" % (p.last_surface if p.last_surface != &"" else "-"))
	lines.append(tr(Settings.tuning().display_key))
	lines.append(
		tr("CAMERA_SMOOTH") if Settings.get_bool("display.smooth_camera") else tr("CAMERA_PIXEL")
	)
	lines.append("Save %s" % ("ok" if SaveSystem.can_save() else ", ".join(SaveSystem.blockers())))
	_label.text = "\n".join(lines)
