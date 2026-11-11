extends CharacterBody2D

# --- Variables and Configuration ---
@export var movement_speed: float = 200.0
@export var jump_force: float = -300.0

# Animation names matching your SpriteFrames panel
@export var anim_idle: String = "idle"
@export var anim_walk: String = "walk"
@export var anim_jump: String = "jump"

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	velocity.y += gravity * delta

	# 2. Horizontal movement using built-in input directions (A/D or Left/Right Arrow keys)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed * 0.1)

	# 3. Jump input using your "jump" action
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	# 4. Handle animations safely
	update_animations()

	# 5. Apply movement
	move_and_slide()

# --- Helper Function for Animations ---
func update_animations() -> void:
	# Flip sprite horizontally depending on left/right movement
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

	# Select state animation
	var target_anim = anim_idle
	if not is_on_floor():
		target_anim = anim_jump
	elif velocity.x != 0:
		target_anim = anim_walk

	# Play animation if valid
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(target_anim):
		animated_sprite.play(target_anim)
