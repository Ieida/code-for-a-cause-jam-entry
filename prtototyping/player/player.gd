class_name Player extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_bubble: ChatBubble = $ChatBubble
@export var companion: Companion
@export var gravity: float = 981
@export var speed: float = 128
@export var jump_velocity = -300
@export var default_coyote_time: float = 0.5
@export var default_ground_coyote_time: float = 0.5
@export var abilities: Array[Ability]
var apply_gravity: bool = true
var can_jump: bool = true
var can_move: bool = true
var facing_direction: float:
	get:
		return -1.0 if animated_sprite.flip_h else 1.0
	set (value):
		animated_sprite.flip_h = true if value < 0.0 else false
var is_falling: bool
var spawn_position: Vector2
#coyote time var
var coyote_time: float
var ground_coyote_time: float


func _on_anim_finished():
	if animated_sprite.animation == &"float":
		animated_sprite.play(&"fall")
	elif animated_sprite.animation == &"land":
		can_move = true
		is_falling = false
		animated_sprite.play(&"idle")


func _on_chat_bubble_writing_finished():
	await get_tree().create_timer(5).timeout
	chat_bubble.hide()


func _physics_process(delta: float) -> void:
	# Update abilities first
	for a in abilities:
		a.physics_update(delta)
	
	# Add the gravity.
	if apply_gravity and not is_on_floor():
		velocity.y += gravity * delta

	# Is on ground buffer.
	if ground_coyote_time > 0:
		can_jump = true
	else:
		can_jump = false
	# If jump, apply coyote.
	if Input.is_action_just_pressed(&"jump"):
		coyote_time = default_coyote_time
	# Deduct coyote.
	if coyote_time > 0:
		coyote_time -= delta
	else:
		coyote_time = 0
	
	# Handle jump.
	if can_move and coyote_time > 0 and can_jump:
		ground_coyote_time = 0
		coyote_time = 0
		velocity.y = jump_velocity
	
	var direction := Input.get_axis(&"move_left", &"move_right")
	if can_move:
		# Movement
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
	# Animations
	if can_move:
		if velocity.x > 2.0: animated_sprite.flip_h = false
		if velocity.x < -2.0: animated_sprite.flip_h = true
		if is_on_floor():
			# If grounded, set ground coyote.
			ground_coyote_time = default_ground_coyote_time
			if velocity.x > 2.0:
				animated_sprite.play(&"run")
			elif velocity.x < -2.0:
				animated_sprite.play(&"run")
			else:
				animated_sprite.play(&"idle")
		elif velocity.y < -2.0:
			animated_sprite.play(&"ascend")
		# If not grounded, deduct coyote (jump still allowed)
		elif ground_coyote_time > 0:
			ground_coyote_time -= delta
		
		if is_falling and velocity.y < 2.0:
			can_move = false
			velocity.x = 0
			animated_sprite.play(&"land")
		elif not is_falling and velocity.y > 2.0:
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
	# Abilities
	for a in abilities:
		a.ability_ready()


func respawn():
	global_position = spawn_position


func say(chat: String):
	chat_bubble.text = chat
	await get_tree().create_timer(5).timeout
	companion.chat_say("00101011...")
