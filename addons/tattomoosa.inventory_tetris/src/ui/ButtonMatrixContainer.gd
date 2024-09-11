@tool
class_name ButtonMatrixContainer
extends MatrixContainer

signal cell_pressed(x: int, y: int)

func _get_prototype() -> Control:
	return Button.new()

func _map_signals():
	super()
	map_signal_to_callable("pressed", _on_cell_pressed)

func _on_cell_pressed(x: int, y: int):
	print("cell pressed: ", x, ", ", y)
	cell_pressed.emit(x, y)
