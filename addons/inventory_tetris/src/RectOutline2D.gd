@tool
class_name RectOutline2D
extends Line2D

@export var size := Vector2i(30, 30):
	set(value):
		size = value
		points = [
			Vector2i(size.x, 0),
			Vector2i(size.x, size.y),
			Vector2i(0, size.y),
			Vector2i(0, 0),
		]
	
func _init():
	closed = true

func _validate_property(property: Dictionary) -> void:
	if property.name == "points":
		property.usage = PROPERTY_USAGE_NO_EDITOR