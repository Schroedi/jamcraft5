extends Sprite

onready var player = get_tree().get_nodes_in_group('player')[0]
onready var fog_size = get_parent().size

var last_pos = Vector2()

func _process(delta: float) -> void:
	var pos = player.transform.origin
	pos = Vector2(pos.x, -pos.y)
	
	# 0,0 to center of texture
	pos += fog_size / 2.0
	
	# transform to fog map
	position = pos 
	
	# here we could only update it if the player moved
	if last_pos.distance_squared_to(position) > 0.2:
		get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
		last_pos = position
	pass
