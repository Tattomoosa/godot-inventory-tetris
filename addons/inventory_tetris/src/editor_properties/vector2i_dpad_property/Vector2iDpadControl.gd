@tool
extends Control

@export var vector2i := Vector2i.ZERO:
	set(value):
		vector2i = value
		vector2i_changed.emit()

@export var up_button : Button
@export var right_button : Button
@export var down_button : Button
@export var left_button : Button
@export var label : Label

signal vector2i_changed

func _ready():
	up_button.pressed.connect(func(): vector2i.y -= 1)
	down_button.pressed.connect(func(): vector2i.y += 1)
	left_button.pressed.connect(func(): vector2i.x -= 1)
	right_button.pressed.connect(func(): vector2i.x += 1)

func update_label():
	label.text = str(vector2i)