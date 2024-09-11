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

func add(position: Vector2i):
	print("add ", position)
	_cells[position] = _store_cell_value()
	cells_changed.emit()

func erase(position: Vector2i) -> bool:
	if _cells.erase(position):
		print("erase ", position)
		cells_changed.emit()
		return true
	return false

func toggle(position: Vector2i):
	if !erase(position):
		print("erase failed, adding")
		add(position)

func _store_cell_value():
	return true