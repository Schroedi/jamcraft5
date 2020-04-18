extends Node2D

func _unhandled_key_input(event : InputEventKey) -> void:
	if event.pressed and event.scancode == KEY_C:
		$UILayer/Crafting.popup()
