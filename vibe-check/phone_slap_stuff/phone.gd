extends Node3D
class_name Phone


@onready var body: RigidBody3D = $RigidBody3D


## this function slaps
func slap(slapper_global_pos: Vector3) -> void:
	body.top_level = true
	body.freeze = false
	var slapper_dir_from_phone := slapper_global_pos - body.global_position
	var horizontal_dir := (slapper_dir_from_phone * Vector3(1, 0, 1)).normalized()
	var left_right_dir := horizontal_dir.rotated(Vector3.UP, PI/2 if randi_range(0, 1) else -PI/2)
	body.linear_velocity += left_right_dir * 2.0 + Vector3(0, 5.0, 0)
	#body.angular_velocity += Vector3(2, 3, 4)
