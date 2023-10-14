tool
extends HBoxContainer

var _resource_type : String = "Resource"
var _resource : Resource = null
var _plugin : EditorPlugin = null

var _picker : EditorResourcePicker = null

signal on_resource_changed(new_res)

func set_resource_type(type : String) -> void:
	_resource_type = type
	
	if _picker:
		_picker.base_type = _resource_type
	
func set_resource(res : Resource) -> void:
	if res && !res.is_class(_resource_type):
		return

	var emit : bool = res != _resource

	_resource = res
	
	if _picker:
		_picker.edited_resource = _resource
	
	if emit:
		emit_signal("on_resource_changed", _resource)

func set_plugin(plugin : EditorPlugin) -> void:
	_plugin = plugin

func _enter_tree():
	if Engine.is_editor_hint():
		_picker = EditorResourcePicker.new()
		_picker.set_h_size_flags(SIZE_EXPAND_FILL)
		_picker.set_v_size_flags(SIZE_EXPAND_FILL)
		add_child(_picker)
			
		if _resource:
			_picker.edited_resource = _resource
			
		_picker.base_type = _resource_type
		
		_picker.connect(@"resource_changed", self, "_on_resource_changed")
		_picker.connect(@"resource_selected", self, "_on_resource_selected")

func _on_resource_changed(resource: Resource) -> void:
	var emit : bool = resource != _resource

	_resource = resource
	
	if emit:
		emit_signal("on_resource_changed", _resource)

func _on_resource_selected(resource: Resource, edit: bool) -> void:
	_plugin.edit_resource(resource)

func on_clear_button_pressed() -> void:
	if _resource:
		set_resource(null)

func on_resource_button_pressed() -> void:
	if _resource && _plugin:
		_plugin.get_editor_interface().inspect_object(_resource)

