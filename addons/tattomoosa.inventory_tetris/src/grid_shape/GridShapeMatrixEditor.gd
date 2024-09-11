@tool
class_name GridShapeMatrixEditor
extends ButtonMatrixContainer

@export var grid_shape: GridShape:
	set(value):
		if grid_shape == value:
			return
		_set_connection_to_grid_shape(false)
		grid_shape = value
		_set_connection_to_grid_shape(true)
		if is_node_ready():
			if !grid_shape:
				_clear_slots()
			else:
				_ready()

func _ready():
	print("ready - grid shape ", grid_shape)
	_grid_size = grid_shape.rect if grid_shape else Vector2i.ONE
	super()

func _place_slots():
	super()
	_shape_changed()

func _get_prototype() -> Control:
	var p:= super() as Button
	p.toggle_mode = true
	return p

func _set_grid_size():
	print("set grid size")
	grid_size = grid_shape.rect

func _on_cell_pressed(x: int, y: int):
	super(x, y)
	var slot := _get_slot(x, y) as Button
	var position := Vector2i(x, y)
	if slot.button_pressed:
		grid_shape.add(position)
	else:
		grid_shape.erase(position)

func _shape_changed():
	if !grid_shape:
		_clear_slots()
		return

	for x in grid_size.x:
		for y in grid_size.y:
			_get_slot(x, y).button_pressed = grid_shape.has(Vector2i(x, y))

func _set_connection_to_grid_shape(value: bool):
	if !grid_shape:
		return
	if value:
		grid_shape.rect_changed.connect(_set_grid_size)
		grid_shape.cells_changed.connect(_shape_changed)
	else:
		grid_shape.rect_changed.disconnect(_set_grid_size)
		grid_shape.cells_changed.disconnect(_shape_changed)
