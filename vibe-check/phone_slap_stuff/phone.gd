extends Node3D
class_name Phone


@onready var body: RigidBody3D = $RigidBody3D
@onready var raycast: RayCast3D = %RayCast3D
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")
@onready var phone_pickup_area : Area3D = %Area3D
@onready var pickup_delay : Timer = %PickupDelayTimer

@export var impulse_multiplier : float = 1.0

func _ready() -> void:
	phone_pickup_area.monitoring = false
	pickup_delay.start()

func _process(delta: float) -> void:
	if raycast.is_colliding():
		var impulse = Vector3.UP * randf_range(1.0, 10.0)
		impulse.x = randf_range(1.0, 4.0)
		impulse.z = randf_range(1.0, 4.0)
		body.apply_impulse(impulse * impulse_multiplier)

func _on_pickup_delay_timeout() -> void:
	phone_pickup_area.monitoring = true
	print("pickup delay finished")

## this function slaps
func slap(slapper_global_pos: Vector3) -> void:
	body.top_level = true
	body.freeze = false
	var slapper_dir_from_phone := slapper_global_pos - body.global_position
	var horizontal_dir := (slapper_dir_from_phone * Vector3(1, 0, 1)).normalized()
	var left_right_dir := horizontal_dir.rotated(Vector3.UP, PI/2 if randi_range(0, 1) else -PI/2)
	body.linear_velocity += left_right_dir * 2.0 + Vector3(0, 5.0, 0)
	#body.angular_velocity += Vector3(2, 3, 4)


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("you stepped on your phone!")
	player_reference.holding_phone = true
	self.queue_free()
