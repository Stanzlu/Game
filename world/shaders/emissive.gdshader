shader_type canvas_item;
// Emissive layer of a prop (ADR-017): drawn in place (correct depth), not dimmed by the
// night tint or lights, so glowing mushrooms, crystals and leaves stay bright.
render_mode unshaded;
