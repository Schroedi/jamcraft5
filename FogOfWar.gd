extends TileMap


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var view_size = get_viewport().size
	var cam_offset = Globals.curr_cam.get_camera_position() / (view_size )
	material.set_shader_param("offset", Vector2(cam_offset.x, -cam_offset.y))
	#fogOfWar
	pass
