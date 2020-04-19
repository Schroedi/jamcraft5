extends MarginContainer
class_name MainUI

const heart_full = preload("res://UI/HeartUIFull.png")
const heart_empty = preload("res://UI/HeartUIEmpty.png")
const heart_half = preload("res://UI/HeartUIHalf.png")

onready var healthbar = $"Container/UpperLeft/HBoxContainer"
onready var player = get_tree().get_nodes_in_group('player')[0]
onready var pet = get_tree().get_nodes_in_group('pet')[0]

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
	$Death.visible = false
	player.connect("life_changed", self, "update_health")
	player.connect("died", self, "die")


func die():
	$AnimationPlayer.play("die")


func _process(delta: float) -> void:
	if Input.is_action_pressed("return_base"):
		$Container/ButtomRight/ProgressBar.value += delta * 50
		if $Container/ButtomRight/ProgressBar.value >= $Container/ButtomRight/ProgressBar.max_value:
			player.respawn()
			pet.respawn()
	else:
		$Container/ButtomRight/ProgressBar.value = 0

func _on_Revive_pressed() -> void:
	$Death/Revive.visible = false
	player.respawn()
	pet.respawn()
	$AnimationPlayer.play_backwards("die")
