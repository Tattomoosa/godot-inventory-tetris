@tool
class_name Inventory
extends Resource

# bit hacky but used just to show the inventory control in
# the right spot
@export var _inventory_control: bool = false
# bit hacky but used to add items through the inspector
@export var _add_item: Item:
	get:
		return null
	set(value):
		add_item(value)
# Single item can be in multiple slots, depending on its shape
@export var grid_size := Vector2i(10, 10):
	set(value):
		grid_size = value
		grid_size_changed.emit()
@export var item_instances: Array[InventoryItemInstance]:
	set(value):
		item_instances = value
		_connect_item_instances()
		items_changed.emit()
		_update_slots()
var _slots = {
	# Vector2i.ZERO: InventoryItemInstance
}
# empty means it will allow any item instance
var restrict_to_item_instances : Array[InventoryItemInstance] = []
# empty means it will allow any item
var restrict_to_items : Array[Item] = []

signal grid_size_changed
signal items_changed
signal error_placing_item

func _ready():
	_update_slots()

func _connect_item_instances() -> void:
	for item_instance in item_instances:
		if !item_instance:
			continue
		if !item_instance.changed.is_connected(_on_item_changed):
			item_instance.changed.connect(_on_item_changed)

func has_slot_at(position: Vector2i) -> bool:
	var rect := Rect2i(Vector2i.ZERO, grid_size)
	return rect.has_point(position)

func get_slot(position: Vector2i) -> InventoryItemInstance:
	if !has_slot_at(position):
		push_warning("Out of bounds Inventory access")
	if _slots.has(position):
		return _slots[position]
	return null

func add_item(item: Item) -> bool:
	var position := Vector2i.ZERO
	while !can_fit_shape(item.shape, position):
		position += Vector2i.RIGHT
		if position.x >= grid_size.x:
			position.x = 0
			position.y += 1
		if position.y >= grid_size.y:
			return false
	return add_item_at(item, position)

func add_item_instance_anywhere(item_instance: InventoryItemInstance) -> bool:
	var position := Vector2i.ZERO
	var dup := item_instance.duplicate()
	var start_rotation := item_instance.rotation
	var first_iteration := false
	while !can_fit_shape(dup.shape, position):
		position += Vector2i.RIGHT
		if position.x >= grid_size.x:
			position.x = 0
			position.y += 1
		if position.y >= grid_size.y:
			if !first_iteration:
				if dup.rotation == start_rotation:
					# not found
					return false
			first_iteration = true
			dup.rotate_clockwise()
	item_instance.position = position
	item_instance.rotation = dup.rotation
	return add_item_instance(item_instance)

func add_item_at(item: Item, position: Vector2i) -> bool:
	var item_instance := InventoryItemInstance.from_item(item)
	item_instance.position = position
	return add_item_instance(item_instance)

func add_item_instance_at(item_instance: InventoryItemInstance, position: Vector2i) -> bool:
	item_instance.position = position
	return add_item_instance(item_instance)

func add_item_instance(item_instance: InventoryItemInstance) -> bool:
	if !can_add_item_instance(item_instance):
		return handle_collisions(item_instance)
	item_instances.push_back(item_instance)
	# TODO could just connect the new item
	_connect_item_instances()
	_update_slots()
	items_changed.emit()
	return true

func can_add_item_instance(item_instance: InventoryItemInstance) -> bool:
	if !restrict_to_item_instances.is_empty() and !restrict_to_item_instances.has(item_instance):
		return false
	# TODO untested
	if !restrict_to_items.is_empty() and !restrict_to_items.has(item_instance.item):
		return false
	return can_fit_shape(item_instance.shape, item_instance.position)

func handle_collisions(item_instance: InventoryItemInstance) -> bool:
	var collisions := item_instances_in_shape(item_instance.shape, item_instance.position)
	for collision_instance in collisions:
		for data in collision_instance.data:
			if data.on_item_instance_dropped_onto(item_instance):
				return true

	return false

func can_add_item_instance_at(item_instance: InventoryItemInstance, position: Vector2i) -> bool:
	return can_fit_shape(item_instance.shape, position)

func remove_item_instance(item_instance: InventoryItemInstance) -> void:
	if item_instance.changed.is_connected(_on_item_changed):
		item_instance.changed.disconnect(_on_item_changed)
	item_instances.erase(item_instance)
	_update_slots()
	items_changed.emit()

func remove_item(item: Item):
	for item_instance in item_instances:
		if item_instance.item == item:
			remove_item_instance(item_instance)
			return

func get_item_at(position: Vector2i) -> Item:
	return get_item_instance_at(position).item

func get_item_index_at(position: Vector2i) -> int:
	var instance := get_item_instance_at(position)
	return item_instances.find(instance)

func has_item(item: Item):
	for item_instance in item_instances:
		if item_instance.item == item:
			return true
	return false

func has_item_instance(item_instance: InventoryItemInstance):
	return item_instances.has(item_instance)

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

func get_first_instance_of_item(item: Item) -> InventoryItemInstance:
	for item_instance in item_instances:
		if item_instance.item == item:
			return item_instance
	return null

func get_all_instances_of_item(item: Item) -> Array[InventoryItemInstance]:
	var instances : Array[InventoryItemInstance] = []
	for item_instance in item_instances:
		if item_instance.item == item:
			instances.push_back(item_instance)
	return instances

func get_item_at_index_root_position(item_index: int) -> Vector2i:
	if item_index < 0:
		push_warning("Item not found")
		return Vector2i.ZERO
	return item_instances[item_index].position

func _update_slots() -> void:
	_slots = {}
	for item_instance in item_instances:
		if !item_instance or !item_instance.item:
			continue
		for pos in item_instance.shape:
			_slots[item_instance.position + pos] = item_instance

func _on_item_changed() -> void:
	_update_slots()
	items_changed.emit()

func can_fit_shape(
	shape: Array[Vector2i],
	position: Vector2i = Vector2i.ZERO
) -> bool:
	for slot_pos in shape:
		var pos = position + slot_pos
		if !has_slot_at(pos):
			return false
		if get_slot(pos):
			return false
	return true

func item_instances_in_shape(
	shape: Array[Vector2i],
	position: Vector2i = Vector2i.ZERO
) -> Array[InventoryItemInstance]:
	var collisions : Array[InventoryItemInstance] = []
	for slot_pos in shape:
		var pos = position + slot_pos
		if !has_slot_at(pos):
			continue
		var instance_at := get_slot(pos)
		if instance_at and !collisions.has(instance_at):
			collisions.push_back(instance_at)
	return collisions
		
func _validate_property(property: Dictionary):
	if property.name == "item_instances":
		property.usage = PROPERTY_USAGE_NO_EDITOR