extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# This checks if whatever touched it has the add_money function, 
	# no matter what your player node is named!
	if body.has_method("add_money"):
		body.add_money(10) # Gives exactly 10 rupees per table!
		queue_free()
