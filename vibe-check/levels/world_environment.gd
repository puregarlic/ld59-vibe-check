extends WorldEnvironment

const reddening_rate = 0.005

@onready var initial_sky_color : Color = self.environment.sky.sky_material.sky_top_color
@onready var initial_ambient_light_color : Color = self.environment.ambient_light_color


func _process(delta: float) -> void:
	var lerp_amount = GlobalDifficulty.heat_multiplier / GlobalDifficulty.HEAT_MAX
	self.environment.sky.sky_material.sky_top_color = Color(lerp(initial_sky_color.r, 1.0, lerp_amount), lerp(initial_sky_color.g, 0.0, lerp_amount), lerp(initial_sky_color.b, 0.0, lerp_amount), 0)
	self.environment.ambient_light_color = Color(lerp(initial_ambient_light_color.r, 1.0, lerp_amount), lerp(initial_ambient_light_color.g, 0.0, lerp_amount), lerp(initial_ambient_light_color.b, 0.0, lerp_amount), 0)
