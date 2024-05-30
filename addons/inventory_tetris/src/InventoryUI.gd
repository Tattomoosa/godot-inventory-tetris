@tool
class_name InventoryUi
extends Control

@export var handle_input := true
@export var slot_size := Vector2i(20, 20)

@export_group("Scene Internal")
@export var inventories : Array[InventoryGridPanel] = []
@export var item_info_panel : ItemInfoPanel

var _active_inventory_index := -1:
	set(value):
		_disconnect_inventory_signals(active_inventory)
		_active_inventory_index = value
		_connect_inventory_signals(active_inventory)

var active_inventory: InventoryGridPanel:
	get:
		if _active_inventory_index < 0:
			return null
		return inventories[_active_inventory_index]

var selected_item_instance : InventoryItemInstance:
	get:
		return active_inventory.selected_item_instance

func _ready():
	# if !Engine.is_editor_hint() and get_tree().get_root().owner == self:
	open()

func open():
	handle_input = true
	visible = true
	_active_inventory_index = 0
	active_inventory.set_active()

func close():
	handle_input = false
	visible = false

func _on_selected_item_changed():
	if !selected_item_instance:
		item_info_panel.item = null
		return
	item_info_panel.item = selected_item_instance.item

func _disconnect_inventory_signals(inventory: InventoryGridPanel):
	if !inventory:
		return
	if inventory.selected_item_instance_changed.is_connected(_on_selected_item_changed):
		inventory.selected_item_instance_changed.disconnect(_on_selected_item_changed)

func _connect_inventory_signals(inventory: InventoryGridPanel):
	if !inventory:
		return
	inventory.selected_item_instance_changed.connect(_on_selected_item_changed)

