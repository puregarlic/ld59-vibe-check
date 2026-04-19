extends AnimatedSprite3D


@onready var player_reference: Player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	var angle_from_player_to_me = rad_to_deg(
		(-transform.basis.z).signed_angle_to(
			global_position.direction_to(player_reference.global_position),
			Vector3.UP
		)
	)	

	var anim_set = get_anim_set_from_angle(angle_from_player_to_me)
	%Label.text = "angle: " + str(angle_from_player_to_me) + "\nanim: " + anim_set
	animation = anim_set
	
func get_anim_set_from_angle(angle):
	var a = abs(angle)
	
	if a <= 22.5:
		return "facing_directly_forward"
	elif a >= 157.5:
		return "facing_directly_backward"
	elif a <= 67.5:
		return "facing_forward_right" if angle > 0 else "facing_forward_left"
	elif a <= 112.5:
		return "facing_directly_right" if angle > 0 else "facing_directly_left"
	else: # 112.5 to 157.5
		return "facing_away_right" if angle > 0 else "facing_away_left"
	
func _on_ai_transition_to(phase: Types.Phase, _state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED:
			frame = 0
			stop()
		Types.Phase.TURNING:
			frame = 0
			stop()
		Types.Phase.MOVING:
			frame = 0
			play()
