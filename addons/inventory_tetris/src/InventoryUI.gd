@tool
class_name InventoryUi
extends Control

@export var inventory: Inventory:
	set(value):
		_disconnect_inventory_signals()
		inventory = value
		_connect_inventory_signals()

@export var item_icon_scene : PackedScene
@export var handle_input := true
var selected_slot := Vector2i(0,0):
	set(value):
		selected_slot = value
		_on_selected_slot_changed()
@export var slot_select_debounce := 0.1
@export var picked_item_icon_offset := Vector2i(5, 5)

@export_group("Scene Internal")
@export var grid_slots : InventoryGridSlotUi
@export var item_icons : Control
@export var picked_item_icon : InventoryGridItemIcon
@export var selected_item_outliner : GridShapeOutline
@export var item_info_panel : ItemInfoPanel
@export var selected_grid_slot_indicator : Line2D

var can_change_selected_slot := true
var selected_item_instance : InventoryItemInstance = null:
	set(value):
		selected_item_instance = value
		_on_selected_item_changed()

var picked_item_instance : PickedItemInstance = null:
	set(value):
		if picked_item_instance and picked_item_instance.item_instance.changed.is_connected(_on_picked_item_changed):
			picked_item_instance.item_instance.changed.disconnect(_on_picked_item_changed)
		picked_item_instance = value
		if picked_item_instance:
			picked_item_instance.item_instance.changed.connect(_on_picked_item_changed)
		_on_picked_item_changed()

func _ready():
	_on_selected_slot_changed()
	_on_inventory_items_changed()
	_on_selected_item_changed()
	_on_picked_item_changed()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !handle_input:
		return

	if picked_item_instance:
		if Input.is_action_just_pressed("rotate_item_clockwise"):
			picked_item_instance.rotate_clockwise()
		if Input.is_action_just_pressed("rotate_item_counterclockwise"):
			picked_item_instance.rotate_counterclockwise()

	if Input.is_action_just_pressed("ui_accept"):
		if picked_item_instance:
			_placed_picked_item()
		else:
			_pick_item()
		return
	if Input.is_action_just_pressed("ui_cancel"):
		_cancel_picked_item()
		return

	var directional_input = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down",
	)
	if directional_input == Vector2.ZERO:
		return
	change_selected_slot(Vector2i(directional_input))

func change_selected_slot(delta: Vector2i) -> void:
	if !can_change_selected_slot:
		return
	can_change_selected_slot = false
	selected_slot += delta

	if selected_slot.x < 0:
		selected_slot.x = 0
	elif selected_slot.x >= inventory.grid_size.x:
		selected_slot.x = inventory.grid_size.x - 1

	if selected_slot.y < 0:
		selected_slot.y = 0
	elif selected_slot.y >= inventory.grid_size.y:
		selected_slot.y = inventory.grid_size.y - 1

	await get_tree().create_timer(slot_select_debounce).timeout
	can_change_selected_slot = true

#region Private Methods

func _on_selected_slot_changed() -> void:
	var sel := Vector2(selected_slot)
	selected_grid_slot_indicator.position = sel * grid_slots.slot_size
	var slot := selected_slot
	var item_instance = inventory.get_item_instance_at(slot)
	selected_item_instance = item_instance

func _disconnect_inventory_signals():
	if !inventory:
		return
	if inventory.grid_size_changed.is_connected(_on_inventory_size_changed):
		inventory.grid_size_changed.disconnect(_on_inventory_size_changed)
		inventory.items_changed.disconnect(_on_inventory_items_changed)

func _connect_inventory_signals():
	if !inventory:
		return
	inventory.grid_size_changed.connect(_on_inventory_size_changed)
	inventory.items_changed.connect(_on_inventory_items_changed)

func _on_inventory_size_changed():
	grid_slots.grid_size = inventory.grid_size

func _on_inventory_items_changed():
	for child in item_icons.get_children():
		child.queue_free()
	for item_instance in inventory.item_instances:
		if !item_instance:
			continue
		var item := item_instance.item
		if !item:
			continue
		var pos := item_instance.position
		var icon : InventoryGridItemIcon = item_icon_scene.instantiate()
		icon.cell_size = grid_slots.slot_size
		icon.item_instance = item_instance
		icon.position = Vector2(pos) * grid_slots.slot_size
		item_icons.add_child(icon)

func _on_selected_item_changed():
	if !selected_item_instance:
		selected_item_outliner.shape = []
		item_info_panel.item = null
		return
	selected_item_outliner.shape = selected_item_instance.shape
	selected_item_outliner.position = Vector2(selected_item_instance.position) * grid_slots.slot_size
	item_info_panel.item = selected_item_instance.item

# picked item

func _on_picked_item_changed():
	if picked_item_instance:
		picked_item_icon.item_instance = picked_item_instance.item_instance
		picked_item_icon.position = -Vector2(picked_item_instance.offset) * grid_slots.slot_size + Vector2(picked_item_icon_offset)
	else:
		picked_item_icon.item_instance = null
	_on_selected_slot_changed()

func _placed_picked_item():
	var slot := selected_slot
	var drop_slot := slot - picked_item_instance.offset
	var added := inventory.add_item_instance_at(picked_item_instance.item_instance, drop_slot)
	if !added:
		_cancel_picked_item()
	picked_item_instance = null
	pass

# TODO support picked items in multiple "inventories"
func _cancel_picked_item():
	inventory.add_item_instance(picked_item_instance.from_item_instance)
	picked_item_instance = null

func _pick_item():
	if !selected_item_instance:
		return
	var slot := selected_slot
	picked_item_instance = PickedItemInstance.create(
		selected_item_instance,
		inventory.get_item_local_position_at(slot),
		inventory,
	)
	# picked_item_icon.position = -Vector2(picked_item_instance.offset) * grid_slots.slot_size
	inventory.remove_item_instance(picked_item_instance.from_item_instance)
	selected_item_instance = null
	return

#region PickedItemInstance

class PickedItemInstance:
	var item_instance: InventoryItemInstance
	var offset: Vector2i
	var from_item_instance: InventoryItemInstance
	var from_inventory: Inventory

	var item: Item:
		get:
			return item_instance.item

	var shape: Array[Vector2i]:
		get:
			return item_instance.shape

	static func create(
		item_instance_: InventoryItemInstance,
		offset_: Vector2i,
		from_inventory_: Inventory,
	) -> PickedItemInstance:
		var p := PickedItemInstance.new()
		p.from_item_instance = item_instance_
		p.item_instance = item_instance_.duplicate()
		p.offset = offset_
		p.from_inventory = from_inventory_
		return p
	
	func rotate_clockwise():
		offset = Vector2i(-offset.y, offset.x)
		item_instance.rotate_clockwise()

	func rotate_counterclockwise():
		offset = Vector2i(offset.y, -offset.x)
		item_instance.rotate_counterclockwise()