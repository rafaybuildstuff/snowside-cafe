extends CharacterBody2D

@export var movement_speed: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $Label

enum Customer3State { WAITING_TO_SPAWN, WALKING_TO_SEAT, SITTING, WAITING_FOR_ORDER, DRINKING, LEAVING }
var current_state: Customer3State = Customer3State.WAITING_TO_SPAWN

var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	modulate.a = 0.0
	if prompt_label:
		prompt_label.visible = false
	spawn_sequence()

func spawn_sequence() -> void:
	await get_tree().create_timer(1.0).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	await get_tree().process_frame
	
	var current_scene = get_tree().current_scene
	if current_scene:
		var seat3 = current_scene.find_child("Seat3", true, false)
		if seat3:
			# CODE FIX: Automatically targets the actual chair sprite's position 
			# instead of the broken root node crosshair!
			var sprite_child = seat3.get_node_or_null("Sprite2D")
			if sprite_child:
				target_position = sprite_child.global_position
			else:
				target_position = seat3.global_position
			
			current_state = Customer3State.WALKING_TO_SEAT
		else:
			# Safety fallback so she never gets stuck
			target_position = global_position + Vector2(150, -50)
			current_state = Customer3State.WALKING_TO_SEAT

func _physics_process(_delta: float) -> void:
	match current_state:
		Customer3State.WALKING_TO_SEAT:
			var direction = global_position.direction_to(target_position)
			velocity = direction * movement_speed
			
			animated_sprite.scale = Vector2(1.0, 1.0)
			
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
			
			# Generous distance threshold so she snaps into place cleanly
			if global_position.distance_to(target_position) < 25.0:
				velocity = Vector2.ZERO
				global_position = target_position
				sit_down()
				
		Customer3State.SITTING, Customer3State.WAITING_FOR_ORDER, Customer3State.DRINKING:
			velocity = Vector2.ZERO

	move_and_slide()

func sit_down() -> void:
	current_state = Customer3State.SITTING
	velocity = Vector2.ZERO
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	
	animated_sprite.scale = Vector2(1.2, 1.2)
	
	if animated_sprite.sprite_frames.has_animation("sitting"):
		animated_sprite.play("sitting")
	
	animated_sprite.flip_h = false
	
	await get_tree().create_timer(0.2).timeout
	
	current_state = Customer3State.WAITING_FOR_ORDER
	if prompt_label:
		prompt_label.text = "One coffee"
		prompt_label.visible = true

func start_coffee_countdown() -> void:
	current_state = Customer3State.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Drinking... " + str(i)
			await get_tree().create_timer(1.0).timeout
			
		current_state = Customer3State.WAITING_FOR_ORDER
		prompt_label.text = "One sandwich"

func start_sandwich_countdown() -> void:
	current_state = Customer3State.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Eating... " + str(i)
			await get_tree().create_timer(1.0).timeout
			
		prompt_label.visible = false
	fade_out_and_leave()

func fade_out_and_leave() -> void:
	current_state = Customer3State.LEAVING
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
