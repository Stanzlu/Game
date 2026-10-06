extends StaticBody2D
## An invisible barrier for a way that is not open yet, e.g. the path to the shed before
## anyone needs wood. Params: {"size": [w, h]} in tiles, optional "offset": [x, y] in tiles
## (to cover cells that hold other props, like stepping stones), "cue"/"dialogue" (what the
## protagonist thinks when he tries), "if"/"unless" flags (MapView removes it when done).

const TILE := 16


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0


func apply_params(params: Dictionary) -> void:
	var size: Array = params.get("size", [1, 1])
	var offset_cells: Array = params.get("offset", [0, 0])
	var offset := Vector2(float(offset_cells[0]), float(offset_cells[1])) * TILE
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(float(size[0]), float(size[1])) * TILE
	shape.shape = rect
	shape.position = offset
	add_child(shape)
	if params.has("cue"):
		var path := str(params.get("dialogue", Talk.DEFAULT_DIALOGUE))
		var cue := str(params["cue"])
		var reach := maxf(rect.size.x, rect.size.y) * 0.5 + 6.0
		var area := Talk.add_area(self, "INTERACT_EXAMINE", reach, offset)
		area.interacted.connect(func(actor: Node) -> void: Talk.present(self, path, cue, actor))
