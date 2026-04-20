extends WorldEnvironment

const INITIAL_SKY_TOP_COLOR := Color(0.38400003, 0.5642667, 0.8, 1)
const INITIAL_AMBIENT_LIGHT_COLOR := Color(0, 0, 0, 1)

func _ready() -> void:
	environment.sky.sky_material.sky_top_color = INITIAL_SKY_TOP_COLOR
	environment.ambient_light_color = INITIAL_AMBIENT_LIGHT_COLOR


func _process(delta: float) -> void:
	var lerp_amount = GlobalDifficulty.heat_multiplier / GlobalDifficulty.HEAT_MAX
	self.environment.sky.sky_material.sky_top_color = Color(lerp(INITIAL_SKY_TOP_COLOR.r, 1.0, lerp_amount), lerp(INITIAL_SKY_TOP_COLOR.g, 0.0, lerp_amount), lerp(INITIAL_SKY_TOP_COLOR.b, 0.0, lerp_amount), 0)
	self.environment.ambient_light_color = Color(lerp(INITIAL_AMBIENT_LIGHT_COLOR.r, 1.0, lerp_amount), lerp(INITIAL_AMBIENT_LIGHT_COLOR.g, 0.0, lerp_amount), lerp(INITIAL_AMBIENT_LIGHT_COLOR.b, 0.0, lerp_amount), 0)
