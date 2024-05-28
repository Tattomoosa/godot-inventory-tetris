@tool
class_name Inventory
extends Resource

# Single item can be in multiple slots, depending on its shape
@export var grid_size := Vector2i(10, 10):
	set(value):
		grid_size = value
		grid_size_changed.emit()
@export var item_instances: Array[InventoryItemInstance]:
	set(value):
		item_instances = value
		for item_instance in item_instances:
			if !item_instance:
				continue
			if !item_instance.changed.is_connected(_on_item_changed):
				item_instance.changed.connect(_on_item_changed)
		items_changed.emit()
		_update_slots()
var _slots = {
	# Vector2i.ZERO: InventoryItemInstance
}

signal grid_size_changed
signal items_changed

func _ready():
	_update_slots()

func has_slot_at(position: Vector2i) -> bool:
	var rect := Rect2i(Vector2i.ZERO, grid_size)
	return rect.has_point(position)

func get_slot(position: Vector2i) -> InventoryItemInstance:
	if !has_slot_at(position):
		push_warning("Out of bounds Inventory access")
	if _slots.has(position):
		return _slots[position]
	return null

func add_item(item: Item, position: Vector2i) -> bool:
	var item_instance := InventoryItemInstance.new()
	item_instance.item = item
	item_instance.position = position
	return add_item_instance(item_instance)

func add_item_instance_at(item_instance: InventoryItemInstance, position: Vector2i) -> bool:
	if !can_add_item_instance_at(item_instance, position):
		push_warning("Item instance cannot fit")
		return false
	item_instance.position = position
	return add_item_instance(item_instance)

func add_item_instance(item_instance: InventoryItemInstance) -> bool:
	if !can_add_item_instance(item_instance):
		push_warning("Item instance cannot fit")
		return false
	item_instances.push_back(item_instance)
	_update_slots()
	items_changed.emit()
	return true

func can_add_item_instance(item_instance: InventoryItemInstance) -> bool:
	return can_fit_shape(item_instance.shape, item_instance.position)

func can_add_item_instance_at(item_instance: InventoryItemInstance, position: Vector2i) -> bool:
	return can_fit_shape(item_instance.shape, position)

func remove_item_instance(item_instance: InventoryItemInstance):
	item_instances.erase(item_instance)
	_update_slots()
	items_changed.emit()

func get_item_at(position: Vector2i) -> Item:
	return get_item_instance_at(position).item

func get_item_index_at(position: Vector2i) -> int:
	var instance := get_item_instance_at(position)
	return item_instances.find(instance)

func get_item_root_position_at(position: Vector2i) -> Vector2i:
	var item_instance = get_item_instance_at(position)
	return item_instance.position

func get_item_local_position_at(position: Vector2i) -> Vector2i:
	var item_instance = get_item_instance_at(position)
	if !item_instance:
		push_warning("Item not found at ", position)
		return Vector2i.ZERO
	return item_instance.local_position(position)

func get_item_instance_at(position: Vector2i) -> InventoryItemInstance:
	if _slots.has(position):
		return _slots[position]
	return null

func get_item_at_index_root_position(item_index: int) -> Vector2i:
	if item_index < 0:
		push_warning("Item not found")
		return Vector2i.ZERO
	return item_instances[item_index].position

func _update_slots():
	_slots = {}
	for item_instance in item_instances:
		if !item_instance or !item_instance.item:
			continue
		for pos in item_instance.shape:
			_slots[item_instance.position + pos] = item_instance

func _on_item_changed():
	_update_slots()
	items_changed.emit()

func can_fit_shape(
	shape: Array[Vector2i],
	position: Vector2i = Vector2i.ZERO
) -> bool:
	for slot_pos in shape:
		var pos = position + slot_pos
		if !has_slot_at(pos):
			print("no slot at ", pos)
			return false
		if get_slot(pos):
			print("collision at ", pos)
			return false
	return true