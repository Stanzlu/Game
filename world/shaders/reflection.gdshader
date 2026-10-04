shader_type canvas_item;
// Water reflection of a prop (ADR-017): the sprite is drawn mirrored below its base and only
// shows where the map's water mask says "water". Rows wobble by whole pixels; the image fades
// with distance from the base. In Elysia the protagonist gets no reflection (Game Bible §9);
// in the real world he does, in open water and in puddles (`puddles`).

uniform sampler2D water_mask : filter_nearest;
uniform vec2 map_origin = vec2(0.0);
uniform vec2 map_size = vec2(1.0);
uniform vec4 tint : source_color = vec4(0.62, 0.78, 0.92, 0.5);
uniform bool puddles = false;
// > 0: fade by distance below the owner's feet (animated sheets, whose UV spans the sheet)
uniform float fade_px = 0.0;

varying vec2 world_pos;
varying float below;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	below = VERTEX.y;
}

void fragment() {
	float t = floor(TIME * 6.0) / 6.0;
	float row = floor(world_pos.y);
	float wobble = round(sin(row * 0.8 + t * 3.0) * 0.8);
	vec2 uv = UV + vec2(wobble * TEXTURE_PIXEL_SIZE.x, 0.0);
	vec4 c = texture(TEXTURE, uv);
	vec4 m = texture(water_mask, (world_pos - map_origin) / map_size);
	// mask B: 0 open water, 0.5 waterfall, 1 puddle
	float kind_ok = 1.0 - step(0.25, m.b);
	if (puddles) {
		kind_ok = max(kind_ok, step(0.75, m.b));
	}
	float is_water = step(0.5, m.r) * kind_ok;
	c.rgb *= tint.rgb;
	float fade = 0.35 + 0.65 * UV.y;
	if (fade_px > 0.0) {
		fade = clamp(1.0 - below / fade_px, 0.0, 1.0);
	}
	c.a *= tint.a * is_water * fade;
	COLOR = c;
}
