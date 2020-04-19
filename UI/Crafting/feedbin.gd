extends TextureRect


func can_drop_data(_position, _data):
	return true


func drop_data(_position, data):
	data.queue_free()
