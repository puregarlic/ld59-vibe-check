extends WorldEnvironment

const INITIAL_SKY_TOP_COLOR := Color(0.38400003, 0.5642667, 0.8, 1)
const INITIAL_AMBIENT_LIGHT_COLOR := Color(0, 0, 0, 1)


func _ready() -> void:
	environment.sky.sky_material.sky_top_color = INITIAL_SKY_TOP_COLOR
	environment.ambient_light_color = INITIAL_AMBIENT_LIGHT_COLOR


func _process(delta: float) -> void:
	self.environment.sky.sky_material.sky_top_color += Color(0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, 0)
	self.environment.ambient_light_color += Color(0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, 0)
