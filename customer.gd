extends CharacterBody2D

@export var movement_speed: float = 90.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt_label: Label = $Label

enum CustomerState { WAITING_TO_SPAWN, WALKING_PATH, SITTING, WAITING_FOR_ORDER, DRINKING, LEAVING }
var current_state: CustomerState = CustomerState.WAITING_TO_SPAWN

var path_points: Array[Node2D] = []
var current_point_index: int = 0

func _ready() -> void:
	modulate.a = 0.0
	if prompt_label:
		prompt_label.visible = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

# Receives their assigned waypoint and unique seat from the table script
func set_custom_path(waypoint_node: Node2D, seat_node: Node2D) -> void:
	path_points.clear()
	if waypoint_node:
		path_points.append(waypoint_node)
	if seat_node:
		path_points.append(seat_node)
	current_point_index = 0
	current_state = CustomerState.WALKING_PATH

func _physics_process(_delta: float) -> void:
	match current_state:
		CustomerState.WALKING_PATH:
			if current_point_index < path_points.size():
				var target_node = path_points[current_point_index]
				if not target_node:
					current_point_index += 1
					return
					
				var target_pos = target_node.global_position
				var direction = global_position.direction_to(target_pos)
				velocity = direction * movement_speed
				
				animated_sprite.scale = Vector2(1.0, 1.0)
				
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						animated_sprite.play("walking right")
					else:
						animated_sprite.play("walking left")
				else:
					if direction.y > 0:
						if animated_sprite.sprite_frames.has_animation("walking forward"):
							animated_sprite.play("walking forward")
						else:
							animated_sprite.play("walking right")
					else:
						if animated_sprite.sprite_frames.has_animation("walking backward"):
							animated_sprite.play("walking backward")
						else:
							animated_sprite.play("walking left")
				
				if global_position.distance_to(target_pos) < 8.0:
					current_point_index += 1
					if current_point_index >= path_points.size():
						velocity = Vector2.ZERO
						global_position = target_pos
						sit_down()
			else:
				velocity = Vector2.ZERO
				
		CustomerState.SITTING, CustomerState.WAITING_FOR_ORDER, CustomerState.DRINKING:
			velocity = Vector2.ZERO

	move_and_slide()

func sit_down() -> void:
	current_state = CustomerState.SITTING
	velocity = Vector2.ZERO
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite.scale = Vector2(1.2, 1.2)
	if animated_sprite.sprite_frames.has_animation("sitting"):
		animated_sprite.play("sitting")
	animated_sprite.flip_h = false
	
	await get_tree().create_timer(0.2).timeout
	current_state = CustomerState.WAITING_FOR_ORDER
	if prompt_label:
		prompt_label.text = "One coffee"
		prompt_label.visible = true

func start_coffee_countdown() -> void:
	current_state = CustomerState.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Drinking... " + str(i)
			await get_tree().create_timer(1.0).timeout
		current_state = CustomerState.WAITING_FOR_ORDER
		prompt_label.text = "One sandwich"

func start_sandwich_countdown() -> void:
	current_state = CustomerState.DRINKING
	if prompt_label:
		prompt_label.visible = true
		for i in range(3, 0, -1):
			prompt_label.text = "Eating... " + str(i)
			await get_tree().create_timer(1.0).timeout
		prompt_label.visible = false
	fade_out_and_leave()

func fade_out_and_leave() -> void:
	current_state = CustomerState.LEAVING
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
