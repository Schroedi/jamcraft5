tool
extends TextureButton

onready var weapon_model = $"MarginContainer/ViewportContainer/Viewport/Weapons"
onready var camera = $"MarginContainer/ViewportContainer/Viewport/Camera"

export var part_name: String
export var part_power: int = 0
# part_power: 1-4 for slots, attack damage or special move ID

const parts = {"Handle": preload("res://Weapon/Handle.tscn"),
"Mid 1": preload("res://Weapon/Mid 1.tscn"),
"Mid 2": preload("res://Weapon/Mid 2.tscn"),
"Mid 3": preload("res://Weapon/Mid 3.tscn"),
"Tip 1": preload("res://Weapon/Tip 1.tscn"),
"Tip 2": preload("res://Weapon/Tip 2.tscn"),
"Tip 3": preload("res://Weapon/Tip 3.tscn")}

onready var overlay = {"Handle": $"Overlay/Type/overlay_handle",
"Mid 1": $"Overlay/Type/overlay_mid",
"Mid 2": $"Overlay/Type/overlay_mid",
"Mid 3": $"Overlay/Type/overlay_mid",
"Tip 1": $"Overlay/Type/overlay_tip",
"Tip 2": $"Overlay/Type/overlay_tip",
"Tip 3": $"Overlay/Type/overlay_tip"}

onready var attributes = {"Handle": $"Overlay/Attributes/Handle",
"Mid 1": $"Overlay/Attributes/Mid",
"Mid 2": $"Overlay/Attributes/Mid",
"Mid 3": $"Overlay/Attributes/Mid",
"Tip 1": $"Overlay/Attributes/Tip",
"Tip 2": $"Overlay/Attributes/Tip",
"Tip 3": $"Overlay/Attributes/Tip"}

onready var XOffset = {"Handle": 0.25,
"Mid 1": -0.25,
"Mid 2": -0.25,
"Mid 3": -0.25,
"Tip 1": -0.25,
"Tip 2": -0.25,
"Tip 3": -0.25}

onready var HandleSlots = [$"Overlay/Attributes/Handle/HBoxContainer2/1",$"Overlay/Attributes/Handle/HBoxContainer2/2",$"Overlay/Attributes/Handle/HBoxContainer2/3",$"Overlay/Attributes/Handle/HBoxContainer2/4"]
onready var DamageMid = [$"Overlay/Attributes/Mid/HBoxContainer/1",$"Overlay/Attributes/Mid/HBoxContainer/2",$"Overlay/Attributes/Mid/HBoxContainer/3",$"Overlay/Attributes/Mid/HBoxContainer/4"]
onready var SpetialName = $Overlay/Attributes/Tip/Label

func set_part_name(v):
	part_name = v
	# catch early calls
	if not weapon_model:
		return
	print("part: " + part_name)
	for c in weapon_model.get_children():
		c.queue_free()
	weapon_model.add_child(parts[part_name].instance())
	overlay[part_name].visible = true
	attributes[part_name].visible = true
	camera.translation= Vector3 (XOffset[part_name],0,0)
	for i in 4:
		if part_power>=i+1:
			HandleSlots[i].visible = true
			DamageMid[i].visible = true
	SpetialName.text = Globals.specials[part_power - 1]

func _ready() -> void:
	set_part_name(part_name)

func get_drag_data(_position):
	set_drag_preview(self.duplicate(DUPLICATE_USE_INSTANCING))
	return self

func _on_UIWeaponPart_pressed() -> void:
	pass # Replace with function body.


func _on_UIWeaponPart_mouse_entered() -> void:
	pass # Replace with function body.


func _on_UIWeaponPart_mouse_exited() -> void:
	pass # Replace with function body.

func get_component():
	return weapon_model.get_child(0)
