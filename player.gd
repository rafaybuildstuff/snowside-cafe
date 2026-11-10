extends CharacterBody2D

# Movement & Speed
@export var max_speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0

# Jump & Gravity Physics
@export var jump_force: float = -380.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5 # Falling feels snappier
@export var variable_jump_multiplier: float = 0.5 # Releasing jump mid-air cuts height

# Coyote Time & Jump Buffering (makes controls feel responsive)
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.1

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Update timers
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# 2. Gravity logic
	if not is_on_floor():
		var current_gravity = gravity
		# Fall faster for weightier jumping
		if velocity.y > 0:
			current_gravity *= fall_gravity_multiplier
		velocity.y += current_gravity * delta

	# 3. Jump logic (Handles Coyote Time + Jump Buffer)
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# Variable jump height: release jump button early to short-hop
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= variable_jump_multiplier

	# 4. Horizontal movement
	var input_direction := Input.get_axis("ui_left", "ui_right")
	
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# 5. Execute movement
	move_and_slide()

	# 6. Flip sprite visually
	if input_direction != 0:
		$Sprite2D.scale.x = sign(input_direction)
