tool;
extends WorldGenWorld;

export(int) int normal_surface_id = 2;
export(int) int base_iso_level = 0;
export(int) int water_iso_level = 100;
export(int) int water_surface_id = 5;
export(FastnoiseNoiseParams) FastnoiseNoiseParams base_noise = null;

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_slot_int("get_normal_surface_id", "set_normal_surface_id", "Normal Surface ID");
	inspector.add_slot_int("get_base_iso_level", "set_base_iso_level", "Base Isolevel");
	inspector.add_slot_int("get_water_iso_level", "set_water_iso_level", "Water Isolevel");
	inspector.add_slot_int("get_water_surface_id", "set_water_surface_id", "Water Surface ID");
	
	inspector.add_slot_resource("get_base_noise_params", "set_base_noise_params", "Base Noise Params", "FastnoiseNoiseParams");
}

void generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs) {
	Vector2 p = Vector2(chunk.get_position_x(), chunk.get_position_z());
	WorldGenRaycast raycast = get_hit_stack(p);
	
	_generate_terra_chunk(chunk, pseed, spawn_mobs, raycast);
	
	while raycast.next() {
		raycast.get_resource()._generate_terra_chunk(chunk, pseed, spawn_mobs, raycast);
	}
	
	_generate_terra_chunk_ocean(chunk, pseed, spawn_mobs);
}

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	_generate_terra_chunk_fallback(chunk, pseed, spawn_mobs);
}

void _generate_terra_chunk_fallback(TerrainChunk chunk, int pseed, bool spawn_mobs) {
	chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_TYPE, normal_surface_id);
	chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL, base_iso_level);
	#chunk.set_data(1, 0, 0, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
}

void _generate_terra_chunk_ocean(TerrainChunk chunk, int pseed, bool spawn_mobs) {
	if !chunk.channel_is_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_TYPE) {
		return;
	}
	
	if !chunk.channel_is_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL) {
		return;
	}
	
	bool ensured_channels = false;
	
	for (int x = -chunk.margin_start; x < chunk.size_x + chunk.margin_end; ++x) {
		for (int z = -chunk.margin_start; z < chunk.size_z + chunk.margin_end; ++z) {
			int iso_level = chunk.get_data(x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
			
			if iso_level < water_iso_level {
				if !ensured_channels {
					ensured_channels = true;
					
					chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_LIQUID_TYPE, 0);
					chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_LIQUID_ISOLEVEL, water_iso_level);
				}
				
				chunk.set_data(water_surface_id, x, z, TerrainChunkDefault.DEFAULT_CHANNEL_LIQUID_TYPE);
				chunk.set_data(water_iso_level, x, z, TerrainChunkDefault.DEFAULT_CHANNEL_LIQUID_ISOLEVEL);
			}
		}
	}
}

int get_normal_surface_id() {
	return normal_surface_id;
}

void set_normal_surface_id(int ed) {
	normal_surface_id = ed;
	emit_changed();
}

int get_base_iso_level() {
	return base_iso_level;
}

void set_base_iso_level(int ed) {
	base_iso_level = ed;
	emit_changed();
}

int get_water_iso_level() {
	return water_iso_level;
}

void set_water_iso_level(int ed) {
	water_iso_level = ed;
	emit_changed();
}

int get_water_surface_id() {
	return water_surface_id;
}

void set_water_surface_id(int ed) {
	water_surface_id = ed;
	emit_changed();
}

FastnoiseNoiseParams get_base_noise_params() {
	return base_noise;
}

void set_base_noise_params(FastnoiseNoiseParams ed) {
	base_noise = ed;
	emit_changed();
}
