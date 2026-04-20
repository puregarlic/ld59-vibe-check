extends Timer

var _reset_countdown: float = 0.0
var _last_progress: float = 0.0
var _progress_start: float = 0.0

func force_reset() -> void:
	_reset_countdown = 0.0
	_last_progress = 0.0
	_progress_start = 0.0

func _process(delta: float) -> void:
	if is_stopped():
		if _reset_countdown > 0.0:
			_reset_countdown -= delta
			SignalBus.scan_progress.emit(_last_progress)
		else:
			_last_progress = 0.0
			SignalBus.scan_progress.emit(0.0)
	else:
		_reset_countdown = 1.5
		var relative := (wait_time - time_left) / wait_time if wait_time > 0.0 else 1.0
		_last_progress = _progress_start + relative * (1.0 - _progress_start)
		SignalBus.scan_progress.emit(_last_progress)
