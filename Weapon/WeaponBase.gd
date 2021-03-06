extends Spatial


var facing_dir = Vector2.ZERO setget set_facing

var special = 0
var weight = 0

func set_facing(dir):
	facing_dir = dir
	$Hitbox.knockback = facing_dir * 5

func start_attack():
	$Hitbox.monitorable = true

func end_attack():
	$Hitbox.monitorable = false

func build_from_components(components, p_damage, p_special, p_weight):
	# clear first
	for coll in $Hitbox.get_children():
		coll.queue_free()
	for vis in $Visual.get_children():
		vis.queue_free()
	
	$Hitbox.damage = p_damage
	special = p_special
	weight = p_weight
	
	# add new
	var offset = Transform()
	for comp in components:
		var wp:Spatial = comp.get_component().duplicate()
		
		var collision_shape = wp.get_node("CollisionShape")
		wp.remove_child(collision_shape)
		collision_shape.transform *= offset
		$Hitbox.add_child(collision_shape)
		
		collision_shape.owner = $Hitbox
		
		wp.transform *= offset
		$Visual.add_child(wp)
		
		
		if wp.has_node("Next"):
			offset *= wp.get_node("Next").transform
		
