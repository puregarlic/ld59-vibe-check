extends Node

signal transition_to(phase, transition_time)
var transition_state = Types.TransitionState.new()

func _ready() -> void:
	transition()
	
func transition():
	match transition_state.current_phase:
		Types.Phase.PAUSED:
			transition_state.current_phase = Types.Phase.TURNING
		Types.Phase.TURNING:
			transition_state.current_phase = Types.Phase.MOVING
		Types.Phase.MOVING:
			transition_state.current_phase = Types.Phase.PAUSED
	
	set_state()
	set_transition_time()
	transition_to.emit(transition_state.current_phase, transition_state)

func set_state():
	match transition_state.current_phase:
		Types.Phase.PAUSED:
			transition_state.time_state.delay_range_min = 6.0
			transition_state.time_state.delay_range_max = 12.0
		Types.Phase.TURNING:
			transition_state.time_state.delay_range_min = 1.5
			transition_state.time_state.delay_range_max = 4.0
		Types.Phase.MOVING:
			transition_state.time_state.delay_range_min = 5.0
			transition_state.time_state.delay_range_max = 15.0
			
func set_transition_time():
	transition_state.time = randf_range(
		transition_state.time_state.delay_range_min * GlobalDifficulty.heat_multiplier,
		transition_state.time_state.delay_range_max * GlobalDifficulty.heat_multiplier
	)
	
	get_tree().create_timer(transition_state.time).timeout.connect(transition)
