extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the player touched the money
	if body.name == "player" or body.name == "playerr":
		# TODO: We will add your top-right money score counter here next!
		
		# Disappear when the player picks it up
		queue_free()
