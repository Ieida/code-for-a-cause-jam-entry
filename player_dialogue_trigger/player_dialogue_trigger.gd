class_name PlayerDialogueTrigger extends Area2D


@export_multiline var text: String


func _on_body_entered(body: Node2D):
	if body is Player:
		body.say(text)
		body.companion


func _ready() -> void:
	body_entered.connect(_on_body_entered)
