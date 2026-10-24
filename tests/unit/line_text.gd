class_name LineText
extends RefCounted
## The text of a dialogue line by its stable ID, read from the dialogue files. A test that pins a
## line names the ID and not the wording, so a writing pass can change the text and the tests stay
## (docs/PRODUKTIONSPLAN.md 9.2). Lines with {{ }} values or effects are not meant for this.

const ROOT := "res://content/dialogue"

static var _texts := {}


## The text of line `id` (also an answer). Logs an error and returns "" if there is no such line.
static func of(id: String) -> String:
	if _texts.is_empty():
		_read(ROOT)
	if not _texts.has(id):
		Log.error(Log.Category.CONTENT, "no dialogue line with this ID", {"id": id})
		return ""
	return _texts[id]


static func _read(folder: String) -> void:
	for name in DirAccess.get_directories_at(folder):
		_read(folder.path_join(name))
	for name in DirAccess.get_files_at(folder):
		if not name.ends_with(".dialogue"):
			continue
		var resource := load(folder.path_join(name)) as DialogueResource
		for line: Dictionary in resource.lines.values():
			var id := str(line.get(&"static_id", ""))
			if not id.is_empty() and line.has(&"text") and id != line[&"text"]:
				_texts[id] = line[&"text"]
