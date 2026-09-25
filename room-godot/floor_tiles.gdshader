shader_type spatial;
// Large-format greige floor tiles (0.75 m) with thin grout, drawn from world position so the mesh needs no UVs.

uniform vec3 tile_color : source_color = vec3(0.79, 0.76, 0.72);
uniform vec3 grout_color : source_color = vec3(0.55, 0.53, 0.50);
uniform float tile_size = 0.75;
uniform float grout_width = 0.006;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz / tile_size;
	vec2 f = abs(fract(p) - 0.5) * 2.0;
	float edge = max(f.x, f.y);
	float g = smoothstep(1.0 - grout_width / tile_size * 2.0, 1.0, edge);
	vec2 id = floor(p);
	float shade = fract(sin(dot(id, vec2(12.9898, 78.233))) * 43758.5453) * 0.03;
	ALBEDO = mix(tile_color - shade, grout_color, g);
	ROUGHNESS = mix(0.4, 0.8, g);
}
