extends GutHookScript
## After a test run: removes this run's profile folder and those of runs that are gone
## (a crashed run leaves its folder behind). Runs still going keep theirs.


func run() -> void:
	var root := "user://profiles/"
	var dir := DirAccess.open(root)
	if dir == null:
		return
	var prefix := RuntimeEnv.TEST_PROFILE + "_"
	for name in dir.get_directories():
		if not name.begins_with(prefix):
			continue
		var pid := name.trim_prefix(prefix).to_int()
		if pid == OS.get_process_id() or not OS.is_process_running(pid):
			_remove_tree(root + name)


static func _remove_tree(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_remove_tree(path.path_join(sub))
	for file_name in dir.get_files():
		DirAccess.remove_absolute(path.path_join(file_name))
	DirAccess.remove_absolute(path)
