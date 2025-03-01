class_name PlayerDialogueTrigger extends Area2D


@export_multiline var text: String


func _on_body_entered(body: Node2D):
	if body is Player:
		body.say(text)
		await get_tree().create_timer(5).timeout
		body.companion.chat_say("001110011...")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
