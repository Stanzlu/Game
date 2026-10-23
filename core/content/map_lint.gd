class_name MapLint
extends RefCounted
## Checks of a text map that the parser cannot make (docs/PRODUKTIONSPLAN.md, T4): can the player
## get to everything that matters, does anything stand in a wall, is a symmetric map still
## symmetric. Pure functions over a `MapData`; `validate_project()` runs them over content/maps.
## Problems read "<map>:<x>,<y>: <problem>".
##
## Reachability is about tiles: the player walks on every tile that is not solid, plus the cells
## of props that make a way (stepping stones, bridges). Trees, walls of houses and conditional
## blockers are not known here, so a map can still be walled off by props; the lint finds the
## islands that tiles alone make.

## Props that make a solid tile walkable (the stones in the stream).
const WALKABLE_PROPS: PackedStringArray = [
	"res://world/props/stepping_stone.tscn",
]
## Props the player walks up to: they must be reachable and stand on a floor.
const INTERACTIVE_PROPS: PackedStringArray = [
	"res://world/props/door.tscn",
	"res://world/props/rift.tscn",
	"res://world/props/pickup.tscn",
	"res://world/props/chest.tscn",
	"res://world/props/lever.tscn",
	"res://world/props/sign.tscn",
	"res://world/props/golden_butterfly.tscn",
	"res://entities/npc/npc_walker.tscn",
]
## Props that stay without a twin in a symmetric map: the stone, the rift and the child
## (ADR-031). The stone's picture is a pickup, its label a decor with the cue "stone".
const SINGLE_PROPS: PackedStringArray = ["pickup.tscn", "rift.tscn", "child_guide.tscn"]
const SINGLE_CUES: PackedStringArray = ["stone"]
## How far from a reachable cell a thing may stand and still be reached (cells; furniture
## in a wall is used from the floor in front of it).
const REACH := 2
const SPAWN_MARKER := "player_spawn"

const DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]


## All rules for one map. `is_scene` is false for maps that only feed a script (the segments
## of the Antreiber's road): they have no spawn of their own.
static func validate(data: MapData, name := "", is_scene := true) -> PackedStringArray:
	var label := name if not name.is_empty() else data.source
	var problems: PackedStringArray = []
	if is_scene:
		problems.append_array(spawn_problems(data, label))
		problems.append_array(reach_problems(data, label))
	problems.append_array(floor_problems(data, label))
	problems.append_array(symmetry_problems(data, label))
	return problems


## Every map the game ships.
static func validate_project() -> PackedStringArray:
	var problems: PackedStringArray = []
	var legend := MapView.load_legend(MapView.DEFAULT_LEGEND)
	var scene_maps := StoryLint.load_project().scene_maps.values()
	for path in StoryLint._files(StoryLint.MAP_DIR, ["txt"]):
		var data := MapData.parse(FileAccess.get_file_as_string(path), legend, path)
		if not data.is_valid():
			problems.append_array(data.errors)
			continue
		problems.append_array(validate(data, path.get_file(), path in scene_maps))
	return problems


# --- Walking -------------------------------------------------------------------------------


## The cells the player can walk to from `starts`, as a Dictionary cell -> true.
static func reachable(data: MapData, starts: Array[Vector2i]) -> Dictionary:
	var walkable := walkable_cells(data)
	var seen := {}
	var open: Array[Vector2i] = []
	for start in starts:
		if walkable.has(start):
			seen[start] = true
			open.append(start)
	while not open.is_empty():
		var cell: Vector2i = open.pop_back()
		for direction in DIRECTIONS:
			var next := cell + direction
			if walkable.has(next) and not seen.has(next):
				seen[next] = true
				open.append(next)
	return seen


## Every cell the player may stand on: non-solid tiles and the cells of walkable props.
static func walkable_cells(data: MapData) -> Dictionary:
	var cells := {}
	for y in data.height:
		for x in data.width:
			var cell := Vector2i(x, y)
			if not data.is_solid(cell):
				cells[cell] = true
	for placement: Dictionary in data.placements:
		if str(placement["prop"]) in WALKABLE_PROPS:
			cells[placement["cell"]] = true
	return cells


## Where the player starts: the map's own spawn and every door arrival.
static func spawn_cells(data: MapData) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for placement: Dictionary in data.placements:
		var marker := str(placement["marker"])
		if marker == SPAWN_MARKER or marker.begins_with("spawn_"):
			cells.append(placement["cell"])
	return cells


# --- Rules ---------------------------------------------------------------------------------


## A map has its own spawn, and every spawn stands on a floor.
static func spawn_problems(data: MapData, label: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	for placement: Dictionary in data.placements:
		var marker := str(placement["marker"])
		if marker != SPAWN_MARKER and not marker.begins_with("spawn_"):
			continue
		if data.is_solid(placement["cell"]):
			problems.append("%s: marker '%s' stands in a wall" % [_where(label, placement), marker])
	if data.find_marker(SPAWN_MARKER).is_empty():
		problems.append("%s: the map has no '%s' marker" % [label, SPAWN_MARKER])
	return problems


## Everything the player walks up to can be reached from a spawn.
static func reach_problems(data: MapData, label: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	var starts: Array[Vector2i] = []
	for placement: Dictionary in data.find_marker(SPAWN_MARKER):
		starts.append(placement["cell"])
	var seen := reachable(data, starts)
	for placement: Dictionary in data.placements:
		var prop := str(placement["prop"])
		var marker := str(placement["marker"])
		var interactive := prop in INTERACTIVE_PROPS
		var params: Dictionary = placement["params"]
		var arrival := marker.begins_with("spawn_")
		if not interactive and not params.has("cue") and not arrival:
			continue
		# a door arrival has to be connected to the map's own spawn, not just stand on a floor
		var found := (
			seen.has(placement["cell"]) if arrival else _near(seen, placement["cell"], REACH)
		)
		if not found:
			var what := prop.get_file() if not prop.is_empty() else marker
			problems.append(
				"%s: %s cannot be reached from a spawn" % [_where(label, placement), what]
			)
	return problems


## Things the player picks up, meets or steps into stand on a floor, not in a wall.
static func floor_problems(data: MapData, label: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	var walkable := walkable_cells(data)
	for placement: Dictionary in data.placements:
		var prop := str(placement["prop"])
		if not prop in INTERACTIVE_PROPS or prop in WALKABLE_PROPS:
			continue
		if not walkable.has(placement["cell"]):
			problems.append(
				"%s: %s stands in a wall or in water" % [_where(label, placement), prop.get_file()]
			)
	return problems


## A map with `[meta] symmetry = <column>` mirrors its ground and its props around that column
## (Elysia, ADR-031). Props without a twin are listed in SINGLE_PROPS.
static func symmetry_problems(data: MapData, label: String) -> PackedStringArray:
	var problems: PackedStringArray = []
	if not data.meta.has("symmetry"):
		return problems
	var axis := int(data.meta["symmetry"])
	if data.width != 2 * axis + 1:
		return [
			"%s: symmetry column %d is not the middle of a map %d wide" % [label, axis, data.width]
		]
	for y in data.height:
		var row := data.ground_rows[y]
		for x in axis:
			if row[x] != row[2 * axis - x]:
				problems.append(
					"%s:%d,%d: ground '%s' has twin '%s'" % [label, x, y, row[x], row[2 * axis - x]]
				)
	var props := {}
	var singles := {}
	for placement: Dictionary in data.placements:
		var params: Dictionary = placement["params"]
		props[placement["cell"]] = str(params.get("sprite", placement["prop"]))
		singles[placement["cell"]] = (
			str(placement["prop"]).get_file() in SINGLE_PROPS
			or str(params.get("cue", "")) in SINGLE_CUES
		)
	for cell: Vector2i in props:
		var twin := Vector2i(2 * axis - cell.x, cell.y)
		# wide props (benches) anchor one cell further left on the other side
		var wide := twin + Vector2i.LEFT
		if (
			cell.x == axis
			or props.get(twin, "") == props[cell]
			or props.get(wide, "") == props[cell]
		):
			continue
		if singles[cell]:
			continue
		problems.append(
			(
				"%s:%d,%d: %s has no twin at %d,%d"
				% [label, cell.x, cell.y, (props[cell] as String).get_file(), twin.x, twin.y]
			)
		)
	return problems


# --- Helpers -------------------------------------------------------------------------------


static func _near(seen: Dictionary, cell: Vector2i, reach: int) -> bool:
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			if seen.has(cell + Vector2i(dx, dy)):
				return true
	return false


static func _where(label: String, placement: Dictionary) -> String:
	var cell: Vector2i = placement["cell"]
	return "%s:%d,%d" % [label, cell.x, cell.y]
