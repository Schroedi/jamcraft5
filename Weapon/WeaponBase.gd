extends Spatial


var facing_dir = Vector2.ZERO setget set_facing

func set_facing(dir):
	facing_dir = dir
	$Hitbox.knockback_strength = 5

func start_attack():
	$Hitbox.monitorable = true

func end_attack():
	$Hitbox.monitorable = false
