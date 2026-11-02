class_name WerkstattScene
extends LookScene
## Act IV, S4: the workshop from inside (docs/akt4/REGIONSBRIEFE.md). Tess, an older craftswoman,
## at her bench: she measures, she whistles, she shows it once and then it is her visitor's turn.
## Her dialogue tells all of it (the board, the asking for help); this script plays her whistle
## once she has whistled it and marks the beats. Once the board is sawn she is not here any more
## but outside on her crate (the map decides: `unless city.board_done`). No cutscene, no lock,
## nothing here is needed to go on.

## The room's cells: the camera stays centred on it (it fits whole at the zoom of an interior).
const ROOM := Rect2i(4, 3, 18, 12)


func _ready() -> void:
	music = "silence"
	super()
	view.bounds = Rect2(
		Vector2(ROOM.position * map.data.tile_size), Vector2(ROOM.size * map.data.tile_size)
	)
	WorldState.flag_changed.connect(_on_flag_changed)
	Beat.mark("werkstatt_enter")


func _on_flag_changed(id: String, value: bool) -> void:
	if not value:
		return
	match id:
		"melody.tess_whistle":
			AudioDirector.sfx("tess_whistle", -2.0, 1.0)
		"city.board_done":
			Beat.mark("werkstatt_board")
