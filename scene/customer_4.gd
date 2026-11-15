extends CharacterBody2D

@export var movement_speed: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $Label

enum Customer4State { WAITING_TO_SPAWN, WALKING_PATH, SITTING, WAITING_FOR_ORDER, DRINKING, LEAVING }
var current_state: Customer4State = Customer4State.WAITING_TO_SPAWN

var path_points: Array[Node2D] = []
var current_point_index: int = 0
var sit_spot: Node2D = null

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
	
	var current_scene = get_tree().current_scene
	if current_scene:
		var wp4 = current_scene.find_child("Waypoint4", true, false)
		var seat4 = current_scene.find_child("Seat4", true, false)
		
		if seat4:
			if seat4.global_position == Vector2.ZERO and seat4.has_node("CollisionShape2D"):
				sit_spot = seat4.get_node("CollisionShape2D")
			else:
				sit_spot = seat4
		
		path_points.clear()
		if wp4:
			path_points.append(wp4)
		if sit_spot:
			path_points.append(sit_spot)
			
	if path_points.size() > 0:
		current_point_index = 0
		current_state = Customer4State.WALKING_PATH
	else:
		print("WARNING: Seat4 or Waypoint4 not found for Customer 4!")

func _physics_process(_delta: float) -> void:
	match current_state:
		Customer4State.WALKING_PATH:
			if current_point_index < path_points.size():
				var target_node = path_points[current_point_index]
				var direction = global_position.direction_to(target_node.global_position)
				velocity = direction * movement_speed
				
				animated_sprite.scale = Vector2(1.0, 1.0)
				
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						animated_sprite.play("walking right")
					else:
						animated_sprite.play("walking left")
				else:
					if direction.y > 0:
						animated_sprite.play("walking forward")
					else:
						animated_sprite.play("walking backward")
				
				if global_position.distance_to(target_node.global_position) < 6.0:
					current_point_index += 1
					if current_point_index >= path_points.size():
						velocity = Vector2.ZERO
						global_position = target_node.global_position
						sit_down()
			else:
				velocity = Vector2.ZERO
				
		Customer4State.SITTING, Customer4State.WAITING_FOR_ORDER, Customer4State.DRINKING:
			velocity = Vector2.ZERO

	move_and_slide()

func sit_down() -> void:
	current_state = Customer4State.SITTING
	velocity = Vector2.ZERO
	
	animated_sprite.scale = Vector2(1.2, 1.2)
	
	if animated_sprite.sprite_frames.has_animation("sitting"):
		animated_sprite.play("sitting")
	
	animated_sprite.flip_h = false
	
	await get_tree().create_timer(0.2).timeout
	
	current_state = Customer4State.WAITING_FOR_ORDER
	if prompt_label:
		prompt_label.text = "One coffee"
		prompt_label.visible = true

func start_coffee_countdown() -> void:
	current_state = Customer4State.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Drinking... " + str(i)
			await get_tree().create_timer(1.0).timeout
			
		current_state = Customer4State.WAITING_FOR_ORDER
		prompt_label.text = "One sandwich"

func start_sandwich_countdown() -> void:
	current_state = Customer4State.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Eating... " + str(i)
			await get_tree().create_timer(1.0).timeout
			
		prompt_label.visible = false
	fade_out_and_leave()

func fade_out_and_leave() -> void:
	current_state = Customer4State.LEAVING
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
