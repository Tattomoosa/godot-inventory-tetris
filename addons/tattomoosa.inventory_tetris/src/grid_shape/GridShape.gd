@tool
class_name GridShape
extends Resource

signal rect_changed
signal cells_changed

@export var rect : Vector2i = Vector2i.ONE:
	set(value):
		if rect != value:
			rect = value
			rect_changed.emit()
@export var _cells := {}:
	set(value):
		_cells = value
		cells_changed.emit()

func has(position: Vector2i) -> bool:
	return _cells.has(position)

func insert(position: Vector2i, value : Variant = true):
	if _cells.has(position):
		push_warning("insert in occupied position: ", position, " - either erase first or use assign")
		return
	_cells[position] = value
	cells_changed.emit()

func assign(position: Vector2i, value : Variant = true):
	_cells[position] = value
	cells_changed.emit()

func erase(position: Vector2i) -> bool:
	if _cells.erase(position):
		cells_changed.emit()
		return true
	return false

func toggle(position: Vector2i):
	if !erase(position):
		insert(position)

func _store_cell_value():
	return true

func _translate_all(by: Vector2i):
	var new_cells := {}
	for c in _cells:
		new_cells[c + by] = _cells[c]
	_cells = new_cells
	# var translated_cells = {}
	# var positions : Array[Vector2i] = _cells.keys()
	# var values : Array[Vector2i] = _cells.values()
	# var translated_positions : Array[Vector2i] = []
	# for i in positions.size():
	# 	var pos := positions[i]
	# 	var translated_pos := pos + by
	# 	_cells.erase(pos)
	# 	translated_positions.push_back(translated_pos)
	# for i in translated_positions.size():

