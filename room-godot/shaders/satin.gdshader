shader_type spatial;
// Generic "real object" surface: painted, lacquered, brushed-metal or fabric, driven by world position.
// Roughness drifts like smudges and wear, a fine orange-peel bump breaks up highlights, and there is an optional
// clearcoat (enamel), brushed anisotropy (steel) or fabric sheen (curtain).

uniform vec3 albedo : source_color = vec3(0.85);
uniform float roughness = 0.4;
uniform float rough_var = 0.12;       // how far roughness drifts, 0 = uniform
uniform float metallic = 0.0;
uniform float specular = 0.5;
uniform float clearcoat = 0.0;
uniform float clearcoat_rough = 0.06;
uniform float brushed = 0.0;          // 1 = brushed anisotropic metal
uniform float sheen = 0.0;            // >0 = fabric rim sheen
uniform float weave = 0.0;            // >0 = fabric weave pattern strength
uniform float bump_strength = 0.0006; // metres
uniform float tint_var = 0.03;

varying vec3 wpos;

float hash13(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float vnoise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = mix(mix(hash13(i), hash13(i + vec3(1, 0, 0)), f.x), mix(hash13(i + vec3(0, 1, 0)), hash13(i + vec3(1, 1, 0)), f.x), f.y);
	float b = mix(mix(hash13(i + vec3(0, 0, 1)), hash13(i + vec3(1, 0, 1)), f.x), mix(hash13(i + vec3(0, 1, 1)), hash13(i + vec3(1, 1, 1)), f.x), f.y);
	return mix(a, b, f.z);
}

float fade(float freq, float footprint) {
	return 1.0 - smoothstep(0.5 / freq, 1.5 / freq, footprint);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float fp = length(fwidth(wpos));
	// fine surface relief (orange peel on paint, weave on fabric)
	float h = vnoise(wpos * 700.0) * 0.6 * fade(700.0, fp) + vnoise(wpos * 220.0) * 0.4 * fade(220.0, fp);
	if (weave > 0.0) {
		float wv = (sin(wpos.x * 900.0) * sin(wpos.y * 900.0 + wpos.z * 900.0)) * 0.5 + 0.5;
		h = mix(h, wv, weave) * fade(900.0, fp);
	}

	// smudges / wear: low-frequency roughness and tint variation
	float smudge = vnoise(wpos * 9.0) * 0.6 + vnoise(wpos * 38.0) * 0.4;
	float r = clamp(roughness + (smudge - 0.5) * 2.0 * rough_var, 0.03, 1.0);
	vec3 col = albedo * (1.0 + (vnoise(wpos * 4.0) - 0.5) * 2.0 * tint_var);

	ALBEDO = col;
	ROUGHNESS = r;
	METALLIC = metallic;
	SPECULAR = specular;
	if (clearcoat > 0.0) {
		CLEARCOAT = clearcoat;
		CLEARCOAT_ROUGHNESS = clearcoat_rough;
	}
	if (brushed > 0.0) {
		ANISOTROPY = 0.7 * brushed;
		ANISOTROPY_FLOW = vec2(1.0, 0.0);
	}
	if (sheen > 0.0) {
		RIM = sheen;
		RIM_TINT = 0.6;
	}

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
