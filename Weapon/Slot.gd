extends Area

export var hoverColor = Color(.8, .1, .1, .8)
export var normalColor = Color(1, 1, 1, .8)

onready var slotMesh = $MeshInstance

func _on_Slot_mouse_entered() -> void:
	slotMesh.get_surface_material(0).albedo_color = hoverColor


func _on_Slot_mouse_exited() -> void:
	slotMesh.get_surface_material(0).albedo_color = normalColor


func _on_Slot_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	# item drop
	if event is InputEventMouseButton and not event.is_pressed():
		# 
		pass
