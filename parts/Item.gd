extends StaticBody2D

var dragging = false

func _on_Item_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		dragging = event.pressed
		pass
	elif event is InputEventMouseMotion:
		pass
