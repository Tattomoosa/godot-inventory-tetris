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

@export var cell_size := Vector2i(30,30):
	set(value):
		cell_size = value
		_on_item_changed()

@export_group("Texture Tint")
@export var texture_modulate : Color = Color.WHITE:
	set(value):
		texture_modulate = value
		if is_node_ready():
			_update_texture()

@export_group("Background", "background_")
@export var background_use_item_color := true:
	set(value):
		background_use_item_color = value
		if is_node_ready():
			_update_background()

## If the color has a lower opacity it will be used instead
@export var background_opacity := 0.2:
	set(value):
		background_opacity = value
		if is_node_ready():
			_update_background()

@export var background_color := Color(1,1,1,0.1):
	set(value):
		background_color = value
		if is_node_ready():
			_update_background()

@export_group("Outline", "outline_")
@export var outline_show := false:
	set(value):
		outline_show = value
		outline_changed.emit()
@export var outline_use_item_color := true:
	set(value):
		outline_use_item_color = value
		outline_changed.emit()
@export var outline_width := 2.0:
	set(value):
		outline_width = value
		outline_changed.emit()
@export var outline_color := Color.WHITE:
	set(value):
		outline_color = value
		outline_changed.emit()

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect
@onready var shape_preview: Control = $Shape
@onready var shape_outline: GridShapeOutline = $GridShapeOutline
@onready var badge_container : Control = $BadgeContainer

var shape_cell := ColorRect.new()

signal outline_changed

func _ready() -> void:
	shape_cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outline_changed.connect(_update_outline)
	_on_item_changed()

func _on_item_changed() -> void:
	if !is_node_ready():
		return
	if !item_instance:
		_clear()
		return
	label.text = item_instance.item_name
	_update_shape()
	_update_badges()

func _clear() -> void:
	if !is_node_ready():
		return
	label.text = ""
	texture_rect.texture = null
	for child in shape_preview.get_children():
		child.queue_free()
	shape_outline.shape = []

# Draws the item shape using the item's slot_color
func _update_shape() -> void:
	_update_background()
	_update_outline()
	_update_texture()

func _get_top_left_slot() -> Vector2i:
	var shape := item_instance.shape
	var top_left : Vector2i = item_instance.rect.position
	while !shape.has(top_left):
		top_left.x += 1
	return top_left

func _get_bottom_right_slot() -> Vector2i:
	var shape := item_instance.shape
	var bottom_right : Vector2i = item_instance.rect.position + item_instance.rect.size
	while !shape.has(bottom_right):
		bottom_right.x -= 1
	return bottom_right

func _update_badges() -> void:
	if Engine.is_editor_hint():
		return
	for child in badge_container.get_children():
		child.queue_free()
	for data in item_instance.data:
		var badge : Control = data.get_badge()
		if badge:
			badge_container.add_child(badge)

	badge_container.position = _get_top_left_slot() * cell_size
	# var pos := _get_bottom_right_slot() * cell_size
	# badge_container.size = Vector2i.ZERO
	# pos.y += cell_size.y - badge_container.size.y
	# badge_container.position = pos


func _update_background() -> void:
	var color := item_instance.slot_color if background_use_item_color else background_color
	color.a = background_opacity if background_opacity < color.a else color.a

	# var color := Color(
	# 	item_instance.slot_color.r,
	# 	item_instance.slot_color.g,
	# 	item_instance.slot_color.b,
	# 	opacity)
	for child in shape_preview.get_children():
		child.queue_free()
	for pos in item_instance.shape:
		var cell : ColorRect = shape_cell.duplicate()
		shape_preview.add_child(cell)
		var offset := Vector2i.ZERO
		cell.position = (pos * cell_size) + offset
		cell.color = color
		cell.size = cell_size

func _update_outline() -> void:
	shape_outline.width = outline_width
	if !item_instance:
		return
	shape_outline.visible = outline_show
	shape_outline.shape = item_instance.shape
	shape_outline.cell_size = cell_size
	if outline_use_item_color:
		shape_outline.color = item_instance.slot_color
	else:
		shape_outline.color = outline_color


func _update_texture() -> void:
	var item := item_instance.item
	var item_rect := item.rect
	item_rect.size += Vector2i.ONE
	item_rect.size *= cell_size
	item_rect.position *= cell_size
	texture_rect.pivot_offset = cell_size / 2
	texture_rect.texture = item.texture
	texture_rect.size = item_rect.size
	texture_rect.position = item_rect.position
	texture_rect.rotation_degrees = item_instance.get_rotation_degrees()
	texture_rect.modulate = texture_modulate
