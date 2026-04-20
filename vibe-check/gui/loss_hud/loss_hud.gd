extends TextureRect

func _ready() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.4)

func _on_timer_timeout() -> void:
	SignalBus.start_game.emit()
