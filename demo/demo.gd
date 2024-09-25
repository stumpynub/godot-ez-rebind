extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Move Left"): 
		print("moving left")
	if Input.is_action_just_pressed("Move Right"): 
		print("moving right")
