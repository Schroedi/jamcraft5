extends PanelContainer

enum ItemTypes {Weapon, Armor}

const rarity_colors = {1: Color.white, 2: Color.dodgerblue, 3: Color.yellow, 4: Color.darkorange, 5: Color.green, 6: Color.purple}

static func show_rarity(p_label:Label, p_rarity):
	var text = ""
	match(int(p_rarity)):
		1:
			text = GPassives.get_translation("ui_loot_rarity_normal")
		2:
			text = GPassives.get_translation("ui_loot_rarity_magic")
		3:
			text = GPassives.get_translation("ui_loot_rarity_rare")
		4:
			text = GPassives.get_translation("ui_loot_rarity_legendary")
		5:
			text = "Set"
		6:
			text = GPassives.get_translation("ui_loot_rarity_unique")
			
		_:
			print("unknown rarity: " + str(p_rarity))
			pass
		
	p_label.text = text
	p_label.modulate = rarity_colors[int(p_rarity)]


func show_quality(p_label:Label, p_quality):
	var qualy_str = ""
	for _i in range(int(p_quality)):
		qualy_str += "*"
	p_label.text = qualy_str


const weapon_types = {"Shield": "ui_WeaponType_SmallShield",
		"Dagger": "ui_WeaponType_Dagger",
		"Staff": "ui_WeaponType_Staff",
		"Gun": "ui_WeaponType_Gun",
		"Trinket": "ui_WeaponType_Trinket",
		"Sword1H": "ui_WeaponType_1HSword", #?
		"Sword2H": "ui_WeaponType_2HSword",
		"Axe1H": "ui_WeaponType_1HAxe",
		"Axe2H": "ui_WeaponType_2HAxe", #?
		"Bow": "ui_WeaponType_Bow", #?
		"Mace1H": "ui_WeaponType_1HMace", #?
		"Mace2H": "ui_WeaponType_2HMace" #?
		}


func get_weapon_type_translation(p_weapon_type):
	var trans_id = weapon_types[p_weapon_type]
	return GPassives.get_translation(trans_id)


func add_affixes(group_node, effects, magic = false):
	# hack as we currently cannot add RichTextLabels dynamically without destroying 
	# the parent's layout
	for c in group_node.get_children():
		c.visible = false
	var eff_i = 0
	for effect in effects:
		# pseudo eim so we can reuse the function
		var eim = effect
		eim['HUDDesc'] = "ui_eim_" + effect.EffectId
		var eim_text = GPassives.build_eim(eim)
		var lbl = group_node.get_node("RichTextLabel" + str(eff_i))
		if magic:
			eim_text = "[color=#1E90FF]%s[/color]" % eim_text
		lbl.bbcode_text = eim_text
		lbl.visible = true
		eff_i += 1


func format_base_stat(p_type, p_value):
	match p_type:
		"Armor":
			return "%d %s" % [p_value, GPassives.get_translation("ui_cs_defense")]
		"Health":
			return "%d %s" % [p_value, GPassives.get_translation("ui_cs_health")]
		"Resistance":
			return "%d %s" % [p_value, GPassives.get_translation("ui_cs_defense")]
		"DamageMin":
			# handeled in _damage currently
			pass
		"DamageMax":
			# handeled in _damage currently
			pass
		"_damage":
			return GPassives.get_translation("ui_AST_Param_Physicaldamage").replace("%1", p_value[0]).replace("%2", p_value[1])
			# as soon as we calculate the real damage, we should use this
			#return GPassives.get_translation("ui_AST_Param_TotalBasedamage").replace("%1", p_value[0]).replace("%2", p_value[1])
		"ShieldResistance":
			return "%d %s" % [p_value, GPassives.get_translation("ui_cs_defense")]
			pass
		"ShieldBlockChance":
			pass
		"ShieldBlockEfficiency":
			pass
		"ResourceGeneration":
			# TODO: this will be either willpower od rage
			return "Resource per Hit: %d" % [p_value]
		_ : 
			print("Ignoring unknown base stat")


func show_item(item, p_flip_h = false):
	var name_id
	var item_type
	
	var base_stats = {}
	var base_stat_names = ["Armor", "Health", "Resistance", "DamageMin", "DamageMax", "ShieldResistance", "ShieldBlockChance", "ShieldBlockEfficiency", "ResourceGeneration"]
	
	# TODO: Gems, Dyes, Enneracts
	if "Weapon" in item:
		name_id = item.Weapon.Name
		item_type = ItemTypes.Weapon
		
		var dmgMin = null
		var dmgMax = null
		for stat_name in base_stat_names:
			if stat_name in item.Weapon:
				if stat_name == "DamageMin":
					dmgMin = item.Weapon.get(stat_name)
				elif stat_name == "DamageMax":
					dmgMax = item.Weapon.get(stat_name)
				else:
					base_stats[stat_name] = item.Weapon.get(stat_name)
		if dmgMax != null and dmgMin != null:
			base_stats["_damage"] = [dmgMin, dmgMax]
	elif "Armor" in item:
		name_id = item.Armor.Name
		item_type = ItemTypes.Armor
		for stat_name in base_stat_names:
			if stat_name in item.Armor:
				base_stats[stat_name] = item.Armor.get(stat_name)
	
	var item_meta = GMetadata.loot[name_id]
	
	$MarginContainer/VBoxContainer/Name.text = GPassives.get_translation(item_meta.UIName)
	$MarginContainer/VBoxContainer/Name.modulate = rarity_colors[int(item.Rarity)]
	
	# Base stats
	for c in $MarginContainer/VBoxContainer/BaseStats.get_children():
		c.visible = false
	var eff_i = 0
	for stat_name in base_stats.keys():
		var lbl = $MarginContainer/VBoxContainer/BaseStats.get_node("S" + str(eff_i))
		lbl.text = format_base_stat(stat_name, base_stats[stat_name])
		lbl.visible = true
		eff_i += 1
	
	
	# left
	match(item_type):
		ItemTypes.Armor:
			$MarginContainer/VBoxContainer/Img/VBoxContainer/Class.text = item_meta.ArmorType
			$MarginContainer/VBoxContainer/Img/VBoxContainer/Type.text = item_meta.ItemType
		ItemTypes.Weapon:
			var text = "Two-Handed" if item_meta.IsTwoHanded else "One-Handed"
			$MarginContainer/VBoxContainer/Img/VBoxContainer/Class.text = text
			$MarginContainer/VBoxContainer/Img/VBoxContainer/Type.text = get_weapon_type_translation(item.ItemType)
		_:
			pass
	
	# image
	$MarginContainer/VBoxContainer/Img/TextureRect.texture = load("res://UI/Items/ItemBorders/%d.png" % int(item.Rarity))
	#var item_base_url = "https://cors_remove.keks.workers.dev/?https://wolcen.dev/item_imgs"
	var item_base_url = "https://wolcen.dev/item_imgs"
	$MarginContainer/VBoxContainer/Img/TextureRect/Item.url = "%s/%s.png" % [item_base_url, item_meta.Name.to_lower()]
	$MarginContainer/VBoxContainer/Img/TextureRect/Item.flip_h = p_flip_h
	
	# right
	show_rarity($MarginContainer/VBoxContainer/Img/VBoxContainer2/Rarity, item.Rarity)
	show_quality($MarginContainer/VBoxContainer/Img/VBoxContainer2/Quality, item.Quality)
	$MarginContainer/VBoxContainer/Img/VBoxContainer2/HBoxContainer/Level.text = str(item_meta.Level)
	
	# TODO: gems
	
	# affixes
	# Implicit(Default)
	add_affixes($MarginContainer/VBoxContainer/Affixes/Implicits, item.MagicEffects.Default)
	
	# RolledAffixes
	if "RolledAffixes" in item.MagicEffects:
		add_affixes($MarginContainer/VBoxContainer/Affixes/RolledAffixes, item.MagicEffects.RolledAffixes, true)
	
	# buttom
	$MarginContainer/VBoxContainer/ValLevel/LevelReqH/LevelReq.text = str(item_meta.LevelPrereq)
	$MarginContainer/VBoxContainer/ValLevel/ValueH/Value.text = str(item.Value)
	
	show()


