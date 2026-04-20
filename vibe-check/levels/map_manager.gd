extends Node3D
class_name MapManager

@export var num_bad_slappers: int = 2

var phone = preload("res://phone_slap_stuff/phone.tscn")
@onready var player_reference: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	await get_tree().process_frame
	var spawners := get_tree().get_nodes_in_group("spawner")
	_pending_spawners = spawners.size()
	if _pending_spawners == 0:
		_assign_bad_vibes()
		return
	for spawner in spawners:
		spawner.spawn_complete.connect(_on_spawner_complete.bind(spawner), CONNECT_ONE_SHOT)

var _pending_spawners: int = 0

func _on_spawner_complete(_spawner: Node) -> void:
	_pending_spawners -= 1
	if _pending_spawners <= 0:
		_assign_bad_vibes()

func _assign_bad_vibes() -> void:
	var slappers := get_tree().get_nodes_in_group("slapper")
	slappers.shuffle()
	var count: int = min(num_bad_slappers, slappers.size())
	for i in count:
		var slapper = slappers[i]
		slapper.vibe = Types.Vibe.BAD
		if not slapper.is_in_group("bad"):
			slapper.add_to_group("bad")

func phone_slap_trigger(from_position: Vector3) -> void:
	print("phone spawned")
	var instance = phone.instantiate()
	add_child(instance)
	var spawned_phone = get_child(-1)
	spawned_phone.position = player_reference.global_position + Vector3(0, 2, 0)
	spawned_phone.slap(from_position)
	print(spawned_phone.position)
