extends Node

signal transition_to(phase: Types.Phase, state: Types.TransitionState)

const PAUSED_RANGE := Vector2(6.0, 12.0)
const TURNING_RANGE := Vector2(1.0, 2.0)
const MOVING_RANGE := Vector2(5.0, 15.0)
const SCAN_ALERT_RANGE := Vector2(1.2, 1.6)

var _phase: Types.Phase = Types.Phase.PAUSED
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_advance)
	add_child(_timer)
	_enter(Types.Phase.TURNING)

func on_scan_detected() -> void:
	if _phase == Types.Phase.SCAN_ALERT or _phase == Types.Phase.SCAN_CHARGE or _phase == Types.Phase.SLAPPING:
		return
	_enter(Types.Phase.SCAN_ALERT)

func end_scan_response() -> void:
	_enter(Types.Phase.PAUSED)

func start_slap() -> void:
	_enter(Types.Phase.SLAPPING)

func start_caught() -> void:
	_enter(Types.Phase.CAUGHT)

func _enter(phase: Types.Phase) -> void:
	_phase = phase
	_timer.stop()
	var duration := _duration_for(phase)
	var state := Types.TransitionState.new()
	state.current_phase = phase
	state.time = duration
	transition_to.emit(phase, state)
	if duration > 0.0:
		_timer.start(duration)

func _advance() -> void:
	match _phase:
		Types.Phase.PAUSED:
			_enter(Types.Phase.TURNING)
		Types.Phase.TURNING:
			_enter(Types.Phase.MOVING)
		Types.Phase.MOVING:
			_enter(Types.Phase.PAUSED)
		Types.Phase.SCAN_ALERT:
			_enter(Types.Phase.SCAN_CHARGE)
		Types.Phase.CAUGHT:
			_enter(Types.Phase.CAUGHT)

func _duration_for(phase: Types.Phase) -> float:
	match phase:
		Types.Phase.PAUSED:
			return _scaled(PAUSED_RANGE)
		Types.Phase.TURNING:
			return _scaled(TURNING_RANGE)
		Types.Phase.MOVING:
			return _scaled(MOVING_RANGE)
		Types.Phase.SCAN_ALERT:
			return _scaled(SCAN_ALERT_RANGE)
		_:
			return 0.0

func _scaled(range_vec: Vector2) -> float:
	return randf_range(range_vec.x, range_vec.y) / GlobalDifficulty.heat_multiplier
