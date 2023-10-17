extends CharacterBody2D

@export var bomb_scene: PackedScene
@export var speed = 400
var animation

# Called when the node enters the scene tree for the first time.
func _ready():
	animation = get_node("AnimatedSprite2D")
	

func get_input(delta):
	var input_direction = Input.get_vector("dpad_left", "dpad_right", "dpad_up", "dpad_down")
	if input_direction == Vector2.ZERO:
		input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input_direction * speed * delta
	
func _input(event):
	if event.is_action_pressed("place_bomb"):
		var new_bomb = bomb_scene.instantiate()
		new_bomb.position = position
		get_parent().add_child(new_bomb)
	
func set_animation():
	if velocity == Vector2.ZERO:
		animation.stop()
		animation.set_frame_and_progress(0, 0)
		return
		
	var sin_of_angle = sin(velocity.angle())
	
	if sin_of_angle > -0.5 and sin_of_angle < 0.5 and velocity.x > 0:
		animation.flip_h = false
		animation.play("walk_right")
	elif sin_of_angle > -0.5 and sin_of_angle < 0.5 and velocity.x < 0:
		animation.flip_h = true
		animation.play("walk_right")
	elif sin_of_angle > 0.5:
		animation.play("walk_down")
	elif sin_of_angle < -0.5:
		animation.play("walk_up")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	set_animation()
	move_and_slide()
