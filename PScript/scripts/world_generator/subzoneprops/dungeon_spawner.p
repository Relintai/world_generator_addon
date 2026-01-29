tool;
extends SubZoneProp;

export(PackedScene) PackedScene dungeon_teleporter;

float terrain_Scale = 1;
int current_seed = 0;

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	terrain_Scale = chunk.terrain_Scale;
	current_seed = pseed;

	int cx = chunk.get_position_x();
	int cz = chunk.get_position_z();
	
	int chunk_seed = 123 + (cx * 231) + (cz * 123);

	RandomNumberGenerator rng = RandomNumberGenerator.new();
	rng.seed = chunk_seed;
	
	Vector2i p = Vector2i(get_rect().size.x / 2, get_rect().size.y / 2);
	Vector2i lp = raycast.get_local_position();

	if p == lp {
		spawn_dungeon(chunk, chunk_seed, spawn_mobs);
	}
}

void spawn_dungeon(TerrainChunk chunk, int dungeon_seed, bool spawn_mobs) {
	int world_space_data_coordinates_x = chunk.position_x * chunk.size_x;
	int world_space_data_coordinates_z = chunk.position_z * chunk.size_z;
	
	int vpx = 6;
	int vpz = 6;
	
	float x = (world_space_data_coordinates_x + vpx) * chunk.terrain_Scale;
	float z = (world_space_data_coordinates_z + vpz) * chunk.terrain_Scale;
	
	int vh = chunk.get_data(vpx, vpz, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
	
	int orx = (randi() % 3) + 2;
	int orz = (randi() % 3) + 2;
	
	for (int wx = vpx - orx; wx < vpx + orx + 1; ++wx) {
		for (int wz = vpz - orz; wx < vpz + orz + 1; ++wz) {
			chunk.set_data(vh, wx, wz, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
		}
	}
	
	float vwh = chunk.get_terrain_Scale() * chunk.get_world_height() * (vh / 255.0);
	
	Spatial dt = dungeon_teleporter.instance();
	chunk.terrain_world.add_child(dt);
	dt.owner_chunk = chunk;
	
	int level = 2;
		
	if chunk.get_data_world().has_method("get_mob_level") {
		level  = chunk.get_data_world().get_mob_level();
	}
	
	dt.min_level = level - 1;
	dt.max_level = level + 1;
	dt.dungeon_seed = dungeon_seed;
	dt.spawn_mobs = spawn_mobs;
	dt.transform = Transform(Basis().scaled(Vector3(chunk.terrain_Scale, chunk.terrain_Scale, chunk.terrain_Scale)), Vector3(x, vwh, z));
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
	return "DungeonSpawner";
}

String get_editor_additional_text() {
	return "";
}

PackedScene get_dungeon_teleporter() {
	return dungeon_teleporter;
}

void set_dungeon_teleporter(PackedScene ed) {
	dungeon_teleporter = ed;
	emit_changed();
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_resource("get_dungeon_teleporter", "set_dungeon_teleporter", "Dungeon Teleporter", "PackedScene");
}
