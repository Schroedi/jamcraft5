extends Spatial


var facing_dir = Vector2.ZERO setget set_facing
var dragMouse = false

func set_facing(dir):
	facing_dir = dir
	$Hitbox.knockback_strength = 5

func start_attack():
	$Hitbox.monitorable = true

func end_attack():
	$Hitbox.monitorable = false


func _on_Hitbox_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseMotion and dragMouse:
		translate(Vector3(0, -event.relative.x, event.relative.y)/50.0)
	elif event is InputEventMouseButton:
		dragMouse = event.is_pressed()

