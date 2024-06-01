@tool
class_name InventoryGridSlotUi
extends GridContainer

@export var slot_size := Vector2(30.0, 30.0)
@export var grid_size := Vector2i(10, 10):
	set(value):
		grid_size = value
		if is_node_ready():
			_populate()

@export var slot_scene : PackedScene
@export var selected_slot := Vector2i.ZERO
@export var slot_focused := false

signal selected_slot_changed
signal slot_clicked(Vector2i)
signal slot_right_clicked(Vector2i)

var _slots := {}

func _init():
	# TODO this doesn't work...
	add_theme_constant_override("theme_override_constants/h_separation", 0)
	add_theme_constant_override("theme_override_constants/v_separation", 0)

func _ready():
	_populate()
	focus_mode = Control.FOCUS_ALL
	focus_entered.connect(_on_focused)
	mouse_exited.connect(
		func():
			print("MOSUE EXITED")
			_slots[selected_slot].release_focus()
	)

func _populate() -> void:
	for child in get_children():
		child.queue_free()
	if !slot_scene:
		push_warning("no slot scene set")
	columns = grid_size.x
	for y in grid_size.y:
		for x in grid_size.x:
			var slot : Control = slot_scene.instantiate()
			slot.custom_minimum_size = slot_size
			_slots[Vector2i(x,y)] = slot
			add_child(slot)
			slot.name = "Slot_" + str(x) + "_" + str(y)

	# setup focus neighbors
	for x in grid_size.x:
		for y in grid_size.y:
			var pos := Vector2i(x, y)
			var slot := get_slot(pos)
			slot.focus_mode = Control.FOCUS_ALL
			slot.focus_entered.connect(
				func():
					selected_slot = pos
					slot_focused = true
					selected_slot_changed.emit()
			)
			slot.focus_exited.connect(
				func():
					slot_focused = false
					selected_slot_changed.emit()
			)
			slot.clicked.connect(
				func():
					slot_clicked.emit(pos)
			)
			slot.right_clicked.connect(
				func():
					slot_right_clicked.emit(pos)
			)
			if x > 0:
				var left_neighbor = get_slot(Vector2i(x - 1, y))
				slot.focus_neighbor_left = left_neighbor.get_path()
			if y > 0:
				var top_neighbor = get_slot(Vector2i(x, y - 1))
				slot.focus_neighbor_top = top_neighbor.get_path()
			if x < grid_size.x - 1:
				var right_neighbor = get_slot(Vector2i(x + 1, y))
				slot.focus_neighbor_right = right_neighbor.get_path()
			if y < grid_size.y - 1:
				var bottom_neighbor = get_slot(Vector2i(x, y + 1))
				slot.focus_neighbor_bottom = bottom_neighbor.get_path()

func get_slot(pos: Vector2i) -> Control:
	return _slots[pos]

func _on_focused():
	var slot := get_slot(selected_slot)
	slot.grab_focus()