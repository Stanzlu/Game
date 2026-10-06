shader_type canvas_item;
// Scrolls a vertically repeating texture downwards in whole pixels (the title waterfall)
// and fades it out in a few hard steps towards the bottom.

uniform float speed = 60.0;
uniform float fade_from = 0.55;

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	float offset = floor(TIME * speed) / size.y;
	vec4 moving = texture(TEXTURE, vec2(UV.x, fract(UV.y - offset)));
	float fade = clamp((1.0 - UV.y) / (1.0 - fade_from), 0.0, 1.0);
	COLOR = vec4(moving.rgb, floor(fade * 4.0) / 4.0);
}
