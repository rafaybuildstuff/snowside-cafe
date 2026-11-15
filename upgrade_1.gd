extends Area2D

@export var table_cost: int = 20
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = "Unlock\nTable: $20"
		
	# Automatically hide Seat3 and Seat4 at the start of the game
	call_deferred("set_chairs_active", false)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_money") and "score" in body:
		if body.score >= table_cost:
			body.add_money(-table_cost)
			call_deferred("spawn_new_cafe_content")
		else:
			print("Not enough money! Need $20.")

func spawn_new_cafe_content() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	# 1. Spawn Table 2 and mark it as the second table
	var table_scene = load("res://scene/tabel.tscn") 
	if table_scene:
		var new_table = table_scene.instantiate()
		new_table.is_second_table = true # Tells this table to use Customer 3 & 4
		current_scene.add_child(new_table)
		new_table.global_position = global_position
		
		# Immediately spawn Customer 3 and Customer 4 for this new table!
		new_table.spawn_new_customers()
		
	# 2. Reveal Seat3 and Seat4 and enable their collisions
	set_chairs_active(true)
	
	# 3. Remove the upgrade zone permanently
	queue_free()

func set_chairs_active(is_active: bool) -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	for chair_name in ["Seat3", "Seat4"]:
		var chair = current_scene.find_child(chair_name, true, false)
		if chair:
			chair.visible = is_active
			if chair.has_node("Sprite2D"):
				var sprite = chair.get_node("Sprite2D")
				sprite.visible = is_active
				sprite.modulate.a = 1.0 if is_active else 0.0
			if chair.has_node("CollisionShape2D"):
				chair.get_node("CollisionShape2D").disabled = !is_active
