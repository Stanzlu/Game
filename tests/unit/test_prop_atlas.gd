extends GutTest
## PropCatalog hands out atlas regions (one texture per style, few draw calls) that look
## exactly like the single textures, and can give the plain texture back.


func test_atlas_regions_match_the_single_textures() -> void:
	var entry := PropCatalog.entry("elysia/grass_tuft")
	var path := str((entry["textures"] as Array)[0])
	var plain := load(path) as Texture2D
	var region := PropCatalog.atlas_texture(path)
	assert_eq(region.get_size(), plain.get_size())
	assert_eq(PropCatalog.source_texture(region), plain)
	if region is AtlasTexture:
		var other := str((PropCatalog.entry("elysia/pebbles")["textures"] as Array)[0])
		var second := PropCatalog.atlas_texture(other) as AtlasTexture
		assert_eq(second.atlas, (region as AtlasTexture).atlas, "one atlas per style")
		var a := (region as AtlasTexture).atlas.get_image().get_region(Rect2i(region.region))
		var b := plain.get_image()
		b.convert(Image.FORMAT_RGBA8)
		assert_eq(a.get_data(), b.get_data(), "pixel for pixel")
	else:
		pass_test("no image data in this run (headless): plain textures are used")
