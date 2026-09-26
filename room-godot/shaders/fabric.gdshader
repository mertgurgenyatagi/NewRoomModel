shader_type spatial;
// Woven cloth (linen / cotton) for cushions, driven by world position, no UVs.
// Instead of noise bumps (which turned into big pixels), it modulates colour with fine slubs: thin streaks running along
// the warp and the weft, plus a plain-weave check that fades out with distance so nothing shimmers. Soft rim sheen.

uniform vec3 albedo : source_color = vec3(0.8);
uniform float roughness = 0.95;
uniform float sheen = 0.14;
uniform float slub = 0.07;     // strength of the warp/weft colour streaks
uniform float thread = 0.05;   // strength of the plain-weave check, visible only close up
uniform float freq = 260.0;    // streak cells per metre across the thread

varying vec3 wpos;
varying vec3 wnorm;

float h21(vec2 p) {
	p = fract(p * vec2(0.1031, 0.1030));
	p += dot(p, p.yx + 33.33);
	return fract((p.x + p.y) * p.x);
}

float vn(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}

float fade(float f, float footprint) {
	return 1.0 - smoothstep(0.5 / f, 1.5 / f, footprint);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(wnorm);
	vec2 p = (n.x >= n.y && n.x >= n.z) ? wpos.yz : ((n.y >= n.z) ? wpos.xz : wpos.xy);
	float fp = length(fwidth(p));
	float warp = vn(vec2(p.x * freq, p.y * freq * 0.04));
	float weft = vn(vec2(p.x * freq * 0.04, p.y * freq));
	float fine = vn(p * freq * 3.4);
	float streak = ((warp - 0.5) + (weft - 0.5)) * slub * fade(freq, fp) + (fine - 0.5) * slub * 0.5 * fade(freq * 3.4, fp);
	float check = (sin(p.x * 1300.0) * sin(p.y * 1300.0)) * thread * fade(1300.0, fp);
	// broad, faint unevenness so a big cushion is not one flat tone
	float cloud = (vn(p * 6.0) - 0.5) * 0.03;
	ALBEDO = albedo * (1.0 + streak + check + cloud);
	ROUGHNESS = roughness;
	SPECULAR = 0.1;
	RIM = sheen;
	RIM_TINT = 0.7;
}
