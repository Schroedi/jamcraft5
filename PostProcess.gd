extends Control

onready var player = get_tree().get_nodes_in_group('player')[0]

func _ready() -> void:
	material.set_shader_param("fog_scale", Globals.FOG_SCALE)

func _process(_delta: float) -> void:
	# normalize by project screen size
	#var cam_offset = Globals.curr_cam.get_camera_position() / Vector2(1920, 1080)
	var cam_offset = player.translation
	material.set_shader_param("camera_offset", Vector2(-cam_offset.x, -cam_offset.y))
