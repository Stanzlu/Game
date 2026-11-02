class_name StadtScene
extends LookScene
## Act IV, S2: the city (docs/akt4/REGIONSBRIEFE.md). Elysia's market with a contradiction: a
## gate whose keeper has a bad day, a square with a fountain (Mira sits at its rim), the board with
## the Gefällige's slips, the town hall, two shops that are still shut, Lio playing in a corner,
## three stations of a perfect day that did not go to plan and a goat on a roof. The map and the
## dialogue tell all of it; this script only goes on with the hero's walk to the town, plays Lio's
## tune once he has played it and marks the beats. No cutscene, no lock, nothing here is needed.


func _ready() -> void:
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# the road ends here: the walk of the hero goes on from the road to the town
	if WorldState.quest_stage("main_city_way") == "west":
		WorldState.advance_quest("main_city_way", "town")
	Beat.mark("stadt_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "melody.lio_street":
		AudioDirector.sfx("lio_street", -2.0, 1.0)
		Beat.mark("stadt_lio")
