shader_type spatial;
// Black speckled worktop: dark base with grey and white flecks, semi-gloss.

uniform vec3 base_color : source_color = vec3(0.02, 0.02, 0.022);
uniform float fleck_scale = 220.0;

varying vec3 wpos;

float hash13(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float footprint = length(fwidth(wpos));
	float fade = 1.0 - smoothstep(0.5 / fleck_scale, 1.5 / fleck_scale, footprint);
	float h = hash13(floor(wpos * fleck_scale));
	float fleck = smoothstep(0.86, 0.9, h) * 0.45 + smoothstep(0.965, 0.98, h) * 0.5;
	float avg = 0.035;
	ALBEDO = base_color + vec3(mix(avg, fleck, fade));
	ROUGHNESS = 0.38;
	SPECULAR = 0.35;
}
