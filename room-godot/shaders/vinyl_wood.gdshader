shader_type spatial;
// Rolled vinyl sheet with an oak-plank print (muşamba): matte, embossed in register with the print.
// Drawn from world position, so the floor meshes need no UVs. Planks run along Z, toward the window.
//   - printed plank joints: a thin dark line with a shallow groove, not a real gap
//   - each plank has its own tone and its own grain, and the print repeats every 7 rows x 5 planks like a real roll
//   - one butt seam where the 3.0 m roll ends and a narrow filler strip runs to the far wall
// Every high-frequency layer fades out with the pixel footprint (per axis) so nothing shimmers at a distance.

uniform vec3 wood_light : source_color = vec3(0.60, 0.33, 0.19);   // dark reddish-brown walnut, matched to a "koyu kahve" reference photo
uniform vec3 wood_dark : source_color = vec3(0.42, 0.21, 0.12);
uniform vec3 groove_color : source_color = vec3(0.12, 0.06, 0.035);
uniform float plank_width = 0.16;
uniform float plank_length = 1.22;
uniform float row_shift = 0.06;        // the roll is trimmed at the left wall, so the first row is a partial plank
uniform float joint_width = 0.0021;    // printed joint line, metres
uniform float seam_x = 100.0;          // outside the room = no seam (one roll covers it; the real room is 2.71 m wide, this model 3.11 m). Use 3.0 to show a 3 m roll plus an 11 cm filler strip
uniform float seam_z_shift = 0.07;     // filler strip is cut from elsewhere on the roll, so its print is slightly out of register
uniform float bump_strength = 0.0008;  // metres
uniform float roughness_base = 0.6;

varying vec3 wpos;

float h21(vec2 p) {
	p = fract(p * vec2(0.1031, 0.1030));
	p += dot(p, p.yx + 33.33);
	return fract((p.x + p.y) * p.x);
}

float n2(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x), mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fade(float freq, float footprint) {
	return 1.0 - smoothstep(0.5 / freq, 1.5 / freq, footprint);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Pixel footprint on the floor, per axis: x is across the planks, z is along them.
	float fpx = max(fwidth(wpos.x), 1e-5);
	float fpz = max(fwidth(wpos.z), 1e-5);
	float fp = max(fpx, fpz);

	bool filler = wpos.x > seam_x;
	float x = wpos.x + row_shift;
	float z = -wpos.z + (filler ? seam_z_shift : 0.0);

	// Plank layout: rows across, each row staggered by its own random offset along the length.
	float row = floor(x / plank_width);
	float a = x - row * plank_width;                       // 0..plank_width across the plank
	float row_id = mod(row, 7.0);
	float off = h21(vec2(row_id, 3.7)) * plank_length;
	float pz = (z + off) / plank_length;
	float pidx = floor(pz);
	float b = (pz - pidx) * plank_length;                  // 0..plank_length along the plank
	float seed = h21(vec2(row_id, mod(pidx, 5.0)) + 11.0);
	float seed2 = h21(vec2(mod(pidx, 5.0), row_id) + 47.0);

	// Distance to the nearest printed joint.
	float e = min(min(a, plank_width - a), min(b, plank_length - b));
	float jw = joint_width * 0.5;
	float cov = min(1.0, joint_width / max(fp, 1e-4));    // a joint thinner than a pixel must not darken the whole pixel
	float joint = (1.0 - smoothstep(jw, jw + max(fpx, 0.0004), e)) * cov;
	float edge_mask = smoothstep(joint_width, joint_width * 5.0, e);

	// Grain: stretched noise along the plank, warped so the streaks wander like flat-sawn oak.
	float warp = n2(vec2(a * 5.0, b * 2.2) + seed * 31.0);
	float ring_freq = 110.0 + seed2 * 110.0;               // different band spacing per plank, so no floor-wide corduroy
	float ring = 0.5 + 0.5 * sin(a * ring_freq + warp * 4.5 + seed * 40.0);
	ring = mix(0.5, ring, fade(ring_freq / 6.2832, fpx));
	float fib1 = n2(vec2(a * 420.0, b * 14.0) + seed * 17.0);
	fib1 = mix(0.5, fib1, fade(420.0, fpx));
	float fib2 = n2(vec2(a * 1100.0, b * 40.0) + seed * 9.0);
	fib2 = mix(0.5, fib2, fade(1100.0, fpx));
	float broad = n2(vec2(a * 8.0, b * 1.3) + seed2 * 23.0);
	float pore = smoothstep(0.78, 0.95, n2(vec2(a * 900.0, b * 70.0) + seed * 5.0)) * fade(900.0, fpx);

	float grain = 0.10 * ring + 0.34 * fib1 + 0.14 * fib2 + 0.42 * broad;
	float t = smoothstep(0.28, 0.72, grain);
	vec3 wood = mix(wood_dark, wood_light, t);
	wood *= 1.0 + (seed - 0.5) * 0.22;                     // plank-to-plank tone
	wood = mix(wood, wood * vec3(1.05, 0.97, 0.9), seed2);  // some planks a touch warmer
	wood *= 1.0 - pore * 0.22;

	// Butt seam: a hairline, slightly darker than the printed joints.
	float seam = (1.0 - smoothstep(0.0003, 0.0003 + max(fpx, 0.0004), abs(wpos.x - seam_x))) * min(1.0, 0.0006 / max(fpx, 1e-4));

	vec3 col = mix(wood, groove_color, clamp(joint * 0.85 + seam * 0.9, 0.0, 1.0));
	ALBEDO = col;
	ROUGHNESS = clamp(roughness_base + (fib1 - 0.5) * 0.08 + joint * 0.15, 0.3, 1.0);
	SPECULAR = 0.42;

	// Emboss in register with the print: grain relief, joints as shallow grooves.
	float h = mix(0.5, 0.35 * ring + 0.45 * fib1 + 0.2 * fib2, edge_mask);
	h -= joint * 1.4 + seam * 1.0;
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
