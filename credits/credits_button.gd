class_name CreditsButton extends Button


var social_link: String


func _on_pressed():
	if not social_link.is_empty():
		OS.shell_open(social_link)


func _ready() -> void:
	pressed.connect(_on_pressed)
