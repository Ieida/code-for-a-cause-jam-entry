class_name Drone extends Companion


@export var player: Player
@onready var chat_bubble: ChatBubble = $ChatBubble


func _on_chat_bubble_writing_finished():
	await get_tree().create_timer(5).timeout
	chat_bubble.hide()


func _physics_process(_delta: float) -> void:
	if player:
		var fnl_pos = player.global_position
		fnl_pos += Vector2(player.facing_direction * -32.0, -32.0)
		velocity = fnl_pos - global_position
	
	move_and_slide()


func _ready() -> void:
	chat_bubble.writing_finished.connect(_on_chat_bubble_writing_finished)


func chat_say(chat: String):
	#await get_tree().create_timer(2).timeout
	chat_bubble.text = chat
