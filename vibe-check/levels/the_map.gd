extends Node3D

var _failed: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if _failed:
		return
	_failed = true
	SignalBus.failed.emit()
