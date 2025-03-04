@tool
class_name ChatBubble extends PanelContainer


signal writing_finished


@export var offset: Vector2:
	set(value):
		offset = value
		has_offset_changed = true
## In letters per second.
@export var write_speed: float = 16
@export_multiline var text: String:
	set(value):
		text = value
		if is_node_ready():
			has_text_changed = true
@onready var label: Label = $Label
var has_offset_changed: bool
var has_text_changed: bool
var is_writing: bool
var writing_time_elapsed: float


func _process(delta: float) -> void:
	if has_text_changed:
		has_text_changed = false
		show()
		if not Engine.is_editor_hint():
			is_writing = true
			writing_time_elapsed = 0
		set_label_text(text)
	
	if is_writing:
		writing_time_elapsed += delta
		var d = write_speed * writing_time_elapsed
		var r = d / float(text.length())
		label.visible_ratio = r
		if r >= 1.0:
			is_writing = false
			writing_finished.emit()
	
	if has_offset_changed:
		has_offset_changed = false
		position = offset - (size / 2.0)


func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()


func set_label_text(new_text: String):
	label.text = new_text
	size = Vector2.ZERO
	position = offset - (size / 2.0)
