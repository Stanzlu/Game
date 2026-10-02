shader_type canvas_item;
// Dithered sky gradient in a few hard bands (ADR-017), so the sky stays pixel art.

uniform vec4 top : source_color = vec4(0.53, 0.77, 0.93, 1.0);
uniform vec4 bottom : source_color = vec4(0.86, 0.93, 0.98, 1.0);
uniform float steps = 6.0;

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[x + y * 4]) + 0.5) / 16.0;
}

void fragment() {
	float t = UV.y * steps;
	float band = floor(t);
	float s = (band + step(bayer4(floor(FRAGCOORD.xy)), t - band)) / steps;
	COLOR = mix(top, bottom, clamp(s, 0.0, 1.0));
}
