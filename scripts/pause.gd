extends Control

@export var timecolor: Gradient
@export var timeangle: Curve
@export var shadowenabled: bool;
var animating
# Called when the node enters the scene tree for the first time.
func _ready():
	animating = true
	shadowenabled = true
	_on_h_slider_value_changed(0.6)
	$VBoxContainer/HSlider.value = 0.6

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if visible:
				hide()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_settingsbtn_pressed():
	$Settings.show()


func _on_quitbtn_pressed():
	get_tree().quit()



func _on_showcasebtn_pressed():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if animating:
		$"../env".camera_attributes.dof_blur_far_enabled = false
		$"../env".camera_attributes.dof_blur_amount = 0.2
		$"../AnimationPlayer".stop()
		$"../Drone/Camera3D".fov = 70.0
		$"../Drone".animating = false
		animating = false
	else:
		if $"../env".camera_attributes.dof_blur_near_enabled:
			$"../env".camera_attributes.dof_blur_far_enabled = true
		$"../env".camera_attributes.dof_blur_amount = 0.1
		$"../Drone".animating = true
		$"../AnimationPlayer".play("camera cinematic")
		animating = true


func _on_h_slider_value_changed(value):
	if (value < 0.01):
		if shadowenabled:
			$"../Drone/DroneLight".shadow_enabled = true
		else:
			$"../Drone/DroneLight".shadow_enabled = false
		get_node("%sun").shadow_enabled = false
		$"../Drone/DroneLight".visible = true
	else:
		if shadowenabled:
			$"../Drone/DroneLight".shadow_enabled = true
			get_node("%sun").shadow_enabled = true
		$"../Drone/DroneLight".visible = false
	get_node("%sun").light_color = timecolor.sample(value)
	get_node("%sun").rotation_degrees.x = timeangle.sample(value) * -1.0
	




func _on_showcasebtn_2_pressed():
	$"../MonitorOverlay".visible = not $"../MonitorOverlay".visible


func _on_blackbars_pressed():
	$"../BlackBars".visible = not $"../BlackBars".visible
