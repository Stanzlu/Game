class_name ConfirmMenu
extends MenuLayer
## A yes/no question over another menu (new game over a running one, leaving with unsaved
## progress, resetting the settings). The safe answer has the focus; back means no.

signal answered(yes: bool)

## A page with long questions (the key layout) sets a wider panel before adding the menu to
## the tree: the frame is built in _ready. 0 keeps the narrow default.
var panel_width_override := 0
var question_key := ""
var yes_key := "OPTION_YES"
var no_key := "OPTION_NO"
## The question is shown as given (already formatted), not looked up as a translation key.
var _literal := false


func _ready() -> void:
	title_key = ""
	panel_width = panel_width_override if panel_width_override > 0 else 220
	# above every menu it can be asked from
	layer = 60
	super()


## Opens the question; `answered` tells the result.
func ask(question: String, yes := "OPTION_YES", no := "OPTION_NO") -> void:
	_ask(question, false, yes, no)


## The same question with a text that was formatted already (names of keys and actions in it).
func ask_text(text: String, yes := "OPTION_YES", no := "OPTION_NO") -> void:
	_ask(text, true, yes, no)


func _ask(question: String, literal: bool, yes: String, no: String) -> void:
	question_key = question
	_literal = literal
	yes_key = yes
	no_key = no
	open()
	list.focus_index(1)


func _build() -> void:
	title.visible = false
	list.add_info(question_key if _literal else tr(question_key))
	list.add_action(yes_key, func() -> void: _answer(true))
	list.add_action(no_key, func() -> void: _answer(false))
	hint.text = ""


func _on_cancel() -> void:
	_answer(false)


func _answer(yes: bool) -> void:
	close()
	answered.emit(yes)
