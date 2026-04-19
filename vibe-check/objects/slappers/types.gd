class_name Types

enum Phase { PAUSED, TURNING, MOVING }
enum Vibe { GOOD, BAD }

class TransitionState:
	var current_phase = Types.Phase.PAUSED
	var time = null
	var time_state = TransitionTimeState.new()

class TransitionTimeState:
	var delay_range_min = null
	var delay_range_max = null
