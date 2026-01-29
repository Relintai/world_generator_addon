tool;
extends SubZoneProp;

export (EntityData) EntityData mob;
export (int) int level = 1;
#density

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	if !mob {
		return;
	}
	
	int cx = chunk.get_position_x();
	int cz = chunk.get_position_z();
	
	int chunk_seed = 123 + (cx * 231) + (cz * 123);

	RandomNumberGenerator rng = RandomNumberGenerator.new();
	rng.seed = chunk_seed;
	
	if not Engine.editor_hint and spawn_mobs and rng.randi() % 4 == 0 {
		chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL, 0);
		int oil = chunk.get_data(chunk.size_x / 2, chunk.size_z / 2, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
		
		ESS.entity_spawner.spawn_mob(mob.id, level, \
					Vector3(chunk.position_x * chunk.size_x * chunk.terrain_Scale + chunk.size_x / 2,\
							((oil - 2) / 255.0) * chunk.world_height, \
							chunk.position_z * chunk.size_z * chunk.terrain_Scale + chunk.size_z / 2));
	}
}

EntityData get_mob() {
	return mob;
}

void set_mob(EntityData ed) {
	mob = ed;
	emit_changed();
}

int get_level() {
	return level;
}

void set_level(int val) {
	level = val;
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
	return "MobSpawner";
}

String get_editor_additional_text() {
	return "";
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_resource("get_mob", "set_mob", "Mob", "EntityData");
	inspector.add_slot_int("get_level", "set_level", "level");
}
