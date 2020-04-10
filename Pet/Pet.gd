extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO

var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			var direction = (player.global_position - global_position).normalized()
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			sprite.flip_h = velocity.x < 0
			if playerDetectionZone.player:
				state = IDLE

	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = IDLE
	else:
		state = CHASE
		print("chase")

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
