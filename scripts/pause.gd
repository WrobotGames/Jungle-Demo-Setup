extends Control

@export var timecolor: Gradient
@export var timeangle: Curve
@export var shadowenabled: bool;
var animating
var dof = false
var is_fps
# This variable stores to position of fps or drone mode,
# so when switching to showcase and back does not lose the position.
var lastpos = Vector3(479, 119, 435)

# Set default time of day.
func _ready():
	animating = true
	shadowenabled = true
	_on_h_slider_value_changed(0.6)
	$VBoxContainer/HSlider.value = 0.6

# Input to show/hide pause menu
func _process(_delta: float) -> void:
		if Input.is_action_just_pressed('pause'):
			if visible:
				hide()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Hide the pause menu
func _on_resume_pressed():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Show the settings menu
func _on_settingsbtn_pressed():
	$Settings.show()

# Quit game
func _on_quitbtn_pressed():
	get_tree().quit()

# Switch to showcase (cinematic) mode
func _on_showcasebtn_pressed():
	hide()
	$"../black_panel".show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not animating:
		lastpos = $"../Drone".position
		$"../Drone".animating = true
		$"../AnimationPlayer".play("camera cinematic")
		animating = true
		$"../Drone".set_fps(false)
		is_fps = false
		toggle_dof(dof)

# Switch to drone mode
func _on_drone_mode_pressed() -> void:
	hide()
	$"../black_panel".hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if animating or is_fps:

		$"../Drone/Camera3D".fov = 70.0
		$"../Drone".animating = false
		$"../Drone".set_fps(false)
		is_fps = false
		if animating:
			$"../AnimationPlayer".stop()
			animating = false
			$"../Drone".position = lastpos
		toggle_dof(dof)

# Switch to fps mode.
func _on_fps_mode_pressed() -> void:
	hide()
	$"../black_panel".hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if animating or not is_fps:
		$"../Drone/Camera3D".fov = 70.0
		$"../Drone".animating = false
		$"../Drone".set_fps(true)
		is_fps = true
		if animating:
			$"../AnimationPlayer".stop()
			animating = false
			$"../Drone".position = lastpos
		toggle_dof(dof)

# Time of day system.
func _on_h_slider_value_changed(value):
	# If the value is small, switch to night.
	# Switching to night disables the sun including its shadows
	# but it does enable player lights so they can still see stuff up close.
	if (value < 0.01):
		get_node("%sun").visible = false
		get_node("%sun").light_color = Color(0.,0.,0.)
		if shadowenabled:
			$"../Drone/DroneLight".shadow_enabled = true
			$"../Drone/head/flashlight".shadow_enabled = true
		else:
			$"../Drone/DroneLight".shadow_enabled = false
			$"../Drone/head/flashlight".shadow_enabled = false
		get_node("%sun").shadow_enabled = false
		if is_fps:
			$"../Drone/head/flashlight".visible = true
		else:
			$"../Drone/DroneLight".visible = true
	else:
		get_node("%sun").visible = true
		var col = clamp(lerp(0.5, 2., value), 0., 1.)
		col = 1.
		get_node("%sun").light_color = Color(col,col,col)
		if shadowenabled:
			$"../Drone/DroneLight".shadow_enabled = true
			get_node("%sun").shadow_enabled = true
			$"../Drone/head/flashlight".shadow_enabled = true
		if is_fps:
			$"../Drone/head/flashlight".visible = false
		else:
			$"../Drone/DroneLight".visible = false
	# Sample the color temperature and sun angle based on predefined curves.
	get_node("%sun").light_temperature = lerp(1300., 5700.,value)
	get_node("%sun").rotation_degrees.x = timeangle.sample(value) * -1.0

# Enable / Disable Depth of Field effect.
func toggle_dof(toggled):
	dof = toggled
	if animating:
		$"Settings".env.camera_attributes.dof_blur_near_enabled = toggled
		$"Settings".env.camera_attributes.dof_blur_far_enabled = toggled
	else:
		$"Settings".env.camera_attributes.dof_blur_near_enabled = false
		$"Settings".env.camera_attributes.dof_blur_far_enabled = false

# Toggle performance statistics overlay.
func _on_showcasebtn_2_pressed():
	$"../MonitorOverlay".visible = not $"../MonitorOverlay".visible

# Toggle cinematic bars visibility
func _on_blackbars_pressed():
	$"../BlackBars".visible = not $"../BlackBars".visible

# Toggle plush visibility.
func _on_plush_pressed() -> void:
	get_tree().get_nodes_in_group('plush')[0].visible = not get_tree().get_nodes_in_group('plush')[0].visible
