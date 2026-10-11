class_name ConfirmMenu
extends MenuLayer
## A yes/no question over another menu (new game over a running one, leaving with unsaved
## progress, resetting the settings). The safe answer has the focus; back means no.

signal answered(yes: bool)

var question_key := ""
var yes_key := "OPTION_YES"
var no_key := "OPTION_NO"


func _ready() -> void:
	title_key = ""
	panel_width = 220
	# above every menu it can be asked from
	layer = 60
	super()


## Opens the question; `answered` tells the result.
func ask(question: String, yes := "OPTION_YES", no := "OPTION_NO") -> void:
	question_key = question
	yes_key = yes
	no_key = no
	open()
	list.focus_index(1)


func _build() -> void:
	title.visible = false
	list.add_info(tr(question_key))
	list.add_action(yes_key, func() -> void: _answer(true))
	list.add_action(no_key, func() -> void: _answer(false))
	hint.text = ""


func _on_cancel() -> void:
	_answer(false)


func _answer(yes: bool) -> void:
	close()
	answered.emit(yes)
