extends CharacterBody3D
class_name Player

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed : float = 1.0
@export var look_pitch_max_angle : int = 80
var mouse_sensitivity : float = 0.002

var movement : Callable

func _physics_process(delta: float) -> void:
	velocity.y += -gravity * delta

	var input := Input.get_vector("left", "right", "forward", "back")
	var movement_dir := transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(look_pitch_max_angle), deg_to_rad(look_pitch_max_angle))
