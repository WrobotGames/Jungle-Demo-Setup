extends CharacterBody3D


#Code partially from turorials




var SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



@export var animating = true

var camrot_h = 0
var camrot_v = 0
@export var cam_v_max = 80 # 75 recommended
@export var cam_v_min = -80 # -55 recommended
@export var joystick_sensitivity = 10
var h_sensitivity = .01
var v_sensitivity = .01
var h_acceleration = 20
var v_acceleration = 20
var joyview = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
	
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += -event.relative.y * v_sensitivity
		
func _joystick_input():
	if (Input.is_action_pressed("lookup") ||  Input.is_action_pressed("lookdown") ||  Input.is_action_pressed("lookleft") ||  Input.is_action_pressed("lookright")):
		
		joyview.x = Input.get_action_strength("lookleft") - Input.get_action_strength("lookright")
		joyview.y = Input.get_action_strength("lookup") - Input.get_action_strength("lookdown")
		camrot_h += joyview.x * joystick_sensitivity * h_sensitivity
		camrot_v += joyview.y * joystick_sensitivity * v_sensitivity 
		
		
func _process(delta):
	
		# JoyPad Controls
		
	_joystick_input()
	#Clamping the vertical rotation
	camrot_v = clamp(camrot_v, deg_to_rad(cam_v_min), deg_to_rad(cam_v_max))
	
	if not animating and not $"../pausemenu".visible:
		rotation.y = lerp_angle(rotation.y, camrot_h, delta * h_acceleration)
		rotation.x = lerp_angle(rotation.x, camrot_v, delta * v_acceleration)
	
	if Input.is_action_pressed('sprint'):
		SPEED = 15.0
	else:
		SPEED = 5.0
		
	if position.x > 1000:
		position.x = 999
	if position.z > 1000:
		position.z = 999
	if position.x < 0:
		position.x = 1
	if position.z < 0:
		position.z = 1


func _physics_process(delta):


	var direction = (transform.basis * Vector3(Input.get_action_strength("right") - Input.get_action_strength('left'), 0, Input.get_action_strength("backward") - Input.get_action_strength('forward'))).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, SPEED * delta)
		velocity.z = lerp(velocity.z, 0.0, SPEED * delta)
		velocity.y = lerp(velocity.y, 0.0, SPEED * delta)
	if not animating and not $"../pausemenu".visible:
		move_and_slide()
