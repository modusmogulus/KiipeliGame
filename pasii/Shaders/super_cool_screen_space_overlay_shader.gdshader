shader_type spatial;
render_mode cull_back, unshaded, blend_mix, alpha_to_coverage, depth_test_disabled;

varying vec3 real_normal;
varying vec3 world_normal;
uniform sampler2D screentex : hint_screen_texture;
uniform sampler2D screendepth : hint_depth_texture;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

uniform sampler2D uvremap_texture : source_color, hint_default_black;
uniform sampler2D albedo_texture : hint_default_white;
uniform float intensity = 0.0;
uniform float size = 1.0;
uniform float saturation = 1.0;
vec2 generate_matcap_uv(vec3 _normal, vec3 _node_position_view) {
	vec3 cross_space = cross(normalize(_node_position_view), _normal); // cross products the normal with it's base position
	vec2 mat_space = vec2(cross_space.y * 1.0, cross_space.x); // converts to a Vec2 UV, having to switch x and y
	mat_space *= vec2(-0.5, -0.5); // modifies the mat space's size to fit into uv coords, & flips it
	mat_space += vec2(0.5, 0.5); // transforms the mat space into uv coords
	return mat_space; // export the final uv's
}

void vertex() {
	real_normal = (MAIN_CAM_INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz * 0.1;
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
void fragment() {
	vec2 screenuv = SCREEN_UV;
	vec2 uvA = UV;
	float depth = textureLod(screendepth, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	world_normal = textureLod(normal_roughness_texture, screenuv, 0.8).xyz;
	vec4 uvremaplayer = texture(uvremap_texture, generate_matcap_uv(vec3(world_normal.x*sin(TIME), world_normal.y+cos(TIME), pixel_position.z * size), pixel_position)) ;
	vec4 uvremaplayerinv = texture(uvremap_texture, generate_matcap_uv(vec3(world_normal.x*cos(TIME), world_normal.y+sin(TIME), pixel_position.z * size), pixel_position)) ;
	vec4 mappedtexture = texture(albedo_texture, uvremaplayer.xy+uvremaplayerinv.yz);
	vec3 col = texture(screentex, mix(screenuv, uvremaplayer.rg, intensity*intensity)).rgb;
	col = rgb2hsv(col);
	col.y += saturation*intensity;
	col.x = mix(col.x, rgb2hsv(mappedtexture.xyz).x + sin(TIME), intensity);
	col = hsv2rgb(col);
	//ALPHA = mappedtexture.r;
	ALBEDO = col;
}

//void light() {
//}
