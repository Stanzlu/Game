shader_type canvas_item;
// Post-process for the world display sprite (ADR-017): a light bloom for lamps and
// highlights, saturation, contrast, tint, colored shadows and a vignette. Works on the
// game-resolution viewport texture, so the glow stays chunky like the pixels.

uniform float saturation = 1.0;
uniform float contrast = 1.0;
uniform float brightness = 0.0;
uniform vec3 tint : source_color = vec3(1.0);
uniform vec3 shadow_tint : source_color = vec3(0.0);
uniform float vignette = 0.0;
uniform float bloom = 0.0;
uniform float bloom_threshold = 0.72;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 col = c.rgb;
	if (bloom > 0.0) {
		// sampled inline: built-in textures cannot be passed to helper functions everywhere
		vec2 o = TEXTURE_PIXEL_SIZE;
		vec2 taps[8] = vec2[](vec2(2.0, 0.0), vec2(-2.0, 0.0), vec2(0.0, 2.0), vec2(0.0, -2.0),
				vec2(4.0, 3.0), vec2(-4.0, -3.0), vec2(-4.0, 3.0), vec2(4.0, -3.0));
		vec3 acc = vec3(0.0);
		for (int i = 0; i < 8; i++) {
			vec3 s = texture(TEXTURE, UV + taps[i] * o).rgb;
			acc += max(s - bloom_threshold, vec3(0.0)) * (i < 4 ? 1.0 : 0.6);
		}
		col += bloom * acc / 6.4;
	}
	float l = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(l), col, saturation);
	col = (col - 0.5) * contrast + 0.5 + brightness;
	col *= tint;
	col += shadow_tint * (1.0 - clamp(l, 0.0, 1.0));
	float v = length((UV - 0.5) * vec2(1.0, 0.7));
	col *= 1.0 - vignette * smoothstep(0.3, 0.8, v);
	COLOR = vec4(col, c.a);
}
