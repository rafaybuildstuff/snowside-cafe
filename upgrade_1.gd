extends Area2D

@export var upgrade_cost: int = 20
@export var target_table: Node2D # Assign Table 2 in the Main Cafe scene Inspector
@onready var label: Label = $Label
@onready var sfx = get_node_or_null("music")

var purchased: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label:
		label.text = "Unlock\nTable: $" + str(upgrade_cost)
	call_deferred("_set_table_active", false)

func _on_body_entered(body: Node2D) -> void:
	if purchased:
		return
	if body.name == "player" or body.name == "playerr":
		if "score" in body:
			if body.score >= upgrade_cost:
				purchased = true
				body.add_money(-upgrade_cost)
				unlock_table()
			else:
				print("Not enough money! Need $" + str(upgrade_cost))

func unlock_table() -> void:
	_set_table_active(true)

	var current_scene = get_tree().current_scene
	if current_scene:
		for item_name in ["Seat3", "Seat4", "Waypoint3", "Waypoint4"]:
			var item = current_scene.find_child(item_name, true, false)
			if item and item is CanvasItem:
				item.visible = true

	visible = false
	set_deferred("monitoring", false)
	if sfx and sfx.stream:
		sfx.play()
		await sfx.finished

	queue_free()

func _set_table_active(active: bool) -> void:
	var table = target_table
	if not table and get_tree().current_scene:
		for node in get_tree().current_scene.find_children("*", "Area2D", true, false):
			if node.get("use_alternate_customers") == true:
				table = node
				break

	if not table:
		return

	table.visible = active
	if table is Area2D:
		table.set_deferred("monitoring", active)
		table.set_deferred("monitorable", active)

	# Disable/enable all CollisionShape2D nodes inside the table (including StaticBody2D)
	for col in table.find_children("*", "CollisionShape2D", true, false):
		col.set_deferred("disabled", not active)

	if active and table.has_method("spawn_new_customers"):
		table.call_deferred("spawn_new_customers")
