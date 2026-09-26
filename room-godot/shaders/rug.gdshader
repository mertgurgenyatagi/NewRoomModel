shader_type spatial;
// Low-pile machine-made rug: the product photo (top-down) mapped from world position, so the mesh needs no UVs.
// Top face gets the photo, a soft fabric sheen, a fibre bump taken from the photo's own brightness and, if ring_pitch > 0,
// fine concentric ridges (a round braided-look rug). The sides get the edge colour.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec3 edge_color : source_color = vec3(0.6, 0.46, 0.3);
uniform vec2 rug_center = vec2(1.6, -4.05); // world X, Z of the rug centre
uniform vec2 rug_size = vec2(1.2, 1.2);     // width along X, length along Z (metres) that the photo covers
uniform float bump_strength = 0.0007;       // bump height in metres per unit of brightness
uniform float sheen = 0.15;
uniform float ring_pitch = 0.0;             // metres between concentric ridges, 0 = none
uniform float ring_amount = 0.9;            // ridge height, in the same units as brightness
uniform float ring_shade = 0.05;            // how much the ridges darken and lighten the colour

varying vec3 wpos;
varying vec3 wnorm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float top = step(0.5, wnorm.y);
	vec2 uv = clamp((wpos.xz - rug_center) / rug_size + 0.5, vec2(0.0), vec2(1.0));
	vec3 tex = texture(albedo_tex, uv).rgb;

	// Concentric ridges, zero-mean and faded out when one pixel covers about a ridge, so nothing shimmers in the distance.
	float ring = 0.0;
	if (ring_pitch > 0.0) {
		float footprint = length(fwidth(wpos));
		float r = length(wpos.xz - rug_center);
		ring = sin(r / ring_pitch * 6.2831853) * (1.0 - smoothstep(0.3 * ring_pitch, 0.8 * ring_pitch, footprint)) * top;
	}

	ALBEDO = mix(edge_color, tex * (1.0 + ring_shade * ring), top);
	ROUGHNESS = 0.95;
	SPECULAR = 0.2;
	RIM = sheen * top;
	RIM_TINT = 0.6;

	// Screen-space bump mapping (Mikkelsen) from the photo's brightness and the ridges
	float h = dot(tex, vec3(0.299, 0.587, 0.114)) * top + ring * ring_amount;
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
