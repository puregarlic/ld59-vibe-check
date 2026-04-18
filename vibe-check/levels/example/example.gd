extends Node3D

func set_room(room_number: int) -> void:
	# Randomish color based on room_number
	var hue := room_number * 1.13
	hue = hue - int(hue)

	var sat := room_number * 1.57
	sat = sat - int(sat)
	var color := Color.from_hsv(hue, sat, 1.0)
	$Sprite3D.modulate = color

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		SignalBus.pause.emit()
