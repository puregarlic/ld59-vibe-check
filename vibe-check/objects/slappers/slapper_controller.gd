class_name Slapper
extends CharacterBody3D

signal scan_detected
signal slap_triggered

@export var vibe = Types.Vibe.GOOD
@export var scan_alert_audio: AudioStreamPlayer3D
@export var scan_alert_visual: Sprite3D
@export var pre_slap_audio: AudioStreamPlayer3D
@export var slap_impact_audio: AudioStreamPlayer3D

@onready var _ai: Node = $AI
@onready var _animated_sprite: AnimatedSprite3D = $"Animated Sprite"
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")
@onready var map_manager_reference: MapManager = get_tree().get_first_node_in_group("map_manager")
@onready var variation : Types.SlapperVariant = Types.SlapperVariant.J1

var _current_phase: Types.Phase = Types.Phase.PAUSED
var _target_angle: float = 0.0
var _turn_speed: float = 0.0
var _slap_cooldown_remaining: float = 0.0
var _slap_hold_timer: Timer

const SCAN_DETECTION_ANGLE: float = 112.5
const SCAN_CHARGE_SPEED: float = 8.0
const SCAN_TURN_SPEED: float = 5.0
const SLAP_DISTANCE: float = 2.0
const SLAP_COOLDOWN: float = 10.0
const SLAP_HOLD_DURATION: float = 0.5
const EDGE_PROBE_DISTANCE: float = 1.5
const EDGE_PROBE_DEPTH: float = 3.0
const SPAWN_GRAVITY_DURATION: float = 1.0
const FALL_DESPAWN_DURATION: float = 5.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _gravity_active: bool = true
var _spawn_grace_remaining: float = SPAWN_GRAVITY_DURATION
var _off_floor_time: float = 0.0

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
	add_to_group("slapper")
	if vibe == Types.Vibe.BAD:
		add_to_group("bad")

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

	if is_on_floor():
		_gravity_active = false
		_off_floor_time = 0.0
	else:
		_off_floor_time += delta
		if _off_floor_time > FALL_DESPAWN_DURATION:
			queue_free()
			return
		if _gravity_active:
			_spawn_grace_remaining -= delta
			if _spawn_grace_remaining <= 0.0:
				_gravity_active = false

	if _gravity_active:
		velocity.y -= _gravity * delta
	else:
		velocity.y = 0.0

	if not _gravity_active and _edge_ahead():
		if _current_phase == Types.Phase.MOVING:
			_redirect_from_edge()
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

func _edge_ahead() -> bool:
	var horizontal = Vector3(velocity.x, 0.0, velocity.z)
	if horizontal.length_squared() < 0.01:
		return false
	return not _ground_at(global_position + horizontal.normalized() * EDGE_PROBE_DISTANCE)

func _ground_at(point: Vector3) -> bool:
	var from = point + Vector3.UP * 0.1
	var to = point + Vector3.DOWN * EDGE_PROBE_DEPTH
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self.get_rid()]
	return not space.intersect_ray(query).is_empty()

func _redirect_from_edge() -> void:
	var speed = Vector3(velocity.x, 0.0, velocity.z).length()
	if speed < 0.01:
		speed = 1.0 * GlobalDifficulty.movement_multiplier()
	for i in range(8):
		var candidate_angle = randf_range(-PI, PI)
		var forward = Vector3(-sin(candidate_angle), 0.0, -cos(candidate_angle))
		if _ground_at(global_position + forward * EDGE_PROBE_DISTANCE):
			rotation.y = candidate_angle
			velocity = forward * speed
			return
	rotation.y += PI
	velocity = Vector3(-velocity.x, 0.0, -velocity.z)

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
	if slap_impact_audio:
		slap_impact_audio.stream = VoicePools.SLAP_IMPACT
		slap_impact_audio.play()
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
				scan_alert_audio.stream = VoicePools.random_pick(VoicePools.HUH)
				scan_alert_audio.play()
				scan_alert_visual.visible = true
		Types.Phase.SLAPPING:
			velocity = Vector3.ZERO
			if pre_slap_audio:
				pre_slap_audio.stream = VoicePools.random_pick(VoicePools.PRE_SLAP)
				pre_slap_audio.play()


func _on_audio_stream_player_3d_finished() -> void:
	scan_alert_visual.visible = false

func caught() -> void:
	_ai.start_caught()
