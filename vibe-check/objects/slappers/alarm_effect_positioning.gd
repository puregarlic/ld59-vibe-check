extends PathFollow3D

@onready var player_reference: Player = get_tree().get_first_node_in_group("player")
@export var path: Path3D = null

func _process(delta: float) -> void:
	#progress += delta
	if player_reference:
		var local_point = to_local(player_reference.global_position)
		var closest_offset = path.curve.get_closest_offset(local_point)
		progress = closest_offset
