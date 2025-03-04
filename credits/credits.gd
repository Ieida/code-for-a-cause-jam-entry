extends CanvasLayer


signal closed
signal opened


@onready var button_scene: PackedScene = preload("res://credits/credits_button.tscn")
@onready var container: VBoxContainer = %ButtonContainer


func _input(event: InputEvent) -> void:
	if event.is_action(&"toggle_credits"):
		if event.is_pressed() and not event.is_echo():
			toggle()


func _ready() -> void:
	close.call_deferred()
	clear()
	populate()


func clear():
	for c in container.get_children():
		c.queue_free()


func close():
	visible = false
	closed.emit()


func open():
	visible = true
	for c in container.get_children():
		if c is Control:
			c.grab_focus()
	opened.emit()


func populate():
	var file := FileAccess.open("res://credits/credits.txt", FileAccess.READ)
	var elc := 0
	while elc < 2:
		var title = file.get_line()
		if title.is_empty():
			elc += 1
			continue
		else: elc = 0
		var author = file.get_line()
		var social = file.get_line()
		var button := button_scene.instantiate() as CreditsButton
		button.text = "\n".join([title, author])
		button.set(&"social_link", social)
		container.add_child(button)
	file.close()


func toggle():
	if visible: close()
	else: open()
