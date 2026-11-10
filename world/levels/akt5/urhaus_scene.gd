class_name UrhausScene
extends LookScene
## Act V, G8: the first house from inside (docs/akt5/REGIONSBRIEFE.md, O2, O7, O10, O19). One room
## with a small bed in the middle, six rings of blue chalk drawn on the floor one inside the other
## (the innermost round the bed, the outermost along the walls and over the threshold), a window in
## the back wall that is chalked over, and a stick of chalk on the floor. Nothing is explained: the
## dialogue only says what is there. This script plays the first look once (a few lines as the
## player steps in), moves the walk of the hero one step on (`house`) and marks the beats; the
## picture at the bed (`fragment.first_house`), the window (the facet `courage` lets her wipe the
## chalk away, `urhaus.window_clear`) and the chalk (a curiosity) are props with their cues. No
## timer, nothing locked after the first look, nothing here is needed to go on.

const DIALOGUE := "res://content/dialogue/akt5/urhaus.dialogue"
const QUEST := "main_mountain_way"
## The room's cells: the camera stays centred on it (it fits whole at the zoom of an interior).
const ROOM := Rect2i(4, 4, 25, 14)
## Quiet after the door and before the first lines (seconds of play time).
const LOOK_PAUSE := 0.8


func _ready() -> void:
	music = "silence"
	super()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	WorldState.flag_changed.connect(_on_flag_changed)
	# the walk of the hero takes its next step when she steps in (before the entry is saved)
	if WorldState.quest_stage(QUEST) == "child":
		WorldState.advance_quest(QUEST, "house")
	Beat.mark("urhaus_enter")
	if not Beat.reached("urhaus_look"):
		_first_look()


## The first look at the room: a few lines, once; then she walks as she likes.
func _first_look() -> void:
	await NodeTimer.after(self, LOOK_PAUSE)
	var cut := Cutscene.begin(self)
	await cut.say(DIALOGUE, "house_look")
	cut.end()
	Beat.mark("urhaus_look")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	if id == "fragment.first_house":
		Beat.mark("urhaus_house")
	elif id == "urhaus.window_clear":
		Beat.mark("urhaus_window")
