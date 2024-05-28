@tool
extends EditorInspectorPlugin

const VECTOR2I_DPAD_PROPERTY := preload("res://addons/inventory_tetris/src/editor_properties/vector2i_dpad_property/Vector2iDpadProperty.gd")

func _can_handle(object):
	return object is InventoryItemInstance

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var item_instance : InventoryItemInstance = object
	if name == "position":
		add_property_editor(name, VECTOR2I_DPAD_PROPERTY.new())
		return true
	return false

