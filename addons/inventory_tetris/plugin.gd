@tool
extends EditorPlugin

var item_inspector_plugin := preload("./src/inspector_plugins/ItemInspector.gd").new()
var item_instance_inspector_plugin := preload("./src/inspector_plugins/InventoryItemInstanceInspector.gd").new()
var inventory_inspector_plugin := preload("./src/inspector_plugins/InventoryInspector.gd").new()

func _enter_tree():
	# Initialization of the plugin goes here.
	add_inspector_plugin(item_inspector_plugin)
	add_inspector_plugin(item_instance_inspector_plugin)
	add_inspector_plugin(inventory_inspector_plugin)
	pass

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(item_inspector_plugin)
	remove_inspector_plugin(item_instance_inspector_plugin)
	remove_inspector_plugin(inventory_inspector_plugin)
	pass