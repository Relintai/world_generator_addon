tool;
extends SubZone;

export(PropData) PropData prop_tree;
export(PropData) PropData prop_tree2;

PropData get_prop_tree() {
	return prop_tree;
}

void set_prop_tree(PropData ed) {
	prop_tree = ed;
	emit_changed();
}

PropData get_prop_tree2() {
	return prop_tree2;
}

void set_prop_tree2(PropData ed) {
	prop_tree2 = ed;
	emit_changed();
}

Color get_editor_rect_border_color() {
	return Color(0.8, 0.8, 0.8, 1);
}

Color get_editor_rect_color() {
	return Color(0.8, 0.8, 0.8, 0.9);
}

int get_editor_rect_border_size() {
	return 2;
}

Color get_editor_font_color() {
	return Color(0, 0, 0, 1);
}

String get_editor_class() {
	return "Forest";
}

String get_editor_additional_text() {
	return "";
}

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	int cx = chunk.get_position_x();
	int cz = chunk.get_position_z();
	
	int chunk_seed = 123 + (cx * 231) + (cz * 123);

	RandomNumberGenerator rng = RandomNumberGenerator.new();
	rng.seed = chunk_seed;
	
	#chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_TYPE, 1);
	chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL, 0);
	
	# TODO refactor this, it's inefficient
	for (int x = -chunk.margin_start; x < chunk.size_x + chunk.margin_end; ++x) {
		for (int z = -chunk.margin_start; z < chunk.size_z + chunk.margin_end; ++z) {
			if rng.randf() > 0.992 {
				int oil = chunk.get_data(x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
				
				Transform tr = Transform();
					
				tr = tr.rotated(Vector3(0, 1, 0), rng.randf() * PI);
				tr = tr.rotated(Vector3(1, 0, 0), rng.randf() * 0.2 - 0.1);
				tr = tr.rotated(Vector3(0, 0, 1), rng.randf() * 0.2 - 0.1);
				tr = tr.scaled(Vector3(0.9 + rng.randf() * 0.2, 0.9 + rng.randf() * 0.2, 0.9 + rng.randf() * 0.2));
				tr.origin = Vector3((x + chunk.position_x * chunk.size_x), ((oil - 2) / 255.0) * chunk.world_height, (z + chunk.position_z * chunk.size_z));

				chunk.terrain_world.prop_add(tr, prop_tree);
			}
		}
	}
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_resource("get_prop_tree", "set_prop_tree", "Prop Tree", "PropData");
	inspector.add_slot_resource("get_prop_tree2", "set_prop_tree2", "Prop Tree2", "PropData");
}
