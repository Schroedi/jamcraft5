extends KinematicBody

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
var velocity = Vector3.ZERO
var facing_dir = Vector3.BACK

export var weapon_wobble_offset = 0.0

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var weapon = $"Smurp/Armature/Skeleton/BoneAttachment/HitboxPivot/Weapon/"
onready var Smurp = $Smurp

func _ready():
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

func move_state(delta):
	process_input(delta)
#	wobble_weapon()
	move(delta)
	
func process_input(delta):
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector3.ZERO:
		facing_dir = input_vector
		weapon.facing_dir = input_vector
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		
		# rotate smurp
		var rotTransform = Smurp.transform.looking_at(-input_vector, Vector3.UP)
		var thisRotation = Quat(Smurp.transform.basis).slerp(rotTransform.basis, .1)
		Smurp.transform = Transform(thisRotation,Smurp.transform.origin)
		
		#animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		#animationState.travel("Idle")
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
	
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		animationState.travel("Attack_charge")
		
	if Input.is_action_just_released("attack"):
		state = ATTACK
		animationState.travel("Attack_end")

func roll_state(delta):
	velocity = facing_dir * ROLL_SPEED
	animationState.travel("Roll")
	#process_input(delta) # this will not stop the roll as we override the animation state directly
	move(delta)

func attack_state(delta):
	process_input(delta)
	move(delta)
	

func move(_delta):
	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN * 100, Vector3.UP, true, 4, PI/2.0)

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_started():
	weapon.start_attack()
	print("dmg start")

func attack_animation_finished():
	state = MOVE
	weapon.end_attack()
	print("dmg end")

func charged():
	print("charged")

func charge_start():
	print("charge start")
