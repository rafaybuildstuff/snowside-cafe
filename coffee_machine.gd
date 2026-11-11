extends Area2D

@onready var prompt_label: Label = $Label

var player_in_range: bool = false
var is_brewing: bool = false
var coffee_ready: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt_label:
		prompt_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = true
		update_label_text()
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Check if player is in range and presses the 'E' key
	if player_in_range and event is InputEventKey and event.pressed and event.keycode == KEY_E:
		
		# Case 1: Pick up coffee when ready
		if coffee_ready:
			for body in get_overlapping_bodies():
				if body.name == "player" or body.name == "playerr":
					if "has_cup" in body:
						body.has_cup = true
					print("Coffee picked up!")
					coffee_ready = false
					update_label_text()
			return

		# Case 2: Start brewing countdown
		if not is_brewing:
			is_brewing = true
			print("Brewing started...")
			
			for i in range(3, 0, -1):
				if prompt_label:
					prompt_label.text = "Brewing... " + str(i)
				await get_tree().create_timer(1.0).timeout
			
			is_brewing = false
			coffee_ready = true
			print("Drink is done!")
			
			if prompt_label and player_in_range:
				prompt_label.text = "[E] Drink Done!"

func update_label_text() -> void:
	if not prompt_label:
		return
		
	if coffee_ready:
		prompt_label.text = "[E] Drink Done!"
	elif is_brewing:
		pass
	else:
		prompt_label.text = "[E]"
