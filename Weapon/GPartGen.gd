extends Node

const weapon_part = preload("res://UI/Crafting/UIWeaponPart.tscn")

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

const part_loot_table = [[5, "Handle"], [25, "Mid 1"], [15, "Mid 2"], [5, "Mid 3"], [5, "Tip 1"], [3, "Tip 2"], [1, "Tip 3"]]

const power_table = [[200, 1], [70, 2], [30, 3], [5, 4]]

func gen_item():
	var wp = weapon_part.instance()
	var rand_part = rand_array(part_loot_table.duplicate())
	wp.part_name = rand_part[1]
	wp.part_power = rand_array(power_table.duplicate())[1]
	return wp
