extends Control

@export var textures : Array[Texture2D] = [null, null, null, null]
@export var distance_modifier: float = 0.75
@export var visible_duration: float = 5.0

var player : Player = null

var scan_tween : Tween = null

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]
	%Signal.modulate = Color.hex(0xffffff00)
	SignalBus.scan_progress.connect(scan_progress)
	SignalBus.scan_success.connect(scan_success)

func _process(delta: float) -> void:
	if player != null:
		var baddie = get_closest_baddie()
		if baddie != null:
			var forward : Vector3 = -player.global_transform.basis.z
			forward.y = 0
			forward = forward.normalized()

			var target = baddie.global_position - player.global_position
			target.y = 0
			target = target.normalized()

			var strength = forward.dot(target)
			var distance = player.global_position.distance_to(baddie.global_position)
			# Heh
			var strength_max = clamp(2 - (log((distance_modifier * distance) + 10) / log(10)), 0.25, 1.0)

			signal_strength(forward.dot(target) * strength_max)
			#signal_strength(strength_max)


func get_closest_baddie() -> Node:
	var baddies := get_tree().get_nodes_in_group("bad")

	var closest : Node = null
	var closest_distance : float = 0.0
	for baddie in baddies:
		if baddie._current_phase == Types.Phase.CAUGHT:
			continue
		var distance = player.global_position.distance_to(baddie.global_position)
		if closest == null:
			closest = baddie
			closest_distance = distance
		elif closest_distance >= distance:
			closest = baddie
			closest_distance = distance

	return closest

func signal_strength(strength: float) -> void:
	%Signal.texture = textures[round(clamp(strength, 0.0, 1.0) * 3)]

func scan_progress(progress: float) -> void:
	%ProgressBar.value = clamp(progress, 0.0, 1.0)

func scan_success() -> void:
	%Battery.visible = false
	if scan_tween != null and scan_tween.is_running():
		scan_tween.kill()
	%Signal.modulate = Color.hex(0xffffffff)

	scan_tween = get_tree().create_tween()
	scan_tween.tween_property(%Signal, "modulate", Color.hex(0xffffff00), visible_duration)
	scan_tween.tween_callback(low_battery)

func low_battery():
	%Battery.visible = true
