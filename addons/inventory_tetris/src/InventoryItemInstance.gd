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
		resource_name = item.item_name + " (Instance)"
		if item:
			item.changed.connect(_on_item_changed)
		_load_item_data()
		emit_changed()

@export var position: Vector2i:
	set(value):
		position = value
		emit_changed()

@export var rotation: ROTATION = ROTATION.DEG_0:
	set(value):
		rotation = value
		emit_changed()

@export var data: Array[ItemData]:
	get:
		return _data

var _data: Array[ItemData] = []

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
var context_menu: Array[MenuItem]:
	get:
		return _get_context_menu()

var rect : Rect2i:
	get:
		var r := Rect2i(shape[0], Vector2i.ZERO)
		for slot in shape:
			r = r.expand(slot)
		return r

func local_position(pos: Vector2i):
	return pos - position

func _on_item_changed():
	_load_item_data()
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

func _get_context_menu() -> Array[MenuItem]:
	var context_menu: Array[MenuItem] = []
	for d in _data:
		context_menu.append_array(d.context_menu)
	return context_menu

func _load_item_data():
	for d in _data:
		if d.changed.is_connected(emit_changed):
			d.changed.disconnect(emit_changed)
	_data = []
	if !item:
		return
	# TODO this seems to be called much more than it needs to
	for d in item.data:
		if !d: continue
		# var d1 := d.duplicate(true)
		var d1 := d.clone()
		d1.item_instance = self
		d1.changed.connect(emit_changed)
		_data.push_back(d1)

static func from_item(item: Item) -> InventoryItemInstance:
	var item_instance := InventoryItemInstance.new()
	item_instance.item = item
	return item_instance

func get_data(data_type: Variant) -> ItemData:
	for d in data:
		if is_instance_of(d, data_type):
			return d
	return null

class MenuItem extends RefCounted:
	var text : String
	var callable : Callable

	static func create(
		text_: String,
		callable_: Callable
	) -> MenuItem:
		var m := MenuItem.new()
		m.text = text_
		m.callable = callable_
		return m