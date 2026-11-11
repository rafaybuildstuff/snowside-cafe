extends Area2D

enum TableState { EMPTY, WAITING_FOR_COFFEE, COFFEE_COUNTDOWN, WAITING_FOR_SANDWICH, SANDWICH_COUNTDOWN, DIRTY }
var state: TableState = TableState.EMPTY

@onready var prompt_label: Label = $Label
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player_in_range: bool = false
var current_player: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false
	update_table_appearance()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = true
		current_player = body
		update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		player_in_range = false
		current_player = null
		if prompt_label:
			prompt_label.visible = false

func update_prompt() -> void:
	if not prompt_label or not player_in_range:
		return
		
	if state == TableState.WAITING_FOR_COFFEE and current_player and current_player.get("has_cup"):
		prompt_label.text = "[Q] Serve Coffee"
		prompt_label.visible = true
	elif state == TableState.WAITING_FOR_SANDWICH and current_player and current_player.get("has_food"):
		prompt_label.text = "[Q] Serve Sandwich"
		prompt_label.visible = true
	else:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		# 1. Serve Coffee
		if state == TableState.WAITING_FOR_COFFEE and current_player and current_player.get("has_cup"):
			current_player.has_cup = false
			state = TableState.COFFEE_COUNTDOWN
			update_table_appearance()
			start_coffee_countdown()
			
		# 2. Serve Sandwich
		elif state == TableState.WAITING_FOR_SANDWICH and current_player and current_player.get("has_food"):
			current_player.has_food = false
			state = TableState.SANDWICH_COUNTDOWN
			update_table_appearance()
			start_sandwich_countdown()

func start_coffee_countdown() -> void:
	print("Coffee placed on table! Customer drinking...")
	if prompt_label:
		prompt_label.visible = true
		
	for i in range(3, 0, -1):
		prompt_label.text = "Customer drinking... " + str(i)
		await get_tree().create_timer(1.0).timeout
		
	state = TableState.WAITING_FOR_SANDWICH
	print("Coffee finished! Now customer wants a sandwich.")
	update_table_appearance()
	update_prompt()

func start_sandwich_countdown() -> void:
	print("Sandwich placed on table! Customer eating...")
	if prompt_label:
		prompt_label.visible = true
		
	for i in range(3, 0, -1):
		prompt_label.text = "Eating sandwich... " + str(i)
		await get_tree().create_timer(1.0).timeout
		
	state = TableState.EMPTY
	print("Meal completed! Table is now clean and empty.")
	update_table_appearance()
	update_prompt()

func update_table_appearance() -> void:
	if not animated_sprite:
		return
		
	match state:
		TableState.EMPTY:
			if animated_sprite.sprite_frames.has_animation("clean"):
				animated_sprite.play("clean")
		TableState.WAITING_FOR_COFFEE:
			if animated_sprite.sprite_frames.has_animation("clean"):
				animated_sprite.play("clean")
		TableState.COFFEE_COUNTDOWN:
			if animated_sprite.sprite_frames.has_animation("one coffee"):
				animated_sprite.play("one coffee")
		TableState.WAITING_FOR_SANDWICH:
			if animated_sprite.sprite_frames.has_animation("one coffee"):
				animated_sprite.play("one coffee")
		TableState.SANDWICH_COUNTDOWN:
			if animated_sprite.sprite_frames.has_animation("one sandwish"):
				animated_sprite.play("one sandwish")
		TableState.DIRTY:
			if animated_sprite.sprite_frames.has_animation("clean"):
				animated_sprite.play("clean")
