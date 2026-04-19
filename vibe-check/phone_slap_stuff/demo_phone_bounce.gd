extends Node3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'ui_cancel'):
		#get_window().gui_release_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_WM_CLOSE_REQUEST:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.slap(%StaticBody3DSlapper)
