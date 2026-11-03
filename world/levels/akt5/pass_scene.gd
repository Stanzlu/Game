class_name PassScene
extends LookScene
## Act V, G1: the climb into the mountains (docs/akt5/REGIONSBRIEFE.md). A path that follows the
## brook north from the road, up through the wood's edge and the scree to a rock terrace from
## which the smoke of the Anlage can be seen. The way finds itself without markers (cairns in sight
## of each other, the smoke, the light); a trace of Mira's, three small things to look at, nothing
## speaks. Everything on the map lives in props with `if`/`unless` and in the dialogue; this script
## only starts the hero's walk and marks the beats. No cutscene, no lock.

const QUEST := "main_mountain_way"


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# the way up: the walk begins on the path (a game begun in this scene has it too)
	if not WorldState.is_quest_started(QUEST):
		WorldState.start_quest(QUEST)
	Beat.mark("pass_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "mountain.view_seen":
		Beat.mark("pass_view")
