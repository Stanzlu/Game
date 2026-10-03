extends GutTest
## Proves that the vendored Dialogue Manager works with the pinned Godot version.

const FIXTURE := "res://tests/fixtures/smoke.dialogue"


func test_imported_dialogue_file_yields_lines_and_responses() -> void:
	var resource: DialogueResource = load(FIXTURE)
	assert_not_null(resource, "fixture did not import as DialogueResource")
	if resource == null:
		return
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	assert_not_null(line)
	if line == null:
		return
	assert_eq(line.character, "Mira")
	assert_eq(line.text, "Nein.")
	assert_eq(line.responses.size(), 2)
	assert_eq(line.responses[0].text, "…", "silence must be a full response")


func test_dialogue_compiles_from_text_at_runtime() -> void:
	var resource: DialogueResource = DialogueManager.create_resource_from_text(
		"~ start\nTess: Setz dich.\n=> END"
	)
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	assert_eq(line.character, "Tess")
	assert_eq(line.text, "Setz dich.")
