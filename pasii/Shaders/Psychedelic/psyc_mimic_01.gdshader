shader_type spatial;
render_mode unshaded, depth_test_disabled;
uniform sampler2D screentex : hint_screen_texture, filter_linear_mipmap_anisotropic;
uniform sampler2D depthtex : hint_depth_texture, filter_linear;
uniform float tiling_multiplier = 4.0;
uniform sampler2D itex1;
vec2 mirroring(vec2 uv) {
    uv = fract(uv); uv = 1.0 - abs(2.0 * uv - 1.0);
    return uv;
}
mat2 rotator(float angle)
{
	angle *= PI / 180.0;
    float sine = sin(angle);
	float cosine = cos(angle);
    return mat2(vec2(cosine, -sine),  vec2(sine, cosine));
}
void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 r2h(vec3 rgb) {
    float cmax = max(rgb.r, max(rgb.g, rgb.b));
    float cmin = min(rgb.r, min(rgb.g, rgb.b));
    float delta = cmax - cmin;
    
    vec3 hsv = vec3(0.0, 0.0, cmax);
    
    if (delta > 0.0001) {
        hsv.y = delta / cmax;
        
        if (abs(cmax - rgb.r) < 0.0001) {
            hsv.x = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6.0 : 0.0);
        } else if (abs(cmax - rgb.g) < 0.0001) {
            hsv.x = (rgb.b - rgb.r) / delta + 2.0;
        } else {
            hsv.x = (rgb.r - rgb.g) / delta + 4.0;
        }
        
        hsv.x /= 6.0;
    }
    
    return hsv;
}

vec3 h2r(vec3 hsv) {
    if (abs(hsv.y) < 0.0001) {
        return vec3(hsv.z);
    }
    
    float h = hsv.x * 6.0;
    int i = int(floor(h));
    float f = h - float(i);
    float p = hsv.z * (1.0 - hsv.y);
    float q = hsv.z * (1.0 - hsv.y * f);
    float t = hsv.z * (1.0 - hsv.y * (1.0 - f));
    
    if (i == 0) return vec3(hsv.z, t, p);
    else if (i == 1) return vec3(q, hsv.z, p);
    else if (i == 2) return vec3(p, hsv.z, t);
    else if (i == 3) return vec3(p, q, hsv.z);
    else if (i == 4) return vec3(t, p, hsv.z);
    else return vec3(hsv.z, p, q);
}

void fragment() {
	vec3 col = vec3(1.0);
	float dep = texture(depthtex, SCREEN_UV).x;
	
	vec2 scruvb = 0.5*tanh(2.0*SCREEN_UV-1.0+cos(TIME)*0.01)+0.5-sin(TIME+cos(TIME*0.2))*0.01;
	scruvb = mix(scruvb, 0.5*tanh(2.0*rotator(TIME*-0.12)*SCREEN_UV-1.0+cos(TIME*0.6)*0.01)+0.5-sin(TIME+cos(TIME*1.3))*0.01, 0.01*sin(9.3*scruvb.x+TIME));
	scruvb = mix(SCREEN_UV, scruvb, cosh(1.-dep));
	scruvb = mix(scruvb, scruvb*rotator(dep*39.), texture(itex1, scruvb).x*0.01);
	vec2 scruvd = texture(screentex, scruvb).xy; //painting effect
	vec2 scruv = scruvb;
	dep = texture(depthtex, scruvb).x;
	dep = mirroring(vec2((1.0+dep)*(tiling_multiplier*0.5)*(1.0/tiling_multiplier)*(2.-dep), 0.0)).x;
	scruv = mirroring((1.0+scruv)*(tiling_multiplier*0.5)*(1.0/tiling_multiplier)*(1.-dep));
	scruv = mix(scruv/dep, scruvd/dep, 0.5)/tiling_multiplier;
	scruv = mirroring(scruv)/2.0;
	col = texture(itex1, (scruv+vec2(0.0, TIME*-0.1))+scruvb).xyz;
	col = 1.3*h2r(r2h(texture(screentex, scruvb).xyz).xyz+vec3(0.0-0.01*fract(0.113*TIME+dep*21.0), 0.3-0.12*sin(TIME+dep*920.0), 0.02)) / max(col*0.3, 0.01);
	
	ALBEDO.xyz = col.xyz;
}

