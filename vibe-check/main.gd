extends Node
class_name Main

@export var world_scene: PackedScene

func _ready() -> void:
	if not OS.has_feature("web"):
		for child in $GUI.get_children():
			child.queue_free()
		var world = world_scene.instantiate()
		world.gui = $GUI
		add_child(world)
