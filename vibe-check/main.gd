extends Node
class_name Main

@onready var world : World = $World

func _ready() -> void:
	world.gui = $GUI
	world.start_menu()
