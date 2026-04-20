extends MarginContainer

#[wave amp=20.0 freq=3.0]
#[shake rate=30.0 level=10 connected=0]
#Baddies Remaining:
	#[b]0[/b]
	#[/share]
	#[/wave]

@onready var label := %Text
var remaining : int = 0

func _ready() -> void:
	update_text(remaining, GlobalDifficulty.heat_multiplier)
	SignalBus.baddie_scanned.connect(_on_timer_timeout)
	SignalBus.baddie_killed.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if %Timer.is_stopped():
		%Timer.start()

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
