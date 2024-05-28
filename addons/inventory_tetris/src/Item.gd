@tool
class_name Item
extends Resource
# TODO maybe rename ItemDefinition or ItemData

@export var item_name := "Item":
	set(value):
		item_name = value
		emit_changed()
@export_multiline var description := "Some sort of thing...":
	set(value):
		description = value
		emit_changed()
@export var shape : Array[Vector2i] = [
	Vector2i.ZERO
]:
	set(value):
		shape = value
		emit_changed()
@export var texture : ImageTexture:
	set(value):
		texture = value
		emit_changed()
@export var slot_color : Color = Color.GRAY:
	set(value):
		slot_color = value
		emit_changed()

var rect : Rect2i:
	get:
		var r := Rect2i(0,0,0,0)
		for slot in shape:
			r.expand(slot)
		return r