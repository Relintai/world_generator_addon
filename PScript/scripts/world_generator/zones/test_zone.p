tool;
extends Zone;

export(float) float zone_radius = 0.5;
export(float) float zone_bevel = 0.3;
export(float) float zone_base = 0;

float terrain_Scale = 1;
int current_seed = 0;

float get_zone_radius() {
	return zone_radius;
}

void set_zone_radius(float ed) {
	zone_radius = ed;
	emit_changed();
}

float get_zone_bevel() {
	return zone_bevel;
}

void set_zone_bevel(float ed) {
	zone_bevel = ed;
	emit_changed();
}

float get_zone_base() {
	return zone_base;
}

void set_zone_base(float ed) {
	zone_base = ed;
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
	return "TestZone";
}

String get_editor_additional_text() {
	return "";
}

static float circle(Vector2 uv, Vector2 c, float r) {
	c.x += 0.5;
	c.y += 0.5;
	
	return (uv - c).length() - r;
}

float get_value_for(Vector2 uv) {
	float f = circle(uv, Vector2(), zone_radius);
	
	float cf = clamp(zone_base - f / max(zone_bevel, 0.00001), 0.0, 1.0);
	
	return cf;
}

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	terrain_Scale = chunk.terrain_Scale;
	current_seed = pseed;

	int cx = chunk.get_position_x();
	int cz = chunk.get_position_z();
	
	int chunk_seed = 123 + (cx * 231) + (cz * 123);

	RandomNumberGenerator rng = RandomNumberGenerator.new();
	rng.seed = chunk_seed;
	
	gen_terra_chunk(chunk, rng, raycast);
}

void gen_terra_chunk(TerrainChunk chunk, RandomNumberGenerator rng, WorldGenRaycast raycast) {
	chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_TYPE, 1);
	chunk.channel_ensure_allocated(TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL, 0);

	FastNoise s = FastNoise.new();
	s.set_noise_type(FastNoise.TYPE_SIMPLEX);
	s.set_seed(current_seed);
	
	FastNoise sdet = FastNoise.new();
	sdet.set_noise_type(FastNoise.TYPE_SIMPLEX);
	sdet.set_seed(current_seed);
	
	Vector2 luv = raycast.get_local_uv();
	
	Vector2 lhit_world_pos = raycast.get_local_position();
	lhit_world_pos.x *= chunk.size_x;
	lhit_world_pos.y *= chunk.size_z;
	
	Vector2 world_rect_size = get_rect().size;
	world_rect_size.x *= chunk.size_x;
	world_rect_size.y *= chunk.size_z;
	
	for (int x = -chunk.margin_start; x < chunk.size_x + chunk.margin_end; ++x) {
		for (int z = -chunk.margin_start; z < chunk.size_x + chunk.margin_end; ++z) {
			int vx = x + (chunk.position_x * chunk.size_x);
			int vz = z + (chunk.position_z * chunk.size_z);
			Vector2 lwp = lhit_world_pos + Vector2(x, z);
			Vector2 local_uv = lwp / world_rect_size;
			float interp = get_value_for(local_uv);
			
			float val = (s.get_noise_2d(vx * 0.05, vz * 0.05) + 2);
			val *= val;
			#val *= 10.0;
			val += abs(sdet.get_noise_2d(vx * 0.8, vz * 0.8)) * 5;
			
			int oil = chunk.get_data(x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
			
			oil += float(val) * interp;

			chunk.set_data(oil, x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
			
			if interp < 0.2 {
				continue;
			}
			
			chunk.set_data(1, x, z, TerrainChunkDefault.DEFAULT_CHANNEL_TYPE);
		}
	}
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_float("get_zone_radius", "set_zone_radius", "Zone Radius", 0.01);
	inspector.add_slot_float("get_zone_bevel", "set_zone_bevel", "Zone Bevel", 0.01);
	inspector.add_slot_float("get_zone_base", "set_zone_base", "Zone Base", 0.01);
}
