class_name BachlaufScene
extends LookScene
## Act II, B3: the stream below the valley, a loop of a worn track along both banks
## (docs/akt2/REGIONSBRIEFE.md). Everything the stream left behind lives in the map (props with
## `if`/`unless`/`sprite_when`) and in the dialogue; this script only reads what the player is (the
## facet Wahrnehmung becomes a flag the map can ask for) and marks the beats of the walk. No
## cutscene, no lock, nothing here is needed for the evening's end.


func _ready() -> void:
	# whoever looks closely sees one more spot at the post (the map's prop reads the flag)
	if WorldState.has_facet("perception"):
		WorldState.set_flag("valley.looks_closely")
	super()
	WorldState.flag_changed.connect(_on_flag_changed)
	WorldState.quest_changed.connect(_on_quest_changed)
	# Act III (ADR-070): the morning after leads along the stream; the quest only moves from its start
	if WorldState.quest_stage("main_forest_way") == "leave":
		WorldState.advance_quest("main_forest_way", "brook")
	Beat.mark("bachlauf_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if id == "valley.knot_seen" and value:
		Beat.mark("bachlauf_blick")


## The empty hook, the float in the reeds, the trap behind the weir, the trap in the stream.
func _on_quest_changed(quest_id: String, stage: String) -> void:
	if quest_id != "side_valley_trap":
		return
	match stage:
		"hook":
			Beat.mark("bachlauf_hook")
		"float":
			Beat.mark("bachlauf_float")
		"weir":
			Beat.mark("bachlauf_weir")
		"done":
			Beat.mark("bachlauf_freed")
