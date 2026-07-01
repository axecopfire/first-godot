extends Node

## Boot scene - minimal initialization then transition to main.
## TextureCache autoload has already generated all textures by the time we reach _ready.

func _ready() -> void:
	# Defer scene transition to avoid modifying the tree while Boot is still
	# processing its own _ready callback.
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
