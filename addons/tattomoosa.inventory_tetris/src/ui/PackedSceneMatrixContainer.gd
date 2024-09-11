@tool
class_name PackedSceneMatrixContainer
extends GridContainer

## A container that duplicates its first child to fill a grid with a specified `grid_size`

signal cell_mouse_entered(x: int, y: int)
signal cell_mouse_exited(x: int, y: int)

@export var grid_size := Vector2i(2, 2):
	get:
		return _grid_size
	set(value):
		_grid_size = value
		if is_node_ready():
			_place_slots()
@export var custom_minimum_cell_size := Vector2i(40, 40):
	set(value):
		custom_minimum_cell_size = value
		if is_node_ready():
			_place_slots()
@export var refresh : bool = false:
	set(value):
		if value and is_node_ready():
			_place_slots()
@export var prototype: PackedScene:
	set(value):
		prototype = value
		if value:
			_prototype_instance = value.instantiate()

var _grid_size := Vector2i(2, 2)
var _prototype_instance : Control

const SLOT_META := &"slot_grid_container_slot"
const INTERNAL_META := &"internal_child"

func _ready():
	_place_slots()

func map_signal_to_callable(signal_name: String, callable: Callable):
	for x in grid_size.x:
		for y in grid_size.y:
			var slot := _get_slot(x, y)
			if !slot.is_connected(signal_name, callable):
				slot.connect(signal_name, callable.bind(x, y))
			else:
				push_warning(slot, " at: ", x, ", ", y, " meta: ", slot.get_meta(SLOT_META), " - already connected")

func _clear_slots():
	var external_children := get_children()
	for child in get_children(true):
		if !external_children.has(child):
			remove_child(child)
			child.queue_free()
	if get_child_count(true) > 1:
		push_warning("CLEAR: child count expected: ", 1, "actual: ", get_child_count(true))
		push_warning("CLEAR: external child count expected: ", 1, "actual: ", get_child_count())

func _place_slots():
	_clear_slots()
	columns = grid_size.x

	for y in grid_size.y:
		for x in grid_size.x:
			_add_slot(x, y, _get_prototype_instance())
	size = Vector2i.ZERO
	var expected_child_count := grid_size.x * grid_size.y
	if get_child_count(true) != expected_child_count:
		push_warning("PLACE: child count expected: ", expected_child_count, "actual: ", get_child_count(true))
	if get_child_count() != 1:
		push_warning("PLACE: external child count expected: ", 1, "actual: ", get_child_count())
	_map_signals()

func _map_signals():
	map_signal_to_callable("mouse_entered", _on_cell_mouse_entered)
	map_signal_to_callable("mouse_exited", _on_cell_mouse_exited)

func _get_default_prototype() -> Control:
	return Panel.new()

func _get_prototype_instance() -> Control:
	return _prototype_instance if _prototype_instance else _get_default_prototype()
			
func _add_slot(x: int, y: int, slot_control: Control) -> void:
	var slot := slot_control.duplicate()
	slot.custom_minimum_size = custom_minimum_cell_size
	slot.set_meta(INTERNAL_META, true)
	slot.name = "MatrixContainerSlot[%d,%d]" % [x, y]
	add_child(slot, true, INTERNAL_MODE_FRONT)
	slot.set_meta(SLOT_META, Vector2i(x,y))
	slot.show()

func _get_slot(x: int, y: int) -> Control:
	return get_child(_get_index(x, y), true)

func _get_slotv(slot_position: Vector2i) -> Control:
	@warning_ignore("integer_division")
	return _get_slot(slot_position.x, slot_position.y)

func _get_index(x: int, y: int) -> int:
	return (y * grid_size.x) + x

func _get_indexv(slot_position: Vector2i) -> int:
	return slot_position.x + (slot_position.y * grid_size.x)

func _get_position(i: int) -> Vector2i:
	var x := i % grid_size.x - 1
	@warning_ignore("integer_division")
	var y := (i / grid_size.x)
	return Vector2i(x, y)

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() > 1:
		return PackedStringArray(["MatrixContainer is meant to be used with no more than one child control"])
	return []

func _on_cell_mouse_entered(x: int, y: int):
	cell_mouse_entered.emit(x, y)

func _on_cell_mouse_exited(x: int, y: int):
	cell_mouse_entered.emit(x, y)

func _notification(what):
	match what:
		NOTIFICATION_PRE_SORT_CHILDREN:
			print("pre sort")
			# remove_child(prototype)
		NOTIFICATION_SORT_CHILDREN:
			print("sort")
			