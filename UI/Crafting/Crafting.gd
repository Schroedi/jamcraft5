extends Popup

const weapon_part = preload("res://UI/Crafting/UIWeaponPart.tscn")

onready var inv_grid = $PanelContainer/MarginContainer/VBoxContainer/Inventory/MarginContainer/GridContainer

func _ready() -> void:
	call_deferred("popup")

static func rand_array(array): # -> [int, object]
	# arrays must be [weight, value]
	# returns [idx, object]
	var sum_of_weights = 0
	for t in array:
		sum_of_weights += t[0]
   
	var x = randf() * sum_of_weights
   
	var cumulative_weight = 0
	var idx = 0
	for t in array:
		cumulative_weight += t[0]
		if x < cumulative_weight:
			return [idx, t[1]]
		idx += 1

const part_loot_table = [[1, "Handle"], [50, "Mid 1"], [30, "Mid 2"], [10, "Mid 3"], [5, "Tip 1"], [3, "Tip 2"], [1, "Tip 3"]]

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.button_index == BUTTON_RIGHT:
		var wp = weapon_part.instance()
		var rand_part = rand_array(part_loot_table.duplicate())
		wp.part_name = rand_part[1]
		try_add_item(wp)

func try_add_item(item):
	for slot in inv_grid.get_children():
		if slot.is_free():
			slot.set_item(item)
			return true
	return false
	
	
func _on_Crafting_about_to_show() -> void:
	# TODO load current sword
	pass # Replace with function body.


func save_craft():
	# make 3d sword again
	pass
