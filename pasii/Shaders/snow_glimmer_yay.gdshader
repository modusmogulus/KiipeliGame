shader_type spatial;
render_mode blend_add;

uniform float seed;
uniform float emission_factor;

void vertex() {
}

float randomiperseesta(float siemen){
	float seed2 = fract(mod(69934.34 * siemen + 48302.9942, 3.0));
	return seed2;
}

float uvr(vec2 uv){
	return randomiperseesta(seed+uv.x+sin(mod(uv.y, 9.8)));
}
void fragment() {
	float lerpednoise = mix(uvr(UV)*uvr(UV), 
		uvr(vec2(UV.x + 0.01, UV.y + 0.01)) *
		uvr(vec2(UV.x * 30.3, UV.y * 0.009)), 0.5);
	ALBEDO = vec3(0.0);
	EMISSION = abs(3.0*vec3(pow(lerpednoise*1.3, 40.0)))*emission_factor;
}
