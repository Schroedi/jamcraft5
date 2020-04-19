extends Control


func can_drop_data(_position, _data):
	return get_child_count() == 0


func drop_data(_position, data):
	data.get_parent().remove_child(data)
	data.rect_position = Vector2()
	get_parent().set_item(data)
