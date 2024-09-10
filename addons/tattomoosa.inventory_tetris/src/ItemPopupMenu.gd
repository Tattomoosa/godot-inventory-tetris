extends PopupMenu

@export var item_instance: InventoryItemInstance:
	set(value):
		item_instance = value
		_on_item_changed()

var callbacks : Array[Callable] = []

func _ready():
	id_pressed.connect(
		func(index: int):
			callbacks[index].call()
	)
	
func _on_item_changed():
	callbacks = []
	clear()
	for menu_item in item_instance.context_menu:
		add_item(menu_item.text)
		callbacks.push_back(menu_item.callable)