extends TextureRect

@export var world_scene: PackedScene

func _on_button_button_up() -> void:
	var world = world_scene.instantiate()
	world.gui = get_parent()
	get_tree().root.add_child(world)
	queue_free()
