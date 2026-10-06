shader_type canvas_item;
// Wind sway for plants (ADR-017). Shears the sprite top sideways by whole pixels; the
// phase comes from the world position, so neighbours move like a gust passing through.
// Symmetric maps (Elysia, Game Bible §9) set mirror_x: then there is no gust, only one
// clean sine for every plant, mirrored at the axis, so the whole garden breathes in step.
// In the real world broad waves of wind roll across the meadow (ADR-041): where a wave
// passes, plants lean further and catch the light, a soft sheen that travels through the
// grass. Elysia has none of it: its wind never comes from anywhere.

uniform float amount = 1.0; // offset of the top edge in pixels at full gust
uniform float speed = 1.4;
uniform float mirror_x = -1.0e9; // world x of the mirror axis; far left = off
uniform float sheen = 0.14; // brightening where a wave passes (real world only)

varying float wave;

// 0..1: how strongly a wind wave is passing at this world position right now.
float wind_wave(vec2 world) {
	vec2 dir = normalize(vec2(1.0, 0.32));
	float along = dot(world, dir);
	float a = 0.5 + 0.5 * sin(along * 0.011 - TIME * 0.62);
	float b = 0.5 + 0.5 * sin(along * 0.0073 + world.y * 0.004 - TIME * 0.41 + 1.3);
	return max(pow(a, 7.0), 0.75 * pow(b, 9.0));
}

void vertex() {
	vec2 world = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
	float t = TIME * speed - world.x * 0.035 + world.y * 0.01;
	wave = 0.0;
	float gust = 0.55 + 0.45 * sin(TIME * 0.31 - world.x * 0.004);
	if (mirror_x <= -1.0e8) {
		wave = wind_wave(world);
		gust = gust * 0.7 + wave * 0.6;
	}
	float w = (sin(t) + 0.35 * sin(t * 2.3 + 1.7)) * gust;
	if (mirror_x > -1.0e8) {
		w = sin(TIME * speed * 0.8) * 0.8 * sign(world.x - mirror_x);
	}
	// top vertices (above the anchor) move, the base stays (UV is atlas space, not 0..1)
	VERTEX.x += round(w * amount * step(VERTEX.y, -0.5));
}

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	// the lit side of bent blades: brighter and a touch warmer, never a new hue
	vec3 lit = min(c.rgb * 1.22 + vec3(0.035, 0.04, 0.0), vec3(1.0));
	c.rgb = mix(c.rgb, lit, clamp(wave * sheen * 4.0, 0.0, 1.0));
	COLOR = c;
}
