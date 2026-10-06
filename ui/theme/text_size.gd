class_name TextSize
extends RefCounted
## Scalable text everywhere (Game Bible §50, setting "text.large"): switches the shared
## themes between the normal pixel sizes and a large set, so menus, journal, HUD, prompts
## and developer panels grow together. The dialogue box has its own large layout on top.
## Pixel fonts stay at sizes that render crisp: body Jersey 10 at 19 becomes Jersey 15 at
## 27 (as in the large dialogue), small Tiny5 at 8 doubles to 16.

const BODY := preload("res://assets/fonts/jersey10/Jersey10-Regular.ttf")
const LARGE_BODY := preload("res://assets/fonts/jersey15/Jersey15-Regular.ttf")
## Held here so the change sticks (a freed theme would reload at its saved size).
const COMPACT := preload("res://ui/theme/compact_theme.tres")
const BODY_SIZE := {false: 19, true: 27}
const SMALL_SIZE := {false: 8, true: 16}
## Theme types drawn in the small font.
const SMALL_TYPES: Array[StringName] = [
	&"SmallLabel", &"PromptLabel", &"PromptText", &"PromptKeyLabel"
]

static var large := false


static func apply(enable: bool) -> void:
	large = enable
	var theme := ThemeDB.get_project_theme()
	if theme == null:
		Log.warn(Log.Category.UI, "no project theme, text size unchanged")
		return
	theme.default_font = LARGE_BODY if enable else BODY
	theme.default_font_size = BODY_SIZE[enable]
	for type in SMALL_TYPES:
		if theme.has_font_size(&"font_size", type):
			theme.set_font_size(&"font_size", type, SMALL_SIZE[enable])
	COMPACT.set(&"default_font_size", SMALL_SIZE[enable])
	Log.info(Log.Category.UI, "text size", {"large": enable})
