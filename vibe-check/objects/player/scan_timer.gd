extends Timer

func _process(delta: float) -> void:
	if is_stopped():
		SignalBus.scan_progress.emit(0.0)
	else:
		SignalBus.scan_progress.emit((%ScanTimer.wait_time - %ScanTimer.time_left) / %ScanTimer.wait_time)
