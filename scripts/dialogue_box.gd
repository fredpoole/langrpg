class_name DialogueBox
extends CanvasLayer
## Shows an NPC's lines one at a time. Press interact to advance.

signal finished

var _lines: Array[String] = []
var _index: int = 0

@onready var _panel: Panel = $Panel
@onready var _name_label: Label = $Panel/NameLabel
@onready var _text_label: Label = $Panel/TextLabel


func _ready() -> void:
	_panel.hide()


func open(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		finished.emit()
		return
	_lines = lines
	_index = 0
	_name_label.text = speaker
	_text_label.text = _lines[0]
	_panel.show()


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	_index += 1
	if _index < _lines.size():
		_text_label.text = _lines[_index]
	else:
		_panel.hide()
		finished.emit()
