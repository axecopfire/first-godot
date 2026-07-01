extends Node

## Boot scene - minimal initialization then transition to main.
## TextureCache autoload has already generated all textures by the time we reach _ready.

func _ready() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
