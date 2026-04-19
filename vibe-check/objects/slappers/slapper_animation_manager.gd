extends AnimatedSprite3D

@onready var player_reference: Player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	var angle_from_player_to_me = player_reference.global_position.angle_to(global_position)
	%Label.text = "angle: " + str(angle_from_player_to_me)
	
func _on_ai_transition_to(phase: Types.Phase, state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED:
			pass
		Types.Phase.TURNING:
			pass
		Types.Phase.MOVING:
			pass
