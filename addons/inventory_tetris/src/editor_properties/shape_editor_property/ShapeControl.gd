@tool
extends Control

@export var button_size := Vector2i(20, 20)
@export var spacing := 1
@export var shape : Array[Vector2i] = [Vector2i.ZERO]:
	set(value):
		shape = value
		if is_node_ready():
			_update_buttons()
		shape_changed.emit()

@export var add_cell_button : Button
@export var active_cell_button : Button
@export var root_cell_button : Button
@export var center : Control
@export var reset_button : Button
@export var root_left_button : Button
@export var root_down_button : Button
@export var root_up_button : Button
@export var root_right_button : Button

signal shape_changed

func _ready():
	_update_buttons()
	reset_button.pressed.connect(
		func(): shape = [Vector2i.ZERO]
	)
	root_left_button.pressed.connect(func(): _move_root(Vector2i.LEFT))
	root_down_button.pressed.connect(func(): _move_root(Vector2i.DOWN))
	root_up_button.pressed.connect(func(): _move_root(Vector2i.UP))
	root_right_button.pressed.connect(func(): _move_root(Vector2i.RIGHT))

func _move_root(direction: Vector2i) -> void:
	var new_shape := shape.duplicate()
	direction = -direction
	for i in range(0, new_shape.size()):
		new_shape[i] += direction
	shape = new_shape


func _update_buttons() -> void:
	var bounds := Rect2i(0,0,0,0)
	for child in center.get_children():
		child.queue_free()
	var add_btn_positions : Array[Vector2i] = []
	var btn_size := button_size
	var space := Vector2i(spacing, spacing)
	for slot in shape:
		var btn : Button
		if slot == Vector2i.ZERO:
			btn = root_cell_button.duplicate()
		else:
			btn = active_cell_button.duplicate()
			btn.pressed.connect(
				func():
					shape.erase(slot)
					shape_changed.emit()
			)
		center.add_child(btn)
		btn.custom_minimum_size = btn_size
		btn.show()
		btn.position = slot * (Vector2i(btn.size) + space)

		bounds = bounds.expand(slot)

		var add_slots = [
			slot + Vector2i.UP,
			slot + Vector2i.LEFT,
			slot + Vector2i.RIGHT,
			slot + Vector2i.DOWN
		]
		for s in add_slots:
			if !shape.has(s) and !add_btn_positions.has(s):
				var add_btn := add_cell_button.duplicate()
				center.add_child(add_btn)
				add_btn.custom_minimum_size = btn_size
				add_btn.show()
				add_btn.position = s * (Vector2i(add_btn.size) + space)
				add_btn_positions.push_back(s)
				add_btn.pressed.connect(
					func():
						shape.push_back(s)
						shape_changed.emit()
				)
			bounds = bounds.expand(s)
	# custom_minimum_size = bounds.size + Vector2i(2,2) * (btn_size + space) * 2
	root_left_button.disabled = !shape.has(Vector2i.LEFT)
	root_down_button.disabled = !shape.has(Vector2i.DOWN)
	root_up_button.disabled = !shape.has(Vector2i.UP)
	root_right_button.disabled = !shape.has(Vector2i.RIGHT)

