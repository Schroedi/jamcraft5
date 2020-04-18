extends KinematicBody

export var ACCELERATION = 5
export var MAX_SPEED = 2
export var ROLL_SPEED = 3
export var FRICTION = 5

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

func _ready():
	animationPlayer.get_animation("Walk").loop = true
	animationPlayer.get_animation("Idle").loop = true
	
	animationTree.active = true
	weapon.facing_dir = facing_dir
	Globals.player_weapon = weapon

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
	move(delta)
	
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
		animationTree.set("parameters/RollShot/active", true)
		$RollTimer.wait_time = animationPlayer.get_animation("Roll").length
		$RollTimer.start()
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		#animationState.travel("Attack")
		pass

func roll_state(delta):
	velocity = facing_dir * ROLL_SPEED
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

func _on_RollTimer_timeout() -> void:
	roll_animation_finished()
	pass # Replace with function body.
