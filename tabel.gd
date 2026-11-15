extends Area2D

# If true, this table uses Customer 3 & 4. If false, it uses Customer 1 & 2.
@export var is_second_table: bool = false

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

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if prompt_label:
		prompt_label.visible = false
	update_table_appearance()
	
	# Link initial Table 1 customers if they exist in the scene
	if not is_second_table:
		var current_scene = get_tree().current_scene
		if current_scene:
			var c1 = current_scene.find_child("Customer", true, false)
			var c2 = current_scene.find_child("Customer2", true, false)
			if c1: current_customers.append(c1)
			if c2: current_customers.append(c2)

func _on_body_entered(body: Node2D) -> void:
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
			
	# Wait 3 seconds while they finish eating
	await get_tree().create_timer(3.0).timeout
	
	# Spawn money on the left side of this table
	var money_scene = load("res://scene/money.tscn")
	if money_scene:
		var money_instance = money_scene.instantiate()
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(money_instance)
			money_instance.global_position = global_position + Vector2(-40, 0)

	# Reset table back to clean
	state = TableState.CLEAN_WAITING_COFFEE
	update_table_appearance()
	
	# Respawn the correct pair of customers for this specific table
	spawn_new_customers()

func spawn_new_customers() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	var cust1_scene
	var cust2_scene
	
	if is_second_table:
		cust1_scene = load("res://scene/customer_3.tscn")
		cust2_scene = load("res://scene/customer_4.tscn")
	else:
		cust1_scene = load("res://scene/customer.tscn")
		cust2_scene = load("res://scene/customer_2.tscn")
		
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
		
		# Entrance spawn position inside the cafe
		c1.global_position = Vector2(10, -20)
		c2.global_position = Vector2(35, 0)

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
