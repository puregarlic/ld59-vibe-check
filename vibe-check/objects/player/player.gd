extends CharacterBody3D
class_name Player

#movement and camera control variables
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_impulse : float = 10.0
@export var coyote_time : float = 0.12
@export var speed : float = 14.0
@export var sprint_speed : float = 28.0
@export var scan_move_speed : float = 5.0
@export var slap_horizontal_force : float = 5.0
@export var slap_vertical_force : float = 3.0
@export var look_pitch_max_angle : int = 80

var _in_knockback : bool = false
var _coyote_timer : float = 0.0
var _was_on_floor : bool = false
var mouse_sensitivity : float = 0.002

const FALL_VO_THRESHOLD : float = 0.5
const FALL_VO_FADE_TIME : float = 0.18
const FALL_VO_FADE_TARGET_DB : float = -40.0
const FALL_VO_DUCK_DB : float = 9.0
const FALL_VO_DEATH_DUCK_DB : float = 13.0
const FALL_DEATH_DISTANCE : float = 22.0
var _airborne_time : float = 0.0
var _fall_start_y : float = 0.0
var _fall_start_recorded : bool = false
var _fall_vo_started : bool = false
var _fall_vo_base_db : float = 0.0
var _fall_fade_tween : Tween = null
@onready var _fall_audio : AudioStreamPlayer = $FallAudio

@onready var scanner_progress_audio : AudioStreamPlayer = $ScannerProgressAudio
@onready var postive_scan_audio : AudioStreamPlayer = $PositiveScanResultAudio
@onready var bad_vibes_scan_audio : AudioStreamPlayer = $BadVibesScanResultAudio

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
var scanning : bool = false :
	get: return scanning
	set(value):
		change_phone_height(value)
		scanning = value

var holding_phone : bool :
	get: return holding_phone
	set(value):
		if value:
			%RightHand.visible = true
			%RightHandEmpty.visible = false
		else:
			%RightHand.visible = false
			%RightHandEmpty.visible = true
		holding_phone = value
@onready var initial_left_hand_position = %LeftHand.position
var left_hand_tween: Tween
var left_hand_bob: bool = true
@onready var initial_right_hand_position = %RightHand.position
@onready var raised_right_hand_position = initial_right_hand_position + (Vector3.UP * 0.07)
var right_hand_tween: Tween
@onready var initial_right_hand_empty_position = %RightHandEmpty.position


func _ready() -> void:
	%ScanTimer.timeout.connect(scan_timer_end)
	SignalBus.left_hand_visibility.connect(update_left_hand_visibility)
	holding_phone = true
	_fall_vo_base_db = _fall_audio.volume_db

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
		movement_dir = movement_dir.normalized()
		if scanning == true:
			velocity.x = movement_dir.x * scan_move_speed
			velocity.z = movement_dir.z * scan_move_speed
		else:
			velocity.x = movement_dir.x * move_speed
			velocity.z = movement_dir.z * move_speed
	
	if is_on_floor():
		_coyote_timer = coyote_time
	elif _was_on_floor and velocity.y <= 0.0:
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

	if _coyote_timer > 0.0 and Input.is_action_just_pressed("jump"):
		velocity.y = jump_impulse
		_coyote_timer = 0.0

	_was_on_floor = is_on_floor()
	move_and_slide()

	if _in_knockback and is_on_floor():
		_in_knockback = false

	_update_fall_voice(delta)

	headbob_time += delta * velocity.length() * float(is_on_floor())
	$Camera3D.transform.origin = headbob(headbob_time) + Vector3(0, 1, 0)
	if not scanning:
		%RightHand.transform.origin = (headbob(headbob_time) * (Vector3.UP * 0.2)) + initial_right_hand_position
	%RightHandEmpty.transform.origin = (headbob(headbob_time) * (Vector3.UP * 0.2)) + initial_right_hand_empty_position
	if left_hand_bob:
		%LeftHand.transform.origin = (headbob(headbob_time) * (Vector3.UP * -0.2)) + initial_left_hand_position

	scan_target = %ScanCast.get_collider()
	if Input.is_action_just_pressed("interact") and scan_target != null and holding_phone == true:
		current_scan_target = scan_target
		%ScanTimer.wait_time = scan_time * bad_vibes_proximity
		%ScanTimer.start()
		scanning = true
		print("we're scanning a target!")
		scanner_progress_audio.play()
	if Input.is_action_just_released("interact") and scanning == true and holding_phone == true:
		%ScanTimer.stop()
		current_scan_target = null
		scanning = false
		scanner_progress_audio.stop()
		print("we broke from our target")
	if Input.is_action_pressed("interact") and scan_target != current_scan_target and scanning == true and holding_phone == true:
		%ScanTimer.stop()
		current_scan_target = null
		scanning = false
		scanner_progress_audio.stop()
		print("we broke from our target")


func headbob(headbob_time: float) -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(look_pitch_max_angle), deg_to_rad(look_pitch_max_angle))

func _update_fall_voice(delta: float) -> void:
	if _fall_vo_started and is_on_floor():
		_fade_out_fall_voice()
		_fall_vo_started = false
	if %ScreamCast.is_colliding():
		_airborne_time = 0.0
		_fall_start_recorded = false
		return
	if not _fall_start_recorded:
		_fall_start_y = global_position.y
		_fall_start_recorded = true
	_airborne_time += delta
	if _fall_vo_started or _airborne_time <= FALL_VO_THRESHOLD:
		return
	if _fall_fade_tween != null and _fall_fade_tween.is_valid():
		_fall_fade_tween.kill()
		_fall_fade_tween = null
	var fell_far := (_fall_start_y - global_position.y) > FALL_DEATH_DISTANCE
	var use_death := fell_far or not _trajectory_will_find_ground()
	_fall_audio.volume_db = _fall_vo_base_db - (FALL_VO_DEATH_DUCK_DB if use_death else FALL_VO_DUCK_DB)
	var pool: Array = VoicePools.FALLING_DEATH if use_death else VoicePools.FALLING
	_fall_audio.bus = &"Echo" if use_death else &"Master"
	_fall_audio.stream = VoicePools.random_pick(pool)
	_fall_audio.play()
	_fall_vo_started = true

func _fade_out_fall_voice() -> void:
	if _fall_fade_tween != null and _fall_fade_tween.is_valid():
		_fall_fade_tween.kill()
	_fall_fade_tween = create_tween()
	_fall_fade_tween.tween_property(_fall_audio, "volume_db", FALL_VO_FADE_TARGET_DB, FALL_VO_FADE_TIME)
	_fall_fade_tween.tween_callback(_fall_audio.stop)
	_fall_fade_tween.tween_callback(func(): _fall_audio.volume_db = _fall_vo_base_db)

func _trajectory_will_find_ground() -> bool:
	var space := get_world_3d().direct_space_state
	var horiz := Vector3(velocity.x, 0.0, velocity.z)
	var samples := [0.3, 0.6, 1.0, 1.5, 2.0]
	for t in samples:
		var pos: Vector3 = global_position + horiz * t
		var from: Vector3 = pos + Vector3.UP * 0.2
		var to: Vector3 = pos + Vector3.DOWN * 60.0
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self.get_rid()]
		if not space.intersect_ray(query).is_empty():
			return true
	return false

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
	var positive_scan_audio = postive_scan_audio
	var bad_vibes_scan_audio = bad_vibes_scan_audio
	var scanner_progress_audio = scanner_progress_audio
	
	print("timer out")
	if Input.is_action_pressed("interact") and scan_target == current_scan_target and scanning == true:
		SignalBus.scan_success.emit()
		scanner_progress_audio.stop()
		if current_scan_target.vibe == Types.Vibe.GOOD:
			positive_scan_audio.play()
			pass_vibe_check = true
			print("GOOD VIBES FOUND")
		if current_scan_target.vibe == Types.Vibe.BAD:
			bad_vibes_scan_audio.play()
			pass_vibe_check = false
			print("BAD VIBES DETECTED")
			SignalBus.baddie_scanned.emit(current_scan_target)
			current_scan_target.caught()

func update_left_hand_visibility(val: bool) -> void:
	if left_hand_tween:
		left_hand_tween.kill()

	left_hand_tween = get_tree().create_tween()
	if val:
		left_hand_tween.tween_property(%LeftHand, "position", initial_left_hand_position, 0.1)
		left_hand_tween.tween_callback(set_left_bob.bind(true))
	else:
		set_left_bob(false)
		left_hand_tween.tween_property(%LeftHand, "position", Vector3(-0.85, initial_left_hand_position.y, initial_left_hand_position.z), 0.1)

func set_left_bob(val: bool) -> void:
	left_hand_bob = val

func change_phone_height(val: bool) -> void:
	if right_hand_tween:
			right_hand_tween.kill()
	right_hand_tween = get_tree().create_tween()
	if val:
		right_hand_tween.tween_property(%RightHand, "position", raised_right_hand_position, 0.1)
	else:
		right_hand_tween.tween_property(%RightHand, "position", initial_right_hand_position, 0.1)
