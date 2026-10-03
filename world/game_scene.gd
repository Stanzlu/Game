class_name GameScene
extends Node
## Shared composition for playable scenes: pixel-perfect GameView, a text map, the player,
## footstep effects, dialogue box, pause menu and info overlay.
## Subclasses override _build_world() for non-map content (e.g. encounters).

const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const DIALOGUE_BOX_SCENE := preload("res://ui/dialogue/dialogue_box.tscn")
const PAUSE_MENU_SCENE := preload("res://ui/menus/pause_menu.tscn")

@export_file("*.txt") var map_path := ""

var view: GameView
var map: MapView
var player: Player
var fx: FootstepFx
var dialogue_box: DialogueBox
var pause_menu: PauseMenu
var overlay: InfoOverlay


func _ready() -> void:
	view = GameView.new()
	view.name = "GameView"
	add_child(view)
	fx = FootstepFx.new()
	fx.name = "FootstepFx"
	_build_world()
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(dialogue_box)
	overlay = InfoOverlay.new()
	overlay.name = "InfoOverlay"
	add_child(overlay)
	overlay.attach(self)
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	pause_menu.options_changed.connect(apply_options)
	apply_options()
	Log.info(Log.Category.BOOT, "scene ready", {"scene": str(name)})


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
	parent.add_child(player)
	player.teleport(at)
	view.follow(player)
	fx.watch(player)
	return player


func apply_options() -> void:
	SessionOptions.apply(player, view)
	if overlay != null:
		overlay.visible = SessionOptions.show_overlay
