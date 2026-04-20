extends Node2D

func _ready():
	for collision in $StaticBody2D.get_children():
		if collision is CollisionPolygon2D:
			var obstacle = NavigationObstacle2D.new()
			add_child(obstacle)
			obstacle.vertices = collision.polygon
			obstacle.position = collision.position
