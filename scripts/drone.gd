extends CharacterBody3D

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var fps = false

@export var animating = true

var camrot_h = 0
var camrot_v = 0
@export var cam_v_max = 80
@export var cam_v_min = -80
@export var joystick_sensitivity = 10
var h_sensitivity = .01
var v_sensitivity = .01
var h_acceleration = 20
var v_acceleration = 20
var joyview = Vector2()

#fps
var connected = false
var t_pos
var t = 0.
var t_target = 1. #max rail speed
var actual_rotation := Vector3()
var rel_pos
var rail
var rail_speed
var cayote_t = 0.
var jump_t = 10.
@export var mouse_sensitivity := 2.0
@export var look_sensitivity = 20.
@export var speed = 2
@export var speed_running = 5
@export var jump_height = 6
@export var acceleration = 20.
## Vertical angle limit of rotation move
@export var vertical_angle_limit := 1.4
var vel_keep
var last_vel

var travel = 0.
var haptics = true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.make_current()

# Rotate the in the correct way for fps mode and drone mode.
func _input(event):	
	if fps:
		if event is InputEventMouseMotion and not $"../pausemenu".visible:
			rotate_camera(event.relative)
	else:
		if event is InputEventMouseMotion and not $"../pausemenu".visible and not animating:
			rotate_camera2(event.relative)
		
func _joystick_input():
	if (Input.is_action_pressed("lookup") ||  Input.is_action_pressed("lookdown") ||  Input.is_action_pressed("lookleft") ||  Input.is_action_pressed("lookright")):
		joyview.x = Input.get_action_strength("lookleft") - Input.get_action_strength("lookright")
		joyview.y = Input.get_action_strength("lookup") - Input.get_action_strength("lookdown")
		camrot_h += joyview.x * joystick_sensitivity * h_sensitivity
		camrot_v += joyview.y * joystick_sensitivity * v_sensitivity 
		
# Switch between fps mode and drone mode.
func set_fps(enable: bool):
	fps = enable
	if not animating:
		rotation.x = 0.
		rotation.y = 0.
		$head.rotation.x = 0.
	if fps:
		$head/Camera3D.make_current()
		$CollisionShape3D2.disabled = false
		$CollisionShape3D.disabled = true
		if $"./DroneLight".visible:
			$head/flashlight.visible = true
			$"./DroneLight".visible = false
	else:
		$Camera3D.make_current()
		$CollisionShape3D2.disabled = true
		$CollisionShape3D.disabled = false
		if $head/flashlight.visible:
			$head/flashlight.visible = false
			$"./DroneLight".visible = true

func _process(delta):
	if fps:
		# send camera position to renderingserver so it can be used by the shaders fading in and out distant objects.
		RenderingServer.global_shader_parameter_set("cam_pos", $head/Camera3D.global_position)
		rotate_camera(Input.get_vector("look_left","look_right", "look_up", "look_down" ) * look_sensitivity * delta * 60.)
		# Gravity and jumping using cayote time, so it feels a bit better when jumping from a tree.
		if is_on_floor():
			cayote_t = 0.
			if jump_t < 0.2:
				cayote_t = 10.
				velocity.y = jump_height
				jump_t = 10.
		else:
			jump_t += delta
			cayote_t += delta
			velocity.y -= 9.81 * delta
		# Jump action
		if Input.is_action_just_pressed("move_jump"):
			if cayote_t < 0.2:
				cayote_t = 10.
				$AudioStreamPlayer3D.play()
				if haptics:
					Input.start_joy_vibration(0, 1., 1.0, 0.1)
				velocity.y = jump_height
			else:
				jump_t = 0.

		# Movement.
		var input =  Input.get_vector("move_left","move_right",  "move_forward", "move_backward" )
		var input_dir = (transform.basis * Vector3(input.x, 0., input.y))
		var trueaccel = acceleration
		# When not on the floor, there is less control over acceleration, but not zero.
		if not is_on_floor():
			trueaccel *= 0.25
		var vel_y = velocity.y
		if Input.get_action_strength("move_sprint"):
			velocity = velocity.move_toward(input_dir * speed_running, delta * trueaccel)
			travel += speed_running * delta * input_dir.length()
		else:
			velocity = velocity.move_toward(input_dir * speed, delta * trueaccel)
			travel += speed * delta * input_dir.length()
		# sounds effects and haptics
		if is_on_floor() and travel > 1.7:
			$AudioStreamPlayer3D.play()
			if haptics:
				Input.start_joy_vibration(0, 0.5, 0.5, 0.05)
			travel = 0.
		velocity.y = vel_y
		move_and_slide()
	else:
		# send camera position to renderingserver so it can be used by the shaders fading in and out distant objects.
		RenderingServer.global_shader_parameter_set("cam_pos", $Camera3D.global_position)
			
		# JoyPad Controls
		if not animating and not $"../pausemenu".visible:
			rotate_camera2(Input.get_vector("look_left","look_right", "look_up", "look_down" ) * look_sensitivity * delta * 60.)

		if Input.is_action_pressed('sprint'):
			SPEED = 15.0
		else:
			SPEED = 5.0
		
		# Prevents the player from going out of bounds.
		if position.x > 998:
			position.x = 995
		if position.z > 998:
			position.z = 995
		if position.x < 2:
			position.x = 5
		if position.z < 2:
			position.z = 5
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
	
# Rotate camera function for fps mode
func rotate_camera(mouse_axis : Vector2) -> void:
	actual_rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	actual_rotation.x = clamp(actual_rotation.x - mouse_axis.y * (mouse_sensitivity/1000), -vertical_angle_limit, vertical_angle_limit)
	rotation.y = actual_rotation.y
	$head.rotation.x = actual_rotation.x
	
# Rotate camera function for drone mode
func rotate_camera2(mouse_axis : Vector2) -> void:
	actual_rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	actual_rotation.x = clamp(actual_rotation.x - mouse_axis.y * (mouse_sensitivity/1000), -vertical_angle_limit, vertical_angle_limit)
	rotation.y = actual_rotation.y
	rotation.x = actual_rotation.x
	
