extends AnimatedSprite3D

@export var vibe = Types.Vibe.GOOD
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	var angle_from_player_to_me = rad_to_deg(player_reference.global_position.angle_to(-transform.basis.z))
	var anim_set = get_anim_set_from_angle(angle_from_player_to_me)
	%Label.text = "angle: " + str(angle_from_player_to_me) + "\nanim: " + anim_set
	
func get_anim_set_from_angle(angle):
	if angle <= 45:
		return "facing_directly_forward"
	if angle <= 180 && angle >= 135:
		return "facing_directly_backward"
	if angle >= 90 && angle <= 135:
		return "facing_directly_left"
	if angle >= 45 && angle <= 90:
		return "facing_directly_right"
	
	#if angle_from_player_
	
func _on_ai_transition_to(phase: Types.Phase, state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED:
			pass
		Types.Phase.TURNING:
			pass
		Types.Phase.MOVING:
			pass
