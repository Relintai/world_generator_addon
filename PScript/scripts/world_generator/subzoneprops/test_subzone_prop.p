tool;
extends SubZoneProp;

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
	return "TestSubZoneProp";
}

String get_editor_additional_text() {
	return "";
}
