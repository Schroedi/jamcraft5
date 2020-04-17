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

func build_from_components(components):
	# clear first
	for coll in $Hitbox.get_children():
		coll.queue_free()
	for vis in $Visual.get_children():
		vis.queue_free()
	
	# add new
	var start_pos = Vector3()
	for comp in components:
		var wp:Spatial = comp.get_component()
		
		wp.translate(start_pos)
		
		$Visual.add_child(wp.duplicate())
		$Hitbox.add_child(wp.get_node("CollisionShape").duplicate())
		
		if wp.has_node("Next"):
			start_pos += wp.get_node("Next").transform.origin
		
