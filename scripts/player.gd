extends CharacterBody2D

class_name Player

@export var level: Level
@export var bomb_scene: PackedScene
@export var speed = 400
@export var max_bombs = 1
var available_bombs = 0
var number = 1
var animation

# Called when the node enters the scene tree for the first time.
func _ready():
	animation = get_node("AnimatedSprite2D")
	available_bombs = max_bombs
	
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
	custom_physics_process(delta)
	set_animation()
	move_and_slide()
	
func custom_physics_process(delta):
	pass

func _on_explosion(body):
	queue_free()
	
func _on_placed_bomb_explode():
	if available_bombs < max_bombs: available_bombs += 1
	
func place_bomb():
	if (available_bombs <= 0): return
	
	available_bombs -= 1
	
	var bomb_tile = level.local_to_map(position)
	var player_tile = level.map_to_local(bomb_tile)
	var new_bomb : Bomb = bomb_scene.instantiate()
	
	new_bomb.position = player_tile
	new_bomb.origin_player = self
	new_bomb.level = level
	new_bomb.coords = bomb_tile
	new_bomb.strength = 3
	new_bomb.set_collision_layer_value(number, false)
	new_bomb.exploded.connect(_on_placed_bomb_explode)
	new_bomb.set_collision_mask_value(number, false)
	get_parent().add_child(new_bomb)
