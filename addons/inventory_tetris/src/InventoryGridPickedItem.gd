@tool
class_name InventoryGridPickedItem
extends Control

signal rotated

## picked from item_instance
var item_instance: InventoryItemInstance:
	set(value):
		item_instance = value
		if item_icon:
			item_icon.item_instance = value
			item_icon.position = Vector2(-offset * cell_size) + icon_offset

## offset from selected grid slot
var offset: Vector2i
var icon_offset: Vector2
var cell_size: Vector2i
## picked from inventory
var from_inventory: Inventory
var from_slot : Vector2i
var from_rotation : InventoryItemInstance.ROTATION
## currently over inventory
var over_inventory: Inventory

@export_category("Scene Internal")
@export var item_icon: InventoryGridItemIcon

var item: Item:
	get:
		return item_instance.item

var shape: Array[Vector2i]:
	get:
		return item_instance.shape

static func create(
 	item_instance_: InventoryItemInstance,
	slot_size_: Vector2i,
 	offset_: Vector2i,
 	from_inventory_: Inventory,
	scene: PackedScene,
	icon_offset_: Vector2i = Vector2i.ZERO,
	over_inventory_: Inventory = null,
) -> InventoryGridPickedItem:
	var p : InventoryGridPickedItem = scene.instantiate()
	p.item_instance = item_instance_
	p.cell_size = slot_size_
	p.icon_offset = icon_offset_
	p.offset = offset_
	p.from_slot = item_instance_.position
	p.from_inventory = from_inventory_
	p.from_rotation = item_instance_.rotation
	p.over_inventory = over_inventory_ if over_inventory_ else from_inventory_
	return p

func rotate_clockwise() -> void:
	offset = Vector2i(-offset.y, offset.x)
	item_instance.rotate_clockwise()
	rotated.emit()

func rotate_counterclockwise() -> void:
	offset = Vector2i(offset.y, -offset.x)
	item_instance.rotate_counterclockwise()
	rotated.emit()

func cancel() -> void:
	if from_inventory:
		item_instance.rotation = from_rotation
		from_inventory.add_item_instance_at(item_instance, from_slot)

func place(slot: Vector2i) -> bool:
	var drop_slot := slot - offset
	var result := over_inventory.add_item_instance_at(item_instance, drop_slot)
	if result:
		if over_inventory != from_inventory:
			for d in item_instance.data:
				d.on_changed_inventory()
	return result

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if InputMap.has_action("rotate_item_clockwise"):
		if Input.is_action_just_pressed("rotate_item_clockwise"):
			rotate_clockwise()
	if InputMap.has_action("rotate_item_counterclockwise"):
		if Input.is_action_just_pressed("rotate_item_counterclockwise"):
			rotate_counterclockwise()