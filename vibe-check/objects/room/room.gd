extends Node3D


func _on_area_player_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.next_room.emit()
