shader_type canvas_item;
// Elysia's reward lettering on a Label: a banded gold gradient from top to bottom, an
// optional rainbow shimmer (legendary) and a highlight that sweeps across. Pixels in
// `keep_color` (the outline) stay as they are.

uniform vec4 top_color : source_color = vec4(1.0, 0.97, 0.72, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.96, 0.6, 0.16, 1.0);
uniform vec4 keep_color : source_color = vec4(0.22, 0.08, 0.16, 1.0);
uniform float height = 24.0;
uniform float rainbow : hint_range(0.0, 1.0) = 0.0;
uniform float shine_every = 2.5;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

void fragment() {
	if (distance(COLOR.rgb, keep_color.rgb) > 0.12) {
		float t = clamp(local.y / max(height, 1.0), 0.0, 1.0);
		t = floor(t * 4.0) / 3.0;
		vec3 c = mix(top_color.rgb, bottom_color.rgb, t);
		if (rainbow > 0.0) {
			vec3 band = hue(fract(floor(local.x / 3.0) * 0.03 - TIME * 0.4)) * 0.55 + 0.5;
			c = mix(c, band, rainbow);
		}
		float sweep = mod(TIME, shine_every) / 0.6;
		float d = floor(local.x) - (sweep * 160.0 - 20.0) + floor(local.y) * 0.5;
		if (sweep < 1.0 && d > 0.0 && d < 4.0) {
			c = mix(c, vec3(1.0), 0.7);
		}
		COLOR.rgb = c;
	}
}
