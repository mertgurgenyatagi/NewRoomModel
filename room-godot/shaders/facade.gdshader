shader_type spatial;
// Building facade with punched or ribbon windows, drawn on the faces that point along Z (toward the room).
// Windows sit on a grid in world X/Y. x_min/x_max keep them away from the building's side edges.

uniform vec3 wall_color : source_color = vec3(0.8, 0.75, 0.65);
uniform vec3 trim_color : source_color = vec3(0.9, 0.88, 0.83);
uniform vec3 glass_color : source_color = vec3(0.05, 0.08, 0.12);
uniform vec2 pitch = vec2(2.2, 3.0);        // metres between window centres
uniform vec2 win_size = vec2(1.1, 1.7);     // window width, height
uniform float y0 = -12.0;                   // street level
uniform float ground_h = 3.4;               // shopfront storey height
uniform float x_min = -1000.0;
uniform float x_max = 1000.0;
uniform float top_y = 1000.0;

varying vec3 wpos;
varying vec3 wnorm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 col = wall_color;
	float rough = 0.85;
	float metal = 0.0;
	float spec = 0.5;

	if (abs(wnorm.z) > 0.5) {
		float y = wpos.y - y0;
		bool ground = y < ground_h;
		vec2 p = vec2(wpos.x - x_min - 1.0, max(y - ground_h, 0.0));
		vec2 cell = ground ? vec2(pitch.x * 1.6, ground_h) : pitch;
		vec2 local = ground ? vec2(mod(wpos.x - x_min - 1.0, cell.x), y) : vec2(mod(p.x, cell.x), mod(p.y, cell.y));
		vec2 size = ground ? vec2(cell.x * 0.78, 2.4) : win_size;
		vec2 c0 = ground ? vec2(cell.x * 0.5, 1.5) : vec2(cell.x * 0.5, cell.y * 0.5);
		vec2 d = abs(local - c0);
		vec2 half_s = size * 0.5;
		bool inside_x = wpos.x > x_min + 1.0 && wpos.x < x_max - 1.0 && wpos.y < top_y - 1.5;
		float win = step(d.x, half_s.x) * step(d.y, half_s.y) * float(inside_x);
		float trim = step(d.x, half_s.x + 0.09) * step(d.y, half_s.y + 0.09) * float(inside_x);
		col = mix(col, trim_color, trim);
		col = mix(col, glass_color, win);
		rough = mix(0.85, 0.05, win);
		spec = mix(0.5, 1.0, win);
		metal = win * 0.0;
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metal;
	SPECULAR = spec;
}
