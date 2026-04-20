extends TextureRect
class_name WinHud

func set_time(seconds: float) -> void:
	var minutes := int(seconds) / 60
	var secs := int(seconds) % 60
	var hundredths := int(fmod(seconds, 1.0) * 100.0)
	%Time.clear()
	%Time.push_bold()
	%Time.append_text("Time: %02d:%02d.%02d" % [minutes, secs, hundredths])
	%Time.pop()

func _on_timer_timeout() -> void:
	SignalBus.start_menu.emit()
