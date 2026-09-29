extends Control

var env : WorldEnvironment
var sun : DirectionalLight3D

# Loading the high preset by default.
func _ready():
	env = get_tree().get_nodes_in_group("env")[0]
	sun = get_tree().get_nodes_in_group("sun")[0]
	_on_high_pressed()

# Hide the settings panel.
func _on_close_requested():
	hide()
	
####### Graphics Presets #######
# This "clicks" the buttons for the user.

func _on_lowest_pressed():
	_on_shadow_item_selected(1)
	_on_aa_item_selected(0)
	_on_dof_toggled(false)
	_on_vf_toggled(false)
	_on_glow_toggled(false)
	_on_global_illumination_item_selected(0)
	_on_render_distance_item_selected(0)
	$VBoxContainer/ScrollContainer/VBoxContainer/shadow.selected = 1
	$VBoxContainer/ScrollContainer/VBoxContainer/aa_container/aa.selected = 0
	$VBoxContainer/ScrollContainer/VBoxContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/vf.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/glow.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer5/global_illumination.selected = 0
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer4/render_distance.selected = 0
	

func _on_low_pressed():
	_on_shadow_item_selected(2)
	_on_aa_item_selected(0)
	_on_dof_toggled(false)
	_on_vf_toggled(false)
	_on_glow_toggled(true)
	_on_global_illumination_item_selected(1)
	_on_render_distance_item_selected(1)
	$VBoxContainer/ScrollContainer/VBoxContainer/shadow.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/aa_container/aa.selected = 0
	$VBoxContainer/ScrollContainer/VBoxContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/vf.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer5/global_illumination.selected = 1
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer4/render_distance.selected = 1

func _on_medium_pressed():
	_on_shadow_item_selected(3)
	_on_aa_item_selected(2)
	_on_dof_toggled(false)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_global_illumination_item_selected(2)
	_on_render_distance_item_selected(2)
	$VBoxContainer/ScrollContainer/VBoxContainer/shadow.selected = 3
	$VBoxContainer/ScrollContainer/VBoxContainer/aa_container/aa.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer5/global_illumination.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer4/render_distance.selected = 2

func _on_high_pressed():
	_on_shadow_item_selected(4)
	_on_aa_item_selected(2)
	_on_dof_toggled(false)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_global_illumination_item_selected(3)
	_on_render_distance_item_selected(3)
	$VBoxContainer/ScrollContainer/VBoxContainer/shadow.selected = 4
	$VBoxContainer/ScrollContainer/VBoxContainer/aa_container/aa.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer5/global_illumination.selected = 3
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer4/render_distance.selected = 3

func _on_ultra_pressed():
	_on_shadow_item_selected(5)
	_on_aa_item_selected(2)
	_on_dof_toggled(true)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_global_illumination_item_selected(3)
	_on_render_distance_item_selected(4)
	$VBoxContainer/ScrollContainer/VBoxContainer/shadow.selected = 5
	$VBoxContainer/ScrollContainer/VBoxContainer/aa_container/aa.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/dof.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer5/global_illumination.selected = 3
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer4/render_distance.selected = 4
	
#####################################

# DoF toggling is handled by the pause menu
# This does not really make sense but this is what I made.
func _on_dof_toggled(toggled_on):
	$"..".toggle_dof(toggled_on)

# Toggle volumetric fog.
func _on_vf_toggled(toggled_on):
	env.environment.volumetric_fog_enabled = toggled_on
	if toggled_on:
		env.environment.fog_density = 0.0005
	else:
		env.environment.fog_density = 0.002

# Toggle glow/bloom
func _on_glow_toggled(toggled_on):
	env.environment.glow_enabled = toggled_on

# Enabled sdfgi, toggles the background ground color to something so less light leaking is visible. 
func _on_sdfgi_toggled(toggled_on):
	env.environment.sdfgi_enabled = toggled_on
	RenderingServer.global_shader_parameter_set("ground_col_black", toggled_on)

# Set resolution.
func _on_res_value_changed(value):
	$"VBoxContainer/ScrollContainer/VBoxContainer/3d_res/reslabel".text = str(value) + "%"
	get_viewport().scaling_3d_scale = value / 100

# Set different shadow quality presets.
func _on_shadow_item_selected(index):
	if index == 0:
		sun.shadow_enabled = false
		$"..".shadowenabled = false
		$".."._on_h_slider_value_changed($"../VBoxContainer/HSlider".value)
	else:
		$"..".shadowenabled = true
		sun.shadow_enabled = true
		$".."._on_h_slider_value_changed($"../VBoxContainer/HSlider".value)
	if index == 1:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.directional_shadow_atlas_set_size(512,true)
		sun.directional_shadow_max_distance = 50
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_ORTHOGONAL)
		_on_grass_shadows_toggled(true)
	if index == 2:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.directional_shadow_atlas_set_size(1024,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS)
		sun.directional_shadow_max_distance = 100
		sun.directional_shadow_split_1 = 0.25
		_on_grass_shadows_toggled(true)
	
	if index == 3:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.directional_shadow_atlas_set_size(2048,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.04
		sun.directional_shadow_max_distance = 200
		_on_grass_shadows_toggled(true)
	
	if index == 4:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.directional_shadow_atlas_set_size(4096,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.02
		sun.directional_shadow_max_distance = 400
		_on_grass_shadows_toggled(false)
	if index == 5:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.directional_shadow_atlas_set_size(8192,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.02
		sun.directional_shadow_max_distance = 400
		_on_grass_shadows_toggled(false)
	if index == 6:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.directional_shadow_atlas_set_size(8192*2,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.02
		sun.directional_shadow_max_distance = 400
		_on_grass_shadows_toggled(false)
		
	if index == 0 or index == 1 or index == 2:
		$VBoxContainer/ScrollContainer/VBoxContainer/grass_shadows.disabled = true
	else:
		$VBoxContainer/ScrollContainer/VBoxContainer/grass_shadows.disabled = false

# Disables grass shadows.
func _on_grass_shadows_toggled(toggled_on: bool) -> void:
	$VBoxContainer/ScrollContainer/VBoxContainer/grass_shadows.button_pressed = toggled_on
	var grasses = get_tree().get_nodes_in_group("g_s")
	for grass in grasses:
		if toggled_on:
			grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

# Toggle grass visibility
func _on_grass_toggled(toggled_on):
	var grasses = get_tree().get_nodes_in_group("grass")
	for grass in grasses:
		grass.visible = toggled_on

# Toggle groundvegetation visibility
func _on_groundveg_toggled(toggled_on):
	get_tree().get_nodes_in_group("veg")[0].visible = toggled_on

# Toggle vsync
func _on_vsync_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Set music volume
func _on_music_vol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/reslabel.text = str(value * 100) + "%"

# Set sfx volume
func _on_sfx_vol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("GameSFX"), linear_to_db(value))
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer3/reslabel.text = str(value * 100) + "%"

# Enable / disable haptics (controller rumble)
func _on_haptics_toggled(toggled_on: bool) -> void:
	$"../../Drone".haptics = toggled_on
	$VBoxContainer/ScrollContainer/VBoxContainer/haptics.button_pressed = toggled_on

# Switch tone mapper.
func _on_d_p_toggled(toggled_on: bool) -> void:
	if toggled_on:
		env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	else:
		env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES

# Switch between windowed, fullscreen and exclusive.
func _on_windowmode_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# set frame rate limit.
func _on_fpscap_text_submitted(new_text: String) -> void:
	Engine.max_fps = new_text.to_int()

# set ui scale.
func _on_ui_scale_sl_drag_ended(value_changed: bool) -> void:
	if value_changed:
		get_tree().root.content_scale_factor = $VBoxContainer/ScrollContainer/VBoxContainer/ui_scale/ui_scale_sl.value
		$VBoxContainer/ScrollContainer/VBoxContainer/ui_scale/uiscalelabel.text = str($VBoxContainer/ScrollContainer/VBoxContainer/ui_scale/ui_scale_sl.value * 100.) + "%"

# render distance presets.
func _on_render_distance_item_selected(index: int) -> void:
	# Render distance for the trees
	var draw_distance
	# Distance at which the trees start to fade out.
	var draw_distance_start
	# multiplier for the grass render distance. with the high preset using a factor of 1.
	var draw_dist_factor
	if index == 0: #xlow (grass = off)
		draw_distance = 50
		draw_distance_start = 45
		draw_dist_factor = 0.25
		RenderingServer.global_shader_parameter_set("render_dist_factor", 0.25)
	elif index == 1: #low
		draw_distance = 100
		draw_distance_start = 90
		draw_dist_factor = 0.5
		RenderingServer.global_shader_parameter_set("render_dist_factor", 0.5)
	elif index == 2: #medium
		draw_distance = 150
		draw_distance_start = 140
		draw_dist_factor = 0.75
		RenderingServer.global_shader_parameter_set("render_dist_factor", 0.75)
	elif index == 3: #high
		draw_distance = 200
		draw_distance_start = 190
		draw_dist_factor = 1.
		RenderingServer.global_shader_parameter_set("render_dist_factor", 1.)
	elif index == 4: #ultra
		draw_distance = 300
		draw_distance_start = 290
		draw_dist_factor = 1.5
		RenderingServer.global_shader_parameter_set("render_dist_factor", 1.5)
	elif index == 5: #Extreme
		draw_distance = 400
		draw_distance_start = 390
		draw_dist_factor = 2.
		RenderingServer.global_shader_parameter_set("render_dist_factor", 2.)
	# Apply render distance to grass. Loop though grass spawners to set it.
	var grasses = get_tree().get_nodes_in_group("grass")
	for grass in grasses:
		grass.amount = grass.get_meta("p_amount") * draw_dist_factor * draw_dist_factor
		if index == 0:
			grass.visible = false
		else:
			grass.visible = true
	# Apply render distance to trees shader and loop though tree chunks.
	RenderingServer.global_shader_parameter_set("trees_draw_distance", draw_distance)
	RenderingServer.global_shader_parameter_set("trees_draw_distance_start", draw_distance_start)
	for child in get_tree().get_nodes_in_group("ctree")[0].get_child(2).get_children():
		for childchild in child.get_children():
			childchild.get_child(0).visibility_range_end = draw_distance
	for child in get_tree().get_nodes_in_group("dtree")[0].get_child(2).get_children():
		for childchild in child.get_children():
			childchild.visibility_range_begin = draw_distance_start

# Switch between anti aliasing methods.
func _on_aa_item_selected(index: int) -> void:
	if index == 0:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		get_viewport().use_taa = false
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	elif index == 1:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		get_viewport().use_taa = false
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	elif index == 2:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		get_viewport().use_taa = true
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	elif index == 3:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		get_viewport().use_taa = false
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2

# Set msaa.
func _on_msaa_item_selected(index: int) -> void:
	get_viewport().msaa_3d = index

# set SSAO and SDFGI
func _on_global_illumination_item_selected(index: int) -> void:
	if index ==0:
		_on_sdfgi_toggled(false)
		env.environment.ssao_enabled = false
	if index ==1:
		_on_sdfgi_toggled(false)
		env.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 1, 400., 500.)
	if index ==2:
		_on_sdfgi_toggled(false)
		env.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, false, 0.5, 1, 400., 500.)
	if index ==3:
		_on_sdfgi_toggled(true)
		env.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, false, 0.5, 1, 400., 500.)
		RenderingServer.gi_set_use_half_resolution(false)

# toggle SSIL
func _on_ssil_toggled(toggled_on: bool) -> void:
	env.environment.ssil_enabled = toggled_on
