@tool
class_name ItemInfoPanel
extends PanelContainer

@export var item_name_label : RichTextLabel
@export var item_description_label : RichTextLabel
@export var null_item_name := ""
@export var null_item_description := ""

@export var item : Item:
	set(value):
		if item and item.changed.is_connected(_on_item_changed):
			item.changed.disconnect(_on_item_changed)
		item = value
		_on_item_changed()
		if item:
			item.changed.connect(_on_item_changed)

func _on_item_changed() -> void:
	if !is_node_ready():
		await ready
	if !item:
		item_name_label.text = null_item_name
		item_description_label.text = null_item_description
		return
	item_name_label.text = item.item_name
	item_description_label.text = item.description
