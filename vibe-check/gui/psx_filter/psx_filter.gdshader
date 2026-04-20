shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 render_resolution = vec2(320.0, 180.0);
uniform int color_levels : hint_range(2, 64) = 32;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.9;

const float BAYER4[16] = float[16](
	 0.0,  8.0,  2.0, 10.0,
	12.0,  4.0, 14.0,  6.0,
	 3.0, 11.0,  1.0,  9.0,
	15.0,  7.0, 13.0,  5.0
);

void fragment() {
	vec2 uv = floor(SCREEN_UV * render_resolution) / render_resolution;
	vec3 col = texture(screen_tex, uv).rgb;

	int x = int(mod(FRAGCOORD.x, 4.0));
	int y = int(mod(FRAGCOORD.y, 4.0));
	float bayer = BAYER4[y * 4 + x] / 16.0 - 0.5;

	float levels = float(color_levels) - 1.0;
	col += bayer * dither_strength / levels;
	col = floor(clamp(col, 0.0, 1.0) * levels + 0.5) / levels;

	COLOR = vec4(col, 1.0);
}
