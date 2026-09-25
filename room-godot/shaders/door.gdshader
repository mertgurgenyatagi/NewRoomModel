shader_type spatial;
// Glossy black door with light vertical stripes (the entrance door in the photos).

uniform vec3 black_color : source_color = vec3(0.06, 0.055, 0.05);
uniform vec3 stripe_color : source_color = vec3(0.72, 0.69, 0.63);
uniform float stripe_pitch = 0.075;
uniform float stripe_width = 0.014;

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float u = fract(wpos.x / stripe_pitch) * stripe_pitch;
	float aa = fwidth(wpos.x);
	float s = smoothstep(0.0, aa + 0.0005, u) * (1.0 - smoothstep(stripe_width, stripe_width + aa + 0.0005, u));
	ALBEDO = mix(black_color, stripe_color, s);
	ROUGHNESS = mix(0.1, 0.35, s);
	SPECULAR = 0.9;
}
