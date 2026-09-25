shader_type spatial;
// Fine roughcast plaster from world position: grain in albedo plus a screen-space bump, faded out with distance to avoid shimmer.

uniform vec3 base_color : source_color = vec3(0.65, 0.64, 0.63);
uniform float grain_contrast = 0.22;
uniform float bump_strength = 0.0011; // bump height in metres
uniform float roughness_base = 0.9;

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

float octave_fade(float freq, float footprint) {
	// Fully visible while one pixel covers less than half a noise cell, gone when it covers more than 1.5 cells.
	return 1.0 - smoothstep(0.5 / freq, 1.5 / freq, footprint);
}

float height(vec3 p, float footprint) {
	float h = vnoise(p * 60.0) * 0.5 * octave_fade(60.0, footprint);
	h += vnoise(p * 140.0) * 0.32 * octave_fade(140.0, footprint);
	h += vnoise(p * 320.0) * 0.18 * octave_fade(320.0, footprint);
	return h;
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float footprint = length(fwidth(wpos));
	float h = height(wpos, footprint);
	float patch_var = vnoise(wpos * 1.7) * 0.06 - 0.03;
	ALBEDO = base_color * (1.0 + (h - 0.5) * grain_contrast + patch_var);
	ROUGHNESS = roughness_base;
	SPECULAR = 0.35;

	// Screen-space bump mapping (Mikkelsen)
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
