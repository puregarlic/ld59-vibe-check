extends WorldEnvironment


func _process(delta: float) -> void:
	self.environment.sky.sky_material.sky_top_color += Color(0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, 0)
	self.environment.ambient_light_color += Color(0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, -0.05 * GlobalDifficulty.HEAT_GROWTH_PER_SECOND, 0)
