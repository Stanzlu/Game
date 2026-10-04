shader_type canvas_item;
render_mode unshaded;
// Wind sway for the emissive layer of glowing plants (unshaded, see emissive.gdshader).
// Same motion as wind_sway.gdshader, including the mirrored breathing of symmetric maps.

uniform float amount = 1.0; // offset of the top edge in pixels at full gust
uniform float speed = 1.4;
uniform float mirror_x = -1.0e9;

void vertex() {
	vec2 world = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
	float t = TIME * speed - world.x * 0.035 + world.y * 0.01;
	float gust = 0.55 + 0.45 * sin(TIME * 0.31 - world.x * 0.004);
	float w = (sin(t) + 0.35 * sin(t * 2.3 + 1.7)) * gust;
	if (mirror_x > -1.0e8) {
		w = sin(TIME * speed * 0.8) * 0.8 * sign(world.x - mirror_x);
	}
	VERTEX.x += round(w * amount * step(VERTEX.y, -0.5));
}
