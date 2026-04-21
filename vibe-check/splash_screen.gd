extends TextureRect

@export var world_scene: PackedScene

func _on_button_button_up() -> void:
	var world = world_scene.instantiate()
	get_tree().root.add_child(world)
	world.gui = get_parent()
	world.start_menu()
	queue_free()
