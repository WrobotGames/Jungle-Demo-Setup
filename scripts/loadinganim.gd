extends ColorRect

var timer = 0.

# Simple loading animation to show the engine hasnt stalled.
func _process(delta: float) -> void:
	custom_minimum_size.y = 10. * abs(sin(timer))
	timer += delta * 5.
