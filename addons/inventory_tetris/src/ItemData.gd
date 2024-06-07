class_name ItemData
extends Resource

var context_menu: Array[MenuItem]:
	get:
		return _get_context_menu()

func _get_context_menu() -> Array[MenuItem]:
	return []

func get_badge() -> Control:
	return null