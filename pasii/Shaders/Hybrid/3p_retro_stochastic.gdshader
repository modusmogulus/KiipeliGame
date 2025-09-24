shader_type spatial;
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo_ceiling : source_color;
uniform sampler2D texture_albedo_ceiling : source_color, filter_linear, repeat_enable;
uniform float roughness : hint_range(0.0, 1.0);
uniform vec4 albedo_wall : source_color;
uniform sampler2D texture_albedo_wall : source_color, filter_linear, repeat_enable;

uniform vec4 albedo_floor : source_color;
uniform sampler2D texture_albedo_floor : source_color, filter_linear, repeat_enable;

uniform float ground_threshold : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float blend_smoothness : hint_range(0.0, 1.0, 0.01) = 0.1; // Controle de suavidade da transição


varying vec3 uv1_triplanar_pos;
varying vec2 uv1;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001);
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

varying vec3 vertex_normal;

uniform bool uv_global = true;
//Adapted from this pastebin
//https://pastebin.com/sDrnzYxB
//hash for randomness
vec2 hash2D2D (vec2 s)
{
	//magic numbers
	vec2 i = vec2(0.0);
	return fract(sin(modf(vec2(dot(s, vec2(127.1,311.7)), dot(s, vec2(269.5,183.3))) / 3.14159, i))*43758.5453);
}

//stochastic sampling
vec4 tex2DStochastic(sampler2D tex, vec2 uv, vec2 r, vec2 dx, vec2 dy, int samples, bool aniso)
{
	//triangle vertices and blend weights
	//BW_vx[0...2].xyz = triangle verts
	//BW_vx[3].xy = blend weights (z is unused)
	mat4 BW_vx;

	//uv transformed into triangular grid space with UV scaled by approximation of 2*sqrt(3)
	vec2 skewUV = mat2(vec2(1.0 , 0.0) , vec2(-0.57735027, 1.15470054 )) * (uv * 3.464);

	//vertex IDs and barycentric coords
	vec2 vxID = vec2 (floor(skewUV));
	vec3 barry = vec3 (fract(skewUV), 0);
	barry.z = 1.0-barry.x-barry.y;

	BW_vx = ((barry.z > 0.0) ?
		mat4(vec4(vxID, 0, 0), vec4(vxID + vec2(0, 1), 0, 0), vec4(vxID + vec2(1, 0), 0, 0), vec4(barry, 0)) :
		mat4(vec4(vxID + vec2 (1, 1), 0, 0), vec4(vxID + vec2 (1, 0), 0, 0), vec4(vxID + vec2 (0, 1), 0, 0), vec4(-barry.z, 1.0-barry.y, 1.0-barry.x, 0.0)));

	//blend samples with calculated weights
    return textureGrad(tex, uv + hash2D2D(BW_vx[0].xy), dx, dy) * BW_vx[3].x +
        textureGrad(tex, uv + hash2D2D(BW_vx[1].xy), dx, dy) * BW_vx[3].y +
        textureGrad(tex, uv + hash2D2D(BW_vx[2].xy), dx, dy) * BW_vx[3].z;
}

void vertex() {
	vertex_normal = NORMAL;
	ROUGHNESS = 0.0;
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);


	uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
	if (uv_global){
		uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale + uv1_offset;
	}else{
		uv1_triplanar_pos = vec4(VERTEX, 1.0).xyz * uv1_scale + uv1_offset;
	}

	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);

	uv1 = UV;
}


vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos, vec3 vert) {
	vec4 samp = vec4(0.0);
	samp += tex2DStochastic(p_sampler, p_triplanar_pos.xy, vert.xy-p_triplanar_pos.xy, vert.xy-p_triplanar_pos.xz, vec2(0.8, 0.8), 8, true) * p_weights.z;
	samp += tex2DStochastic(p_sampler, p_triplanar_pos.xz, vert.xy-p_triplanar_pos.xy, vert.xy-p_triplanar_pos.xz, vec2(0.8, 0.8), 8, true) * p_weights.y;
	samp += tex2DStochastic(p_sampler, p_triplanar_pos.zy, vert.xy-p_triplanar_pos.xy, vert.xy-p_triplanar_pos.xz, vec2(0.8, 0.8), 8, true) * p_weights.x;


	return samp;
}

const vec4 ZERO = vec4(0.0,0.0,0.0,0.0);


uniform bool use_uv_on_wall = false;
uniform bool use_uv_on_floor = false;
uniform bool use_uv_on_ceiling = false;
void fragment() {


	vec4 albedo_tex_floor = vec4(0.0);
	if(use_uv_on_floor){
		albedo_tex_floor = texture(texture_albedo_floor,UV * uv1_scale.xy + uv1_offset.xy);
	}else{
		albedo_tex_floor = triplanar_texture(texture_albedo_floor, uv1_power_normal, uv1_triplanar_pos, VERTEX);
	}

	vec4 albedo_tex_wall = vec4(0.0);
	if(use_uv_on_wall){
		albedo_tex_wall = texture(texture_albedo_wall,UV * uv1_scale.xy + uv1_offset.xy);
	}else{
		albedo_tex_wall = triplanar_texture(texture_albedo_wall, uv1_power_normal, uv1_triplanar_pos, VERTEX);
	}

	vec4 albedo_tex_ceiling = vec4(0.0);
	if(use_uv_on_ceiling){
		albedo_tex_ceiling = texture(texture_albedo_ceiling,UV * uv1_scale.xy + uv1_offset.xy);
	}else{
		albedo_tex_ceiling = triplanar_texture(texture_albedo_ceiling, uv1_power_normal, uv1_triplanar_pos, VERTEX);
	}

	float blend_factor_floor = smoothstep(ground_threshold - blend_smoothness, ground_threshold + blend_smoothness, vertex_normal.y);
	float blend_factor_cealing = smoothstep(ground_threshold - blend_smoothness, ground_threshold + blend_smoothness, -vertex_normal.y);


	vec4 albedo_tex =  mix(mix(albedo_tex_wall, albedo_tex_floor, blend_factor_floor),albedo_tex_ceiling,blend_factor_cealing);
	vec4 albedo_color = mix(mix(albedo_wall, albedo_floor, blend_factor_floor),albedo_ceiling,blend_factor_cealing);






	ALBEDO = albedo_color.rgb * albedo_tex.rgb;

	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = roughness;
}