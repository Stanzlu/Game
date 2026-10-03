class_name RuntimeEnv
extends RefCounted
## Where this run keeps its user files. Normal runs use user:// directly. Test runs (GUT) and
## runs started with `--profile=<name>` (smoke runs, captures) get their own folder under
## user://profiles/, so automated runs never touch a player's saves or settings.

const TEST_PROFILE := "test"


static func is_test_run() -> bool:
	for arg in OS.get_cmdline_args():
		if arg.ends_with("gut_cmdln.gd"):
			return true
	return false


## Profile name from `--profile=<name>`; "test" under GUT; empty for normal runs.
static func profile() -> String:
	if is_test_run():
		return TEST_PROFILE
	return profile_from_args(OS.get_cmdline_user_args())


static func profile_from_args(args: PackedStringArray) -> String:
	for arg in args:
		if arg.begins_with("--profile="):
			var name := arg.trim_prefix("--profile=")
			if name.is_valid_filename() and not name.is_empty():
				return name
			Log.warn(Log.Category.BOOT, "invalid profile name ignored", {"profile": name})
	return ""


## Base folder for saves and settings, always ending with "/".
static func user_dir() -> String:
	var name := profile()
	return "user://" if name.is_empty() else "user://profiles/%s/" % name
