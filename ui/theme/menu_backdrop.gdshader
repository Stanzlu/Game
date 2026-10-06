shader_type canvas_item;
// Backdrop behind menus: the game, softly blurred, partly desaturated, darkened and tinted.
// Elysia keeps its warm colour; the Real world turns grey and quiet (Game Bible §34).

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_px = 2.0;
uniform float desaturate : hint_range(0.0, 1.0) = 0.5;
uniform float darken : hint_range(0.0, 1.0) = 0.45;
uniform vec4 tint : source_color = vec4(0.1, 0.08, 0.14, 0.25);
// 0..1, faded in on open
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// blur radius in game pixels (640x360) regardless of the window size
	vec2 px = blur_px * amount / vec2(640.0, 360.0);
	vec3 c = vec3(0.0);
	float w = 0.0;
	for (int i = -2; i <= 2; i++) {
		for (int j = -2; j <= 2; j++) {
			float k = 1.0 / (1.0 + float(i * i + j * j));
			c += texture(screen_texture, SCREEN_UV + vec2(float(i), float(j)) * px * 0.5).rgb * k;
			w += k;
		}
	}
	c /= w;
	float grey = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(grey), desaturate * amount);
	c *= 1.0 - darken * amount;
	c = mix(c, tint.rgb, tint.a * amount);
	// gentle vignette
	vec2 d = SCREEN_UV - 0.5;
	c *= 1.0 - 0.35 * amount * dot(d, d) * 2.0;
	COLOR = vec4(c, 1.0);
}
