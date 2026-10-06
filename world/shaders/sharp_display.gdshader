shader_type canvas_item;
// The world display without color grading (sandbox, encounters without a look): only the
// sharp scaling for zoomed views (ADR-043).

#include "res://world/shaders/sharp_sample.gdshaderinc"

void fragment() {
	COLOR = texture(TEXTURE, sharp_uv(UV, 1.0 / TEXTURE_PIXEL_SIZE));
}
