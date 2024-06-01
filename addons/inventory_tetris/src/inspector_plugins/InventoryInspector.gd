@tool
extends EditorInspectorPlugin

const INVENTORY_GRID_PANEL := preload("res://addons/inventory_tetris/src/inventory_grid_panel.tscn")

func _can_handle(object):
	return object is Inventory

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "_inventory_control":
		var inventory : Inventory = object
		var grid : InventoryGridPanel = INVENTORY_GRID_PANEL.instantiate()
		grid.inventory = inventory

		var center_parent := CenterContainer.new()
		center_parent.add_child(grid)
		add_custom_control(center_parent)
		return true
	if name == "item_instances":
		return true