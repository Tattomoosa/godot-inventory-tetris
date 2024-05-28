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

func _ready():
	_populate()

func _populate() -> void:
	for child in get_children():
		child.queue_free()
	if !slot_scene:
		push_warning("no slot scene set")
	columns = grid_size.x
	for x in grid_size.x:
		for y in grid_size.y:
			var slot : Control = slot_scene.instantiate()
			slot.custom_minimum_size = slot_size
			add_child(slot)
