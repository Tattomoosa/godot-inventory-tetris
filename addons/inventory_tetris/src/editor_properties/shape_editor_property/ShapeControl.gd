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
@export var center : Control
@export var reset_button : Button

signal shape_changed

func _ready():
	_update_buttons()
	reset_button.pressed.connect(
		func(): shape = [Vector2i.ZERO]
	)

func _update_buttons():
	var bounds := Rect2i(0,0,0,0)
	for child in center.get_children():
		child.queue_free()
	var add_btn_positions : Array[Vector2i] = []
	var btn_size := button_size
	var space := Vector2i(spacing, spacing)
	for slot in shape:
		var btn := active_cell_button.duplicate()
		btn.position = slot * (btn_size + space)
		btn.custom_minimum_size = btn_size
		center.add_child(btn)
		btn.show()
		btn.pressed.connect(
			func():
				shape.erase(slot)
				shape_changed.emit()
		)

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
				add_btn.position = s * (btn_size + space)
				center.add_child(add_btn)
				add_btn.show()
				add_btn.custom_minimum_size = btn_size
				add_btn_positions.push_back(s)
				add_btn.pressed.connect(
					func():
						shape.push_back(s)
						shape_changed.emit()
				)
			bounds = bounds.expand(s)
	# custom_minimum_size = bounds.size + Vector2i(2,2) * (btn_size + space) * 2
