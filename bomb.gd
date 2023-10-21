class_name Bomb extends RigidBody2D

@export var timer = 30000
var origin_player : Player
var start_time = 0
var level: Level
var coords: Vector2i
var strength: int

# Called when the node enters the scene tree for the first time.
func _ready():
	start_time = Time.get_ticks_msec()
	get_node("AnimatedSprite2D").play("idle")
	connect("body_exited", _on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() > start_time + timer:
		explode()
		
func explode():
	level.explode(coords, strength)
	queue_free()

func _on_body_exited(body):
	if body == origin_player:
		set_collision_layer_value(origin_player.number, true)

func _on_explosion(body):
	explode()
