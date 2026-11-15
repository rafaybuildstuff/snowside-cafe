extends Area2D

@export var unlock_cost: int = 20
@export var target_table: Node2D
@export var seats: Array[Node2D] = []

@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = "Unlock\nTable: $" + str(unlock_cost)
		
	# Automatically hide the table and seats when the game starts
	set_items_active(false)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		if "score" in body:
			if body.score >= unlock_cost:
				body.add_money(-unlock_cost)
				# Make both the table and its seats visible and active
				set_items_active(true)
				queue_free()
			else:
				print("Not enough money! Need $" + str(unlock_cost))

func set_items_active(is_active: bool) -> void:
	var all_items: Array[Node2D] = []
	if target_table:
		all_items.append(target_table)
	all_items.append_array(seats)
	
	for item in all_items:
		if not item:
			continue
		item.visible = is_active
		
		# Turn visuals on/off
		for child in item.get_children():
			if child is CanvasItem:
				child.visible = is_active
			if child is AnimatedSprite2D and is_active:
				child.play()
			if child is StaticBody2D:
				child.visible = is_active
				var static_col = child.get_node_or_null("CollisionShape2D")
				if static_col:
					static_col.set_deferred("disabled", not is_active)
					
		# Turn main collision on/off
		var col = item.get_node_or_null("CollisionShape2D")
		if col:
			col.set_deferred("disabled", not is_active)
