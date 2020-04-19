extends Popup

const weapon_part = preload("res://UI/Crafting/UIWeaponPart.tscn")

onready var inv_grid = $Inventory/Inventory/GridContainer
onready var weapon_slots = $Crafting/Weapon
onready var slots = [$"Crafting/Weapon/Slot5",$"Crafting/Weapon/Slot4",$"Crafting/Weapon/Slot3",$"Crafting/Weapon/Slot2",$"Crafting/Weapon/Slot"]
onready var dmgtxt = $"Crafting/Attack"
onready var specialtxt = $"Crafting/Special Attack"

var dmg = 0
var special = 0

func _ready() -> void:
	# start weapon
	var wp = weapon_part.instance()
	wp.part_name = "Handle"
	wp.part_power = 1
	try_add_item(wp)
	
	wp = weapon_part.instance()
	wp.part_name = "Tip 1"
	wp.part_power = 1
	try_add_item(wp)
	
	for slot in weapon_slots.get_children():
		slot.connect("changed", self, "is_weapon_valid")
	
	for slot in inv_grid.get_children():
		slot.connect("changed", self, "is_weapon_valid")
	
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

const part_loot_table = [[1, "Handle"], [25, "Mid 1"], [15, "Mid 2"], [5, "Mid 3"], [5, "Tip 1"], [3, "Tip 2"], [1, "Tip 3"]]

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.button_index == BUTTON_RIGHT:
		var wp = weapon_part.instance()
		var rand_part = rand_array(part_loot_table.duplicate())
		wp.part_name = rand_part[1]
		wp.part_power = randi()%4+1
		try_add_item(wp)

func try_add_item(item):
	for slot in inv_grid.get_children():
		if slot.is_free():
			slot.set_item(item)
			return true
	return false
	
func update_stats_ui():
	dmgtxt.text = str(dmg)
	if special > 0:
		specialtxt.text = Globals.specials[special - 1]
	else:
		specialtxt.text = ""

func is_weapon_valid():
	var count_handles = 0
	var count_tips = 0
	var first_item = slots[0].get_item()
	var first_is_handle = first_item and first_item.part_name.begins_with("Handle")
	var last_is_tip = false
	dmg = 1
	special = 0
	for s in slots:
		var item = s.get_item()
		if not item:
			# skip free slots
			continue
		last_is_tip = item.part_name.begins_with("Tip")
		if last_is_tip:
			count_tips += 1
			special = item.part_power
		if item.part_name.begins_with("Handle"):
			count_handles += 1
		if item.part_name.begins_with("Mid"):
			dmg += item.part_power
	
	var is_valid = count_handles == 1 and count_tips == 1 and first_is_handle and last_is_tip
	
	if not is_valid:
		if not first_is_handle:
			$Error.text = "Start with a handle."
		elif not last_is_tip:
			$Error.text = "Finish with a tip."
		elif not (count_handles == 1 and count_tips == 1):
			$Error.text = "This won't hold."
	$Error.visible = not is_valid
	
	update_stats_ui()
	
	return is_valid


func save_craft():
	# make 3d sword again
	if not is_weapon_valid():
		return
	
	var components = []
	for s in slots:
		var item = s.get_item()
		if not item:
			# skip free slots
			continue
		components.append(item)
	Globals.player_weapon.build_from_components(components, dmg, special)
	hide()
	pass


func _on_Button_pressed() -> void:
	save_craft()


func _on_CheckItem_timeout() -> void:
	print("is weapon valid: " + str(is_weapon_valid()))
	pass # Replace with function body.
