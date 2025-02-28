class_name Drone extends Companion


@export var player: Player


func _physics_process(_delta: float) -> void:
	if player:
		var fnl_pos = player.global_position
		fnl_pos += Vector2(player.facing_direction * -32.0, -32.0)
		velocity = fnl_pos - global_position
	
	move_and_slide()
