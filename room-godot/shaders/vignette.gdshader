shader_type canvas_item;
// Soft warm vignette laid over the whole screen. Kept gentle: it should be felt, not seen.

uniform float strength : hint_range(0.0, 1.0) = 0.42;
uniform float softness : hint_range(0.1, 1.5) = 0.85;
uniform vec3 tint : source_color = vec3(0.12, 0.07, 0.05);

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= 1.15;
	float d = length(uv);
	float v = smoothstep(0.28, 0.28 + softness, d);
	COLOR = vec4(tint, v * strength);
}
