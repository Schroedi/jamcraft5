extends TextureRect

func is_free():
	return $CenterContainer.can_drop_data(null, null)

func set_item(item):
	assert(is_free())
	$CenterContainer.add_child(item)
