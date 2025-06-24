shader_type spatial;
uniform vec3 material_type: source_color = vec3(0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

bool is_material_camera(uint camera_visible_layers) {
	return (int(camera_visible_layers) & (1 << 1)) == 0;
}

void fragment() {
	if (is_material_camera(CAMERA_VISIBLE_LAYERS) == true) {
		
		ALPHA = 1.0;
		ALBEDO = vec3(0.0, 1.0, 0.0);
		
	}
	else {
		ALPHA = 0.0;
		ALBEDO = vec3(1.0, 0.0, 0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
