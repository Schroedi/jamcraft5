extends KinematicBody

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 3.0
export var MAX_SPEED = 2
export var FRICTION = 2.0

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector3.ZERO
var knockback = Vector3.ZERO

var state = CHASE

onready var animations = $Nocts/AnimationPlayer
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone

func _ready() -> void:
	animations.get_animation("ArmatureAction").loop = true
	animations.play("ArmatureAction")
	animations.seek(randf())

func _physics_process(delta):
	knockback = knockback.move_toward(Vector3.ZERO, FRICTION * delta)
	knockback = move_and_slide_with_snap(knockback, Vector3.DOWN * 100, Vector3.UP, true, 4, PI/2.0)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			var player:Spatial = playerDetectionZone.player
			if player != null:
				var direction = player.transform.origin - transform.origin
				direction.y = 0
				velocity = velocity.move_toward(direction.normalized() * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE

	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN * 100, Vector3.UP, true, 4, PI/2.0)
	# rotate smurp
	if velocity != Vector3.ZERO:
		var facing = Vector3(velocity.x, 0, velocity.z).normalized()
		var rotTransform = $Nocts.transform.looking_at(-facing, Vector3.UP)
		var thisRotation = Quat($Nocts.transform.basis).slerp(rotTransform.basis, .1)
		$Nocts.transform = Transform(thisRotation, $Nocts.transform.origin)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.global_position = global_position
