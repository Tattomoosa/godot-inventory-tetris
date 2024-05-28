@tool
extends EditorProperty

var shape_creator := preload("res://addons/inventory_tetris/src/shape_creator/shape_creator.tscn").instantiate()

func _init():
	add_child(shape_creator)
	add_focusable(shape_creator)

func _ready():
	shape_creator.shape = get_edited_object()[get_edited_property()]
	shape_creator.shape_changed.connect(
		func():
			get_edited_object()[get_edited_property()] = shape_creator.shape
			emit_changed(get_edited_property(), get_edited_property())
	)

func _update_property():
	# Read the current value from the property.
	var shape = get_edited_object()[get_edited_property()]

	# Update the control with the new value.
	# shape_creator.shape = shape
	shape_creator._update_buttons()
