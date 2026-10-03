class_name PhysicsLayers
extends RefCounted
## Collision layer bits. Names are mirrored in project.godot (layer_names/2d_physics).

const WORLD := 1 << 0
const PLAYER := 1 << 1
const NPC := 1 << 2
const INTERACTABLE := 1 << 3
const SURFACE := 1 << 4
const TRIGGER := 1 << 5
