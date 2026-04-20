class_name Types

enum Phase { PAUSED, TURNING, MOVING, SCAN_ALERT, SCAN_CHARGE, SLAPPING, CAUGHT }
enum Vibe { GOOD, BAD }
enum SlapperVariant {J1, G}

class TransitionState:
	var current_phase = Types.Phase.PAUSED
	var time: float = 0.0
