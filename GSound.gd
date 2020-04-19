extends Node


onready var intro = $Intro

onready var tween_out = get_node("Tween")
onready var tween_in = get_node("Tween")

export var transition_duration = 2.00
export var transition_type = 1 # Linear


func start_explore():
	tween_out.interpolate_property($Crafting, "volume_db", $Crafting.volume_db, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_in.interpolate_property($Explore, "volume_db", $Explore.volume_db, -0, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	tween_in.start()

func start_crafting():
	tween_out.interpolate_property($Crafting, "volume_db", $Crafting.volume_db, -0, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_in.interpolate_property($Explore, "volume_db", $Explore.volume_db, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	tween_in.start()


func _on_Intro_finished() -> void:
	$Explore.seek(0)
	$Crafting.seek(0)
	pass # Replace with function body.
