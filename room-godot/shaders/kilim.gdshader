shader_type spatial;
// The daybed's flat-woven kilim: the product photo (top-down) mapped ONCE over the whole cloth, as if it were unfolded:
// across the top from the wall edge to the front edge, then straight down the front face. The photo is 541 x 875 px
// (portrait), close to the cloth's proportions, so it is not tiled and shows no seams. Bounds come from main.gd,
// which measures the S_Kilim_* meshes, so the cloth follows the bed if it is moved. The weave bump comes from the photo's brightness.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float bed_x0 = 0.02;     // world X of the wall edge of the cloth
uniform float top_y = 0.578;     // world Y of the top surface of the cloth
uniform float top_w = 0.9;       // width of the top across X (metres)
uniform float sheet_w = 1.078;   // top width plus the drop down the front face
uniform float z_min = -4.475;    // world Z of the lower-Z end of the cloth
uniform float bed_len = 1.9;     // length of the cloth along Z
uniform float bump_strength = 0.0011;
uniform float sheen = 0.1;

varying vec3 wpos;
varying vec3 wnorm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float top = step(0.5, wnorm.y);
	float across = mix(top_w + (top_y - wpos.y), wpos.x - bed_x0, top);
	vec2 uv = clamp(vec2(across / sheet_w, (wpos.z - z_min) / bed_len), vec2(0.0), vec2(1.0));
	vec3 tex = texture(albedo_tex, uv).rgb;

	ALBEDO = tex;
	ROUGHNESS = 0.95;
	SPECULAR = 0.15;
	RIM = sheen;
	RIM_TINT = 0.6;

	// Screen-space bump mapping (Mikkelsen) from the photo's brightness: the weave catches the light.
	float h = dot(tex, vec3(0.299, 0.587, 0.114));
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	float dhx = dFdx(h);
	float dhy = dFdy(h);
	vec3 r1 = cross(dpdy, NORMAL);
	vec3 r2 = cross(NORMAL, dpdx);
	float det = dot(dpdx, r1);
	vec3 grad = sign(det) * (dhx * r1 + dhy * r2);
	NORMAL = normalize(abs(det) * NORMAL - bump_strength * grad);
}
