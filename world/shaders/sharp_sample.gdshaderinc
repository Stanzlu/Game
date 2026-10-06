// Sharp scaling for pixel art at any zoom (ADR-043): inside a texel the color stays flat,
// only across texel edges does linear filtering blend over about one screen pixel. With a
// linear texture filter this keeps 1.5x (or 4.5x on 1080p) crisp and lets the camera glide
// by fractions of a pixel without shimmering. Needs fragment stage (fwidth).
vec2 sharp_uv(vec2 uv, vec2 texture_size) {
	vec2 px = uv * texture_size;
	vec2 width = max(fwidth(px), vec2(1.0e-5));
	vec2 seam = floor(px + 0.5);
	px = seam + clamp((px - seam) / width, -0.5, 0.5);
	return px / texture_size;
}
