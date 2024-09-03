extends EditorInspectorPlugin

const SHAPE_EDITOR_PROPERTY := preload("res://addons/inventory_tetris/src/editor_properties/shape_editor_property/ShapeProperty.gd")

func _can_handle(object):
	return object is Item

func _parse_begin(object):
	return
	# TODO thought this would show a preview but it doesn't
	var item : Item = object
	var center = CenterContainer.new()
	var texture_rect = TextureRect.new()
	texture_rect.texture = item.texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	texture_rect.custom_minimum_size = Vector2(100,100)
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	center.add_child(texture_rect)
	add_custom_control(center)

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	var item : Item = object
	if name == "shape":
		var shape_creator := SHAPE_EDITOR_PROPERTY.new()
		add_property_editor(name, shape_creator)
		return true
	return false
