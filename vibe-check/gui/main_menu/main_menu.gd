extends TextureRect

func _on_play_pressed() -> void:
	SignalBus.start_game.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
