class_name MapData
extends RefCounted
## Parsed, validated text map (ADR-004). Pure data: no nodes, fully unit-testable.
##
## File format (content/maps/*.txt):
##   ; comment                    allowed before the [map] block
##   [legend]                     optional, map-local symbols as JSON objects
##   1 = {"ground": ",", "prop": "res://world/props/sign.tscn", "params": {"cue": "x"}}
##   [map]
##   ##########
##   #..@...1.#
##   ##########
## Symbols come from content/maps/legend.json; local symbols override global ones.
## A symbol is either a tile: {"atlas": [x, y], "surface": "...", "solid": bool}
## or a placement on top of a tile symbol:
##   {"ground": "<tile symbol>", "prop": "<scene>" or "marker": "<name>", "params": {}}

var source := ""
var width := 0
var height := 0
var tile_size := 16
## Resolved tile definitions: symbol -> {atlas: Vector2i, surface: StringName, solid: bool}
var tiles: Dictionary = {}
## Ground tile symbol per cell, row-major (rows are Strings of single-char tile symbols)
var ground_rows: PackedStringArray = []
## Placements: {symbol, cell: Vector2i, prop: String, marker: String, params: Dictionary}
var placements: Array[Dictionary] = []
var errors: PackedStringArray = []


func is_valid() -> bool:
	return errors.is_empty()


func tile_symbol_at(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.y >= height or cell.x >= width:
		return ""
	return ground_rows[cell.y][cell.x]


func tile_at(cell: Vector2i) -> Dictionary:
	return tiles.get(tile_symbol_at(cell), {})


func surface_at_cell(cell: Vector2i) -> StringName:
	return tile_at(cell).get("surface", &"")


func is_solid(cell: Vector2i) -> bool:
	return tile_at(cell).get("solid", true)


func find_marker(marker: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for p: Dictionary in placements:
		if p["marker"] == marker:
			found.append(p)
	return found


## Parses map text with the global legend dictionary (already JSON-decoded).
static func parse(map_text: String, legend: Dictionary, source_name: String = "") -> MapData:
	var data := MapData.new()
	data.source = source_name
	data.tile_size = int(legend.get("tile_size", 16))
	var symbols: Dictionary = (legend.get("symbols", {}) as Dictionary).duplicate(true)

	var section := "map"
	var saw_section_header := false
	var rows: PackedStringArray = []
	var line_no := 0
	for raw_line: String in map_text.replace("\r", "").split("\n"):
		line_no += 1
		var stripped := raw_line.strip_edges()
		if stripped == "[legend]" or stripped == "[map]":
			section = stripped.trim_prefix("[").trim_suffix("]")
			saw_section_header = true
			continue
		var in_map_block := section == "map" and saw_section_header
		if stripped.begins_with(";") and not in_map_block:
			continue
		if section == "legend":
			if stripped.is_empty():
				continue
			data._parse_local_symbol(stripped, line_no, symbols)
		else:
			if stripped.is_empty() and (rows.is_empty() or not saw_section_header):
				continue
			if not stripped.is_empty():
				rows.append(raw_line.strip_edges(false, true))
	data._resolve(rows, symbols)
	return data


func _parse_local_symbol(line: String, line_no: int, symbols: Dictionary) -> void:
	var eq := line.find("=")
	if eq < 1:
		_error("line %d: expected '<symbol> = {json}'" % line_no)
		return
	var symbol := line.substr(0, eq).strip_edges()
	if symbol.length() != 1:
		_error("line %d: symbol must be one character, got '%s'" % [line_no, symbol])
		return
	var json := JSON.new()
	if json.parse(line.substr(eq + 1).strip_edges()) != OK or not json.data is Dictionary:
		_error("line %d: invalid JSON for symbol '%s'" % [line_no, symbol])
		return
	symbols[symbol] = json.data


func _resolve(rows: PackedStringArray, symbols: Dictionary) -> void:
	# Tile definitions first.
	for symbol: String in symbols:
		var def: Dictionary = symbols[symbol]
		if def.has("atlas"):
			var a: Array = def["atlas"]
			if a.size() != 2:
				_error("symbol '%s': atlas must be [x, y]" % symbol)
				continue
			tiles[symbol] = {
				"atlas": Vector2i(int(a[0]), int(a[1])),
				"surface": StringName(str(def.get("surface", ""))),
				"solid": bool(def.get("solid", false)),
			}
	for symbol: String in symbols:
		var def: Dictionary = symbols[symbol]
		if def.has("atlas"):
			continue
		var ground := str(def.get("ground", ""))
		if not tiles.has(ground):
			_error("symbol '%s': ground '%s' is not a tile symbol" % [symbol, ground])
		if not def.has("prop") and not def.has("marker"):
			_error("symbol '%s': needs 'atlas', 'prop' or 'marker'" % symbol)

	if rows.is_empty():
		_error("map has no rows")
		return
	height = rows.size()
	width = rows[0].length()
	for y in height:
		var row := rows[y]
		if row.length() != width:
			_error("row %d has length %d, expected %d" % [y + 1, row.length(), width])
		var ground_row := ""
		for x in row.length():
			var symbol := row[x]
			if not symbols.has(symbol):
				_error("row %d col %d: unknown symbol '%s'" % [y + 1, x + 1, symbol])
				ground_row += "#" if tiles.has("#") else symbol
				continue
			var def: Dictionary = symbols[symbol]
			if def.has("atlas"):
				ground_row += symbol
			else:
				var ground := str(def.get("ground", ""))
				ground_row += ground if tiles.has(ground) else symbol
				var placement := {
					"symbol": symbol,
					"cell": Vector2i(x, y),
					"prop": str(def.get("prop", "")),
					"marker": str(def.get("marker", "")),
					"params": (def.get("params", {}) as Dictionary).duplicate(true),
				}
				placements.append(placement)
		ground_rows.append(ground_row.rpad(width, "#"))


func _error(message: String) -> void:
	errors.append(("%s: " % source if not source.is_empty() else "") + message)
