@tool
extends Control

@export var color_unfocused := Color.BLACK
@export var color_focused := Color.GRAY
@export var color_rect : ColorRect

signal clicked
signal right_clicked

func _ready() -> void:
	color_rect.color = color_unfocused
	focus_entered.connect(func() -> void: color_rect.color = color_focused)
	focus_exited.connect(func() -> void: color_rect.color = color_unfocused)
	mouse_entered.connect(grab_focus)
	# TODO not working??
	mouse_exited.connect(release_focus)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit()
	if !Engine.is_editor_hint():
		if event.is_action_pressed("ui_accept"):
			clicked.emit()
		if event.is_action_pressed("inventory_context_menu"):
			right_clicked.emit()
