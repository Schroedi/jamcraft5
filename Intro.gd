extends Node2D


func _ready() -> void:
	$Timer.start()

func _process(delta: float) -> void:
	if GSound.intro.get_playback_position() > 0:
		$AnimationTree.active = true
		set_process(false)
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GSound.intro.stop()
		start_game()

func start_game():
	$AnimationTree.active = false
	Loader.goto_scene("res://Game.tscn")


func _on_Timer_timeout() -> void:
	GSound.intro.play()
