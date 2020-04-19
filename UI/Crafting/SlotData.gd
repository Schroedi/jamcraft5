extends TextureRect

signal changed

func is_free():
	return $CenterContainer.can_drop_data(null, null)

func set_item(item):
	assert(is_free())
	$CenterContainer.add_child(item)
	emit_signal("changed")

func get_item():
	return null if $CenterContainer.get_child_count() == 0 else $CenterContainer.get_child(0)
