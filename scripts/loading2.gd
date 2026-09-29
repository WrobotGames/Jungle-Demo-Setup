extends Control

var tween

# Fade out the loading screen and start the cinematic.
func _ready():
	tween = get_tree().create_tween()
	$"../AnimationPlayer".play("camera cinematic")
	tween.tween_interval(0.5)
	tween.tween_property($".","modulate", Color(0.0,0.0,0.0,0.0), 0.5)
	tween.tween_property(self, "visible", false, 0)
