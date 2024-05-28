@tool
extends EditorPlugin

var item_inspector_plugin := preload("res://addons/inventory_tetris/src/inspector_plugins/ItemInspector.gd").new()

func _enter_tree():
	# Initialization of the plugin goes here.
	add_inspector_plugin(item_inspector_plugin)
	pass

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(item_inspector_plugin)
	pass