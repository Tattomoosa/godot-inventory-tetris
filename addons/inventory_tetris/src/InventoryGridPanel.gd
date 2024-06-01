@tool
extends PanelContainer
class_name InventoryGridPanel

signal selected_slot_changed
signal selected_item_instance_changed(InventoryItemInstance)
signal picked_item_instance_changed(PickedItemInstance)

@export var inventory: Inventory:
	set(value):
		_disconnect_inventory_signals()
		inventory = value
		_connect_inventory_signals()
		if is_node_ready():
			_on_inventory_items_changed()
			_on_inventory_size_changed()

@export var item_icon_scene : PackedScene
@export var handle_input := true
var selected_slot := Vector2i(0,0):
	get:
		return grid_slots.selected_slot
var has_selected_slot : bool:
	get:
		return grid_slots.has_slot_focused

@export var slot_select_debounce := 0.1
@export var picked_item_icon_offset := Vector2i(5, 5)

@export_group("Scene Internal")
@export var item_icons : Control
@export var grid_slots : InventoryGridSlotUi
@export var selected_item_outliner : GridShapeOutline
@export var selected_grid_slot_indicator : Line2D
@export var inspector_item_popup_menu : PopupMenu
@export var item_popup_menu : PopupMenu
@export var picked_item_scene : PackedScene # InventoryGridPickedItem

var can_change_selected_slot := true
var selected_item_instance : InventoryItemInstance = null:
	set(value):
		selected_item_instance = value
		_on_selected_item_changed()

var picked_item_instance : InventoryGridPickedItem = null:
	set(value):
		if value == picked_item_instance:
			return
		if value == null and picked_item_instance and picked_item_instance.over_inventory == self.inventory:
			picked_item_instance.queue_free()
		if picked_item_instance and picked_item_instance.item_instance.changed.is_connected(_on_picked_item_changed):
			picked_item_instance.item_instance.changed.disconnect(_on_picked_item_changed)
		picked_item_instance = value
		if picked_item_instance:
			picked_item_instance.item_instance.changed.connect(_on_picked_item_changed)
			if picked_item_instance.over_inventory == self.inventory:
				selected_grid_slot_indicator.add_child(picked_item_instance)
		_on_picked_item_changed()

#region Public Methods

func set_active():
	if !Engine.is_editor_hint():
		grid_slots.grab_focus()

func pick_item(item_instance: InventoryItemInstance):
	picked_item_instance = InventoryGridPickedItem.create(
		item_instance,
		Vector2i.ZERO,
		inventory,
		picked_item_scene
	)
	picked_item_instance_changed.emit(picked_item_instance)

#region Private Methods

func _ready():
	grid_slots.selected_slot_changed.connect(_on_selected_slot_changed)
	grid_slots.slot_clicked.connect(_on_slot_clicked)
	grid_slots.slot_right_clicked.connect(_on_slot_right_clicked)
	item_popup_menu.popup_hide.connect(
		func():
			grid_slots.grab_focus()
	)
	_on_selected_slot_changed()
	_on_inventory_size_changed()
	_on_inventory_items_changed()
	_on_selected_item_changed()
	_on_picked_item_changed()
	if Engine.is_editor_hint():
		_setup_inspector_item_popup_menu()

func _gui_input(_event):
	grid_slots.grab_focus()

# picked item

func _on_picked_item_changed():
	if picked_item_instance:
		picked_item_instance.item_icon.item_instance = picked_item_instance.item_instance
		picked_item_instance.item_icon.position = -Vector2(picked_item_instance.offset) * grid_slots.slot_size + Vector2(picked_item_icon_offset)
	_on_selected_slot_changed()

func _placed_picked_item():
	var slot := selected_slot
	var drop_slot := slot - picked_item_instance.offset
	var added := inventory.add_item_instance_at(picked_item_instance.item_instance, drop_slot)
	if !added:
		_cancel_picked_item()
	picked_item_instance = null
	picked_item_instance_changed.emit(picked_item_instance)

# TODO support picked items in multiple "inventories"
func _cancel_picked_item():
	if picked_item_instance:
		picked_item_instance.cancel()
		# inventory.add_item_instance(picked_item_instance.from_item_instance)
	picked_item_instance = null
	picked_item_instance_changed.emit(picked_item_instance)

func _pick_selected_item():
	if !selected_item_instance:
		return
	var slot := selected_slot
	picked_item_instance = InventoryGridPickedItem.create(
		selected_item_instance,
		inventory.get_item_local_position_at(slot),
		inventory,
		picked_item_scene
	)
	inventory.remove_item_instance(picked_item_instance.from_item_instance)
	selected_item_instance = null
	picked_item_instance_changed.emit(picked_item_instance)


func _on_slot_clicked(_pos: Vector2i):
	if picked_item_instance:
		_placed_picked_item()
	else:
		_pick_selected_item()

func _on_slot_right_clicked(pos: Vector2i):
	if !selected_item_instance:
		return
	var screen_position := grid_slots.get_slot(pos).get_screen_position()
	if Engine.is_editor_hint():
		inspector_item_popup_menu.position = screen_position
		inspector_item_popup_menu.show()
	else:
		item_popup_menu.item_instance = selected_item_instance
		if item_popup_menu.item_count > 0:
			item_popup_menu.position = screen_position
			item_popup_menu.show()

#region callbacks

func _setup_inspector_item_popup_menu():
	inspector_item_popup_menu.id_pressed.connect(
		func(index: int):
			match index:
				0:
					selected_item_instance.rotate_clockwise()
					inventory._on_item_changed()
					selected_item_instance = null
				1:
					selected_item_instance.rotate_counterclockwise()
					inventory._on_item_changed()
					selected_item_instance = null
				2:
					inventory.remove_item_instance(selected_item_instance)
					inventory._on_item_changed()
					selected_item_instance = null
	)

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

func _on_selected_slot_changed() -> void:
	selected_slot
	if !grid_slots.has_slot_focused:
		selected_grid_slot_indicator.hide()
		selected_item_instance = null
		return
	selected_grid_slot_indicator.show()
	selected_grid_slot_indicator.position = Vector2(selected_slot) * grid_slots.slot_size
	var slot := selected_slot
	if picked_item_instance:
		if picked_item_instance.over_inventory != self.inventory:
			picked_item_instance.over_inventory = self.inventory
			picked_item_instance.reparent(selected_grid_slot_indicator, false)
			picked_item_instance.position = Vector2i.ZERO
		return
	selected_item_instance = inventory.get_item_instance_at(slot)

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
	# TODO this fires whenever slot changed...
	if !selected_item_instance:
		selected_item_outliner.shape = []
	else:
		selected_item_outliner.shape = selected_item_instance.shape
		selected_item_outliner.color = selected_item_instance.slot_color
		selected_item_outliner.position = Vector2(selected_item_instance.position) * grid_slots.slot_size
	selected_item_instance_changed.emit(selected_item_instance)