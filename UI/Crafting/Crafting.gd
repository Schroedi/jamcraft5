extends Popup

const weapon_part = preload("res://UI/Crafting/UIWeaponPart.tscn")

onready var player = get_tree().get_nodes_in_group('player')[0]

onready var inv_grid = $Inventory/Inventory/GridContainer
onready var weapon_slots = $Crafting/Weapon
onready var slots = [$"Crafting/Weapon/Slot5",$"Crafting/Weapon/Slot4",$"Crafting/Weapon/Slot3",$"Crafting/Weapon/Slot2",$"Crafting/Weapon/Slot"]
onready var dmgtxt = $"Crafting/Attack"
onready var attacktxt = $Crafting/Attackspeed
onready var specialtxt = $"Crafting/Special Attack"

var dmg = 0
var special = 0
var slot_count = 0
var weight = 0

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
	
	is_weapon_valid()
	
	player.connect("pickup", self, "addDrop")
	player.connect("died", self, "init_weapon")
	player.connect("crafting", self, "popup")
	
	call_deferred("popup")
	
	#level_test()

func level_test():
	var level_sum = 0
	for i in 100:
		var wp = gen_level(1)
		level_sum += wp.part_power
	print ("l1: %f" % (level_sum / 100.0))
	
	level_sum = 0
	for i in 100:
		var wp = gen_level(10)
		level_sum += wp.part_power
	print ("l10: %f" % (level_sum / 100.0))

func init_weapon():
	for slot in slots:
		if slot.get_item():
			slot.get_item().queue_free()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var wp = weapon_part.instance()
	wp.part_name = "Handle"
	wp.part_power = 1
	slots[0].set_item(wp)
	
	wp = weapon_part.instance()
	wp.part_name = "Tip 1"
	wp.part_power = 1
	slots[1].set_item(wp)
	
	save_craft()

func _input(ev: InputEvent) -> void:
	if Input.is_action_just_pressed("item_cheat"):
		try_add_item(gen_level(1))
	
func addDrop(drop):
	# from pickups
	var level = drop.level
	var best = gen_level(level)
	if try_add_item(best):
		drop.picked()

func gen_level(level):
	var best = GPartGen.gen_item()
	for i in level - 1:
		var item = GPartGen.gen_item()
		if item.part_power > best.part_power:
			best = item
	return best

func try_add_item(item):
	print("try add: %d" % item.part_power)
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
	
	var i = 0
	for s in weapon_slots.get_children():
		s.get_node("Blocked").visible = (4 - i > slot_count)
		i += 1
	
	if weight <= 4:
		attacktxt.text = "Fast"
	elif weight > 4 and weight <= 7:
		attacktxt.text = "Normal"
	elif weight > 7 and weight <= 9:
		attacktxt.text = "Heavy"
	elif weight > 9:
		attacktxt.text = "Brutal"

func is_weapon_valid():
	var count_handles = 0
	var count_tips = 0
	var first_item = slots[0].get_item()
	var first_is_handle = first_item and first_item.part_name.begins_with("Handle")
	var last_is_tip = false
	dmg = 1
	special = 0
	slot_count = 0
	weight = 0
	var i = 0
	for s in slots:
		# handle slot limit
		if (i > slot_count):
			break
		i += 1
		
		var item = s.get_item()
		if not item:
			# end on free slot
			break
		last_is_tip = item.part_name.begins_with("Tip")
		if last_is_tip:
			count_tips += 1
			special = item.part_power
			weight += int(item.part_name.right(4))
		if item.part_name.begins_with("Handle"):
			count_handles += 1
			slot_count = item.part_power
		if item.part_name.begins_with("Mid"):
			dmg += item.part_power
			weight += int(item.part_name.right(4))
	
	var is_valid = count_handles == 1 and count_tips == 1 and first_is_handle and last_is_tip
	
	if not is_valid:
		if not first_is_handle:
			$Error.text = "Start with a handle."
		elif not last_is_tip:
			$Error.text = "Finish with a tip."
		elif not (count_handles == 1 and count_tips == 1):
			$Error.text = "This won't hold."
	$Error.visible = not is_valid
	$Crafting/Button.disabled = not is_valid
	
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
	Globals.player_weapon.build_from_components(components, dmg, special, weight)
	hide()
	GSound.start_explore()
	
	for c in get_tree().get_nodes_in_group('dome_char'):
		c.visible = false
	
	get_tree().get_nodes_in_group('pet')[0].visible = true
	var plr = get_tree().get_nodes_in_group('player')[0]
	plr.visible = true
	plr.get_node('Camera').current = true


func _on_Button_pressed() -> void:
	save_craft()


func _on_CheckItem_timeout() -> void:
	print("is weapon valid: " + str(is_weapon_valid()))
	pass # Replace with function body.


func _on_Crafting_about_to_show() -> void:
	for c in get_tree().get_nodes_in_group('dome_char'):
		c.visible = true
	get_tree().get_nodes_in_group('player')[0].visible = false
	get_tree().get_nodes_in_group('pet')[0].visible = false
	get_tree().get_nodes_in_group('craft_cam')[0].current = true
	GSound.start_crafting()
