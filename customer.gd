extends CharacterBody2D

@export var movement_speed: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $Label

enum CustomerState { WAITING_TO_SPAWN, WALKING_TO_SEAT, SITTING, WAITING_FOR_ORDER, DRINKING, LEAVING }
var current_state: CustomerState = CustomerState.WAITING_TO_SPAWN

var target_seat: Area2D = null

func _ready() -> void:
	# Make customer invisible initially for the fade-in effect
	modulate.a = 0.0
	if prompt_label:
		prompt_label.visible = false
		
	# Start the spawn sequence
	spawn_sequence()

func spawn_sequence() -> void:
	await get_tree().create_timer(2.0).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(0.5).timeout
	
	var current_scene = get_tree().current_scene
	if current_scene:
		target_seat = current_scene.find_child("Seat1", true, false)
		
	if target_seat:
		print("Customer walking towards Seat1...")
		current_state = CustomerState.WALKING_TO_SEAT
	else:
		print("WARNING: Seat1 could not be found!")

func _physics_process(_delta: float) -> void:
	match current_state:
		CustomerState.WALKING_TO_SEAT:
			if target_seat:
				# Calculate direction vector towards the seat
				var direction = global_position.direction_to(target_seat.global_position)
				velocity = direction * movement_speed
				
				# Play walking animation based on direction
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						animated_sprite.play("walking right")
					else:
						animated_sprite.play("walking left")
				else:
					if direction.y > 0:
						animated_sprite.play("walking toward")
					else:
						animated_sprite.play("walking backward")
				
				# Check if customer has reached Seat1
				if global_position.distance_to(target_seat.global_position) < 12.0:
					velocity = Vector2.ZERO
					sit_down()
			else:
				velocity = Vector2.ZERO
				
		CustomerState.SITTING, CustomerState.WAITING_FOR_ORDER, CustomerState.DRINKING:
			velocity = Vector2.ZERO

	# This is what stops the customer from flying through things!
	move_and_slide()

func sit_down() -> void:
	current_state = CustomerState.SITTING
	velocity = Vector2.ZERO
	
	if animated_sprite.sprite_frames.has_animation("sitting"):
		animated_sprite.play("sitting")
		
	print("Customer sat down successfully!")
	
	await get_tree().create_timer(0.2).timeout
	
	current_state = CustomerState.WAITING_FOR_ORDER
	if prompt_label:
		prompt_label.text = "One coffee"
		prompt_label.visible = true
		
	if target_seat and target_seat.has_method("customer_seated"):
		target_seat.customer_seated(self)

func start_coffee_countdown() -> void:
	current_state = CustomerState.DRINKING
	if prompt_label:
		for i in range(3, 0, -1):
			prompt_label.text = "Drinking... " + str(i)
			await get_tree().create_timer(1.0).timeout
			
		prompt_label.visible = false
	print("Customer finished coffee!")
