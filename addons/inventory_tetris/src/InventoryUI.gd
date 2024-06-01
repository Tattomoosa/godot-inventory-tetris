@tool
class_name InventoryUi
extends Control

@export var slot_size := Vector2i(30, 30)

@export_group("Scene Internal")
@export var inventories : Array[InventoryGridPanel] = []
@export var item_info_panel : ItemInfoPanel

signal opened
signal closed
signal picked_item_changed

var selected_item_instance : InventoryItemInstance:
	set(value):
		selected_item_instance = value
		_update_item_panel()

var picked_item_instance : InventoryGridPanel.PickedItemInstance:
	set(value):
		picked_item_instance = value
		for inventory in inventories:
			inventory.picked_item_instance = picked_item_instance
		_update_item_panel()
		picked_item_changed.emit()

var can_close := true

func _ready():
	for inventory in inventories:
		inventory.picked_item_instance_changed.connect(
			func(picked_item_instance_):
				picked_item_instance = picked_item_instance_
		)
		inventory.selected_item_instance_changed.connect(
			func(selected_item_instance_):
				selected_item_instance = selected_item_instance_
		)

# func _unhandled_input(event):
# 	if !visible:
# 		return
# 	print("inventory ui event\n", event)
# 	if event is InputEventKey:
# 		if event.is_action_pressed("ui_cancel"):
# 			if picked_item_instance:
# 				picked_item_instance.cancel()
# 				picked_item_instance = null
# 				get_viewport().set_input_as_handled()
# 			else:
# 				close()
# 				get_viewport().set_input_as_handled()
# 		if event.is_action_pressed("inventory"):
# 			close()
# 			get_viewport().set_input_as_handled()

func _process(_delta: float):
	if Engine.is_editor_hint():
		return
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if picked_item_instance:
			picked_item_instance.cancel()
			picked_item_instance = null
			get_viewport().set_input_as_handled()
		else:
			close()
			get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("inventory"):
		close()
		get_viewport().set_input_as_handled()

func open():
	visible = true
	inventories[0].set_active()
	opened.emit()
	can_close = false
	await get_tree().create_timer(0.1).timeout
	can_close = true

func close():
	if !can_close:
		print("CANT CLOSE")
		return
	if picked_item_instance:
		picked_item_instance.cancel()
	visible = false
	closed.emit()

func _update_item_panel():
	var item : Item = null
	if picked_item_instance:
		item = picked_item_instance.item_instance.item
	elif selected_item_instance:
		item = selected_item_instance.item
	item_info_panel.item = item

