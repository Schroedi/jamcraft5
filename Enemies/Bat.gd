extends KinematicBody

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const Drop = preload("res://Weapon/Drop.tscn")

export var ACCELERATION = 3.0
export var MAX_SPEED = 2
export var FRICTION = 2.0

export var level = 1

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
	animations.get_animation("Actions").loop = true
	#animations.play("ArmatureAction")
	$AnimationTree.set("parameters/Seek/seek_position", randf())
	$AnimationTree.active = true

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
	var facing = Vector3(velocity.x, 0, velocity.z).normalized()
	if not velocity.is_equal_approx(Vector3.ZERO):
		var rotTransform = $Nocts.transform.looking_at(-facing, Vector3.UP)
		var thisRotation = Quat($Nocts.transform.basis).slerp(rotTransform.basis, .1)
		$Nocts.transform = Transform(thisRotation, $Nocts.transform.origin)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func deal_damage():
	$Hitbox.monitorable = true
	yield(get_tree(), "idle_frame")
	$Hitbox.monitorable = false
	pass

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback

func _on_Stats_no_health():
	var drop = Drop.instance()
	drop.transform = transform
	drop.level = level
	get_parent().add_child(drop)
	
	
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.transform = transform
