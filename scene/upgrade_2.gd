extends Area2D

@export var unlock_cost: int = 5
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = "Unlock new\nLounge: $" + str(unlock_cost)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.name == "playerr":
		if "score" in body:
			if body.score >= unlock_cost:
				body.add_money(-unlock_cost)
				unlock_area()
			else:
				print("Not enough money! Need $" + str(unlock_cost))

func unlock_area() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	# 1. Find and delete the barriers node safely
	var barriers = current_scene.find_child("barriers", true, false)
	if not barriers:
		barriers = current_scene.find_child("barers", true, false)
	if barriers:
		barriers.queue_free()
		
	# 2. Reveal and activate everything inside "updates in cafe" safely using set_deferred
	var updates_folder = current_scene.find_child("updates in cafe", true, false)
	if updates_folder:
		for child in updates_folder.get_children():
			if child is CanvasItem:
				child.visible = true
			if child is Area2D:
				child.set_deferred("monitoring", true)
				child.set_deferred("monitorable", true)
				var col = child.get_node_or_null("CollisionShape2D")
				if col:
					col.set_deferred("disabled", false)
					
	# 3. Delete this lounge upgrade box permanently
	queue_free()
