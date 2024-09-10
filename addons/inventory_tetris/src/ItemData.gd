@tool
class_name ItemData
extends Resource

var item_instance : InventoryItemInstance = null
var context_menu: Array[InventoryItemInstance.MenuItem]:
	get:
		return _get_context_menu()

func _get_context_menu() -> Array[InventoryItemInstance.MenuItem]:
	return []

func on_changed_inventory():
	pass

# returning true will consume the item
func on_item_instance_dropped_onto(item_instance: InventoryItemInstance):
	pass

func get_badge() -> Control:
	return null

func clone() -> ItemData:
	return duplicate(true)