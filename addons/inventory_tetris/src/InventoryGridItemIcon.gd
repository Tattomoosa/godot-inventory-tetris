@tool
class_name InventoryGridItemIcon
extends Control

@export var item_instance: InventoryItemInstance:
	set(value):
		if item_instance:
			if item_instance.changed.is_connected(_on_item_changed):
				item_instance.changed.disconnect(_on_item_changed)
		if !value:
			_clear()
		item_instance = value
		if item_instance:
			item_instance.changed.connect(_on_item_changed)
		_on_item_changed()

@export var cell_size := Vector2i(20,20)
@export var outline_width := 2.0:
	set(value):
		outline_width = value
		if is_node_ready():
			_update_shape()

@onready var label: Label = $Label
@onready var icon: TextureRect = $TextureRect
@onready var shape_preview: Control = $Shape
@onready var shape_outline: GridShapeOutline = $GridShapeOutline

var shape_cell := ColorRect.new()

func _ready():
	shape_cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_on_item_changed()

func _on_item_changed():
	if !is_node_ready():
		return
	if !item_instance:
		_clear()
		return
	label.text = item_instance.item_name
	_update_shape()

func _clear():
	if !is_node_ready():
		return
	label.text = "NULL"
	icon.texture = null
	for child in shape_preview.get_children():
		child.queue_free()
	shape_outline.shape = []

# Draws the item shape using the item's slot_color
func _update_shape():
	var color := Color(
		item_instance.slot_color.r,
		item_instance.slot_color.g,
		item_instance.slot_color.b,
		0.2)
	for child in shape_preview.get_children():
		child.queue_free()
	for pos in item_instance.shape:
		var cell : ColorRect = shape_cell.duplicate()
		shape_preview.add_child(cell)
		var offset := Vector2i.ZERO
		cell.position = (pos * cell_size) + offset
		cell.color = color
		cell.size = cell_size

	shape_outline.shape = item_instance.shape
	shape_outline.color = item_instance.slot_color
	shape_outline.width = outline_width