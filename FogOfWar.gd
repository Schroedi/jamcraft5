extends TileMap

onready var player = get_tree().get_nodes_in_group('player')[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var view_size = get_viewport().size
	var cam_offset = player.translation# / view_size 
	material.set_shader_param("offset", Vector2(cam_offset.x, -cam_offset.y))
	#fogOfWar
	pass
