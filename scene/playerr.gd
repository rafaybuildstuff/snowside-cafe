extends CharacterBody2D

# --- Configuration & Speed ---
@export var movement_speed: float = 200.0

# --- Item States (for when you add food or cups later) ---
@export var has_cup: bool = false
@export var has_food: bool = false

# --- Reference to AnimatedSprite2D ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Keep track of the last facing direction
var last_facing: String = "front"

func _physics_process(delta: float) -> void:
	# 1. Get 4-way input directions
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("cafe_right"):
		input_vector.x += 1
	if Input.is_action_pressed("cafe_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("cafe_down"):
		input_vector.y += 1
	if Input.is_action_pressed("cafe_up"):
		input_vector.y -= 1
		
	# Normalize vector so diagonal movement isn't faster
	input_vector = input_vector.normalized()
	
	# Set velocity
	velocity = input_vector * movement_speed

	# 2. Update facing direction based on input (Corrected up/down logic)
	if input_vector.x > 0:
		last_facing = "right"
	elif input_vector.x < 0:
		last_facing = "left"
	elif input_vector.y > 0:
		last_facing = "front" # moving down / towards camera
	elif input_vector.y < 0:
		last_facing = "back"  # moving up / away from camera

	# 3. Apply movement
	move_and_slide()

	# 4. Handle animations safely
	update_cafe_animations(input_vector)

# --- Animation Handler for Cafe Mechanics ---
func update_cafe_animations(input_vector: Vector2) -> void:
	var target_anim = "front idle" # Default fallback
	
	if input_vector != Vector2.ZERO:
		# Player is moving
		if has_cup:
			if last_facing == "left" or last_facing == "right":
				target_anim = last_facing + " cup walk"
			else:
				target_anim = "left cup walk"
		elif has_food:
			if last_facing == "left" or last_facing == "right":
				target_anim = last_facing + " food walk"
			else:
				target_anim = "left food walk"
		else:
			if last_facing == "left" or last_facing == "right":
				target_anim = last_facing + " walk"
			elif last_facing == "back":
				target_anim = "walking backwards" # Playing when moving UP (away from camera)
			elif last_facing == "front":
				target_anim = "walking towards"  # Playing when moving DOWN (towards camera)
	else:
		# Player is standing still (Idle)
		if has_cup:
			target_anim = "left hold cup" if last_facing == "left" else "right hold cup"
		elif has_food:
			target_anim = "left hold food" if last_facing == "left" else "right hold food"
		else:
			if last_facing == "back":
				target_anim = "back idles" if animated_sprite.sprite_frames.has_animation("back idles") else "back idle"
			elif last_facing == "front":
				target_anim = "front idle"
			else:
				target_anim = last_facing + " idle"

	# Safely play the animation if it exists in your SpriteFrames
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(target_anim):
		animated_sprite.play(target_anim)
