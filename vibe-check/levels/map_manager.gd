extends Node3D
class_name MapManager

var phone = preload("res://phone_slap_stuff/phone.tscn")
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")

func phone_slap_trigger(from_position: Vector3) -> void:
	print("phone spawned")
	var instance = phone.instantiate()
	add_child(instance)
	var spawned_phone = get_child(-1)
	spawned_phone.position = player_reference.global_position + Vector3(0, 2, 0)
	spawned_phone.slap(from_position)
	print(spawned_phone.position)
