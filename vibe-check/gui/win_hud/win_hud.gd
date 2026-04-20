extends TextureRect


func _on_timer_timeout() -> void:
	SignalBus.start_menu.emit()
