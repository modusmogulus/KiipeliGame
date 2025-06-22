/*
	Original
	MatCap Shader by Firerabbit
	MIT License
*/
/*
	Edited to include hue shift and vertex lighting by
	Modusmogulus
	
*/

shader_type spatial;

//render_mode unshaded;
render_mode vertex_lighting, cull_back, depth_test_disabled;
uniform sampler2D matcap : source_color, hint_default_black;
uniform float matcappiness : hint_range(0.0,1.0) = 1.0;
uniform vec4 texture_colorize : source_color = vec4(1.0);
uniform sampler2D albedo_texture : hint_default_transparent;
uniform float vertex_shadow_strength : hint_range(0.0, 1.0);
uniform float matcap_hue_shift: hint_range(0.0, 1.0) = 0.0;


vec3 shift_hue(in vec3 color, in float shift) {
	//made by Benmo under CC0
	//https://godotshaders.com/shader/hue-shift/
	vec3 gray = vec3(0.57735);
	vec3 projection = gray * dot(gray, color);
	vec3 U = color - projection;
	vec3 V = cross(gray, U);
	vec3 shifted = U * cos(shift * 2.0 * PI) + V * sin(shift * 2.0 * PI) + projection;
	return shifted;
}

void fragment() {
	
	vec2 uv = UV;
	vec2 matcap_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	vec3 alb1 = texture_colorize.rgb;
	vec3 mctex = texture(matcap, matcap_uv).rgb;
	mctex = shift_hue(mctex, matcap_hue_shift);
	vec4 t2 = texture(albedo_texture, UV);
	alb1 = mix(alb1.rgb, t2.rgb,  t2.a*0.5);
	alb1 *= mix(vec3(1.0), mctex, matcappiness);
	ALBEDO = alb1;
	EMISSION = vec3(alb1.rgb * (1.0-vertex_shadow_strength));
}
