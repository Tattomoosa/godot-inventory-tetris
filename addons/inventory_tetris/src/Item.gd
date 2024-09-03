@tool
class_name Item
extends Resource
# TODO maybe rename ItemDefinition or ItemData

@export var item_name := "Item":
	set(value):
		item_name = value
		resource_name = item_name
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
@export var data : Array[ItemData] = []:
	set(value):
		data = value
		for d in data:
			if d and !d.changed.is_connected(emit_changed):
				d.changed.connect(emit_changed)
		emit_changed()

var rect : Rect2i:
	get:
		var r := Rect2i(shape[0], Vector2i.ZERO)
		for slot in shape:
			r = r.expand(slot)
		return r

func get_data(data_type: Variant) -> ItemData:
	for d in data:
		if is_instance_of(d, data_type):
			return d
	return null