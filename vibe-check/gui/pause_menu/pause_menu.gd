extends TextureRect


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	SignalBus.unpause.emit()


func _on_main_menu_pressed() -> void:
	SignalBus.start_menu.emit()
