extends Node3D
class_name MapManager

var phone = preload("res://phone_slap_stuff/phone.tscn")

func phone_slap_trigger(from_position: Vector3) -> void:
	var instance = phone.instantiate()
	add_child(instance)
	var spawned_phone = get_child(-1)
	spawned_phone.slap(from_position)
