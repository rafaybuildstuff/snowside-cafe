extends Area2D

@onready var prompt_label: Label = $Label if has_node("Label") else null

var player_in_range: bool = false
var is_cooking: bool = false
var food_ready: bool = false

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
		
		# Case 1: Pick up food when ready
		if food_ready:
			for body in get_overlapping_bodies():
				if body.name == "player" or body.name == "playerr":
					if "has_food" in body:
						body.has_food = true # Sets the player's food state variable
					print("Food picked up!")
					food_ready = false
					update_label_text()
			return

		# Case 2: Start cooking countdown if not already cooking
		if not is_cooking:
			is_cooking = true
			print("Cooking started...")
			
			# Live countdown from 3 to 1
			for i in range(3, 0, -1):
				if prompt_label:
					prompt_label.text = "Cooking... " + str(i)
				await get_tree().create_timer(1.0).timeout
			
			# When countdown finishes
			is_cooking = false
			food_ready = true
			print("Food is ready!")
			
			if prompt_label and player_in_range:
				prompt_label.text = "[E] Food Ready!"

func update_label_text() -> void:
	if not prompt_label:
		return
		
	if food_ready:
		prompt_label.text = "[E] Food Ready!"
	elif is_cooking:
		pass
	else:
		prompt_label.text = "[E]"
