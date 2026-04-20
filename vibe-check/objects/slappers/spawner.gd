extends Node3D

signal spawn_complete

@export var min_slap: int = 1
@export var max_slap: int = 2
@export var spawn_radius: float = 5.0
@export var max_placement_attempts: int = 20
@export var min_separation: float = 1.2
@export var ground_probe_height: float = 10.0
@export var ground_probe_depth: float = 30.0
@export var max_ground_above_spawner: float = 0.5

const SLAPPER_HEIGHT: float = 1.7
const SLAPPER_RADIUS: float = 0.5
const GROUND_CLEARANCE: float = 0.4
const PROBE_HEIGHT_SHRINK: float = 0.4
const PROBE_RADIUS_SHRINK: float = 0.15

@onready var slapper_resource = preload("res://objects/slappers/slapper.tscn")

func _ready() -> void:
	add_to_group("spawner")
	# CSG collision bakes on a deferred call after _ready; wait a few frames so it's live.
	for _i in 3:
		await get_tree().physics_frame
	_run_diagnostic()
	_spawn_slappers()
	spawn_complete.emit()

func _run_diagnostic() -> void:
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * ground_probe_height
	var to := global_position + Vector3.DOWN * ground_probe_depth
	var ray := PhysicsRayQueryParameters3D.create(from, to)
	var hit := space.intersect_ray(ray)
	if hit.is_empty():
		push_warning("[Spawner] %s at %s: no collider found directly below (from %s to %s)." % [name, global_position, from, to])

func _spawn_slappers() -> void:
	var num_slappers: int = randi_range(min_slap, max_slap)
	var space := get_world_3d().direct_space_state
	var placed: Array[Vector3] = []
	var spawned: int = 0
	for _i in num_slappers:
		var pos = _find_valid_position(space, placed)
		if pos == null:
			continue
		var slapper := slapper_resource.instantiate()
		if randi_range(0, 1) == 0:
			slapper.variation = Types.SlapperVariant.J1
		else:
			slapper.variation = Types.SlapperVariant.G
		get_tree().get_first_node_in_group("world").add_child(slapper)
		slapper.global_position = pos
		placed.append(pos)
		spawned += 1

func _find_valid_position(space: PhysicsDirectSpaceState3D, placed: Array[Vector3]) -> Variant:
	var shape := CapsuleShape3D.new()
	shape.height = SLAPPER_HEIGHT - PROBE_HEIGHT_SHRINK
	shape.radius = SLAPPER_RADIUS - PROBE_RADIUS_SHRINK
	var ray_fails: int = 0
	var separation_fails: int = 0
	var overlap_fails: int = 0
	var too_high_fails: int = 0
	for _attempt in max_placement_attempts:
		var angle := randf_range(0.0, TAU)
		var r: float = sqrt(randf()) * spawn_radius
		var xz := Vector2(cos(angle) * r, sin(angle) * r)
		var from := global_position + Vector3(xz.x, ground_probe_height, xz.y)
		var to := global_position + Vector3(xz.x, -ground_probe_depth, xz.y)
		var ray := PhysicsRayQueryParameters3D.create(from, to)
		var hit := space.intersect_ray(ray)
		if hit.is_empty():
			ray_fails += 1
			continue
		var ground_y: float = hit.position.y
		if ground_y > global_position.y + max_ground_above_spawner:
			too_high_fails += 1
			continue
		var spawn_pos: Vector3 = hit.position + Vector3(0.0, SLAPPER_HEIGHT * 0.5 + GROUND_CLEARANCE, 0.0)
		var too_close := false
		for p in placed:
			if p.distance_to(spawn_pos) < min_separation:
				too_close = true
				break
		if too_close:
			separation_fails += 1
			continue
		var shape_query := PhysicsShapeQueryParameters3D.new()
		shape_query.shape = shape
		shape_query.transform = Transform3D(Basis(), spawn_pos)
		if not space.intersect_shape(shape_query, 1).is_empty():
			overlap_fails += 1
			continue
		return spawn_pos
	return null
