class_name Types

enum Phase { PAUSED, TURNING, MOVING, SCAN_ALERT, SCAN_CHARGE }
enum Vibe { GOOD, BAD }

class TransitionState:
	var current_phase = Types.Phase.PAUSED
	var time: float = 0.0
