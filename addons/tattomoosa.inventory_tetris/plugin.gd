@tool
extends EditorPlugin

var grid_shape_editor := preload("./src/editor/GridShapeInspector.gd").new()

func _enter_tree():
	# Initialization of the plugin goes here.
	add_inspector_plugin(grid_shape_editor)
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(grid_shape_editor)
	pass
