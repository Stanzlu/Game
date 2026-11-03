class_name StrasseScene
extends LookScene
## Act IV, S1: the road west out of the valley (docs/akt4/REGIONSBRIEFE.md). A cart road through
## fields, hedges and orchards to a hill from which the city's smoke can be seen; a signpost, a
## milestone worn smooth, the goat's bell and hoofprints, a scarecrow. Everything on the map
## lives in props with `if`/`unless`/`sprite_when` and in the dialogue; this script only starts the
## hero's walk and marks the beats. No cutscene, no lock, nothing here is needed to go on.
## Since S8 the road also ends the night: whoever comes out of the city after Mira has gone ahead
## (the quarrel at the gate, S7) walks into the morning (the stage "home"; two lines, once).

const DIALOGUE := "res://content/dialogue/akt4/strasse.dialogue"
const DAWN_PAUSE := 1.0


func _ready() -> void:
	# before the scene saves its entry: the stage says that the night is over
	var dawn := _night_is_over()
	if dawn:
		WorldState.advance_quest("main_city_way", "home")
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	# the way west: the walk to the city begins on the road (a game begun in this scene has it too)
	if not WorldState.is_quest_started("main_city_way"):
		WorldState.start_quest("main_city_way")
	Beat.mark("strasse_enter")
	if dawn:
		_dawn()


## The quarrel is over (Mira went ahead, whichever way it ended) and the player has left the city.
func _night_is_over() -> bool:
	if WorldState.quest_stage("main_city_way") != "night":
		return false
	for flag in StadtScene.PARTED:
		if WorldState.has_flag(flag):
			return true
	return false


## The night goes into the morning without anything happening (two lines, once).
func _dawn() -> void:
	await NodeTimer.after(self, DAWN_PAUSE)
	var cut := Cutscene.begin(self)
	await cut.say(DIALOGUE, "dawn")
	await cut.wait(0.4)
	Beat.mark("strasse_dawn")
	cut.end()


func _on_flag_changed(id: String, value: bool) -> void:
	if value and id == "city.view_seen":
		Beat.mark("strasse_view")
