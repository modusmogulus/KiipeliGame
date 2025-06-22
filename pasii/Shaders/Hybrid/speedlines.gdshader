shader_type canvas_item;
render_mode blend_mix;

uniform vec2 center = vec2(0.5, 0.5);
uniform sampler2D noise;
uniform float sample_radius: hint_range(0.0, 1.0) = 0.5;
uniform vec4 line_color;
uniform float center_radius: hint_range(0.0, 1.0) = 0.5;

const float pi = 3.14159265359;

void fragment() {
	vec2 dist = UV - center;
	float angle = atan(dist.y / dist.x);
	vec2 sample = vec2(sample_radius * cos(angle+sin(TIME*69.0)), sample_radius * sin(angle-sin(TIME*0.3)));
	float noise_value = texture(noise, sample).r;
	vec4 color = mix(line_color, vec4(0.0), noise_value);
	color = mix(color, vec4(color.xyz, 0.0), clamp(1.0 - length(dist) - center_radius, 0.0, 1.0));
	COLOR.rgb = color.rgb;
}