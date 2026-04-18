extends CharacterBody3D
class_name Player

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_impulse : float = 10
@export var speed : float = 14.0
@export var sprint_speed : float = 28.0
@export var look_pitch_max_angle : int = 80
var mouse_sensitivity : float = 0.002

var movement : Callable

@export_group("headbob")
@export var headbob_frequency : float = 2.0
@export var headbob_amplitude : float = 0.04
var headbob_time : float = 0.0

func _physics_process(delta: float) -> void:
	velocity.y += -gravity * delta
	
	var move_speed = speed
	
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		move_speed = speed

	var input := Input.get_vector("left", "right", "forward", "back")
	var movement_dir := transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * move_speed
	velocity.z = movement_dir.z * move_speed
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_impulse
	
	move_and_slide()
	
	headbob_time += delta * velocity.length() * float(is_on_floor())
	$Camera3D.transform.origin = headbob(headbob_time) + Vector3(0, 1, 0)

func headbob(headbob_time):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(look_pitch_max_angle), deg_to_rad(look_pitch_max_angle))
