shader_type canvas_item;

render_mode blend_mix;
uniform sampler2D screentex: hint_screen_texture;
uniform sampler2D vignette: repeat_enable;
//unifmr sampler2D canvatex:
uniform sampler2D uvnoise: repeat_enable;
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
	vec3 col = texture(screentex, SCREEN_UV).rgb;
	
	// yiq
	//vec3 col2 = rgb2yiq(col);
	//vec3 col3 = vec3(1.1, 1.1, 0.9) * col + vec3(-0.1, -0.1, 0.1) * vec3(texture(TEXTURE, UV).rgb);
	//col = mix(col2, col3, col.g);
	//col = yiq2rgb(col);
	vec3 col2 = texture(TEXTURE, UV).rgb;
	col = rgb2hsv(col);
	col2 = rgb2hsv(col2*col2);
	vec2 distort_uv = texture(uvnoise, vec2(UV.x+sin(TIME*0.2) * 0.1, UV.y+cos(TIME*0.3)*-0.565)).xy;
	vec4 vignettecolor = texture(vignette, SCREEN_UV * distort_uv);
	col = hsv2rgb(vec3(col2.r, (col2.g*0.5), 0.5+col.g*0.8));
	COLOR.rgb *= col;
	// Called for every pixel the material is visible on.
}
