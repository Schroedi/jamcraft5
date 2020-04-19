extends Area

export var level = 1

func _ready() -> void:
	$CPUParticles.one_shot = false
	$CPUParticles.emitting = true

func picked():
	$AnimationPlayer.play("picked")
