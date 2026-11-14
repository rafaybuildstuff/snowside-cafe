extends Area2D

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

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if prompt_label:
		prompt_label.visible = false
	update_table_appearance()

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

func get_both_customers() -> Array[Node]:
	var customers: Array[Node] = []
	var current_scene = get_tree().current_scene
	if current_scene:
		var customers_folder = current_scene.find_child("customers", true, false)
		if customers_folder:
			for child in customers_folder.get_children():
				if child.has_method("start_coffee_countdown"):
					customers.append(child)
		else:
			var c1 = current_scene.get_node_or_null("Customer")
			var c2 = current_scene.get_node_or_null("Customer2")
			if c1: customers.append(c1)
			if c2: customers.append(c2)
	return customers

func trigger_customers_coffee() -> void:
	for cust in get_both_customers():
		cust.start_coffee_countdown()
		
	await get_tree().create_timer(3.0).timeout
	state = TableState.CLEAN_WAITING_SANDWICH
	update_table_appearance()

func trigger_customers_sandwich() -> void:
	for cust in get_both_customers():
		if cust.has_method("start_sandwich_countdown"):
			cust.start_sandwich_countdown()
			
	# Wait 3 seconds while they eat
	await get_tree().create_timer(3.0).timeout
	
	# SPAWN MONEY ON THE LEFT SIDE OF THE TABLE AUTOMATICALLY
	var money_scene = load("res://scene/money.tscn")
	if money_scene:
		var money_instance = money_scene.instantiate()
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(money_instance)
			# Places money 40 pixels to the left of the table center
			money_instance.global_position = global_position + Vector2(-40, 0)

	state = TableState.CLEAN_WAITING_COFFEE
	update_table_appearance()

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
