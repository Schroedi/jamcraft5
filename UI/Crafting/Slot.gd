extends Control


func can_drop_data(_position, _data):
	return get_child_count() == 0


func drop_data(_position, data):
	data.get_parent().remove_child(data)
	data.rect_position = Vector2()
	add_child(data)
	#data.unselect()
	#Stats.UnEquipItem(data.Item)
	#Stats.EquipItem(data.Item)
	#GameState.ItemCount -= 1

	#var slotId = get_parent().SlotId
	#var weapon = GameState.Level.get_node("Weapon")
	## it could have been equiped
	#weapon.unequip(data.Item)
	#weapon.equip(data.Item, slotId)
	
