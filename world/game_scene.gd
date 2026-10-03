class_name GameScene
extends Node
## Shared composition for playable scenes: pixel-perfect GameView, a text map, the player,
## footstep effects, dialogue box, journal, pause menu and info overlay.
## Subclasses override _build_world() for non-map content (e.g. encounters).
##
## The scene is the save context (group "save_context"): it tells SaveSystem where the
## player is and whether saving is possible here. After loading a save it puts the player
## back at the saved position; otherwise entering it triggers an autosave.

const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const DIALOGUE_BOX_SCENE := preload("res://ui/dialogue/dialogue_box.tscn")
const PAUSE_MENU_SCENE := preload("res://ui/menus/pause_menu.tscn")
const JOURNAL_SCENE := preload("res://ui/journal/journal.tscn")
const DEBUG_PANEL_SCRIPT := preload("res://ui/debug/debug_panel.gd")

@export_file("*.txt") var map_path := ""
## Optional art override for the player (look prototype uses the 24x32 sheet).
@export var player_sheet: CharacterSheet
## False for places that cannot be resumed (encounters); autosaves wait for the next area.
@export var saveable := true
## Music for this place (AudioDirector); "keep" leaves whatever is playing.
@export_enum("keep", "silence", "elysia", "valley", "forest", "antreiber") var music := "keep"
## Ambience bed (rain, birds); none fades the previous one out.
@export var ambience: AudioStream
@export var ambience_db := -6.0

var view: GameView
var map: MapView
var player: Player
var fx: FootstepFx
var dialogue_box: DialogueBox
var pause_menu: PauseMenu
var journal: Journal
var overlay: InfoOverlay


func _ready() -> void:
	add_to_group(SaveService.CONTEXT_GROUP)
	view = GameView.new()
	view.name = "GameView"
	add_child(view)
	fx = FootstepFx.new()
	fx.name = "FootstepFx"
	_build_world()
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(dialogue_box)
	journal = JOURNAL_SCENE.instantiate()
	add_child(journal)
	overlay = InfoOverlay.new()
	overlay.name = "InfoOverlay"
	add_child(overlay)
	overlay.attach(self)
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	if OS.is_debug_build():
		var debug_panel: CanvasLayer = DEBUG_PANEL_SCRIPT.new()
		debug_panel.name = "DebugPanel"
		add_child(debug_panel)
	if music != "keep":
		AudioDirector.play_music(music)
	AudioDirector.set_ambience(ambience, ambience_db)
	Settings.changed.connect(func(_key: String) -> void: apply_settings())
	apply_settings()
	var arrival := SaveSystem.scene_entered(scene_key())
	if arrival.has("position") and player != null:
		player.teleport(arrival["position"])
		view.follow(player)
	Log.info(Log.Category.BOOT, "scene ready", {"scene": str(name), "key": scene_key()})


## Default world: load map_path, spawn the player at the player_spawn marker.
func _build_world() -> void:
	map = MapView.new()
	map.name = "Map"
	view.world_root.add_child(map)
	if not map.load_map(map_path):
		return
	map.entities.add_child(fx)
	var spawns := map.data.find_marker("player_spawn")
	var at := map.cell_to_world(spawns[0]["cell"]) if not spawns.is_empty() else Vector2.ZERO
	spawn_player(map.entities, at)
	player.surface_provider = map.surface_at
	view.bounds = map.world_rect()


func spawn_player(parent: Node, at: Vector2) -> Player:
	player = PLAYER_SCENE.instantiate()
	if player_sheet != null:
		player.sheet = player_sheet
	parent.add_child(player)
	player.teleport(at)
	view.follow(player)
	fx.watch(player)
	return player


## Stable key of this scene (SceneRegistry), used in save files.
func scene_key() -> String:
	return SceneRegistry.key_for_path(scene_file_path)


func is_saveable() -> bool:
	return saveable and player != null and SceneRegistry.has(scene_key())


func save_location() -> Dictionary:
	return {
		"map": scene_key(), "position": player.global_position if player != null else Vector2.ZERO
	}


func apply_settings() -> void:
	if player != null:
		player.tuning = Settings.tuning()
		player.snap_eight = Settings.get_bool("controls.eight_directions")
		player.sprint_toggle = Settings.get_bool("controls.sprint_toggle")
	if view != null:
		view.set_camera_mode(
			(
				GameView.CameraMode.SMOOTH
				if Settings.get_bool("display.smooth_camera")
				else GameView.CameraMode.PIXEL
			)
		)
	if overlay != null:
		overlay.visible = Settings.get_bool("debug.overlay")
