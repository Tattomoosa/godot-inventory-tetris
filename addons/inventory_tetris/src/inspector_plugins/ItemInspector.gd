extends EditorInspectorPlugin

const SHAPE_EDITOR_PROPERTY := preload("res://addons/inventory_tetris/src/editor_properties/shape_editor_property/ShapeProperty.gd")

func _can_handle(object):
	return object is Item

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var item : Item = object
	if name == "shape":
		var shape_creator := SHAPE_EDITOR_PROPERTY.new()
		add_property_editor(name, shape_creator)
		return true
	return false
