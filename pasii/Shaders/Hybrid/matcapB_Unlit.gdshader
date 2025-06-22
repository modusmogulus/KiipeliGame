shader_type spatial;
render_mode unshaded, depth_draw_never, cull_back;
uniform vec4 color_lighting;
uniform sampler2D base_texture: source_color, hint_default_black, filter_linear_mipmap;
uniform sampler2D matcap : source_color, hint_default_black, filter_linear_mipmap, repeat_disable; // Sampler 2d of the matcap
uniform bool use_global_lighting = false;
uniform float alpha_scissor_threshold = 0.0;
uniform bool is_billboard = false;
uniform vec3 albedo_multiply : source_color = vec3(1.0);
uniform vec3 albedo_add : source_color = vec3(0.0);

void vertex() {
	vec3 tempNormal = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);//Normalize vectors relative to view
	vec2 matcap_uv = clamp(tempNormal.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5), vec2(0.0), vec2(1.0));//Generate Matcap UV
	vec4 _matcap = texture(matcap, matcap_uv).rgba; //Matcap Texture
	COLOR = _matcap.rgba; //Set vertex color to Matcap Color
	//Billboarding
	if (is_billboard){
	    mat4 modified_model_view = VIEW_MATRIX * mat4(
	        INV_VIEW_MATRIX[0],
	        INV_VIEW_MATRIX[1],
	        INV_VIEW_MATRIX[2],
	        MODEL_MATRIX[3]
	    );
	    MODELVIEW_MATRIX = modified_model_view;
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	vec4 _tex = texture(base_texture, UV);
	ALBEDO = ((_tex * COLOR).rgb + albedo_add.rgb) * albedo_multiply.rgb;
	//Global lighting
	if (use_global_lighting){
		ALBEDO = ALBEDO * color_lighting.rgb;
	}
	if (_tex.a < alpha_scissor_threshold){
		discard;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
