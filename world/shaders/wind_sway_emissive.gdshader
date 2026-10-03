shader_type canvas_item;
render_mode unshaded;
// Wind sway for the emissive layer of glowing plants (unshaded, see emissive.gdshader).
// phase comes from the world position, so neighbours move like a gust passing through.

uniform float amount = 1.0; // offset of the top edge in pixels at full gust
uniform float speed = 1.4;

void vertex() {
	vec2 world = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
	float t = TIME * speed - world.x * 0.035 + world.y * 0.01;
	float gust = 0.55 + 0.45 * sin(TIME * 0.31 - world.x * 0.004);
	float w = (sin(t) + 0.35 * sin(t * 2.3 + 1.7)) * gust;
	VERTEX.x += round(w * amount * (1.0 - UV.y));
}
