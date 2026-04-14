extends Area2D

@export var item_name := "Item"

var player_in_range := false
var picked_up := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if picked_up:
		return
	if event.is_action_pressed("interact") and player_in_range:
		_pickup()
		get_viewport().set_input_as_handled()

func _pickup() -> void:
	picked_up = true
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].add_item(item_name)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
