extends AnimatedSprite3D


@onready var player_reference: Player = get_tree().get_first_node_in_group("player")
@export var animations: Array[SpriteFrames]
@export var slapper: Slapper
var _is_looping: bool = false
var _is_slapping: bool = false

func _ready():
	match slapper.variation:
		Types.SlapperVariant.J1:
			sprite_frames = animations[0]
		Types.SlapperVariant.G:
			sprite_frames = animations[1]

func _process(_delta: float) -> void:
	if _is_slapping:
		return
	_update_directional_animation()

func _update_directional_animation() -> void:
	var slapper_forward = -get_parent().global_transform.basis.z
	slapper_forward.y = 0.0
	slapper_forward = slapper_forward.normalized()

	if not is_instance_valid(player_reference):
		return

	var dir_to_player = global_position.direction_to(player_reference.global_position)
	dir_to_player.y = 0.0
	dir_to_player = dir_to_player.normalized()

	var viewer_angle = rad_to_deg(
		dir_to_player.signed_angle_to(slapper_forward, Vector3.UP)
	)

	var new_anim = get_anim_set_from_angle(viewer_angle)
	if new_anim != animation:
		animation = new_anim
		if _is_looping:
			play()


func get_anim_set_from_angle(angle):
	var a = abs(angle)

	if a <= 22.5:
		return "facing_directly_forward"
	elif a >= 157.5:
		return "facing_directly_away"
	elif a <= 67.5:
		return "facing_forward_right" if angle > 0 else "facing_forward_left"
	elif a <= 112.5:
		return "facing_directly_right" if angle > 0 else "facing_directly_left"
	else: # 112.5 to 157.5
		return "facing_away_right" if angle > 0 else "facing_away_left"

func _on_ai_transition_to(phase: Types.Phase, _state: Types.TransitionState) -> void:
	match phase:
		Types.Phase.PAUSED, Types.Phase.TURNING, Types.Phase.SCAN_ALERT:
			_is_slapping = false
			_is_looping = false
			_update_directional_animation()
			frame = 0
			stop()
		Types.Phase.MOVING, Types.Phase.SCAN_CHARGE:
			_is_slapping = false
			_is_looping = true
			_update_directional_animation()
			frame = 0
			play()
		Types.Phase.SLAPPING:
			_is_slapping = true
			_is_looping = false
			animation = "slap"
			frame = 0
			play()
