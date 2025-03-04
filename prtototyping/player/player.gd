class_name Player extends CharacterBody2D


signal landed


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_bubble: ChatBubble = $ChatBubble
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@export var companion: Companion
@export var gravity: float = 981
@export var speed: float = 128
@export var jump_velocity = -300
@export var abilities: Array[Ability]
var apply_gravity: bool = true
var can_jump: bool = true
var can_move: bool = true
var facing_direction: float:
	get:
		return -1.0 if animated_sprite.flip_h else 1.0
	set(value):
		animated_sprite.flip_h = true if value < 0.0 else false
var is_falling: bool
var jumps_left: int
var spawn_position: Vector2


func _on_anim_finished():
	if animated_sprite.animation == &"float":
		animated_sprite.play(&"fall")
	elif animated_sprite.animation == &"land":
		can_move = true
		animated_sprite.play(&"idle")
		jumps_left = 1


func _on_chat_bubble_writing_finished():
	await get_tree().create_timer(5).timeout
	chat_bubble.hide()


func _on_credits_closed():
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func _on_credits_opened():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	# Update abilities first
	for a in abilities:
		a.physics_update(delta)
	
	# Add the gravity.
	if apply_gravity and not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if can_move and can_jump and jumps_left > 0 and Input.is_action_pressed(&"jump"):
		jump()
	
	var direction := Input.get_axis(&"move_left", &"move_right")
	if can_move:
		# Movement
		if direction:
			if direction > 0.0 and direction < 0.2: direction = 0.2
			elif direction < 0.0 and direction > -0.2: direction = -0.2
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Animations
	if can_move:
		if velocity.x > 2.0: animated_sprite.flip_h = false
		if velocity.x < -2.0: animated_sprite.flip_h = true
		if is_on_floor():
			if velocity.x > 2.0:
				if velocity.x < 64.0:
					var sp = velocity.x / 64.0
					animated_sprite.speed_scale = sp
					animated_sprite.play(&"walk")
				else:
					var sp = velocity.x / 128.0
					animated_sprite.speed_scale = sp
					animated_sprite.play(&"run")
			elif velocity.x < -2.0:
				if velocity.x > -64.0:
					var sp = absf(velocity.x) / 64.0
					animated_sprite.speed_scale = sp
					animated_sprite.play(&"walk")
				else:
					var sp = absf(velocity.x) / 128.0
					animated_sprite.speed_scale = sp
					animated_sprite.play(&"run")
			else:
				animated_sprite.speed_scale = 1
				animated_sprite.play(&"idle")
		elif velocity.y < -2.0:
			animated_sprite.play(&"ascend")
			is_falling = false
		
		if not was_on_floor and is_on_floor():
			can_move = false
			is_falling = false
			velocity.x = 0
			animated_sprite.play(&"land")
			landed.emit()
		elif not is_falling and not is_on_floor() and velocity.y > 2.0:
			is_falling = true
			animated_sprite.play(&"float")


func _process(delta: float) -> void:
	# Update abilities first
	for a in abilities:
		a.update(delta)


func _ready() -> void:
	spawn_position = global_position
	animated_sprite.animation_finished.connect(_on_anim_finished)
	animated_sprite.play(&"idle")
	chat_bubble.writing_finished.connect(_on_chat_bubble_writing_finished)
	Credits.closed.connect(_on_credits_closed)
	Credits.opened.connect(_on_credits_opened)
	# Abilities
	for a in abilities:
		a.ability_ready()


func jump():
	jumps_left = maxi(0, jumps_left - 1)
	velocity.y = jump_velocity
	jump_sound.play()


func respawn():
	global_position = spawn_position


func say(line: String):
	chat_bubble.text = line
