class_name FlutlichtungScene
extends LookScene
## Act III, W4: the clearing the brook runs past (docs/akt3/REGIONSBRIEFE.md). The water once stood
## over it, and what it left is the Antreiber's why, shown as things: a bleached trunk without a
## crown with a line of silt above her head, a camp the silt took, the trail of one runner going
## back the way she came. Nothing here is needed to go on and nothing is said about a cause. Every
## thing on the map lives in props with `if`/`unless`/`sprite_when` and in the dialogue; this script
## only marks the beats of the visit and moves the quest of the way through the wood: seeing the
## trunk is the goal "flood". No cutscene, no lock, no timer.


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# he went on ahead of her, unless he sits by the fire in the house (he is not on the way or in
	# the valley any more, the maps read this flag)
	if not WorldState.has_flag("house.antreiber_by_fire"):
		WorldState.set_flag("forest.antreiber_ahead")
	Beat.mark("flut_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"forest.flood_seen":
			_flood_seen()
		"forest.flood_sat":
			Beat.mark("flut_tea")


## She has stood under the trunk: the goal "flood" of the way through the wood is done, and with the
## hut seen too the quest goes on to the night. The mirror image of the hut (huette_scene.gd); only
## in the stage "wood", where both goals live.
func _flood_seen() -> void:
	if WorldState.quest_stage("main_forest_way") == "wood":
		WorldState.complete_objective("main_forest_way", "flood")
		if WorldState.is_objective_done("main_forest_way", "hermit"):
			WorldState.advance_quest("main_forest_way", "night")
	Beat.mark("flut_mark")
