extends Node2D
extends Node2D

var dragMouse = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and dragMouse:
		position += event.relative
	elif event is InputEventMouseButton:
		dragMouse = dragMouse and event.is_pressed()

func _on_StaticBody2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		dragMouse = event.is_pressed()
		set_process_unhandled_input(dragMouse)
