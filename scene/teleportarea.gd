extends Area2D

# Prevents the transition from triggering multiple times
var is_teleporting: bool = false

func _ready() -> void:
	# Automatically connect when the player touches the area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body entering is your player (supports both spellings just in case)
	if (body.name == "player" or body.name == "playerr") and not is_teleporting:
		is_teleporting = true
		play_fade_and_teleport()

func play_fade_and_teleport() -> void:
	# 1. Create a CanvasLayer so the black screen stays on top of everything
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# 2. Create a black ColorRect spanning the whole viewport
	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.modulate.a = 0.0 # Start fully transparent
	canvas_layer.add_child(fade_rect)
	
	# 3. Smoothly animate alpha from 0 to 1 over 0.5 seconds (Fade to black)
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	
	# 4. Wait for the fade animation to finish
	await tween.finished
	
	# 5. Change to your cafe scene
	var error = get_tree().change_scene_to_file("res://scene/cafe_scene.tscn")
	
	# Fallback if something goes wrong
	if error != OK:
		print("Error: Could not load cafe scene! Check the path.")
		canvas_layer.queue_free()
		is_teleporting = false
