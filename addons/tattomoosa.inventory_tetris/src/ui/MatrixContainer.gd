@tool
class_name MatrixContainer
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
@export var custom_minimum_slot_size := Vector2i(40, 40):
	set(value):
		custom_minimum_slot_size = value
		if is_node_ready():
			_place_slots()
@export var refresh : bool = false:
	set(value):
		if value and is_node_ready():
			_place_slots()
@export var edit_cell_prototype := false:
	set(value):
		edit_cell_prototype = value
		if Engine.is_editor_hint():
			_set_edit_prototype(value)
@export var prototype: Control:
	set(value):
		prototype = value
		if prototype and Engine.is_editor_hint():
			edit_cell_prototype = true

var _grid_size := Vector2i(2, 2)

const SLOT_META := &"slot_grid_container_slot"
const INTERNAL_META := &"internal_child"

func _set_edit_prototype(value: bool):
	if value:
		if !prototype:
			prototype = _get_prototype()
		if !get_children().has(prototype):
			add_child(prototype, true)
			prototype.owner = owner
		for child in get_children(true):
			child.visible = child == prototype
		prototype.show()
	else:
		if get_children().has(prototype):
			prototype.hide()
			# remove_child(prototype)
		for child in get_children(true):
			child.visible = child != prototype

func _ready():
	_place_slots()
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)

func map_signal_to_callable(signal_name: String, callable: Callable):
	for x in grid_size.x:
		for y in grid_size.y:
			var slot := _get_slot(x, y)
			if !slot.is_connected(signal_name, callable):
				slot.connect(signal_name, callable.bind(x, y))
			else:
				push_warning(slot, ":", slot.get_meta(SLOT_META), " - already connected")

func _on_child_entered_tree(node: Node):
	if get_child_count() > 0:
		if node == get_child(0):
			if node != prototype:
				prototype.queue_free()
				prototype = node
			edit_cell_prototype = true

func _on_child_exiting_tree(node: Node):
	if get_child_count() > 0:
		if node == get_child(0):
			_place_slots.call_deferred()

func _clear_slots():
	var external_children := get_children()
	for child in get_children(true):
		if !external_children.has(child):
			remove_child(child)
			child.queue_free()
	if get_child_count() > 1:
		push_warning("child count expected: ", 1, "actual: ", get_child_count(true))

func _place_slots():
	_clear_slots()
	columns = grid_size.x

	if !prototype:
		if get_child_count() > 0:
			prototype = get_child(0)
			remove_child(prototype)
		else:
			prototype = _get_prototype()

	prototype.custom_minimum_size = custom_minimum_slot_size
	for y in grid_size.y:
		for x in grid_size.x:
			_add_slot(x, y, prototype)
	size = Vector2i.ZERO
	if get_child_count(true) != grid_size.x * grid_size.y:
		push_warning("child count expected: ", 1, "actual: ", get_child_count(true))
	_map_signals()

func _map_signals():
	map_signal_to_callable("mouse_entered", _on_cell_mouse_entered)
	map_signal_to_callable("mouse_exited", _on_cell_mouse_exited)

func _get_prototype() -> Control:
	return Panel.new()
			
func _add_slot(x: int, y: int, prototype: Control) -> void:
	var slot := prototype.duplicate()
	slot.set_meta(INTERNAL_META, true)
	slot.name = "MatrixContainerSlot[%d,%d]" % [x, y]
	add_child(slot, true, INTERNAL_MODE_BACK)
	slot.set_meta(SLOT_META, Vector2i(x,y))

func _get_slot(x: int, y: int) -> Control:
	return get_child(_get_index(x, y), true)

func _get_slotv(slot_position: Vector2i) -> Control:
	@warning_ignore("integer_division")
	return _get_slot(slot_position.x, slot_position.y)

func _get_index(x: int, y: int) -> int:
	# return x + (y / grid_size.x)
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
