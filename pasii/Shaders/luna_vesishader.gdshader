shader_type spatial;
render_mode blend_mix, depth_draw_opaque, fog_disabled, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled, unshaded;

uniform vec4 albedo : source_color;
uniform float water_fog_exponent: hint_range(-4.0, 4.0);
uniform vec4 glimmer_color : source_color;
uniform vec4 fog_color : source_color;
uniform float water_fog: hint_range(-5.0, 5.0);

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float point_size : hint_range(0.1, 128.0, 0.1);
uniform float speed : hint_range(-1.0, 1.0);
uniform float flow_speed : hint_range(-1.0, 1.0);
uniform float glimmer_strength : hint_range(-0.5, 100.0);
uniform float shore_strength : hint_range(-0.5, 2.0);
uniform vec3 shorecol : source_color;

uniform float refraction : hint_range(-1.5, 1.5);
uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable;
uniform sampler2D distort_tex : repeat_enable;
uniform sampler2D glimmer_tex : repeat_enable;
uniform sampler2D depth_tex : hint_depth_texture;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform float oiliness : hint_range(0.0, 0.2);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec2 water_uv_A = UV;
	vec2 screen_uv = SCREEN_UV;
	vec3 rtex = texture(distort_tex, vec2(base_uv.x + sin(-TIME*0.6*flow_speed), base_uv.y + TIME*flow_speed)).xyz;
	vec3 rtex2 = texture(distort_tex, vec2(base_uv.x + cos(TIME*speed-0.3), base_uv.y + -TIME*speed*1.7)).xyz;
	vec3 gtex = texture(glimmer_tex, vec2(rtex.r*0.02 * rtex2.b*0.01, rtex.x*0.1*rtex2.y*0.52)).xyz;
	float slice = 0.5;//sin(TIME*20.0)*0.2+0.25;
	//rtex = clamp(rtex, -slice, slice)*1.0;
	//slice = 0.5;
	//rtex2 = clamp(rtex2, -slice, slice)*1.0;
	screen_uv = SCREEN_UV-(rtex.xy*refraction*rtex2.xy*0.015);

	float depth = texture(depth_tex, screen_uv, 0.2).r;
  	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float vertical_depth = log(vertex_y - depth_texture_y) / water_fog;
	float shore = clamp(0.6-(4.0 * vertical_depth - 0.1), 0.0, 1.0);
	shore = step(clamp(shore-(rtex.x*1.05)*1.0, 0.0, 1.0), 0.1)*-1.0+1.0;
	vec4 dtex = clamp(textureLod(depth_tex, SCREEN_UV, 1.0)*-water_fog+1.0, 0.0, 0.5);
	dtex = clamp(dtex*vertical_depth, 0.0, 1.0);
	dtex = vec4(pow(dtex.x, water_fog_exponent*0.5), pow(dtex.x, water_fog_exponent), pow(dtex.x, water_fog_exponent*1.1), pow(dtex.x, water_fog_exponent));
	dtex = clamp(dtex, 0.0, 1.0);

	//dtex = vec4(pow(dtex.x, 4.0), pow(dtex.x, 2.0), pow(dtex.x, 1.0), pow(dtex.a, 2.0));
	//screen_uv = vec2(screen_uv.x + (rtex.x*0.6 + sin(TIME*0.95*speed)*0.05), screen_uv.y + (rtex.y*(1.9*sin(TIME)) + (rtex.y * cos(TIME*0.173)*speed))*0.05);
	screen_uv = SCREEN_UV+(rtex.xy*refraction*(dtex.r*dtex.r))*(rtex2.xy);


	//screen_uv = SCREEN_UV - (-refraction + screen_uv * refraction);
	float _stexr = texture(screen_tex, screen_uv+vec2(oiliness, 0.0)).x;
	float _stexg = texture(screen_tex, screen_uv+vec2(0.0, 0.0)).y;
	float _stexb = texture(screen_tex, screen_uv+vec2(-oiliness, 0.0)).z;
	vec3 stex = clamp(vec3(_stexr, _stexg, _stexb), 0.0, 1.0);
	//stex = vec3(dtex.r, 0.0, 0.0);
	float _ov = clamp((gtex.x  * 0.1 * (dtex.x*0.55)-0.01), 0.0, 1.0)*glimmer_strength;

	vec3 otex = vec3(0.0, _ov*50.0, _ov);
	otex += (shore*shore_strength*shorecol);
	vec4 albedo_tex = vec4(mix(stex, fog_color.xyz, clamp((dtex.xyz)*sqrt(2.0), 0.0, 1.0)), 1.0);
	//vec4 albedo_tex = vec4(stex - clamp((dtex.r*dtex.r)*sqrt(2.0)*fog_color.xyz, 0.0, 1.0), 1.0);
	albedo_tex = clamp(albedo_tex, 0.0, 1.0);
	vec4 over_tex = vec4(otex.y, otex.y, otex.y, 1.0);

	vec4 emi_tex = vec4(albedo_tex + over_tex * glimmer_color * glimmer_strength) * albedo;
	ALBEDO = albedo_tex.rgb * albedo.xyz + emi_tex.xyz;
	EMISSION = emi_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
