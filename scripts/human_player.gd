extends Player

class_name HumanPlayer

func get_input(delta):
	var input_direction = Input.get_vector("dpad_left", "dpad_right", "dpad_up", "dpad_down")
	if input_direction == Vector2.ZERO:
		input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input_direction * speed * delta

func _input(event):
	if event.is_action_pressed("place_bomb"):
		place_bomb()
		
func custom_physics_process(delta):
	get_input(delta)
