class_name RathausScene
extends LookScene
## Act IV, S2: the town hall from inside (docs/akt4/REGIONSBRIEFE.md). A counter, a clerk behind
## it, the lost property office (four things that belong to nobody any more) and the plan for the
## mayor's visit ("Ein perfekter Tag"). The clerk's dialogue tells all of it; this script only marks
## the beats of the two side quests. No cutscene, no lock, nothing here is needed to go on.


func _ready() -> void:
	super()
	WorldState.quest_changed.connect(_on_quest_changed)
	Beat.mark("rathaus_enter")


func _on_quest_changed(quest_id: String, stage: String) -> void:
	if stage != "done":
		return
	match quest_id:
		"side_city_lost":
			Beat.mark("rathaus_lost")
		"side_city_day":
			Beat.mark("rathaus_day")
