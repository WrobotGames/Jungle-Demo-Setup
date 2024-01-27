extends Control

var env : WorldEnvironment
var sun : DirectionalLight3D


func _ready():
	env = get_tree().get_nodes_in_group("env")[0]
	sun = get_tree().get_nodes_in_group("sun")[0]
	_on_medium_pressed()



func _on_close_requested():
	hide()

func _on_fsr_toggled(toggled_on):
	if toggled_on:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/fsr2_2.button_pressed = false
	else:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR

func _on_taa_toggled(toggled_on):
	get_viewport().use_taa = toggled_on

func _on_dof_toggled(toggled_on):
	if $"..".animating:
		env.camera_attributes.dof_blur_far_enabled = toggled_on
	env.camera_attributes.dof_blur_near_enabled = toggled_on

func _on_vf_toggled(toggled_on):
	env.environment.volumetric_fog_enabled = toggled_on
	if toggled_on:
		env.environment.fog_density = 0.0005
	else:
		env.environment.fog_density = 0.003

func _on_glow_toggled(toggled_on):
	env.environment.glow_enabled = toggled_on

func _on_sdfgi_toggled(toggled_on):
	env.environment.sdfgi_enabled = toggled_on
	if toggled_on:
		env.environment.volumetric_fog_ambient_inject = 0.3
		env.environment.tonemap_exposure =1.3
	else:
		env.environment.tonemap_exposure = 1.0
		env.environment.volumetric_fog_ambient_inject = 1.0

func _on_ssil_toggled(toggled_on):
	env.environment.ssil_enabled = toggled_on

func _on_ssao_toggled(toggled_on):
	env.environment.ssao_enabled = toggled_on

func _on_res_value_changed(value):
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/reslabel.text = str(value) + "%"
	get_viewport().scaling_3d_scale = value / 100

func _on_shadow_item_selected(index):
	if index == 0:
		sun.shadow_enabled = false
		$"..".shadowenabled = false
	else:
		$"..".shadowenabled = true
		sun.shadow_enabled = true
	if index == 1:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.directional_shadow_atlas_set_size(512,true)
		sun.directional_shadow_max_distance = 50
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_ORTHOGONAL)
	if index == 2:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.directional_shadow_atlas_set_size(1024,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS)
		sun.directional_shadow_max_distance = 100
		sun.directional_shadow_split_1 = 0.32
	
	if index == 3:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.directional_shadow_atlas_set_size(2048,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.08
		sun.directional_shadow_max_distance = 200
	
	if index == 4:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.directional_shadow_atlas_set_size(4096,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.04
		sun.directional_shadow_max_distance = 400
	if index == 5:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.directional_shadow_atlas_set_size(8192,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.04
		sun.directional_shadow_max_distance = 500
	if index == 6:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.directional_shadow_atlas_set_size(8192*2,true)
		sun.set_shadow_mode(DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
		sun.directional_shadow_split_1 = 0.04
		sun.directional_shadow_max_distance = 500

func _on_lowest_pressed():
	_on_shadow_item_selected(0)
	_on_taa_toggled(false)
	_on_dof_toggled(false)
	_on_vf_toggled(false)
	_on_glow_toggled(false)
	_on_sdfgi_toggled(false)
	_on_ssil_toggled(false)
	_on_ssao_toggled(false)
	_on_res_value_changed(75.0)
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/shadow.selected = 0
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/taa.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/vf.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/glow.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/sdfgi.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssil.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssao.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/res.value = 75

func _on_low_pressed():
	_on_shadow_item_selected(2)
	_on_taa_toggled(false)
	_on_dof_toggled(false)
	_on_vf_toggled(false)
	_on_glow_toggled(true)
	_on_sdfgi_toggled(false)
	_on_ssil_toggled(false)
	_on_ssao_toggled(false)
	_on_res_value_changed(100)
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/shadow.selected = 2
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/fsr.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/taa.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/vf.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/sdfgi.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssil.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssao.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/res.value = 100

func _on_medium_pressed():
	_on_shadow_item_selected(3)
	_on_taa_toggled(true)
	_on_dof_toggled(false)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_sdfgi_toggled(false)
	_on_ssil_toggled(false)
	_on_ssao_toggled(true)
	_on_res_value_changed(100)
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/shadow.selected = 3
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/taa.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/sdfgi.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssil.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssao.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/res.value = 100

func _on_high_pressed():
	_on_shadow_item_selected(4)
	_on_taa_toggled(true)
	_on_dof_toggled(false)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_sdfgi_toggled(false)
	_on_ssil_toggled(false)
	_on_ssao_toggled(true)
	_on_res_value_changed(100)
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/shadow.selected = 4
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/taa.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/dof.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/sdfgi.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssil.button_pressed = false
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssao.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/res.value = 100

func _on_ultra_pressed():
	_on_shadow_item_selected(5)
	_on_taa_toggled(true)
	_on_dof_toggled(true)
	_on_vf_toggled(true)
	_on_glow_toggled(true)
	_on_sdfgi_toggled(true)
	_on_ssil_toggled(true)
	_on_ssao_toggled(true)
	_on_res_value_changed(100)
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/shadow.selected = 5
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/taa.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/dof.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/vf.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/glow.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/sdfgi.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssil.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/ssao.button_pressed = true
	$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/HBoxContainer/res.value = 100


func _on_grass_toggled(toggled_on):
	get_tree().get_nodes_in_group("grass")[0].visible = toggled_on


func _on_groundveg_toggled(toggled_on):
	get_tree().get_nodes_in_group("veg")[0].visible = toggled_on


func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_toggled(toggled_on):
	DisplayServer.window_set_vsync_mode(toggled_on)


func _on_fsr_2_2_toggled(toggled_on):
	if toggled_on:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		$VBoxContainer/ScrollContainer/VBoxContainer/GridContainer/fsr.button_pressed = false
	else:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
