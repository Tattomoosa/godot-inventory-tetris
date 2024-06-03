extends PopupMenu

@export var item_instance: InventoryItemInstance:
	set(value):
		item_instance = value
		_on_item_changed()
	
func _on_item_changed():
	clear()
	for menu_option in item_instance.context_menu:
		add_item(menu_option)