tool;
extends Continent;

export(float) float continent_radius = 0.5;
export(float) float continent_bevel = 0.3;
export(float) float continent_base = 0;

float terrain_Scale = 1;
int current_seed = 0;

void _eitor_draw_additional(Control control) {
	gui_draw_continent_radius(control, Color(0.6, 0.6, 0.6, 1));
	gui_draw_continent_bevel(control, Color(1, 1, 1, 1));
}

void _eitor_draw_additional_background(Control control) {
	gui_draw_continent_radius(control, Color(0.3, 0.3, 0.3, 1));
	gui_draw_continent_bevel(control, Color(0.6, 0.6, 0.6, 1));
}

void gui_draw_continent_radius(Control control, Color color) {
	Vector2 s = control.get_size();
	
	PoolVector2Array points = PoolVector2Array();
	float ofsx = (1 - (continent_radius * 2)) * s.x / 2.0;
	float ofsy = (1 - (continent_radius * 2)) * s.y / 2.0;
	
	for (int i = 0; i < 16; ++i) {
		float ifl = float(i);
		float n = ifl / 16.0 * 2 * PI;
		float n1 = (ifl + 1.0) / 16.0 * 2 * PI;
		
		points.push_back(Vector2((sin(n) + 1.0) * 0.5 * continent_radius * 2 * s.x + ofsx, (cos(n) + 1.0) * 0.5 * continent_radius * 2 * s.y + ofsy));
		points.push_back(Vector2((sin(n1) + 1.0) * 0.5 * continent_radius * 2 * s.x + ofsx, (cos(n1) + 1.0) * 0.5 * continent_radius * 2 * s.y + ofsy));
	}
	
	control.draw_polyline(points, color, 1);
}

void gui_draw_continent_bevel(Control control, Color color) {
	Vector2 s = control.get_size();
	
	PoolVector2Array points = PoolVector2Array();
	float bevel_radius =  (min(continent_radius, continent_bevel) / continent_radius) / 2.0;
	float ofsx = (1 - (bevel_radius * 2)) * s.x / 2.0;
	float ofsy = (1 - (bevel_radius * 2)) * s.y / 2.0;
	
	for (int i = 0; i < 16; ++i) {
		float ifl = float(i);
		float n = ifl / 16.0 * 2 * PI;
		float n1 = (ifl + 1.0) / 16.0 * 2 * PI;
		
		points.push_back(Vector2((sin(n) + 1.0) * 0.5 * bevel_radius * 2 * s.x + ofsx, (cos(n) + 1.0) * 0.5 * bevel_radius * 2 * s.y + ofsy));
		points.push_back(Vector2((sin(n1) + 1.0) * 0.5 * bevel_radius * 2 * s.x + ofsx, (cos(n1) + 1.0) * 0.5 * bevel_radius * 2 * s.y + ofsy));
	}
	
	control.draw_polyline(points, color, 1);
}

float get_continent_radius() {
	return continent_radius;
}

void set_continent_radius(float ed) {
	continent_radius = ed;
	emit_changed();
}

float get_continent_bevel() {
	return continent_bevel;
}

void set_continent_bevel(float ed) {
	continent_bevel = ed;
	emit_changed();
}

float get_continent_base() {
	return continent_base;
}

void set_continent_base(float ed) {
	continent_base = ed;
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
	return "TestContinent";
}

String get_editor_additional_text() {
	return "";
}

void _setup_terra_library(TerrainLibrary library, int pseed) {
}

static float circle(Vector2 uv, Vector2 c, float r) {
	c.x += 0.5;
	c.y += 0.5;
	
	return (uv - c).length() - r;
}

float get_value_for(Vector2 uv) {
	float f = circle(uv, Vector2(), continent_radius);
	
	float cf = clamp(continent_base - f / max(continent_bevel, 0.00001), 0.0, 1.0);
	
	return cf;
}

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
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
		for (int z = -chunk.margin_start; z < chunk.size_z + chunk.margin_end; ++z) {
			int vx = x + (chunk.position_x * chunk.size_x);
			int vz = z + (chunk.position_z * chunk.size_z);
			
			Vector2 lwp = lhit_world_pos + Vector2(x, z);
			Vector2 local_uv = lwp / world_rect_size;
			float interp = get_value_for(local_uv);
			
			float val = (s.get_noise_2d(vx * 0.2, vz * 0.2));
			val *= val;
			val += abs(sdet.get_noise_2d(vx * 0.3, vz * 0.3)) * 10;
			val += 110;
			
			int oil = chunk.get_data(x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
			
			oil += float(val) * interp;

			chunk.set_data(oil, x, z, TerrainChunkDefault.DEFAULT_CHANNEL_ISOLEVEL);
		}
	}
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_float("get_continent_radius", "set_continent_radius", "Continent Radius", 0.01);
	inspector.add_slot_float("get_continent_bevel", "set_continent_bevel", "Continent Bevel", 0.01);
	inspector.add_slot_float("get_continent_base", "set_continent_base", "Continent Base", 0.01);
}
