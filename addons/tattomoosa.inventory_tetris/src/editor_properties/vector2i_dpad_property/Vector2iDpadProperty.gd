@tool
extends EditorProperty

var dpad_control := preload("res://addons/inventory_tetris/src/editor_properties/vector2i_dpad_property/vector2i_dpad_control.tscn").instantiate()

func _init():
	add_child(dpad_control)
	add_focusable(dpad_control)

func _ready():
	dpad_control.vector2i = get_edited_object()[get_edited_property()]
	dpad_control.update_label()
	dpad_control.vector2i_changed.connect(
		func():
			get_edited_object()[get_edited_property()] = dpad_control.vector2i
	)

func _update_property():
	dpad_control.update_label()
