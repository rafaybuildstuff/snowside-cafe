extends Area2D

@onready var prompt_label: Label = $Label

var player_in_range: bool = false
var target_player: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt_label:
		prompt_label.text = "[F]"
		prompt_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = true
		target_player = body
		if prompt_label:
			prompt_label.text = "[F]"
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = false
		target_player = null
		if prompt_label:
			prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if target_player:
			if "has_cup" in target_player:
				target_player.has_cup = false
			if "has_food" in target_player:
				target_player.has_food = false
				
			target_player.velocity = Vector2.ZERO
			
			var animated_sprite = target_player.get_node_or_null("AnimatedSprite2D")
			if animated_sprite and animated_sprite.sprite_frames:
				if animated_sprite.sprite_frames.has_animation("front idle"):
					animated_sprite.play("front idle")
					print("Trash used: Player reset to normal!")
