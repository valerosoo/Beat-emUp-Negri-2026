extends "res://scripts/enemigo_2.gd"

func parpadeo():
	$AnimatedSprite2D.modulate = Color(0.851, 0.0, 0.0, 1)
	await get_tree().create_timer(0.15).timeout
	$AnimatedSprite2D.modulate = Color (0.99,0.62,0.59,1)
	
