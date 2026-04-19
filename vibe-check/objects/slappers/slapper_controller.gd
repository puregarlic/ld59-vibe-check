class_name Slapper
extends CharacterBody3D

signal scan_detected
signal slap_triggered

@export var vibe = Types.Vibe.GOOD
@export var scan_alert_audio: AudioStreamPlayer3D

@onready var _ai: Node = $AI
@onready var _animated_sprite: AnimatedSprite3D = $"Animated Sprite"
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")
@onready var map_manager_reference: MapManager = get_tree().get_first_node_in_group("map_manager")

var _current_phase: Types.Phase = Types.Phase.PAUSED
var _target_angle: float = 0.0
var _turn_speed: float = 0.0
var _slap_cooldown_remaining: float = 0.0
var _slap_hold_timer: Timer

const SCAN_DETECTION_ANGLE: float = 45.0
const SCAN_CHARGE_SPEED: float = 8.0
const SCAN_TURN_SPEED: float = 5.0
const SLAP_DISTANCE: float = 2.0
const SLAP_COOLDOWN: float = 10.0
const SLAP_HOLD_DURATION: float = 0.5

func _ready() -> void:
	scan_detected.connect(_ai.on_scan_detected)
	slap_triggered.connect(_on_slap_triggered)
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	_slap_hold_timer = Timer.new()
	_slap_hold_timer.one_shot = true
	_slap_hold_timer.timeout.connect(_on_slap_hold_finished)
	add_child(_slap_hold_timer)
	if player_reference:
		add_collision_exception_with(player_reference)

func _physics_process(delta: float) -> void:
	if _slap_cooldown_remaining > 0.0:
		_slap_cooldown_remaining -= delta

	match _current_phase:
		Types.Phase.TURNING:
			rotation.y += _turn_speed * delta
		Types.Phase.SCAN_ALERT:
			if not _is_being_scanned():
				_ai.end_scan_response()
		Types.Phase.SCAN_CHARGE:
			_update_scan_charge(delta)

	if _should_check_scan() and _player_in_detection_cone():
		scan_detected.emit()

	move_and_slide()

func _is_being_scanned() -> bool:
	return (
		player_reference
		and player_reference.scanning
		and player_reference.current_scan_target == self
	)

func _should_check_scan() -> bool:
	if _slap_cooldown_remaining > 0.0:
		return false
	if _current_phase == Types.Phase.SCAN_ALERT or _current_phase == Types.Phase.SCAN_CHARGE or _current_phase == Types.Phase.SLAPPING:
		return false
	return _is_being_scanned()

func _player_in_detection_cone() -> bool:
	var forward = -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var dir_to_player = global_position.direction_to(player_reference.global_position)
	dir_to_player.y = 0.0
	dir_to_player = dir_to_player.normalized()
	return rad_to_deg(forward.angle_to(dir_to_player)) <= SCAN_DETECTION_ANGLE

func _update_scan_charge(delta: float) -> void:
	if not player_reference:
		return

	var dir_to_player = global_position.direction_to(player_reference.global_position)
	dir_to_player.y = 0.0
	var target_angle = atan2(-dir_to_player.x, -dir_to_player.z)
	rotation.y = lerp_angle(rotation.y, target_angle, delta * SCAN_TURN_SPEED)
	velocity = -transform.basis.z * SCAN_CHARGE_SPEED * GlobalDifficulty.movement_multiplier()

	if global_position.distance_to(player_reference.global_position) <= SLAP_DISTANCE:
		velocity = Vector3.ZERO
		_ai.start_slap()

func _on_animation_finished() -> void:
	if _current_phase != Types.Phase.SLAPPING:
		return
	slap_triggered.emit()
	_slap_hold_timer.start(SLAP_HOLD_DURATION)

func _on_slap_hold_finished() -> void:
	_slap_cooldown_remaining = SLAP_COOLDOWN / GlobalDifficulty.heat_multiplier
	_ai.end_scan_response()

func _on_slap_triggered() -> void:
	player_reference.receive_slap(global_position)
	map_manager_reference.phone_slap_trigger(global_position)

func _on_ai_transition_to(phase: Types.Phase, state: Types.TransitionState) -> void:
	_current_phase = phase
	match phase:
		Types.Phase.PAUSED:
			velocity = Vector3.ZERO
		Types.Phase.TURNING:
			_target_angle = randf_range(-PI, PI)
			_turn_speed = angle_difference(rotation.y, _target_angle) / state.time
		Types.Phase.MOVING:
			rotation.y = _target_angle
			var wander_speed = randf_range(0.5, 5.0) * GlobalDifficulty.movement_multiplier()
			velocity = -transform.basis.z * wander_speed
		Types.Phase.SCAN_ALERT:
			velocity = Vector3.ZERO
			if scan_alert_audio:
				scan_alert_audio.play()
		Types.Phase.SLAPPING:
			velocity = Vector3.ZERO
