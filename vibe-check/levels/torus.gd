extends MeshInstance3D


func _process(delta: float) -> void:
	rotate_x(delta * 0.0375)
	rotate_y(delta * 0.0625)
	rotate_z(delta * 0.025)
