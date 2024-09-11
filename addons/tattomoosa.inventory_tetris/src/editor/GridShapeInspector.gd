@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is GridShape

func _parse_property(
	object: Object,
	type,
	name,
	hint_type,
	hint_string,
	usage_flags,
	wide
):
	match name:
		"_cells": return _shape_editor(object as GridShape)
	
func _shape_editor(object: GridShape):
	var grid_shape : GridShape = object

	var shape_editor := GridShapeMatrixEditor.new()
	shape_editor.grid_shape = grid_shape

	# var btn : Button = shape_editor._get_prototype()
	var btn : GridShapeButton = GridShapeButton.new()

	var center := CenterContainer.new()
	var panel := PanelContainer.new()

	panel.add_child(center)
	center.add_child(shape_editor)
	shape_editor.add_child(btn)
	add_custom_control(panel)
	return true

class GridShapeButton extends Button:
	func _init():
		action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		toggle_mode = true
	func _ready():
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = get_theme_color("icon_pressed_color", "Button")
		# TODO get editor theme colors... its not working
		add_theme_stylebox_override("pressed", style_box)
