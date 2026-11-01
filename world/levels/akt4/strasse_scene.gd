class_name StrasseScene
extends LookScene
## Act IV, S1: the road west out of the valley (docs/akt4/REGIONSBRIEFE.md). A cart road through
## fields, hedges and orchards to a hill from which the city's smoke can be seen; a signpost, a
## milestone worn smooth, the goat's bell and hoofprints, a scarecrow. Everything on the map
## lives in props with `if`/`unless`/`sprite_when` and in the dialogue; this script only starts the
## hero's walk and marks the beats. No cutscene, no lock, nothing here is needed to go on.


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# the way west: the walk to the city begins on the road (a game begun in this scene has it too)
	if not WorldState.is_quest_started("main_city_way"):
		WorldState.start_quest("main_city_way")
	Beat.mark("strasse_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "city.view_seen":
		Beat.mark("strasse_view")
