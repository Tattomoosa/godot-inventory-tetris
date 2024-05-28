@tool
extends EditorProperty

var shape_control := preload("res://addons/inventory_tetris/src/editor_properties/shape_editor_property/shape_control.tscn").instantiate()

func _init():
	add_child(shape_control)
	add_focusable(shape_control)

func _ready():
	shape_control.shape = get_edited_object()[get_edited_property()]
	shape_control.shape_changed.connect(
		func():
			get_edited_object()[get_edited_property()] = shape_control.shape
			emit_changed(get_edited_property(), get_edited_property())
	)

func _update_property():
	# Read the current value from the property.
	# var shape = get_edited_object()[get_edited_property()]

	# Update the control with the new value.
	shape_control._update_buttons()
