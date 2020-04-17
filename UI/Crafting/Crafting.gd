extends Popup

const weapon_part = preload("res://UI/Crafting/UIWeaponPart.tscn")

onready var inv_grid = $PanelContainer/MarginContainer/VBoxContainer/Inventory/MarginContainer/GridContainer
onready var weapon_slots = $PanelContainer/MarginContainer/VBoxContainer/Weapon

func _ready() -> void:
	# start weapon
	var wp = weapon_part.instance()
	wp.part_name = "Handle"
	try_add_item(wp)
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

func is_weapon_valid():
	var count_handles = 0
	var count_tips = 0
	var first_item = weapon_slots.get_child(0).get_item()
	var first_is_handle = first_item and first_item.part_name.begins_with("Handle")
	var last_is_tip = false
	for s in weapon_slots.get_children():
		var item = s.get_item()
		if not item:
			# skip free slots
			continue
		last_is_tip = item.part_name.begins_with("Tip")
		if last_is_tip:
			count_tips += 1
		if item.part_name.begins_with("Handle"):
			count_handles += 1
		
	return count_handles == 1 and count_tips == 1 and first_is_handle and last_is_tip


func save_craft():
	# make 3d sword again
	if not is_weapon_valid():
		return
	
	var components = []
	for s in weapon_slots.get_children():
		var item = s.get_item()
		if not item:
			# skip free slots
			continue
		components.append(item)
	Globals.player_weapon.build_from_components(components)
	pass


func _on_Button_pressed() -> void:
	save_craft()


func _on_CheckItem_timeout() -> void:
	print("is weapon valid: " + str(is_weapon_valid()))
	pass # Replace with function body.
