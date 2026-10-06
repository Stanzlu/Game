class_name SliceAntreiber
extends AntreiberEncounter
## Beat 5 of the vertical slice (docs/PHASE4_PLAN.md): the way to the woodshed in the rain.
## The Antreiber "helps"; the shed stays ahead however fast one goes. Standing still (or
## sitting on a bench, or stopping to read the sign) ends it: the shed is right there and
## the dry wood lies at one's feet. With the wood the way back to the valley is short.

const DIALOGUE := preload("res://content/dialogue/slice/antreiber.dialogue")
const SHEET := preload("res://entities/character/sheet_antreiber_look.tres")
const DECOR := preload("res://world/props/decor.tscn")
const PICKUP := preload("res://world/props/pickup.tscn")
const SOUNDSCAPE := preload("res://content/audio/tal_regentag.tres")
const WOOD_FLAG := "valley.wood_taken"
## Dusk under the trees, rain: the same light as the valley, a little darker.
const WORLD_TINT := Color(0.68, 0.74, 0.86)
const GRADE := {
	"saturation": 0.78,
	"contrast": 0.95,
	"brightness": 0.04,
	"tint": Color(0.96, 0.99, 1.03),
	"shadow_tint": Color(0.05, 0.06, 0.08),
	"vignette": 0.2,
	"bloom": 0.15,
}

var _wood: Node2D


func _build_world() -> void:
	segment_plain = "res://content/maps/antreiber_tal.txt"
	segment_bench = "res://content/maps/antreiber_tal_bench.txt"
	goal_scene = DECOR
	goal_params = {"sprite": "tal/shed"}
	goal_offset_y = -34.0
	goal_beside = 46.0
	bird_offset = Vector2(10, -48)
	ambience = SOUNDSCAPE
	ambience_db = -8.0
	super()
	_add_atmosphere()
	WorldState.flag_changed.connect(_on_flag_changed)
	Beat.mark("shed_path")


func _configure_actor(actor: AntreiberActor) -> void:
	actor.sheet = SHEET
	actor.dialogue = DIALOGUE


func _add_atmosphere() -> void:
	var tint := CanvasModulate.new()
	tint.name = "WorldTint"
	tint.color = WORLD_TINT
	view.world_root.add_child(tint)
	var layer := CanvasLayer.new()
	layer.name = "WeatherLayer"
	layer.layer = 1
	layer.follow_viewport_enabled = true
	view.viewport.add_child(layer)
	var rain := RainFx.new()
	rain.name = "Rain"
	layer.add_child(rain)
	rain.setup(view, 0.8)
	view.world_root.add_child(AmbientParticles.leaves(view))
	view.set_post_material(LookScene.grade_material(GRADE))


## The shed came to the player: the bird lands on its roof, the wood lies on the path.
func _after_resolved() -> void:
	super()
	if WorldState.has_flag(WOOD_FLAG):
		# the wood was taken on an earlier walk: nothing to pick up, just the way back
		await NodeTimer.after(self, 2.0)
		SceneTravel.go(self, "tal", "west", "")
		return
	_wood = PICKUP.instantiate()
	_actors.add_child(_wood)
	_wood.global_position = Vector2(player.global_position.x + 20, PATH_Y + 6)
	_wood.call(
		&"apply_params", {"item": "item_dry_wood", "flag": WOOD_FLAG, "sprite": "tal/wood_bundle"}
	)


func _on_flag_changed(id: String, value: bool) -> void:
	if id != WOOD_FLAG or not value:
		return
	Beat.mark("wood")
	if WorldState.quest_stage("main_valley_shelter") == "wood":
		WorldState.advance_quest("main_valley_shelter", "fire")
	await NodeTimer.after(self, 0.6)
	var cut := Cutscene.begin(self)
	await cut.say(DIALOGUE.resource_path, "wood")
	await cut.wait(0.8)
	cut.end()
	SceneTravel.go(self, "tal", "west", "")
