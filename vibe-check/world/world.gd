extends Node3D
class_name World

var gui : Control

@onready var main_menu_scene : PackedScene = preload("res://gui/main_menu/main_menu.tscn")

@onready var level_scene : PackedScene = preload("res://levels/The Map.tscn")
@onready var main_hud_scene : PackedScene = preload("res://gui/main_hud/main_hud.tscn")
@onready var win_hud_scene : PackedScene = preload("res://gui/win_hud/win_hud.tscn")
@onready var loss_hud_scene : PackedScene = preload("res://gui/loss_hud/loss_hud.tscn")

@onready var pause_menu_scene : PackedScene = preload("res://gui/pause_menu/pause_menu.tscn")


@onready var room_number : int = 0

enum WorldState {MAIN_MENU, ROOMS, PAUSED}
@onready var state : WorldState = WorldState.MAIN_MENU

var baddies := []

@onready var main_menu_stream = preload("res://sfx/music/Vibe Check Menu.wav")
@onready var level_stream = preload("res://sfx/music/Vibe Check Menu.wav")
@onready var tutorial_stream = preload("res://sfx/music/Vibe Check Tutorial.wav")

func _ready() -> void:
	_setup_echo_bus()
	$VoiceAudio.bus = &"Echo"
	SignalBus.start_game.connect(instantiate_level)
	SignalBus.start_menu.connect(start_menu)
	SignalBus.pause.connect(pause_menu)
	SignalBus.unpause.connect(unpause)
	SignalBus.baddie_scanned.connect(baddie_scanned)
	SignalBus.failed.connect(loss)
	SignalBus.baddies_spawned.connect(get_baddies)

func _setup_echo_bus() -> void:
	if AudioServer.get_bus_index("Echo") != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, "Echo")
	AudioServer.set_bus_send(idx, "Master")
	var delay := AudioEffectDelay.new()
	delay.tap1_delay_ms = 280.0
	delay.tap1_level_db = -8.0
	delay.tap2_active = true
	delay.tap2_delay_ms = 560.0
	delay.tap2_level_db = -16.0
	AudioServer.add_bus_effect(idx, delay)

func get_baddies():
	baddies = get_tree().get_nodes_in_group("bad")
	print(baddies.size())

func baddie_scanned(baddie: Slapper) -> void:
	var i := baddies.find(baddie)
	print(baddies.size())
	if i >= 0:
		baddies.remove_at(i)
		print("Removed baddie: %s" % baddies.size())
		if baddies.is_empty():
			win()

func win():
	$Music.stream_paused = true
	$VoiceAudio.stream = VoicePools.SUCCESS
	$VoiceAudio.play()
	for child in gui.get_children():
		child.queue_free()
	var win_hud = win_hud_scene.instantiate()
	gui.add_child(win_hud)

func loss():
	GlobalDifficulty.reset()
	$Music.stream_paused = true
	$VoiceAudio.stream = VoicePools.FAILURE
	$VoiceAudio.play()
	for child in gui.get_children():
		child.queue_free()
	var loss_hud = loss_hud_scene.instantiate()
	gui.add_child(loss_hud)

func start_menu() -> void:
	room_number = 0
	for child in gui.get_children():
		child.queue_free()
	var menu := main_menu_scene.instantiate()
	gui.add_child(menu)

	for child in get_children():
		if child.name != "VoiceAudio" and child.name != "Music":
			child.queue_free()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state = WorldState.MAIN_MENU
	$Music.stream = main_menu_stream
	$Music.play()

func pause_menu() -> void:
	for child in gui.get_children():
		child.queue_free()
	var menu := pause_menu_scene.instantiate()
	gui.add_child(menu)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state = WorldState.PAUSED
	$Music.stream_paused = true

func unpause() -> void:
	for child in gui.get_children():
		child.queue_free()

	#var room_gui : RoomInterface = room_gui_scene.instantiate()
	#gui.add_child(room_gui)
	#room_gui.set_room_number(room_number)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state = WorldState.ROOMS
	$Music.stream_paused = false

func instantiate_level() -> void:
	for gui_child in gui.get_children():
		gui_child.queue_free()

	for child in get_children():
		if child == $VoiceAudio or child == $Music:
			continue
		child.queue_free()
		await child.tree_exited

	var main_hud := main_hud_scene.instantiate()
	gui.add_child(main_hud)

	var level = level_scene.instantiate()
	add_child(level)

	$VoiceAudio.stream = VoicePools.FIND_THEM
	$VoiceAudio.play()

	# TODO swap the stream to level music -- atm its the main menu theme
	$Music.stream = level_stream
	$Music.play()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state = WorldState.ROOMS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and state == WorldState.ROOMS:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
