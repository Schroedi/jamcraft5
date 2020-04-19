extends Node2D


func _ready() -> void:
	GSound.intro.play()

func _process(delta: float) -> void:
	if GSound.intro.get_playback_position() > 0:
		$AnimationTree.active = true
		set_process(false)

func start_game():
	$AnimationTree.active = false
	Loader.goto_scene("res://Game.tscn")
