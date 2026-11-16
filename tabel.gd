extends Area2D

@export var use_alternate_customers: bool = false # False = Table 1 (Cust 1 & 2), True = Table 2 (Cust 3 & 4)

enum TableState { 
	CLEAN_WAITING_COFFEE, 
	ONE_COFFEE, 
	TWO_COFFEE_DRINKING, 
	CLEAN_WAITING_SANDWICH, 
	ONE_SANDWICH, 
	TWO_SANDWICH_EATING 
}
var state: TableState = TableState.CLEAN_WAITING_COFFEE

@onready var prompt_label: Label = $Label
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_customers: Array[Node] = []
var is_occupied: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if prompt_label:
		prompt_label.visible = false
	update_table_appearance()
	
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_try_spawn_customers)
	add_child(spawn_timer)

func spawn_new_customers() -> void:
	_try_spawn_customers()

func _try_spawn_customers() -> void:
	if not visible:
		return
		
	current_customers = current_customers.filter(func(c): return c and is_instance_valid(c))
	
	if is_occupied or current_customers.size() > 0:
		return
		
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	# Determine seats and waypoints based on whether this is Table 1 or Table 2
	var seat_a_name = "Seat3" if use_alternate_customers else "Seat1"
	var seat_b_name = "Seat4" if use_alternate_customers else "Seat2"
	var wp_a_name = "Waypoint3" if use_alternate_customers else "Waypoint1"
	var wp_b_name = "Waypoint4" if use_alternate_customers else "Waypoint2"
	
	var seat_a = current_scene.find_child(seat_a_name, true, false)
	var seat_b = current_scene.find_child(seat_b_name, true, false)
	var wp_a = current_scene.find_child(wp_a_name, true, false)
	var wp_b = current_scene.find_child(wp_b_name, true, false)
	
	if not seat_a or not seat_b or not seat_a.visible or not seat_b.visible:
		return
		
	is_occupied = true
	state = TableState.CLEAN_WAITING_COFFEE
	update_table_appearance()
	
	var cust1_scene = load("res://scene/customer_3.tscn") if use_alternate_customers else load("res://scene/customer.tscn")
	var cust2_scene = load("res://scene/customer_4.tscn") if use_alternate_customers else load("res://scene/customer_2.tscn")
	
	if cust1_scene and cust2_scene:
		var c1 = cust1_scene.instantiate()
		var c2 = cust2_scene.instantiate()
		current_customers = [c1, c2]
		
		var customers_folder = current_scene.find_child("customers", true, false)
		if customers_folder:
			customers_folder.add_child(c1)
			customers_folder.add_child(c2)
		else:
			current_scene.add_child(c1)
			current_scene.add_child(c2)
		
		c1.global_position = Vector2(10, -20)
		c2.global_position = Vector2(35, 0)
		
		# Explicitly route Customer 1 to Seat A and Customer 2 to Seat B
		if c1.has_method("set_custom_path"):
			c1.set_custom_path(wp_a, seat_a)
		if c2.has_method("set_custom_path"):
			c2.set_custom_path(wp_b, seat_b)

func _on_body_entered(body: Node2D) -> void:
	if not visible or not is_occupied:
		return
	if body.name != "player" and body.name != "playerr":
		return
		
	if body.get("has_cup") == true:
		if state == TableState.CLEAN_WAITING_COFFEE:
			body.has_cup = false
			state = TableState.ONE_COFFEE
			update_table_appearance()
		elif state == TableState.ONE_COFFEE:
			body.has_cup = false
			state = TableState.TWO_COFFEE_DRINKING
			update_table_appearance()
			trigger_customers_coffee()

	elif body.get("has_food") == true:
		if state == TableState.CLEAN_WAITING_SANDWICH:
			body.has_food = false
			state = TableState.ONE_SANDWICH
			update_table_appearance()
		elif state == TableState.ONE_SANDWICH:
			body.has_food = false
			state = TableState.TWO_SANDWICH_EATING
			update_table_appearance()
			trigger_customers_sandwich()

func trigger_customers_coffee() -> void:
	for cust in current_customers:
		if cust and is_instance_valid(cust) and cust.has_method("start_coffee_countdown"):
			cust.start_coffee_countdown()
		
	await get_tree().create_timer(3.0).timeout
	state = TableState.CLEAN_WAITING_SANDWICH
	update_table_appearance()

func trigger_customers_sandwich() -> void:
	for cust in current_customers:
		if cust and is_instance_valid(cust) and cust.has_method("start_sandwich_countdown"):
			cust.start_sandwich_countdown()
			
	await get_tree().create_timer(3.0).timeout
	
	var money_scene = load("res://scene/money.tscn")
	if money_scene:
		var money_instance = money_scene.instantiate()
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(money_instance)
			money_instance.global_position = global_position + Vector2(-40, 0)

	current_customers.clear()
	state = TableState.CLEAN_WAITING_COFFEE
	update_table_appearance()
	is_occupied = false

func update_table_appearance() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return
		
	match state:
		TableState.CLEAN_WAITING_COFFEE, TableState.CLEAN_WAITING_SANDWICH:
			if animated_sprite.sprite_frames.has_animation("clean"):
				animated_sprite.play("clean")
		TableState.ONE_COFFEE:
			if animated_sprite.sprite_frames.has_animation("one coffee"):
				animated_sprite.play("one coffee")
		TableState.TWO_COFFEE_DRINKING:
			if animated_sprite.sprite_frames.has_animation("two coffee"):
				animated_sprite.play("two coffee")
		TableState.ONE_SANDWICH:
			if animated_sprite.sprite_frames.has_animation("one sandwish"):
				animated_sprite.play("one sandwish")
		TableState.TWO_SANDWICH_EATING:
			if animated_sprite.sprite_frames.has_animation("two sandwish"):
				animated_sprite.play("two sandwish")
