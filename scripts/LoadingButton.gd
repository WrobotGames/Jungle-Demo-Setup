extends Button

@export var max_load_time = 10000
var tween
# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween()
	tween.tween_interval(3.5)
	tween.tween_property($"../../AspectRatioContainer", 'modulate', Color.TRANSPARENT, 1)
	tween.tween_property($"../../AspectRatioContainer", 'visible', false, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.

func goto_scene(path, current_scene):
	
	var loader = ResourceLoader.load_threaded_request(path, "", true)
	$"../../loadingscreen".show()
	if loader == null:
		print("Resource loader unable to load the resource at path")
		return
	
	
	while true:
		await get_tree().create_timer(0.1).timeout
		if (ResourceLoader.load_threaded_get_status(path) == 3):
			var resource = ResourceLoader.load_threaded_get(path)
			get_tree().get_root().call_deferred('add_child',resource.instantiate())
		
			
			print('loaded')
			current_scene.queue_free()
			break
		
		
		


func _on_pressed():
	self.text = 'Loading'
	self.disabled = true;
	goto_scene("res://scenes/Jungle.tscn", get_parent().get_parent())


func _on_quitbtn_pressed():
	get_tree().quit()


func _on_credits_close_requested():
	$"../../Credits".hide() # Replace with function body.


func _on_creditsbtn_pressed():
	$"../../Credits".show()


func _on_settingsbtn_pressed():
	$"../../Settings".show()


func _on_button_pressed():
	$"../../Precredits".hide()
