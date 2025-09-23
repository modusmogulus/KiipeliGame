shader_type spatial;
render_mode unshaded, depth_test_disabled;
uniform sampler2D dtex : hint_depth_texture;
uniform sampler2D screentex : hint_screen_texture;
uniform sampler2D noise : hint_default_black;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noiscol = texture(noise, vec2(1.0)-vec2(SCREEN_UV.x - sin(SCREEN_UV.y+TIME*0.1)*0.01, SCREEN_UV.y));
	float dp = clamp(0.5-(texture(dtex, SCREEN_UV).x) * 800.0, 0.0, 1.0);
	vec2 m_uv = mix(SCREEN_UV, noiscol.xy, dp);
	ALBEDO = texture(screentex, m_uv).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
