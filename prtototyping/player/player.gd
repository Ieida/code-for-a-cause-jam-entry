extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash := $Dash
@onready var roll := $Roll
@export var gravity: float = 981
@export var speed: float = 128
@export var jump_velocity = -300
@export var default_coyote_time: float = 0.5
@export var default_ground_coyote_time: float = 0.5
var apply_gravity: bool = true
var can_move: bool = true
var is_falling: bool
var can_jump: bool
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


func _physics_process(delta: float) -> void:
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
		# Of not grounded, deduct coyote (jump still allowed)
		elif ground_coyote_time > 0:
			ground_coyote_time -= delta
		
		if is_falling and velocity.y < 2.0:
			can_move = false
			animated_sprite.play(&"land")
		elif not is_falling and velocity.y > 2.0:
			is_falling = true
			animated_sprite.play(&"float")


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_anim_finished)
	animated_sprite.play(&"idle")
