shader_type canvas_item;

render_mode blend_mix;
uniform sampler2D screentex: hint_screen_texture;
//unifmr sampler2D canvatex:

vec3 rgb2yiq(vec3 rgb) {
	return mat3(vec3(0.299, 0.596, 0.211), vec3(0.587, -0.274, -0.523), vec3(0.114, -0.322, 0.312)) * rgb;
}

vec3 yiq2rgb(vec3 yiq) {
	return mat3(vec3(1.0, 1.0, 1.0), vec3(0.956, -0.272, -1.106), vec3(0.621, -0.647, 1.703)) * yiq;
}
vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 col2 = rgb2hsv(texture(screentex, SCREEN_UV).rgb);
	vec3 col = rgb2hsv(texture(TEXTURE, UV).rgb);
	
	vec3 fcol = vec3(col2.r+0.025, col2.g, col.b);
	
	COLOR.rgb = hsv2rgb(fcol);
	if (col2.b < col.b) {
		discard;
	}
	fcol = vec3(col.r+0.025, col.g, col2.b);
	COLOR.rgb = hsv2rgb(fcol);
	// Called for every pixel the material is visible on.
}
