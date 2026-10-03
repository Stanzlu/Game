shader_type canvas_item;
// Air around the rift: the world behind it bends in whole pixels and splits slightly into
// colours near the crack, as if reality were thin there (Game Bible §11).

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float strength = 2.5;
uniform float split = 1.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float mask = clamp(1.0 - length(p * vec2(1.0, 0.55)), 0.0, 1.0);
	mask = mask * mask;
	vec2 px = SCREEN_PIXEL_SIZE;
	float t = floor(TIME * 8.0) / 8.0;
	float wave = sin(UV.y * 22.0 + t * 5.0) + 0.6 * sin(UV.y * 9.0 - t * 3.0);
	float offset = round(wave * strength * mask);
	vec2 uv = SCREEN_UV + vec2(offset * px.x * 2.0, 0.0);
	float s = round(split * mask * 2.0) * px.x * 2.0;
	vec3 c;
	c.r = texture(screen_texture, uv + vec2(s, 0.0)).r;
	c.g = texture(screen_texture, uv).g;
	c.b = texture(screen_texture, uv - vec2(s, 0.0)).b;
	COLOR = vec4(c, step(0.02, mask));
}
