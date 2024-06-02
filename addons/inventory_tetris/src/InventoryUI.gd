@tool
class_name InventoryUi
extends Control

@export var slot_size := Vector2i(30, 30)

@export_group("Scene Internal")
@export var inventories : Array[InventoryGridPanel] = []
@export var item_info_panel : ItemInfoPanel
@export var follow_mouse : FollowMouse
@export_subgroup("Audio Players")
@export var slot_changed_audio_player : AudioStreamPlayer
@export var picked_item_audio_player : AudioStreamPlayer
@export var placed_item_audio_player : AudioStreamPlayer
@export var rotated_item_audio_player : AudioStreamPlayer
@export var canceled_item_audio_player : AudioStreamPlayer
@export var opened_audio_player : AudioStreamPlayer
@export var closed_audio_player : AudioStreamPlayer

signal opened
signal closed
# TODO is anything listening to this?
signal picked_item_changed

var selected_item_instance : InventoryItemInstance:
	set(value):
		selected_item_instance = value
		_update_item_panel()

var picked_item_instance : InventoryGridPickedItem:
	set(value):
		if picked_item_instance:
			if picked_item_instance.rotated.is_connected(_on_picked_item_rotated):
				picked_item_instance.rotated.disconnect(_on_picked_item_rotated)
		picked_item_instance = value
		if picked_item_instance:
			picked_item_instance.rotated.connect(_on_picked_item_rotated)
		for inventory in inventories:
			inventory.picked_item_instance = picked_item_instance
		_update_item_panel()
		_on_picked_item()
		picked_item_changed.emit()

var can_close := true
var silence_grid_sounds := true

func _ready():
	for inventory in inventories:
		inventory.picked_item_instance_changed.connect(
			func(picked_item_instance_):
				picked_item_instance = picked_item_instance_
		)
		inventory.selected_item_instance_changed.connect(
			func(selected_item_instance_):
				selected_item_instance = selected_item_instance_
		)
		inventory.grid_slots.selected_slot_changed.connect(
			func():
				_on_grid_selected_slot_changed(inventory.grid_slots)
		)
		inventory.placed_picked_item.connect(_on_placed_item)
		inventory.canceled_picked_item.connect(_on_canceled_item)
		await get_tree().process_frame

		for other in inventories:
			if inventory == other:
				continue
			var src_grid := inventory.grid_slots
			var dest_grid := other.grid_slots

			src_grid.selected_slot_changed.connect(
				func():
					if src_grid.has_slot_focused:
						#TODO this sets up inter-inventory traversal, would have to do something way smarter to support more configurations
						dest_grid.selected_slot.y = src_grid.selected_slot.y
			)

func _on_picked_item_rotated():
	if !silence_grid_sounds:
		rotated_item_audio_player.play()

func _on_grid_selected_slot_changed(grid: InventoryGridSlotUi):
	if grid.has_slot_focused:
		if !silence_grid_sounds:
			slot_changed_audio_player.play()

func _on_placed_item():
		if !silence_grid_sounds:
			placed_item_audio_player.play()

func _on_picked_item():
	if !picked_item_instance:
		return
	if !silence_grid_sounds:
		picked_item_audio_player.play()

func _on_canceled_item():
	if !silence_grid_sounds:
		canceled_item_audio_player.play()

func _process(_delta: float):
	if Engine.is_editor_hint():
		return
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if picked_item_instance:
			picked_item_instance.cancel()
			picked_item_instance = null
			_on_canceled_item()
			get_viewport().set_input_as_handled()
		else:
			close()
			get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("inventory"):
		close()
		get_viewport().set_input_as_handled()
	
	if picked_item_instance:
		var no_slots_selected = get_selected_inventory() == null
		if no_slots_selected and picked_item_instance.get_parent() != follow_mouse:
			var mouse_offset := picked_item_instance.global_position - follow_mouse.position
			picked_item_instance.over_inventory = null
			picked_item_instance.reparent(follow_mouse, false)
			picked_item_instance.position = mouse_offset

func get_selected_inventory() -> InventoryGridPanel:
	for inventory in inventories:
		if inventory.has_selected_slot:
			return inventory
	return null

func open():
	silence_grid_sounds = true
	visible = true
	inventories[0].set_active()
	opened_audio_player.play()
	opened.emit()
	can_close = false
	await get_tree().create_timer(0.1).timeout
	can_close = true
	silence_grid_sounds = false

func close():
	if !can_close:
		return
	closed_audio_player.play()
	if picked_item_instance:
		picked_item_instance.cancel()
	visible = false
	closed.emit()

func _update_item_panel():
	var item : Item = null
	if picked_item_instance:
		item = picked_item_instance.item_instance.item
	elif selected_item_instance:
		item = selected_item_instance.item
	item_info_panel.item = item
