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
@export var texture : Texture:
	set(value):
		texture = value
		emit_changed()
@export var slot_color : Color = Color.GRAY:
	set(value):
		slot_color = value
		emit_changed()

var rect : Rect2i:
	get:
		#var r := Rect2i(0,0,0,0)
		var r := Rect2i(shape[0], Vector2i.ZERO)
		for slot in shape:
			r = r.expand(slot)
		return r