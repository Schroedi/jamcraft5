extends MarginContainer
class_name MainUI

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var healthbar = $"Container/UpperLeft/HBoxContainer"
var heart_full = preload("res://UI/HeartUIFull.png")
var heart_empty = preload("res://UI/HeartUIEmpty.png")
var heart_half = preload("res://UI/HeartUIHalf.png")
			
func update_health(value):
	for i in healthbar.get_child_count():
		if value > i * 2 + 1:
			healthbar.get_child(i).texture = heart_full
		elif value > i * 2:
			healthbar.get_child(i).texture = heart_half
		else:
			healthbar.get_child(i).texture = heart_empty

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
