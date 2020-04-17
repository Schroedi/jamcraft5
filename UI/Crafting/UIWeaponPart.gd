tool
extends TextureButton

onready var weapon_model = $"MarginContainer/ViewportContainer/Viewport/Weapons"

export var part_name: String

const parts = {"Handle": preload("res://Weapon/Handle.tscn"),
"Mid 1": preload("res://Weapon/Mid 1.tscn"),
"Mid 2": preload("res://Weapon/Mid 2.tscn"),
"Mid 3": preload("res://Weapon/Mid 3.tscn"),
"Tip 1": preload("res://Weapon/Tip 1.tscn"),
"Tip 2": preload("res://Weapon/Tip 2.tscn"),
"Tip 3": preload("res://Weapon/Tip 3.tscn")}


func set_part_name(v):
	part_name = v
	# catch early calls
	if not weapon_model:
		return
	print("part: " + part_name)
	for c in weapon_model.get_children():
		c.queue_free()
	weapon_model.add_child(parts[part_name].instance())

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
