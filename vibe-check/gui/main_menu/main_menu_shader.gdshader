shader_type canvas_item;

uniform sampler2D NOISE_PATTERN;


vec4 hsv_to_rgb(float h, float s, float v, float a){
	//based on
	//https://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
    // So it needs values from 0 to 1
	float r;
	float g;
	float b;

	float i = floor(h*6.0);
	float f = h*6.0 -i;
	float p = v*(1.0-s);
	float q = v*(1.0-f*s);
	float t = v* (1.0-(1.0-f)*s);

	int cond = int(i)%6;

	if (cond == 0){
		r = v; g = t; b = p;
	}
	else if (cond == 1){
		r = q; g = v; b = p;
	}
	else if (cond == 2){
		r = p; g = v; b = t;
	}
	else if (cond == 3){
		r = p; g = q; b = v;
	}
	else if (cond == 4){
		r = t; g = p; b = v;
	}
	else if (cond == 5){
		r = v; g = p; b = q;
	}
	else {
		// THIS SHOULD NEVER HAPPEN
		r = 0.0; g = 0.0; b = 0.0;
	}
	return vec4(r,g,b,a);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec2 offset = vec2(
		mod((UV.x * 0.03) + TIME * 0.003, 1.0),
		mod((UV.y * 0.05) + (cos(TIME + 0.1) * 0.01), 1.0));
	float noise_value = texture(NOISE_PATTERN, offset).x;

	vec2 real_offset = vec2(
		mod(UV.x * pow(noise_value, noise_value + 2.0) + (2.0 * sin(TIME * 0.001)), 1.0),
		mod(UV.y * pow(noise_value, noise_value * 3.0) + (TIME * 0.001), 1.0));
	float noise1_mask = 1.0 - step(0.4, texture(NOISE_PATTERN, real_offset).y);
	float noise1 = texture(NOISE_PATTERN, real_offset).y * noise1_mask;


	vec2 offset2 = vec2(
		mod((UV.x * -0.03) + sin(TIME + 0.3) * 0.02, 1.0),
		mod((UV.y * -0.004) + (TIME * 0.01), 1.0));
	float noise_value2 = texture(NOISE_PATTERN, offset2).x;

	vec2 real_offset2 = vec2(
		mod(UV.x * pow(noise_value2, sin(TIME) * 4.0) + (2.0 * sin(TIME * 0.005)), 1.0),
		mod((UV.y * noise_value2 * 0.00001) + (TIME * 0.001), 1.0));
	float noise2 = texture(NOISE_PATTERN, real_offset).y;


	//COLOR = vec4(clamp(noise1, 0.0, 1.0));
	vec4 noise3 = mix(hsv_to_rgb(noise1 + (TIME * 0.2), 0.4, 0.8, 0.4), hsv_to_rgb(noise2 + (TIME * 0.01), 0.5, 1.0, 0.4), 0.5);
	vec4 gradient = mix(hsv_to_rgb(0.95342, 0.71, 0.92, 1.0), hsv_to_rgb(0.5479, 0.71, 0.92, 1.0), pow(UV.y, 2.0));
	COLOR = mix(gradient, noise3, pow(UV.y, 4.0));
	//COLOR = mix(vec4(vec3(0.0), 1.0), noise3, noise1_mask);
	//COLOR = vec4(vec3(1.0 - step(0.5, noise2)), 1.0);
	//COLOR = vec4(vec3(noise2), 1.0);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
