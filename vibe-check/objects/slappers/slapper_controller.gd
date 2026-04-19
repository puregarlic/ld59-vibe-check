class_name Slapper
extends CharacterBody3D

@export var vibe = Types.Vibe.GOOD

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_ai_transition_to(phase: Types.Phase, state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED:
			pass
		Types.Phase.TURNING:
			pass
		Types.Phase.MOVING:
			pass
