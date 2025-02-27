extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash := $Dash
@onready var roll := $Roll
@export var gravity: float = 981
@export var speed: float = 128
@export var jump_velocity = -300
var apply_gravity: bool = true
var can_move: bool = true
var is_falling: bool


func _on_anim_finished():
	if animated_sprite.animation == &"float":
		animated_sprite.play(&"fall")
	elif animated_sprite.animation == &"land":
		can_move = true
		is_falling = false
		animated_sprite.play(&"idle")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if apply_gravity and not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if can_move and Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var direction := Input.get_axis(&"move_left", &"move_right")
	if can_move:
		var fdir = -1.0 if animated_sprite.flip_h else 1.0
		# Roll
		if is_on_floor() and Input.is_action_just_pressed(&"roll"):
			roll.start(fdir)
		
		# Dash
		if Input.is_action_just_pressed(&"dash"):
			dash.start(fdir)
	
	if can_move and direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
	# Animations
	if can_move:
		if not is_zero_approx(direction):
			animated_sprite.flip_h = velocity.x < 0.0
		if is_on_floor():
			if velocity.x > 2.0:
				animated_sprite.play(&"run")
			elif velocity.x < -2.0:
				animated_sprite.play(&"run")
			else:
				animated_sprite.play(&"idle")
		elif velocity.y < -2.0:
			animated_sprite.play(&"ascend")
		
		if is_falling and velocity.y < 2.0:
			can_move = false
			animated_sprite.play(&"land")
		elif not is_falling and velocity.y > 2.0:
			is_falling = true
			animated_sprite.play(&"float")


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_anim_finished)
	animated_sprite.play(&"idle")
