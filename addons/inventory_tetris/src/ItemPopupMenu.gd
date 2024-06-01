extends PopupMenu

@export var item_instance: InventoryItemInstance:
	set(value):
		item_instance = value
		_on_item_changed()
	
func _on_item_changed():
	clear()
	print(item_instance.context_menu)
	for menu_option in item_instance.context_menu:
		add_item(menu_option)