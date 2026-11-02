class_name BlumenladenScene
extends LookScene
## Act IV, S3: the florist's shop from inside (docs/akt4/REGIONSBRIEFE.md). Orin, who looks like a
## warrior and keeps flowers, behind his work table; a bunch of peonies drying upside down over it.
## His dialogue tells all of it (the duck, the letter); this script only marks the beats of the two
## side quests. No cutscene, no lock, nothing here is needed to go on.

## The room's cells: the camera stays centred on it (it fits whole at the zoom of an interior).
const ROOM := Rect2i(4, 3, 18, 12)


func _ready() -> void:
	music = "silence"
	super()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	WorldState.quest_changed.connect(_on_quest_changed)
	Beat.mark("blumenladen_enter")


func _on_quest_changed(quest_id: String, stage: String) -> void:
	if stage != "done":
		return
	match quest_id:
		"side_city_duck":
			Beat.mark("blumenladen_duck")
		"side_city_letter":
			Beat.mark("blumenladen_letter")
