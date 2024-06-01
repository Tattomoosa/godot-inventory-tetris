@tool
class_name InventoryGridPickedItem
extends Control

var item_instance: InventoryItemInstance
## offset from selected grid slot
var offset: Vector2i
## picked from item_instance
var from_item_instance: InventoryItemInstance
## picked from inventory
var from_inventory: Inventory
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
	p.from_item_instance = item_instance_
	p.item_instance = item_instance_.duplicate()
	p.offset = offset_
	p.from_inventory = from_inventory_
	p.over_inventory = over_inventory_ if over_inventory_ else from_inventory_
	return p

func rotate_clockwise():
	offset = Vector2i(-offset.y, offset.x)
	item_instance.rotate_clockwise()

func rotate_counterclockwise():
	offset = Vector2i(offset.y, -offset.x)
	item_instance.rotate_counterclockwise()

func cancel():
	if from_inventory:
		from_inventory.add_item_instance(from_item_instance)

# TODO handle picked item in its own thing, expose to InventoryUI to share between inventories
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("rotate_item_clockwise"):
		rotate_clockwise()
	if Input.is_action_just_pressed("rotate_item_counterclockwise"):
		rotate_counterclockwise()