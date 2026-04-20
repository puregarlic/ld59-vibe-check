extends MarginContainer

#[wave amp=20.0 freq=3.0]
#[shake rate=30.0 level=10 connected=0]
#Baddies Remaining:
	#[b]0[/b]
	#[/share]
	#[/wave]

@onready var label := %Text
@onready var stopwatch_label := %Stopwatch
var remaining : int = 0
var elapsed : float = 0.0

func _ready() -> void:
	update_text(remaining, GlobalDifficulty.heat_multiplier)
	update_stopwatch(elapsed)
	SignalBus.baddie_scanned.connect(_on_timer_timeout)
	SignalBus.baddie_killed.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if %Timer.is_stopped():
		%Timer.start()
	elapsed += delta
	update_stopwatch(elapsed)

func update_stopwatch(seconds: float) -> void:
	var minutes := int(seconds) / 60
	var secs := int(seconds) % 60
	var hundredths := int(fmod(seconds, 1.0) * 100.0)
	stopwatch_label.clear()
	stopwatch_label.push_bold()
	stopwatch_label.append_text("%02d:%02d.%02d" % [minutes, secs, hundredths])
	stopwatch_label.pop()

func update_text(remaining: int, difficulty: float):
	var color := Color.WHITE
	label.clear()
	label.append_text("[wave amp=20.0 freq=3.0]")
	label.append_text("[shake rate=30.0 level=%s connected=0]" % (pow(difficulty, 2.0)))
	#label.append_text("[color=%s]" % color)
	label.append_text("Baddies Remaining: ")

	label.push_bold()
	label.append_text("%s" % remaining)
	label.pop()

	label.append_text("[/shake]")
	label.append_text("[/wave]")

func get_remaining_baddies() -> int:
	return get_tree().get_nodes_in_group("bad").size()

func _on_timer_timeout() -> void:
	update_text(get_remaining_baddies(), GlobalDifficulty.heat_multiplier)
