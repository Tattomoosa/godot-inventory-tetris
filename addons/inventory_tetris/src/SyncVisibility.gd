@tool
class_name SyncVisibility
extends Node

@export var watch_visibility : Node:
	set(value):
		if watch_visibility\
			and watch_visibility.has_signal("visibility_changed")\
				and watch_visibility.visibility_changed.is_connected(_set_visibility):
					watch_visibility.visibility_changed.disconnect(_set_visibility)
		watch_visibility = value
		if watch_visibility.has_signal("visibility_changed"):
			watch_visibility.visibility_changed.connect(_set_visibility)

func _set_visibility() -> void:
	if !watch_visibility:
		return
	if "visible" in watch_visibility and "visible" in self:
		set("visible", watch_visibility.visible)