// Adapted from YouTube tutorial:
// Ben Cloward - Blur and Sharpen Filter - Shader Graph Basics - Episode 51

shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
//Blur Sharp
uniform float blur_sharp: hint_range(-200.0, 200.0, 0.1) = 0.0;
uniform float pixel: hint_range(1.0, 5.0, 1.0) = 1.0;

void fragment() {
	// Screen Coordinates
	vec2 coord = (1.0 / FRAGCOORD.xy) * SCREEN_UV;
	// Screen Sample
	vec3 screen = texture(screen_tex, SCREEN_UV).rgb;
	//Blur Sharp Sample
	vec3 N = texture(screen_tex, SCREEN_UV + (coord * (vec2(0.0, pixel)))).rgb;
	vec3 S = texture(screen_tex, SCREEN_UV + (coord * (vec2(0.0, -pixel)))).rgb;
	vec3 EF = texture(screen_tex, SCREEN_UV + (coord * (vec2(pixel, 0.0)))).rgb;
	vec3 W = texture(screen_tex, SCREEN_UV + (coord * (vec2(-pixel,0.0)))).rgb;
	//Combined Samples
	vec3 combine_sample = ((N + S + EF + W) / 4.0) * 0.7;
	vec3 blur_screen = clamp((screen * 0.3) + combine_sample, 0.0, 1.0);
	//Final COLOR
	vec3 mix_blur_sharp = mix(screen, blur_screen, blur_sharp);
	COLOR.rgb = mix_blur_sharp ;
}