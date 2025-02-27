class_name ResetTile extends Area2D


func _on_body_entered(body: Node2D):
	if body.has_method(&"respawn"):
		body.call(&"respawn")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
