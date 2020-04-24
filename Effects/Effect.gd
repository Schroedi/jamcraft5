extends Spatial

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	$AnimationPlayer.play("Hit")

func _on_animation_finished():
	queue_free()
