extends Camera2D


@export var target: Node2D
@export var start_at_target: bool = true
@export var influence: float = 3.0
@export_range(0, 1, 0.01) var x_velocity_influence: float = 0.5
@export_range(0, 1, 0.01) var y_velocity_influence: float = 0.25


func _process(delta: float) -> void:
	if target: follow(delta)


func _ready() -> void:
	if target and start_at_target:
		global_position = target.global_position


func follow(delta: float):
	var tp = target.global_position
	if target is CharacterBody2D:
		var v = target.velocity
		tp += Vector2(v.x * x_velocity_influence, v.y * y_velocity_influence)
	elif target is RigidBody2D:
		var v = target.linear_velocity
		tp += Vector2(v.x * x_velocity_influence, v.y * y_velocity_influence)
	var dst = global_position.distance_to(tp)
	var infl = dst * influence
	infl = maxf(1, infl)
	global_position = global_position.move_toward(tp, infl * delta)
