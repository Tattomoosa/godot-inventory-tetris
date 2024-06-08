@tool
class_name InventoryUi
extends Control

@export var slot_size := Vector2i(30, 30)

@export var player_inventory: Inventory
@export var other_inventory: Inventory:
	set(value):
		other_inventory = value
		other_inventory_panel.inventory = other_inventory
		other_inventory_panel.visible = other_inventory != null
@export var other_inventory_name : String = "":
	set(value):
		other_inventory_name = value
		if is_node_ready():
			other_inventory_label.text = value

@export_group("Scene Internal")
@export var item_info_panel : ItemInfoPanel
@export var follow_mouse : FollowMouse
@export var player_inventory_panel : InventoryGridPanel
@export var other_inventory_panel : InventoryGridPanel
@export var other_inventory_label: Label
@export_subgroup("Audio Players")
@export var slot_changed_audio_player : AudioStreamPlayer
@export var picked_item_audio_player : AudioStreamPlayer
@export var placed_item_audio_player : AudioStreamPlayer
@export var rotated_item_audio_player : AudioStreamPlayer
@export var errored_audio_player : AudioStreamPlayer
@export var opened_audio_player : AudioStreamPlayer
@export var closed_audio_player : AudioStreamPlayer

var _inventory_panels : Array[InventoryGridPanel] = []

signal opened
signal hiding
signal closed

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
		for inventory in _inventory_panels:
			inventory.picked_item_instance = picked_item_instance
		_update_item_panel()
		_on_picked_item()
		# picked_item_changed.emit()

var can_close := true
var silence_grid_sounds := true

func get_selected_inventory() -> InventoryGridPanel:
	for inventory in _inventory_panels:
		if inventory.has_selected_slot:
			return inventory
	return null

func open():
	silence_grid_sounds = true
	show()
	_inventory_panels[0].set_active()
	opened_audio_player.play()
	can_close = false
	await create_tween().tween_method(_set_opacity, 0.0, 1.0, 0.25).finished
	#await get_tree().create_timer(0.1).timeout
	can_close = true
	silence_grid_sounds = false
	opened.emit()

func close():
	if !can_close:
		return
	hiding.emit()
	closed_audio_player.play()
	if picked_item_instance:
		picked_item_instance.cancel()
		picked_item_instance = null
	await create_tween().tween_method(_set_opacity, 1.0, 0.0, 0.25).finished
	visible = false
	closed.emit()

func _set_opacity(value: float):
	modulate.a = value

func _set_picked_item_instance(picked_item_instance_: InventoryGridPickedItem):
	picked_item_instance = picked_item_instance_

func _set_selected_item_instance(selected_item_instance_: InventoryItemInstance):
	selected_item_instance = selected_item_instance_

func _connect_inventory_panel_signals(inventory_panel: InventoryGridPanel):
	inventory_panel.picked_item_instance_changed.connect(_set_picked_item_instance)
	inventory_panel.selected_item_instance_changed.connect(_set_selected_item_instance)
	inventory_panel.grid_slots.selected_slot_changed.connect(func(): _on_grid_selected_slot_changed(inventory_panel.grid_slots))
	inventory_panel.blank_context_menu_requested.connect(_error)
	inventory_panel.placed_picked_item.connect(_on_placed_item)
	inventory_panel.canceled_picked_item.connect(_on_canceled_item)

func _ready():
	_inventory_panels = [player_inventory_panel, other_inventory_panel]
	player_inventory_panel.inventory = player_inventory
	other_inventory_panel.inventory = other_inventory

	for inventory_panel in _inventory_panels:
		_connect_inventory_panel_signals(inventory_panel)

		for other in _inventory_panels:
			if inventory_panel == other:
				continue
			var src_grid := inventory_panel.grid_slots
			var dest_grid := other.grid_slots

			src_grid.selected_slot_changed.connect(
				func():
					if src_grid.has_slot_focused:
						#TODO this sets up inter-inventory traversal, would have to do something way smarter to support more configurations
						if dest_grid.has_slot_at(Vector2i(
								src_grid.selected_slot.x,
								dest_grid.selected_slot.y
						)):
							dest_grid.selected_slot.x = src_grid.selected_slot.x
			)

func _error():
	errored_audio_player.play()

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
		errored_audio_player.play()

func _process(_delta: float):
	if Engine.is_editor_hint():
		return
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		if picked_item_instance:
			picked_item_instance.cancel()
			picked_item_instance = null
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

func _update_item_panel():
	var item : Item = null
	if picked_item_instance:
		item = picked_item_instance.item_instance.item
	elif selected_item_instance:
		item = selected_item_instance.item
	item_info_panel.item = item
