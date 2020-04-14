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
onready var weapon_pivot = $Feeny/HitboxPivot
onready var weapon = $Feeny/HitboxPivot/Weapon
onready var feeny = $Feeny

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

func wobble_weapon():
	var target_angle = weapon_pivot.rotation
	target_angle += weapon_wobble_offset
	weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, .1)

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
		
		# rotate feeny
		var rotTransform = feeny.transform.looking_at(-input_vector, Vector3.UP)
		var thisRotation = Quat(feeny.transform.basis).slerp(rotTransform.basis, .1)
		feeny.transform = Transform(thisRotation,feeny.transform.origin)
		
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
	
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	velocity = facing_dir * ROLL_SPEED
	animationState.travel("Roll")
	#process_input(delta) # this will not stop the roll as we override the animation state directly
	move(delta)

func attack_state(delta):
	process_input(delta)
	move(delta)
	animationState.travel("Attack")

func move(delta):
	velocity = move_and_slide_with_snap(Vector3(velocity.x, 0, velocity.z), Vector3.DOWN)
	#velocity = move_and_slide(Vector3(velocity.x, 0, velocity.z))

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_started():
	#weapon_pivot.rotation = facing_dir.angle()
	weapon.start_attack()

func attack_animation_finished():
	state = MOVE
	weapon.end_attack()
