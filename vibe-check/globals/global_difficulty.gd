extends Node

const HEAT_GROWTH_PER_SECOND: float = 0.02
const HEAT_MAX: float = 10.0
const MOVEMENT_HEAT_DAMPENING: float = 0.5
const INITIAL_HEAT_MULTIPLER: float = 1.0

var heat_multiplier: float = 1.0

func _ready() -> void:
	heat_multiplier = INITIAL_HEAT_MULTIPLER

func reset() -> void:
	heat_multiplier = INITIAL_HEAT_MULTIPLER

func _process(delta: float) -> void:
	heat_multiplier = minf(heat_multiplier + HEAT_GROWTH_PER_SECOND * delta, HEAT_MAX)

func movement_multiplier() -> float:
	return 1.0 + (heat_multiplier - 1.0) * MOVEMENT_HEAT_DAMPENING
