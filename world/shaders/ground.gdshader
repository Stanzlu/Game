shader_type canvas_item;
// Baked ground (ADR-017): animated water glints and rain ripples from a water mask
// (R = water or puddle, G = depth, B = puddle) and dithered cloud shadows drifting over
// the map. All effects stay on the game-pixel grid and inside the baked palette's mood.

uniform sampler2D water_mask : filter_nearest;
uniform bool has_water = false;
uniform vec4 glint_color : source_color = vec4(0.86, 0.96, 1.0, 1.0);
uniform float glint_strength = 0.65;
uniform float ripple_strength = 0.0;
uniform sampler2D cloud_noise : repeat_enable, filter_linear;
uniform float cloud_shadow = 0.0;
uniform vec2 cloud_velocity = vec2(7.0, 2.5);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = x + y * 4;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[i]) + 0.5) / 16.0;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);
	if (has_water) {
		vec4 m = texture(water_mask, UV);
		if (m.r > 0.5) {
			// stepped time: water animates in frames like hand-drawn tiles
			float t = floor(TIME * 8.0) / 8.0;
			float wave = sin(px.x * 0.42 + px.y * 2.3 + t * 2.4) * sin(px.y * 0.61 - t * 1.6 + px.x * 0.05);
			if (wave > 0.94 && m.b < 0.5) {
				c.rgb = mix(c.rgb, glint_color.rgb, glint_strength * (0.35 + 0.65 * m.g));
			}
			if (ripple_strength > 0.0) {
				vec2 cell = floor(px / 10.0);
				float life = fract(TIME * 0.85 + hash(cell));
				vec2 center = cell * 10.0 + 3.0 + vec2(hash(cell + 3.1), hash(cell + 7.7)) * 4.0;
				vec2 d = (px + 0.5 - center) * vec2(1.0, 2.0);
				float ring = abs(length(d) - life * 4.5);
				if (ring < 0.55 && life < 0.85) {
					c.rgb = mix(c.rgb, glint_color.rgb, ripple_strength * (1.0 - life));
				}
			}
		}
	}
	if (cloud_shadow > 0.0) {
		float n = texture(cloud_noise, (px + TIME * cloud_velocity) / 720.0).r;
		float s = smoothstep(0.5, 0.68, n);
		if (s > bayer4(px)) {
			c.rgb *= 1.0 - cloud_shadow;
		}
	}
	COLOR = c;
}
