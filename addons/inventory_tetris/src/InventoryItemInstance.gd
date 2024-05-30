@tool
class_name InventoryItemInstance
extends Resource

@export var item: Item:
	set(value):
		if item == value:
			return
		if item:
			if item.changed.is_connected(_on_item_changed):
				item.changed.disconnect(_on_item_changed)
		item = value
		resource_name = item.item_name
		if item:
			item.changed.connect(_on_item_changed)
		emit_changed()
@export var position: Vector2i:
	set(value):
		position = value
		emit_changed()
@export var rotation: ROTATION = ROTATION.DEG_0:
	set(value):
		rotation = value
		emit_changed()

enum ROTATION {
	DEG_0,
	DEG_90,
	DEG_180,
	DEG_270
}

var shape: Array[Vector2i] = []:
	get:
		if !item:
			return []
		return get_rotated_shape()
var item_name: String:
	get:
		if !item:
			return "."
		return item.item_name
var slot_color: Color:
	get:
		if !item:
			return Color.GRAY
		return item.slot_color

func local_position(pos: Vector2i):
	return pos - position

func _on_item_changed():
	emit_changed()

func get_rotated_shape(rot: ROTATION = rotation):
	if rot == ROTATION.DEG_0: return item.shape
	var rotated_shape : Array[Vector2i] = []
	for slot in item.shape:
		rotated_shape.push_back(get_rotated_slot_position(slot))
	return rotated_shape

func rotate_clockwise():
	match rotation:
		ROTATION.DEG_0: rotation = ROTATION.DEG_90
		ROTATION.DEG_90: rotation = ROTATION.DEG_180
		ROTATION.DEG_180: rotation = ROTATION.DEG_270
		ROTATION.DEG_270: rotation = ROTATION.DEG_0

func rotate_counterclockwise():
	match rotation:
		ROTATION.DEG_0: rotation = ROTATION.DEG_270
		ROTATION.DEG_270: rotation = ROTATION.DEG_180
		ROTATION.DEG_180: rotation = ROTATION.DEG_90
		ROTATION.DEG_90: rotation = ROTATION.DEG_0

func get_rotated_slot_position(slot: Vector2i, rot: ROTATION = rotation) -> Vector2i:
	match rot:
		ROTATION.DEG_0: return slot
		ROTATION.DEG_90: return Vector2i(-slot.y, slot.x)
		ROTATION.DEG_180: return Vector2i(-slot.x, -slot.y)
		ROTATION.DEG_270: return Vector2i(slot.y, -slot.x)
		# unreachable, just for type checker
		_: return Vector2i.ZERO

func get_rotation_degrees() -> float:
	match rotation:
		ROTATION.DEG_0: return 0
		ROTATION.DEG_90: return 90
		ROTATION.DEG_180: return 180
		ROTATION.DEG_270: return 270
		# unreachable, just for type checker
		_: return 0

static func from_item(item: Item) -> InventoryItemInstance:
	var item_instance := InventoryItemInstance.new()
	item_instance.item = item
	return item_instance