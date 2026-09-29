extends Button

@export var max_load_time = 10000
var tween

# Fade out the intro video after 3.5 seconds. 
func _ready():
	tween = create_tween()
	tween.tween_interval(3.5)
	tween.tween_property($"../../AspectRatioContainer", 'modulate', Color.TRANSPARENT, 1)
	tween.tween_property($"../../AspectRatioContainer", 'visible', false, 0)

# Loads the target scene, removes the current scene.
func goto_scene(path, current_scene):
	# Show loading screen in front of everything.
	$"../../loadingscreen".show()
	
	# No async loading because this seems fine. 
	await get_tree().create_timer(0.1).timeout
	var scene = load(path)
	get_tree().get_root().add_child(scene.instantiate())
	current_scene.queue_free()

# Start the loading when this button is pressed.
func _on_pressed():
	self.text = 'Loading'
	self.disabled = true;
	goto_scene("res://scenes/Jungle.tscn", get_parent().get_parent())

# Quit the program
func _on_quitbtn_pressed():
	get_tree().quit()

# Show / Hide the credits.
func _on_credits_close_requested():
	$"../../Credits".hide()

func _on_creditsbtn_pressed():
	$"../../Credits".show()

# Hide the precredits 
func _on_button_pressed():
	$"../../Precredits".hide()
