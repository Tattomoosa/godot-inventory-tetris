@tool
class_name InventoryGridPickedItem
extends Control

signal rotated

var item_instance: InventoryItemInstance
## offset from selected grid slot
var offset: Vector2i
## picked from item_instance
# var from_item_instance: InventoryItemInstance
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
 	offset_: Vector2i,
 	from_inventory_: Inventory,
	scene: PackedScene,
	over_inventory_: Inventory = null
):
	var p : InventoryGridPickedItem = scene.instantiate()
	p.item_instance = item_instance_
	p.offset = offset_
	p.from_slot = item_instance_.position
	p.from_inventory = from_inventory_
	p.from_rotation = item_instance_.rotation
	p.over_inventory = over_inventory_ if over_inventory_ else from_inventory_
	return p

func rotate_clockwise():
	offset = Vector2i(-offset.y, offset.x)
	item_instance.rotate_clockwise()
	rotated.emit()

func rotate_counterclockwise():
	offset = Vector2i(offset.y, -offset.x)
	item_instance.rotate_counterclockwise()
	rotated.emit()

func cancel():
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
	if Input.is_action_just_pressed("rotate_item_clockwise"):
		rotate_clockwise()
	if Input.is_action_just_pressed("rotate_item_counterclockwise"):
		rotate_counterclockwise()