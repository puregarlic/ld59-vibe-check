extends Node3D
class_name World

var gui : Control

@onready var main_menu_scene : PackedScene = preload("res://gui/main_menu/main_menu.tscn")

@onready var level_scene : PackedScene = preload("res://levels/The Map.tscn")
@onready var room_gui_scene : PackedScene = preload("res://gui/rooms/rooms.tscn")

@onready var pause_menu_scene : PackedScene = preload("res://gui/pause_menu/pause_menu.tscn")

@onready var room_number : int = 0

enum WorldState {MAIN_MENU, ROOMS, PAUSED}
@onready var state : WorldState = WorldState.MAIN_MENU

func _ready() -> void:
	SignalBus.next_room.connect(change_room)
	SignalBus.start_game.connect(instantiate_level)
	SignalBus.start_menu.connect(start_menu)
	SignalBus.pause.connect(pause_menu)
	SignalBus.unpause.connect(unpause)

func start_menu() -> void:
	room_number = 0
	for child in gui.get_children():
		child.queue_free()
	var menu := main_menu_scene.instantiate()
	gui.add_child(menu)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state = WorldState.MAIN_MENU

func pause_menu() -> void:
	for child in gui.get_children():
		child.queue_free()
	var menu := pause_menu_scene.instantiate()
	gui.add_child(menu)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state = WorldState.PAUSED

func unpause() -> void:
	for child in gui.get_children():
		child.queue_free()

	#var room_gui : RoomInterface = room_gui_scene.instantiate()
	#gui.add_child(room_gui)
	#room_gui.set_room_number(room_number)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state = WorldState.ROOMS

func change_room() -> void:
	room_number += 1
	var child = get_child(0)
	child.queue_free()

	instantiate_level()

func instantiate_level() -> void:
	for gui_child in gui.get_children():
		gui_child.queue_free()

	#var room_gui : RoomInterface = room_gui_scene.instantiate()
	#gui.add_child(room_gui)
	#room_gui.set_room_number(room_number)

	var level = level_scene.instantiate()
	#level.set_room(room_number)
	add_child(level)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state = WorldState.ROOMS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and state == WorldState.ROOMS:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
