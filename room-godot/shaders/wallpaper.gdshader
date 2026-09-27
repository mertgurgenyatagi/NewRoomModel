shader_type spatial;
// Printed wallpaper, top to bottom, mapped from world position (no UVs): a wall facing X uses (Z, height), a wall facing Z
// uses (X, height). The texture is a seamless tile, tile_size metres per repeat, hung with the pattern upright.
// Matt paper with a very faint fibre grain.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec2 tile_size = vec2(0.7, 1.24);   // metres one repeat of the tile covers
uniform vec2 offset = vec2(0.0);            // slide the pattern (metres)
uniform float brightness = 1.0;

varying vec3 wpos;
varying vec3 wnorm;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(wnorm);
	vec2 p;
	if (n.y > n.x && n.y > n.z) {
		p = vec2(wpos.x, wpos.z);            // wall top seen from above
	} else if (n.x > n.z) {
		p = vec2(wpos.z, -wpos.y);           // walls facing X
	} else {
		p = vec2(wpos.x, -wpos.y);           // walls facing Z
	}
	vec2 uv = (p + offset) / tile_size;
	vec3 col = texture(albedo_tex, uv).rgb * brightness;
	float fp = length(fwidth(wpos));
	float grain = (hash12(floor(wpos.xy * 900.0 + wpos.z * 900.0)) - 0.5) * 0.03 * (1.0 - smoothstep(0.0006, 0.0014, fp));
	ALBEDO = col * (1.0 + grain);
	ROUGHNESS = 0.88;
	SPECULAR = 0.25;
}
