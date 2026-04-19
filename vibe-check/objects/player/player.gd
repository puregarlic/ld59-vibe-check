extends CharacterBody3D
class_name Player

#movement and camera control variables
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_impulse : float = 10.0
@export var speed : float = 14.0
@export var sprint_speed : float = 28.0
@export var slap_horizontal_force : float = 5.0
@export var slap_vertical_force : float = 3.0
@export var look_pitch_max_angle : int = 80

var _in_knockback : bool = false
var mouse_sensitivity : float = 0.002

var movement : Callable

#head bobbing variables
@export_group("headbob")
@export var headbob_frequency : float = 2.0
@export var headbob_amplitude : float = 0.04
var headbob_time : float = 0.0

var scan_time : float = 1.0
var bad_vibes_proximity : float = 1.0
var pass_vibe_check : bool
var scan_target : Slapper
var current_scan_target : Slapper
var scanning : bool = false

var holding_phone : bool = true


func _ready() -> void:
	%ScanTimer.timeout.connect(scan_timer_end)

func _physics_process(delta: float) -> void:
	velocity.y += -gravity * delta
	
	var move_speed = speed
	
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		move_speed = speed
	
	
	if not _in_knockback:
		var input := Input.get_vector("left", "right", "forward", "back")
		var movement_dir := transform.basis * Vector3(input.x, 0, input.y)
		velocity.x = movement_dir.x * move_speed
		velocity.z = movement_dir.z * move_speed

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_impulse

	move_and_slide()

	if _in_knockback and is_on_floor():
		_in_knockback = false
	
	headbob_time += delta * velocity.length() * float(is_on_floor())
	$Camera3D.transform.origin = headbob(headbob_time) + Vector3(0, 1, 0)
	
	scan_target = %ScanCast.get_collider()
	
	if Input.is_action_just_pressed("interact") and scan_target != null and holding_phone == true:
		current_scan_target = scan_target
		%ScanTimer.wait_time = scan_time * bad_vibes_proximity
		%ScanTimer.start()
		scanning = true
		print("we're scanning a target!")
	if Input.is_action_just_released("interact") and scanning == true and holding_phone == true:
		%ScanTimer.stop()
		current_scan_target = null
		scanning = false
		print("we broke from our target")
	if Input.is_action_pressed("interact") and scan_target != current_scan_target and scanning == true and holding_phone == true:
		%ScanTimer.stop()
		current_scan_target = null
		scanning = false
		print("we broke from our target")
	

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

func receive_slap(from_position: Vector3) -> void:
	var dir = global_position - from_position
	dir.y = 0.0
	dir = dir.normalized()
	var heat = GlobalDifficulty.heat_multiplier
	velocity.x = dir.x * slap_horizontal_force * heat
	velocity.z = dir.z * slap_horizontal_force * heat
	velocity.y = slap_vertical_force * heat
	_in_knockback = true
	holding_phone = false
	scanning = false

func scan_timer_end():
		print("timer out")
		if Input.is_action_pressed("interact") and scan_target == current_scan_target and scanning == true:
			print("scan complete")
			if current_scan_target.vibe == Types.Vibe.GOOD:
				pass_vibe_check = true
				print("GOOD VIBES FOUND")
			if current_scan_target.vibe == Types.Vibe.BAD:
				pass_vibe_check = false
				print("BAD VIBES DETECTED")
				#current_scan_target.obliterate()
