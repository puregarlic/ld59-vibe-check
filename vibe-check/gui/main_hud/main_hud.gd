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

var guide : bool = false
var guide_tween : Tween

func _ready() -> void:
	update_text(remaining, GlobalDifficulty.heat_multiplier)
	update_stopwatch(elapsed)
	SignalBus.baddies_spawned.connect(_on_baddies_spawned)
	SignalBus.baddie_killed.connect(_on_baddie_killed)

func _process(delta: float) -> void:
	if %Timer.is_stopped():
		%Timer.start()
	elapsed += delta
	update_stopwatch(elapsed)

	if Input.is_action_pressed("guide") and guide == false:
		show_guide()

	if not Input.is_action_pressed("guide") and guide == true:
		hide_guide()

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

func _on_baddies_spawned() -> void:
	remaining = get_tree().get_nodes_in_group("bad").size()
	update_text(remaining, GlobalDifficulty.heat_multiplier)

func _on_baddie_killed() -> void:
	remaining -= 1
	update_text(remaining, GlobalDifficulty.heat_multiplier)

func _on_prompt_timer_timeout() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(%Prompt, "modulate", Color(1.0, 1.0, 1.0, 0.0), 3.0)

func show_guide() -> void:
	SignalBus.left_hand_visibility.emit(false)
	if guide_tween:
		guide_tween.kill()
	guide_tween = get_tree().create_tween()
	guide_tween.tween_property(%Guide, "position", Vector2(0.0, 0.0), 0.25)
	guide = true

func hide_guide() -> void:
	if guide_tween:
		guide_tween.kill()
	guide_tween = get_tree().create_tween()
	guide_tween.tween_property(%Guide, "position", Vector2(-2000.0, 0.0), 0.25)
	guide_tween.tween_callback(SignalBus.left_hand_visibility.emit.bind(true))
	guide = false
