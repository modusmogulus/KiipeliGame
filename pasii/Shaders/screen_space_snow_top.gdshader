shader_type spatial;
render_mode unshaded, cull_back, blend_mix, alpha_to_coverage;

varying vec3 real_normal;
varying vec3 world_normal;
uniform sampler2D screentex : hint_screen_texture;
uniform sampler2D screendepth : hint_depth_texture;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

uniform sampler2D matcap : source_color, hint_default_black;
uniform sampler2D albedo_texture : hint_default_white;
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

void fragment() {
	vec2 screenuv = SCREEN_UV;
	vec2 uvA = UV;
	float depth = textureLod(screendepth, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	world_normal = textureLod(normal_roughness_texture, screenuv, 0.8).xyz;
	vec4 matcaplayer = texture(matcap, generate_matcap_uv(vec3(world_normal.x, world_normal.y, pixel_position.z), pixel_position)) ;
	vec4 mappedtexture = texture(albedo_texture, matcaplayer.xy);
	ALBEDO = matcaplayer.rgb;
	ALPHA = matcaplayer.a;
}

//void light() {
//}
