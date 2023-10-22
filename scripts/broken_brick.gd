extends StaticBody2D

func _ready():
	$AnimatedSprite2D.play("default")

func _on_animated_sprite_2d_animation_finished():
	print("derp")
	queue_free()
