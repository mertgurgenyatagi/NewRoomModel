shader_type spatial;
// Black speckled worktop: dark base with grey and white flecks, semi-gloss.

uniform vec3 base_color : source_color = vec3(0.02, 0.02, 0.022);
uniform float fleck_scale = 260.0;

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
	// round flecks: one sphere per cell, its size and presence come from the cell hash
	vec3 cp = wpos * fleck_scale;
	vec3 cell = floor(cp);
	float h = hash13(cell);
	float h2 = hash13(cell + 17.3);
	float radius = 0.16 + 0.2 * h2;
	float d = length(fract(cp) - 0.5);
	float speck = (1.0 - smoothstep(radius * 0.6, radius, d)) * step(0.5, h);
	float fleck = speck * (h2 > 0.82 ? 0.85 : 0.4);
	float avg = 0.035;
	ALBEDO = base_color + vec3(mix(avg, fleck, fade));
	ROUGHNESS = 0.38;
	SPECULAR = 0.35;
}
