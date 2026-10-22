shader_type canvas_item;
// Sky gradient in a few hard bands (ADR-017), so the sky stays pixel art. The dither only
// blends the seam between two bands (same formula as pixelart.quantize); a band's middle stays
// one flat colour instead of a checkerboard over its whole height.
// The dither follows the rect's own pixels (`size` = its size in game pixels), not the screen:
// on the title, which is drawn at window resolution, FRAGCOORD would dither at screen scale.

uniform vec2 size = vec2(640, 360);
uniform vec4 top : source_color = vec4(0.53, 0.77, 0.93, 1.0);
uniform vec4 bottom : source_color = vec4(0.86, 0.93, 0.98, 1.0);
uniform float steps = 6.0;
// How much of a band stays flat: 1 dithers the whole band, 3 to 4 only its seams.
uniform float seam_contrast = 3.5;

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[x + y * 4]) + 0.5) / 16.0;
}

void fragment() {
	float t = UV.y * steps;
	float band = floor(t);
	float frac = clamp((t - band - 0.5) * seam_contrast + 0.5, 0.0, 1.0);
	float s = (band + step(bayer4(floor(UV * size)), frac)) / steps;
	COLOR = mix(top, bottom, clamp(s, 0.0, 1.0));
}
