@tool
class_name GridShapeOutline
extends Control

# does not support shapes with holes in them
@export var shape : Array[Vector2i]:
	set(value):
		shape = value
		queue_redraw()
@export var width := 4:
	set(value):
		width = value
		queue_redraw()
@export var cell_size := Vector2i(30, 30):
	set(value):
		cell_size = value
		queue_redraw()
@export var color := Color.WHITE:
	set(value):
		color = value
		modulate = Color(1,1,1,color.a)
		queue_redraw()

var _color: Color:
	get: return Color(color.r, color.g, color.b, 1)

func dumb_draw():
	var half_size = floor(width / 2.0)
	var half_width := Vector2i(half_size, 0)
	var half_height := Vector2i(0, half_size)
	var half_cell := cell_size / 2
	# point offsets
	var top_left := -half_cell
	var top_right := Vector2i(half_cell.x, -half_cell.y)
	var bottom_left := Vector2i(-half_cell.x, half_cell.y)
	var bottom_right := half_cell

	for slot in shape:
		var center = (slot * cell_size) + half_cell
		if !shape.has(slot + Vector2i.LEFT):
			draw_line(
				center + top_left - half_height,
				center + bottom_left + half_height,
				_color,
				width
			)
		if !shape.has(slot + Vector2i.RIGHT):
			draw_line(
				center + top_right - half_height,
				center + bottom_right + half_height,
				_color,
				width
			)
		if !shape.has(slot + Vector2i.UP):
			draw_line(
				center + top_left - half_width,
				center + top_right + half_width,
				_color,
				width
			)
		if !shape.has(slot + Vector2i.DOWN):
			draw_line(
				center + bottom_left - half_width,
				center + bottom_right + half_width,
				_color,
				width
			)

func _draw():
	dumb_draw()