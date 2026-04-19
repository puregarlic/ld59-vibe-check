class_name Slapper
extends CharacterBody3D

@export var vibe = Types.Vibe.GOOD

var _target_angle: float = 0.0
var _turn_speed: float = 0.0
var _is_turning: bool = false

func _physics_process(delta: float) -> void:
	if _is_turning:
		rotation.y += _turn_speed * delta
	move_and_slide()

func _on_ai_transition_to(phase: Types.Phase, state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED:
			_is_turning = false
			velocity = Vector3.ZERO
		Types.Phase.TURNING:
			_is_turning = true
			_target_angle = randf_range(-PI, PI)
			_turn_speed = angle_difference(rotation.y, _target_angle) / state.time
		Types.Phase.MOVING:
			_is_turning = false
			rotation.y = _target_angle
			var speed = randf_range(0.5, 5.0 * (1.0 / GlobalDifficulty.heat_multiplier))
			velocity = -transform.basis.z * speed
