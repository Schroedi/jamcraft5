extends KinematicBody

export var ACCELERATION = 3.0
export var MAX_SPEED = 2.5
export var FRICTION = 1.0

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector3.ZERO

var state = CHASE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var animations = $pompom/AnimationPlayer

onready var start_transform = self.transform

func _ready() -> void:
	animations.get_animation("Pompom v3 Pompom v3 Body15 Action").loop = true
	animations.play("Pompom v3 Pompom v3 Body15 Action")

func _physics_process(delta):
	var direction = player.transform.origin - transform.origin
	direction.y = 0
	direction = direction.normalized()
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			if playerDetectionZone.player:
				state = IDLE
	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN * 100, Vector3.UP, true, 4, PI/2.0)
	if direction != Vector3.ZERO:
		var rotTransform = player.transform.looking_at(transform.origin, Vector3.UP)
		var thisRotation = Quat(transform.basis).slerp(rotTransform.basis, .01)
		transform = Transform(thisRotation, transform.origin)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = IDLE
	else:
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage

func _on_Stats_no_health():
	pass

func respawn():
	# teleport
	self.transform = start_transform
	stats.health = stats.max_health
	stats.dead = false
