extends KinematicBody

export var ACCELERATION = 5.0
export var MAX_SPEED = 2.0
export var ROLL_SPEED = 3.0
export var FRICTION = 5.0

signal life_changed #(float)
signal died

const ANIM_LIGHT = 0
const ANIM_SEMILIGHT = 1
const ANIM_MEDIUMT = 2
const ANIM_HEAVY = 3

var curre_attack_type = ANIM_MEDIUMT

var action_queued = MOVE

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector3.ZERO
var facing_dir = Vector3.BACK

onready var animationTree = $AnimationTree
onready var animationPlayer = $Smurp/AnimationPlayer
onready var weapon = $"Smurp/Armature/Skeleton/BoneAttachment/HitboxPivot/Weapon/"
onready var Smurp = $Smurp
onready var stats = $Stats

onready var anim_durations = [animationPlayer.get_animation("Attack Light").length,
animationPlayer.get_animation("Attack Semilight").length,
animationPlayer.get_animation("Attack Medium").length,
animationPlayer.get_animation("Attack Heavy").length]


func _ready():
	animationPlayer.get_animation("Walk").loop = true
	animationPlayer.get_animation("Idle").loop = true
	
	animationTree.active = true
	weapon.facing_dir = facing_dir
	Globals.player_weapon = weapon

func process_input(delta):
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector3.ZERO:
		# rotate smurp
		var rotTransform = Smurp.transform.looking_at(-input_vector, Vector3.UP)
		var thisRotation = Quat(Smurp.transform.basis).slerp(rotTransform.basis, .1)
		Smurp.transform = Transform(thisRotation,Smurp.transform.origin)
		facing_dir = thisRotation.xform(-Vector3.FORWARD)
		weapon.facing_dir = facing_dir
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
	
	animationTree.set("parameters/WalkIdle/blend_amount", 1-velocity.length())
	
	if Input.is_action_just_pressed("roll"):
		action_queued = ROLL
	
	if Input.is_action_just_pressed("attack"):
		action_queued = ATTACK


func _physics_process(delta):
	if stats.dead:
		return
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	process_input(delta)
	match action_queued:
		ATTACK:
			attack_animation_started()
		ROLL:
			start_roll()
	action_queued = MOVE
	
	move(delta)

func roll_state(delta):
	velocity = facing_dir * ROLL_SPEED
	process_input(delta)
	move(delta)

func attack_state(delta):
	process_input(delta)
	move(delta)

func move(_delta):
	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN * 100, Vector3.UP, true, 4, PI/2.0)

func start_roll():
	animationTree.set("parameters/RollShot/active", true)
	$RollTimer.wait_time = animationPlayer.get_animation("Roll").length
	$RollTimer.start()
	state = ROLL

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_started():
	state = ATTACK
	$AttackTimer.wait_time = anim_durations[curre_attack_type]
	$AttackTimer.start()
	# set attack type
	animationTree.set("parameters/Attack/current", curre_attack_type)
	animationTree.set("parameters/Seek/seek_position", 0)
	weapon.start_attack()

func attack_animation_finished():
	animationTree.set("parameters/AttackAdd/amount", 0)
	state = MOVE
	weapon.end_attack()

func _on_RollTimer_timeout() -> void:
	roll_animation_finished()


func _on_AttackTimer_timeout() -> void:
	attack_animation_finished()

func _on_Hurtbox_area_entered(area: Area) -> void:
	# TODO: inv. timer
	stats.health -= area.damage
	
	emit_signal("life_changed", stats.health)

func _on_Stats_no_health() -> void:
	emit_signal("died")
	pass # Replace with function body.
