extends ColorRect

var timer = 0.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	custom_minimum_size.y = 10. * abs(sin(timer))
	timer += delta * 5.
