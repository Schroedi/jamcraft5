extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var facing_dir = Vector2.DOWN

export var weapon_wobble_offset = 0.0

onready var animationPlayer = $AnimationPlayer
onready var animationTree_dirs = $"Assembled 8 Directions/AnimationTree_dirs"
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var weapon_pivot = $HitboxPivot
onready var weapon = $HitboxPivot/Weapon

func _ready():
	Globals.curr_cam = $Camera2D
	animationTree_dirs.active = true
	animationTree.active = true
	weapon.facing_dir = facing_dir

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func wobble_weapon():
	var target_angle = weapon_pivot.rotation
	target_angle += weapon_wobble_offset
	weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, .1)

func move_state(delta):
	process_move(delta)
	# rotate weapon back to start after an attack
	weapon.rotation = lerp_angle(weapon.rotation, 0, .03)
	
	# bring wepon behind player
	var target_angle = facing_dir.angle() - .7
	weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, .1)
	
	wobble_weapon()
	
func process_move(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		facing_dir = input_vector
		weapon.facing_dir = input_vector
		animationTree_dirs.set("parameters/Idle/blend_position", input_vector)
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(_delta):
	velocity = facing_dir * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state(delta):
	process_move(delta)
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_started():
	weapon_pivot.rotation = facing_dir.angle()
	weapon.start_attack()

func attack_animation_finished():
	state = MOVE
	weapon.end_attack()
