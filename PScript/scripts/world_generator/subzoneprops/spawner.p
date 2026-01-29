tool;
extends SubZoneProp;

export (EntityData) EntityData trainer;
export (EntityData) EntityData vendor;

bool _is_spawner() {
	return true;
}

Vector2 _get_spawn_local_position() {
	return Vector2(get_rect().size.x / 2, get_rect().size.y / 2);
}

void _generate_terra_chunk(TerrainChunk chunk, int pseed, bool spawn_mobs, WorldGenRaycast raycast) {
	if !spawn_mobs {
		return;
	}
	
	if trainer == null || vendor == null {
		return;
	}
	
	Vector2i p = Vector2i(get_rect().size.x / 2, get_rect().size.y / 2);
	Vector2i lp = raycast.get_local_position();

	if p == lp {
		Vector3 pos = Vector3(chunk.get_position_x() * chunk.get_size_x() * chunk.terrain_Scale + 4, 50 * chunk.terrain_Scale, chunk.get_position_z() * chunk.get_size_z() * chunk.terrain_Scale + 4);
		ESS.entity_spawner.spawn_mob(trainer.id, 1, pos);
		pos = Vector3(chunk.get_position_x() * chunk.get_size_x() * chunk.terrain_Scale + 2, 50 * chunk.terrain_Scale, chunk.get_position_z() * chunk.get_size_z() * chunk.terrain_Scale + 2);
		ESS.entity_spawner.spawn_mob(vendor.id, 1, pos);
	}
}

EntityData get_trainer() {
	return trainer;
}

void set_trainer(EntityData ed) {
	trainer = ed;
	emit_changed();
}

EntityData get_vendor() {
	return vendor;
}

void set_vendor(EntityData ed) {
	vendor = ed;
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
	return "Spawner";
}

String get_editor_additional_text() {
	return "";
}

void setup_property_inspector(Variant inspector) {
	.setup_property_inspector(inspector);
	
	inspector.add_h_separator();
	inspector.add_slot_resource("get_trainer", "set_trainer", "Trainer", "EntityData");
	inspector.add_slot_resource("get_vendor", "set_vendor", "Vendor", "EntityData");
}
